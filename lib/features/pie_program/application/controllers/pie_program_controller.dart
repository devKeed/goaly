import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/pie_block_category.dart';
import '../../domain/entities/pie_day_schedule.dart';
import '../../domain/entities/pie_template.dart';
import '../../domain/entities/pie_template_block.dart';
import '../../domain/entities/pie_time_block.dart';
import '../../domain/services/pie_insights_engine.dart';
import '../../domain/services/pie_rules_engine.dart';
import '../../domain/services/pie_time_utils.dart';
import '../../infrastructure/services/pie_background_scheduler.dart';
import '../../infrastructure/services/pie_home_widget_sync.dart';
import '../providers/pie_program_providers.dart';
import '../services/pie_daily_reset_service.dart';
import 'pie_program_view_state.dart';

final pieProgramControllerProvider =
    AsyncNotifierProvider<PieProgramController, PieProgramViewState>(
  PieProgramController.new,
);

class OnboardingTaskInput {
  const OnboardingTaskInput({
    required this.title,
    required this.category,
    required this.durationMinutes,
    this.isLocked = false,
  });

  final String title;
  final PieBlockCategory category;
  final int durationMinutes;
  final bool isLocked;
}

class PieProgramController extends AsyncNotifier<PieProgramViewState> {
  final Uuid _uuid = const Uuid();
  Timer? _ticker;
  bool _tickInFlight = false;
  int? _lastWidgetSyncMinute;

  PieDailyResetService get _resetService => ref.read(pieDailyResetServiceProvider);
  PieRulesEngine get _rulesEngine => ref.read(pieRulesEngineProvider);
  PieInsightsEngine get _insightsEngine => ref.read(pieInsightsEngineProvider);
  PieHomeWidgetSync get _widgetSync => ref.read(pieHomeWidgetSyncProvider);
  PieBackgroundScheduler get _backgroundScheduler =>
      ref.read(pieBackgroundSchedulerProvider);

  @override
  Future<PieProgramViewState> build() async {
    await _backgroundScheduler.initialize();
    await _backgroundScheduler.schedulePeriodicWidgetRefresh();

    final now = DateTime.now();
    final schedule = await _resetService.ensureScheduleForNow(now);
    final template = await _resetService.loadTemplate();
    final recentSchedules = await _resetService.loadRecentSchedules();

    final viewState = PieProgramViewState(
      schedule: schedule,
      template: template,
      now: now,
      insights: _insightsEngine.calculate(
        today: schedule,
        recent: recentSchedules.isEmpty ? [schedule] : recentSchedules,
      ),
      motivationalText: _motivationFor(now),
    );

    await _widgetSync.sync(schedule, now);
    _startTicker();

    return viewState;
  }

  Future<void> refreshAfterAppResume() async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    final now = DateTime.now();
    if (!_isSameDay(current.schedule.date, now)) {
      await _reloadFor(now);
      return;
    }

