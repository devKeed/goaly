import 'package:flutter_test/flutter_test.dart';

import 'package:fortune/features/pie_program/application/services/pie_daily_reset_service.dart';
import 'package:fortune/features/pie_program/domain/entities/pie_day_schedule.dart';
import 'package:fortune/features/pie_program/domain/entities/pie_template.dart';
import 'package:fortune/features/pie_program/domain/repositories/pie_program_repository.dart';
import 'package:fortune/features/pie_program/domain/services/pie_rules_engine.dart';
import 'package:fortune/features/pie_program/domain/services/pie_time_utils.dart';

void main() {
  group('PieDailyResetService', () {
    test('archives previous day and creates today from template', () async {
      final repo = _FakePieRepository();
      final rules = PieRulesEngine();
      final service = PieDailyResetService(repository: repo, rulesEngine: rules);

      final createdAt = DateTime(2026, 2, 24, 8);
      final template = rules.buildDefaultTemplate(
        createdAt: createdAt,
        sleepStartMinute: 23 * 60,
        sleepDurationMinutes: 7 * 60,
      );

      await repo.saveTemplate(template);
      final yesterday = DateTime(2026, 2, 24);
      await repo.saveLastResetDate(yesterday);
      await repo.saveSchedule(
        rules.scheduleFromTemplate(date: yesterday, template: template),
      );

      final todayNow = DateTime(2026, 2, 25, 9, 30);
      final todaySchedule = await service.ensureScheduleForNow(todayNow);

      expect(PieTimeUtils.dateKey(todaySchedule.date), '2026-02-25');
      expect(repo.archivedDates.contains('2026-02-24'), isTrue);
      expect((await repo.loadLastResetDate())?.day, 25);
      expect(todaySchedule.totalMinutes, 1440);
    });
  });
}

class _FakePieRepository implements PieProgramRepository {
  final Map<String, PieDaySchedule> schedules = {};
  final Map<String, PieDaySchedule> history = {};
  PieTemplate? template;
  DateTime? lastResetDate;
  final List<String> archivedDates = [];

  @override
  Future<void> init() async {}

  @override
  Future<void> archiveSchedule(PieDaySchedule schedule) async {
    final key = PieTimeUtils.dateKey(schedule.date);
    history[key] = schedule;
    schedules.remove(key);
    archivedDates.add(key);
  }

  @override
  Future<DateTime?> loadLastResetDate() async => lastResetDate;

  @override
  Future<List<PieDaySchedule>> loadRecentSchedules({int limit = 7}) async {
    final combined = [...history.values, ...schedules.values]
      ..sort((a, b) => a.date.compareTo(b.date));
    if (combined.length <= limit) {
      return combined;
    }
    return combined.sublist(combined.length - limit);
  }

  @override
  Future<PieDaySchedule?> loadScheduleForDate(DateTime date) async {
    return schedules[PieTimeUtils.dateKey(date)];
  }

  @override
  Future<PieTemplate?> loadTemplate() async => template;

  @override
  Future<void> saveLastResetDate(DateTime date) async {
    lastResetDate = PieTimeUtils.dateOnly(date);
  }

  @override
  Future<void> saveSchedule(PieDaySchedule schedule) async {
    schedules[PieTimeUtils.dateKey(schedule.date)] = schedule;
  }

  @override
  Future<void> saveTemplate(PieTemplate template) async {
    this.template = template;
  }
}
