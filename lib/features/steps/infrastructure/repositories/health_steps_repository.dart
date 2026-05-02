import 'dart:io';

import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../domain/entities/step_day_summary.dart';
import '../../domain/repositories/steps_repository.dart';

class HealthStepsRepository implements StepsRepository {
  HealthStepsRepository({
    Health? health,
    Future<PermissionStatus> Function()? requestActivityRecognition,
  }) : _health = health ?? Health(),
       _requestActivityRecognition =
           requestActivityRecognition ??
           (() => Permission.activityRecognition.request());

  final Health _health;
  final Future<PermissionStatus> Function() _requestActivityRecognition;
  bool _configured = false;

  @override
  Future<StepsAvailability> checkAvailability() async {
    if (!Platform.isIOS && !Platform.isAndroid) {
      return StepsAvailability.unsupported;
    }

    await _configure();

    if (Platform.isAndroid) {
      final status = await _health.getHealthConnectSdkStatus();
      return status == HealthConnectSdkStatus.sdkAvailable
          ? StepsAvailability.available
          : StepsAvailability.unavailable;
    }

    return _health.isDataTypeAvailable(HealthDataType.STEPS)
        ? StepsAvailability.available
        : StepsAvailability.unavailable;
  }

  @override
  Future<bool> requestAuthorization() async {
    if (!Platform.isIOS && !Platform.isAndroid) {
      return false;
    }

    await _configure();

    if (Platform.isAndroid) {
      final activityStatus = await _requestActivityRecognition();
      if (!activityStatus.isGranted) {
        return false;
      }
    }

    return _health.requestAuthorization(
      [HealthDataType.STEPS],
      permissions: [HealthDataAccess.READ],
    );
  }

  @override
  Future<List<StepDaySummary>> loadRecentStepSummaries({
    required DateTime anchorDate,
    int days = 7,
    int dailyGoal = StepDaySummary.defaultGoal,
  }) async {
    await _configure();

    final anchorDay = _dateOnly(anchorDate);
    final summaries = <StepDaySummary>[];

    for (var offset = days - 1; offset >= 0; offset--) {
      final day = anchorDay.subtract(Duration(days: offset));
      final end = offset == 0 ? anchorDate : day.add(const Duration(days: 1));
      final steps = await _health.getTotalStepsInInterval(day, end);
      summaries.add(
        StepDaySummary(date: day, steps: steps ?? 0, goal: dailyGoal),
      );
    }

    return summaries;
  }

  @override
  Future<void> openHealthConnectInstall() {
    return _health.installHealthConnect();
  }

  Future<void> _configure() async {
    if (_configured) {
      return;
    }
    await _health.configure();
    _configured = true;
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