    state = AsyncData(current.copyWith(now: now, motivationalText: _motivationFor(now)));
  }

  Future<void> createTemplateFromSetup({
    required int sleepStartMinute,
    required int sleepEndMinute,
    required List<OnboardingTaskInput> recurringTasks,
  }) async {
    final now = DateTime.now();

    final normalizedStart = sleepStartMinute.clamp(0, PieRulesEngine.minutesInDay - 1);
    final normalizedEnd = sleepEndMinute.clamp(1, PieRulesEngine.minutesInDay);

    final wakeMinute = normalizedStart > normalizedEnd
        ? normalizedEnd
        : (normalizedEnd + 6 * 60).clamp(1, PieRulesEngine.minutesInDay);

    int cursor = wakeMinute;
    final blocks = <PieTemplateBlock>[
      PieTemplateBlock(
        id: _uuid.v4(),
        title: 'Sleep',
        startMinute: 0,
        endMinute: wakeMinute,
        category: PieBlockCategory.sleep,
        color: _defaultColorFor(PieBlockCategory.sleep),
        isRecurring: true,
        isLocked: true,
        createdAt: now,
      ),
    ];

    for (final task in recurringTasks) {
      final duration = task.durationMinutes.clamp(
        PieRulesEngine.minBlockDurationMinutes,
        PieRulesEngine.minutesInDay,
      );
      final end = (cursor + duration).clamp(cursor, PieRulesEngine.minutesInDay);
      if (end - cursor < PieRulesEngine.minBlockDurationMinutes) {
        continue;
      }

      blocks.add(
        PieTemplateBlock(
          id: _uuid.v4(),
          title: task.title,
          startMinute: cursor,
          endMinute: end,
          category: task.category,
          color: _defaultColorFor(task.category),
          isRecurring: true,
          isLocked: task.isLocked,
          createdAt: now,
        ),
      );
      cursor = end;
      if (cursor >= PieRulesEngine.minutesInDay - PieRulesEngine.minBlockDurationMinutes) {
        break;
      }
    }

    if (cursor < PieRulesEngine.minutesInDay) {
      blocks.add(
        PieTemplateBlock(
          id: _uuid.v4(),
          title: 'Personal',
          startMinute: cursor,
          endMinute: PieRulesEngine.minutesInDay,
          category: PieBlockCategory.personal,
          color: _defaultColorFor(PieBlockCategory.personal),
          isRecurring: true,
          isLocked: false,
          createdAt: now,
        ),
      );
    }

    final normalized = _normalizeTemplateBlocks(blocks, now);
    final template = PieTemplate(
      id: 'pie_template',
      blocks: normalized,
      createdAt: now,
      updatedAt: now,
    );

    await _resetService.saveTemplate(template);

    final todaySchedule = _rulesEngine.scheduleFromTemplate(
      date: PieTimeUtils.dateOnly(now),
      template: template,
    );

    await _resetService.saveSchedule(todaySchedule);
    await _replaceState(schedule: todaySchedule, template: template, now: now);
  }

  Future<bool> resizeBoundary({
    required int boundaryIndex,
    required int deltaMinutes,
  }) async {
    final current = state.valueOrNull;
    if (current == null || deltaMinutes == 0) {
      return false;
    }

    final result = _rulesEngine.resizeBoundary(
      source: current.schedule.blocks,
      boundaryIndex: boundaryIndex,
      deltaMinutes: deltaMinutes,
    );

    if (result.appliedDelta == 0) {
      return !result.hitLimit;
    }

    final updatedSchedule = current.schedule.copyWith(
      blocks: result.blocks,
      updatedAt: DateTime.now(),
    );
    await _persistAndBroadcast(updatedSchedule);
    return !result.hitLimit;
  }

  Future<void> addBlock({
    required String sourceBlockId,
    required String title,
    required PieBlockCategory category,
    int durationMinutes = 60,
  }) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    final day = current.schedule.date;
    final now = DateTime.now();
    final newBlock = PieTimeBlock(
      id: _uuid.v4(),
      title: title,
      startTime: PieTimeUtils.fromMinutes(day, 0),
      endTime: PieTimeUtils.fromMinutes(day, durationMinutes),
      category: category,
      color: _defaultColorFor(category),
      isRecurring: false,
      isLocked: false,
      createdAt: now,
    );

    final result = _rulesEngine.addBlock(
      source: current.schedule.blocks,
      sourceBlockId: sourceBlockId,
      newBlock: newBlock,
    );

    if (!result.success) {
      return;
    }

    final updatedSchedule = current.schedule.copyWith(
      blocks: result.blocks,
      updatedAt: now,
    );
    await _persistAndBroadcast(updatedSchedule);
  }

  Future<void> deleteBlock(String blockId) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    final result = _rulesEngine.deleteBlock(
      source: current.schedule.blocks,
      blockId: blockId,
    );

    if (!result.success) {
      return;
    }

    final updatedSchedule = current.schedule.copyWith(
      blocks: result.blocks,
      updatedAt: DateTime.now(),
    );
    await _persistAndBroadcast(updatedSchedule);
  }

  Future<void> editBlock({
    required String blockId,
    required String title,
    required PieBlockCategory category,
    required int color,
  }) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    final updated = current.schedule.blocks
        .map(
          (block) => block.id == blockId
              ? block.copyWith(
                  title: title,
                  category: category,
                  color: color,
                )
              : block,
        )
        .toList(growable: false);

    final updatedSchedule = current.schedule.copyWith(
      blocks: updated,
      updatedAt: DateTime.now(),
    );
    await _persistAndBroadcast(updatedSchedule);
  }

  Future<void> toggleLock(String blockId) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    final updated = current.schedule.blocks
        .map(
          (block) => block.id == blockId
              ? block.copyWith(isLocked: !block.isLocked)
              : block,
        )
        .toList(growable: false);

    final updatedSchedule = current.schedule.copyWith(
      blocks: updated,
      updatedAt: DateTime.now(),
    );
    await _persistAndBroadcast(updatedSchedule);
  }

  Future<void> saveCurrentAsTemplate() async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    final now = DateTime.now();
    final template = PieTemplate(
      id: current.template?.id ?? 'pie_template',
      blocks: _rulesEngine.toTemplateBlocks(current.schedule.blocks),
      createdAt: current.template?.createdAt ?? now,
      updatedAt: now,
    );

    await _resetService.saveTemplate(template);
    await _replaceState(schedule: current.schedule, template: template, now: now);
  }

  Future<void> _persistAndBroadcast(PieDaySchedule schedule) async {
    await _resetService.saveSchedule(schedule);
    await _replaceState(
      schedule: schedule,
      template: state.valueOrNull?.template,
      now: DateTime.now(),
    );
  }

  Future<void> _replaceState({
    required PieDaySchedule schedule,
    required PieTemplate? template,
    required DateTime now,
  }) async {
    final recent = await _resetService.loadRecentSchedules();
    final insights = _insightsEngine.calculate(
      today: schedule,
      recent: recent.isEmpty ? [schedule] : recent,
    );

    final nextState = PieProgramViewState(
      schedule: schedule,
      template: template,
      now: now,
      insights: insights,
      motivationalText: _motivationFor(now),
    );

    state = AsyncData(nextState);

    final minute = PieTimeUtils.toMinutes(now);
    if (_lastWidgetSyncMinute != minute) {
      _lastWidgetSyncMinute = minute;
      await _widgetSync.sync(schedule, now);
    }
  }

  Future<void> _reloadFor(DateTime now) async {
    final schedule = await _resetService.ensureScheduleForNow(now);
    final template = await _resetService.loadTemplate();
    await _replaceState(schedule: schedule, template: template, now: now);
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (_tickInFlight) {
        return;
      }
      _tickInFlight = true;
      try {
        final current = state.valueOrNull;
        if (current == null) {
          return;
        }

        final now = DateTime.now();
        if (!_isSameDay(current.schedule.date, now)) {
          await _reloadFor(now);
        } else {
          state = AsyncData(
            current.copyWith(
              now: now,
              motivationalText: _motivationFor(now),
            ),
          );
        }
      } finally {
        _tickInFlight = false;
      }
    });

    ref.onDispose(() {
      _ticker?.cancel();
      _ticker = null;
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _motivationFor(DateTime now) {
    final slot = (now.hour / 6).floor();
    switch (slot) {
      case 0:
        return 'Own your morning rhythm.';
      case 1:
        return 'Keep the momentum while it is clean.';
      case 2:
        return 'Small blocks compound into big wins.';
      default:
        return 'Close the day with intention.';
    }
  }

  int _defaultColorFor(PieBlockCategory category) {
    switch (category) {
      case PieBlockCategory.sleep:
        return 0xFF5C6BC0;
      case PieBlockCategory.work:
        return 0xFF26A69A;
      case PieBlockCategory.focus:
        return 0xFF42A5F5;
      case PieBlockCategory.fitness:
        return 0xFFEC407A;
      case PieBlockCategory.meals:
        return 0xFFFF7043;
      case PieBlockCategory.commute:
        return 0xFF8D6E63;
      case PieBlockCategory.personal:
        return 0xFFFFA726;
      case PieBlockCategory.leisure:
        return 0xFFAB47BC;
      case PieBlockCategory.other:
        return 0xFF90A4AE;
    }
  }

  List<PieTemplateBlock> _normalizeTemplateBlocks(
    List<PieTemplateBlock> source,
    DateTime now,
  ) {
    final sorted = [...source]..sort((a, b) => a.startMinute.compareTo(b.startMinute));

    if (sorted.isEmpty) {
      return _rulesEngine.buildDefaultTemplate(
        createdAt: now,
        sleepStartMinute: 23 * 60,
        sleepDurationMinutes: 7 * 60,
      ).blocks;
    }

    final normalized = <PieTemplateBlock>[];
    int cursor = 0;
    for (int i = 0; i < sorted.length; i++) {
      final raw = sorted[i];
      final start = cursor;
      final isLast = i == sorted.length - 1;
      final desiredEnd = raw.endMinute.clamp(
        start + PieRulesEngine.minBlockDurationMinutes,
        PieRulesEngine.minutesInDay,
      );
      final remainingBlocks = sorted.length - i - 1;
      final minRemaining = remainingBlocks * PieRulesEngine.minBlockDurationMinutes;
      int end = isLast
          ? PieRulesEngine.minutesInDay
          : desiredEnd.clamp(
              start + PieRulesEngine.minBlockDurationMinutes,
              PieRulesEngine.minutesInDay - minRemaining,
            );

      if (end <= start) {
        end = (start + PieRulesEngine.minBlockDurationMinutes).clamp(
          0,
          PieRulesEngine.minutesInDay,
        );
      }

      normalized.add(
        raw.copyWith(
          startMinute: start,
          endMinute: end,
        ),
      );
      cursor = end;
    }

    final last = normalized.last;
    if (last.endMinute != PieRulesEngine.minutesInDay) {
      normalized[normalized.length - 1] = last.copyWith(
        endMinute: PieRulesEngine.minutesInDay,
      );
    }

    return normalized;
  }
}
