import 'step_day_summary.dart';

class StepStats {
  const StepStats({required this.days, this.goal = StepDaySummary.defaultGoal});

  final List<StepDaySummary> days;
  final int goal;

  StepDaySummary? get today => days.isEmpty ? null : days.last;

  int get weeklyTotal => days.fold(0, (total, day) => total + day.steps);

  int get dailyAverage =>
      days.isEmpty ? 0 : (weeklyTotal / days.length).round();

  StepDaySummary? get bestDay {
    if (days.isEmpty) {
      return null;
    }
    return days.reduce((best, day) => day.steps > best.steps ? day : best);
  }

  bool get hasData => days.any((day) => day.steps > 0);
}
