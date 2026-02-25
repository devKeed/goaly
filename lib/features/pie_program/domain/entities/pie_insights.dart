import 'pie_block_category.dart';

class PieInsights {
  const PieInsights({
    required this.dailyCategoryPercentages,
    required this.weeklyAverageMinutes,
    required this.sleepMinutesByDay,
    required this.productivityScore,
  });

  final Map<PieBlockCategory, double> dailyCategoryPercentages;
  final Map<PieBlockCategory, double> weeklyAverageMinutes;
  final List<int> sleepMinutesByDay;
  final double productivityScore;

  const PieInsights.empty()
      : dailyCategoryPercentages = const {},
        weeklyAverageMinutes = const {},
        sleepMinutesByDay = const [],
        productivityScore = 0;
}
