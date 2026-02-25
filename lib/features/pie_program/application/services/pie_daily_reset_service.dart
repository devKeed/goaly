import '../../domain/entities/pie_block_category.dart';
import '../../domain/entities/pie_day_schedule.dart';
import '../../domain/entities/pie_template.dart';
import '../../domain/entities/pie_time_block.dart';
import '../../domain/repositories/pie_program_repository.dart';
import '../../domain/services/pie_rules_engine.dart';
import '../../domain/services/pie_time_utils.dart';

class PieDailyResetService {
  PieDailyResetService({
    required PieProgramRepository repository,
    required PieRulesEngine rulesEngine,
  })  : _repository = repository,
        _rulesEngine = rulesEngine;

  final PieProgramRepository _repository;
  final PieRulesEngine _rulesEngine;

  Future<PieDaySchedule> ensureScheduleForNow(DateTime now) async {
    await _repository.init();
    final today = PieTimeUtils.dateOnly(now);
    final lastResetDate = await _repository.loadLastResetDate();

    if (lastResetDate == null || !_isSameDay(lastResetDate, today)) {
      if (lastResetDate != null) {
        final lastSchedule = await _repository.loadScheduleForDate(lastResetDate);
        if (lastSchedule != null && !lastSchedule.isArchived) {
          await _repository.archiveSchedule(
            lastSchedule.copyWith(isArchived: true, updatedAt: now),
          );
        }
      }
      await _repository.saveLastResetDate(today);
    }

    final existingToday = await _repository.loadScheduleForDate(today);
    if (existingToday != null) {
      return existingToday;
    }

    final template = await _repository.loadTemplate();
    final schedule = template == null
        ? _fallbackSchedule(today)
        : _rulesEngine.scheduleFromTemplate(date: today, template: template);

    await _repository.saveSchedule(schedule);
    return schedule;
  }

  Future<void> saveTemplate(PieTemplate template) async {
    await _repository.init();
    await _repository.saveTemplate(template);
  }

  Future<PieTemplate?> loadTemplate() async {
    await _repository.init();
    return _repository.loadTemplate();
  }

  Future<List<PieDaySchedule>> loadRecentSchedules() async {
    await _repository.init();
    return _repository.loadRecentSchedules(limit: 7);
  }

  Future<void> saveSchedule(PieDaySchedule schedule) async {
    await _repository.init();
    await _repository.saveSchedule(schedule);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  PieDaySchedule _fallbackSchedule(DateTime date) {
    final now = DateTime.now();
    return PieDaySchedule(
      date: date,
      createdAt: now,
      updatedAt: now,
      isArchived: false,
      blocks: [
        PieTimeBlock(
          id: 'unplanned',
          title: 'Unplanned',
          startTime: PieTimeUtils.fromMinutes(date, 0),
          endTime: PieTimeUtils.fromMinutes(date, PieRulesEngine.minutesInDay),
          category: PieBlockCategory.other,
          color: 0xFF90A4AE,
          isRecurring: false,
          isLocked: false,
          createdAt: now,
        ),
      ],
    );
  }
}
