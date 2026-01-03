import 'package:hive_flutter/hive_flutter.dart';
import '../models/goal.dart';

class StorageService {
  static const String _goalsBoxName = 'goals';
  static const String _settingsBoxName = 'settings';
  static const String _lastOpenedDateKey = 'lastOpenedDate';
  static const String _lastWeekNumberKey = 'lastWeekNumber';

  late Box<Goal> _goalsBox;
  late Box<dynamic> _settingsBox;

  Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(GoalTypeAdapter());
    Hive.registerAdapter(GoalAdapter());

    _goalsBox = await Hive.openBox<Goal>(_goalsBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
  }

  // Goals CRUD
  List<Goal> getAllGoals() => _goalsBox.values.toList();

  List<Goal> getDailyGoals() =>
      _goalsBox.values.where((g) => g.isDaily).toList();

  List<Goal> getWeeklyGoals() =>
      _goalsBox.values.where((g) => g.isWeekly).toList();

  List<Goal> getLongTermGoals() =>
      _goalsBox.values.where((g) => !g.isDaily && !g.isWeekly).toList();

  Future<void> addGoal(Goal goal) async {
    await _goalsBox.put(goal.id, goal);
  }

  Future<void> deleteGoal(String id) async {
    await _goalsBox.delete(id);
  }

  Goal? getGoal(String id) => _goalsBox.get(id);

  // Reset logic
  DateTime? getLastOpenedDate() {
    final stored = _settingsBox.get(_lastOpenedDateKey);
    if (stored is String) {
      return DateTime.tryParse(stored);
    }
    return null;
  }

  Future<void> setLastOpenedDate(DateTime date) async {
    await _settingsBox.put(_lastOpenedDateKey, date.toIso8601String());
  }

  int? getLastWeekNumber() {
    return _settingsBox.get(_lastWeekNumberKey);
  }

  Future<void> setLastWeekNumber(int weekNumber) async {
    await _settingsBox.put(_lastWeekNumberKey, weekNumber);
  }

  // Check and perform resets
  Future<void> checkAndPerformResets() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Daily reset
    final lastOpened = getLastOpenedDate();
    if (lastOpened == null || !_isSameDay(lastOpened, today)) {
      await _resetDailyGoals();
      await setLastOpenedDate(today);
    }

    // Weekly reset
    final currentWeek = _getWeekNumber(now);
    final lastWeek = getLastWeekNumber();
    if (lastWeek == null || lastWeek != currentWeek) {
      await _resetWeeklyGoals();
      await setLastWeekNumber(currentWeek);
    }
  }

  Future<void> _resetDailyGoals() async {
    for (final goal in getDailyGoals()) {
      goal.reset();
    }
  }

  Future<void> _resetWeeklyGoals() async {
    for (final goal in getWeeklyGoals()) {
      goal.reset();
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysDiff = date.difference(firstDayOfYear).inDays;
    return ((daysDiff + firstDayOfYear.weekday - 1) / 7).ceil();
  }
}
