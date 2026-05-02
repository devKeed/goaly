class StepDaySummary {
  const StepDaySummary({
    required this.date,
    required this.steps,
    this.goal = defaultGoal,
  });

  static const int defaultGoal = 10000;

  final DateTime date;
  final int steps;
  final int goal;

  double get progressPercentage =>
      goal > 0 ? (steps / goal).clamp(0.0, 1.0).toDouble() : 0.0;

  int get remainingSteps => (goal - steps).clamp(0, goal).toInt();

  bool get isGoalMet => goal > 0 && steps >= goal;
}
