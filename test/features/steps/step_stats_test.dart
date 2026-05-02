import 'package:flutter_test/flutter_test.dart';
import 'package:fortune/features/steps/domain/entities/step_day_summary.dart';
import 'package:fortune/features/steps/domain/entities/step_stats.dart';

void main() {
  group('StepDaySummary', () {
    test('calculates progress and remaining steps', () {
      final summary = StepDaySummary(
        date: DateTime(2026, 5, 2),
        steps: 4200,
        goal: 10000,
      );

      expect(summary.progressPercentage, 0.42);
      expect(summary.remainingSteps, 5800);
      expect(summary.isGoalMet, isFalse);
    });

    test('clamps progress and remaining steps when goal is exceeded', () {
      final summary = StepDaySummary(
        date: DateTime(2026, 5, 2),
        steps: 12500,
        goal: 10000,
      );

      expect(summary.progressPercentage, 1.0);
      expect(summary.remainingSteps, 0);
      expect(summary.isGoalMet, isTrue);
    });
  });

  group('StepStats', () {
    test('calculates total, average, best day, and today', () {
      final days = [
        StepDaySummary(date: DateTime(2026, 4, 29), steps: 0),
        StepDaySummary(date: DateTime(2026, 4, 30), steps: 5000),
        StepDaySummary(date: DateTime(2026, 5, 1), steps: 10000),
        StepDaySummary(date: DateTime(2026, 5, 2), steps: 12000),
      ];
      final stats = StepStats(days: days);

      expect(stats.weeklyTotal, 27000);
      expect(stats.dailyAverage, 6750);
      expect(stats.bestDay, days.last);
      expect(stats.today, days.last);
      expect(stats.hasData, isTrue);
    });

    test('handles an empty week', () {
      const stats = StepStats(days: []);

      expect(stats.weeklyTotal, 0);
      expect(stats.dailyAverage, 0);
      expect(stats.bestDay, isNull);
      expect(stats.today, isNull);
      expect(stats.hasData, isFalse);
    });
  });
}
