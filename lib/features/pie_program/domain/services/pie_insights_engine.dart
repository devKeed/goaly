import '../entities/pie_block_category.dart';
import '../entities/pie_day_schedule.dart';
import '../entities/pie_insights.dart';

class PieInsightsEngine {
  PieInsights calculate({
    required PieDaySchedule today,
    required List<PieDaySchedule> recent,
  }) {
    final daily = _dailyPercentages(today);
    final weekly = _weeklyAverages(recent);
    final sleepByDay = recent
        .map(
          (schedule) => schedule.blocks
              .where((block) => block.category == PieBlockCategory.sleep)
              .fold<int>(0, (sum, block) => sum + block.durationMinutes),
        )
        .toList(growable: false);

    final productivity = _productivityScore(today);

    return PieInsights(
      dailyCategoryPercentages: daily,
      weeklyAverageMinutes: weekly,
      sleepMinutesByDay: sleepByDay,
      productivityScore: productivity,
    );
  }

  Map<PieBlockCategory, double> _dailyPercentages(PieDaySchedule schedule) {
    final buckets = <PieBlockCategory, int>{};
    for (final block in schedule.blocks) {
      buckets.update(
        block.category,
        (value) => value + block.durationMinutes,
        ifAbsent: () => block.durationMinutes,
      );
    }

    return buckets.map(
      (key, value) => MapEntry(key, (value / (24 * 60)) * 100),
    );
  }

  Map<PieBlockCategory, double> _weeklyAverages(List<PieDaySchedule> schedules) {
    if (schedules.isEmpty) {
      return const {};
    }

    final buckets = <PieBlockCategory, int>{};
    for (final schedule in schedules) {
      for (final block in schedule.blocks) {
        buckets.update(
          block.category,
          (value) => value + block.durationMinutes,
          ifAbsent: () => block.durationMinutes,
        );
      }
    }

    final days = schedules.length;
    return buckets.map(
      (key, value) => MapEntry(key, value / days),
    );
  }

  double _productivityScore(PieDaySchedule schedule) {
    double weighted = 0;
    for (final block in schedule.blocks) {
      weighted += block.durationMinutes * block.category.productivityWeight;
    }

    return ((weighted / (24 * 60)) * 100).clamp(0, 100);
  }
}
