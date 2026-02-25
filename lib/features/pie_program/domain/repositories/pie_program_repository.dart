import '../entities/pie_day_schedule.dart';
import '../entities/pie_template.dart';

abstract class PieProgramRepository {
  Future<void> init();

  Future<PieTemplate?> loadTemplate();

  Future<void> saveTemplate(PieTemplate template);

  Future<PieDaySchedule?> loadScheduleForDate(DateTime date);

  Future<void> saveSchedule(PieDaySchedule schedule);

  Future<void> archiveSchedule(PieDaySchedule schedule);

  Future<List<PieDaySchedule>> loadRecentSchedules({int limit = 7});

  Future<DateTime?> loadLastResetDate();

  Future<void> saveLastResetDate(DateTime date);
}
