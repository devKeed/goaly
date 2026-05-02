import '../entities/step_day_summary.dart';

enum StepsAvailability { available, unavailable, unsupported }

abstract class StepsRepository {
  Future<StepsAvailability> checkAvailability();

  Future<bool> requestAuthorization();

  Future<List<StepDaySummary>> loadRecentStepSummaries({
    required DateTime anchorDate,
    int days = 7,
    int dailyGoal = StepDaySummary.defaultGoal,
  });

  Future<void> openHealthConnectInstall();
}
