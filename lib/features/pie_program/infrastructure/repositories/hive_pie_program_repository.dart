import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/pie_day_schedule.dart';
import '../../domain/entities/pie_template.dart';
import '../../domain/repositories/pie_program_repository.dart';
import '../../domain/services/pie_time_utils.dart';

class HivePieProgramRepository implements PieProgramRepository {
  static const String _boxName = 'pie_program';
  static const String _templateKey = 'template';
  static const String _schedulePrefix = 'schedule_';
  static const String _historyPrefix = 'history_';
  static const String _lastResetKey = 'pie_last_reset_date';

  Box<dynamic>? _box;
  SharedPreferences? _prefs;

  @override
  Future<void> init() async {
    _box ??= await Hive.openBox<dynamic>(_boxName);
    _prefs ??= await SharedPreferences.getInstance();
  }

  @override
  Future<PieTemplate?> loadTemplate() async {
    await init();
    final raw = _box!.get(_templateKey);
    if (raw is! Map) {
      return null;
    }
    return PieTemplate.fromJson(Map<String, dynamic>.from(raw));
  }

  @override
  Future<void> saveTemplate(PieTemplate template) async {
    await init();
    await _box!.put(_templateKey, template.toJson());
  }

  @override
  Future<PieDaySchedule?> loadScheduleForDate(DateTime date) async {
    await init();
    final key = _scheduleKey(date);
    final raw = _box!.get(key);
    if (raw is! Map) {
      return null;
    }
    return PieDaySchedule.fromJson(Map<String, dynamic>.from(raw));
  }

  @override
  Future<void> saveSchedule(PieDaySchedule schedule) async {
    await init();
    await _box!.put(_scheduleKey(schedule.date), schedule.toJson());
  }

  @override
  Future<void> archiveSchedule(PieDaySchedule schedule) async {
    await init();
    await _box!.put(_historyKey(schedule.date), schedule.toJson());
    await _box!.delete(_scheduleKey(schedule.date));
  }

  @override
  Future<List<PieDaySchedule>> loadRecentSchedules({int limit = 7}) async {
    await init();

    final history = <PieDaySchedule>[];
    for (final key in _box!.keys.whereType<String>()) {
      if (!key.startsWith(_historyPrefix)) {
        continue;
      }
      final raw = _box!.get(key);
      if (raw is! Map) {
        continue;
      }
      history.add(
        PieDaySchedule.fromJson(Map<String, dynamic>.from(raw)),
      );
    }

    history.sort((a, b) => b.date.compareTo(a.date));
    final trimmedHistory = history.take(limit).toList(growable: true);

    final todaySchedule = await loadScheduleForDate(DateTime.now());
    if (todaySchedule != null) {
      final duplicateIndex = trimmedHistory.indexWhere(
        (item) => PieTimeUtils.dateKey(item.date) == PieTimeUtils.dateKey(todaySchedule.date),
      );
      if (duplicateIndex >= 0) {
        trimmedHistory[duplicateIndex] = todaySchedule;
      } else {
        trimmedHistory.insert(0, todaySchedule);
      }
    }

    trimmedHistory.sort((a, b) => a.date.compareTo(b.date));
    if (trimmedHistory.length > limit) {
      return trimmedHistory.sublist(trimmedHistory.length - limit);
    }
    return trimmedHistory;
  }

  @override
  Future<DateTime?> loadLastResetDate() async {
    await init();
    final raw = _prefs!.getString(_lastResetKey);
    if (raw == null) {
      return null;
    }
    return DateTime.tryParse(raw)?.toLocal();
  }

  @override
  Future<void> saveLastResetDate(DateTime date) async {
    await init();
    await _prefs!.setString(_lastResetKey, PieTimeUtils.dateOnly(date).toIso8601String());
  }

  String _scheduleKey(DateTime date) {
    return '$_schedulePrefix${PieTimeUtils.dateKey(date)}';
  }

  String _historyKey(DateTime date) {
    return '$_historyPrefix${PieTimeUtils.dateKey(date)}';
  }
}
