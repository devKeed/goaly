import '../../domain/entities/step_day_summary.dart';
import '../../domain/entities/step_stats.dart';

enum StepsViewStatus { ready, denied, unavailable, error }

class StepsViewState {
  const StepsViewState({
    required this.status,
    required this.stats,
    this.message,
  });

  factory StepsViewState.ready(List<StepDaySummary> days) {
    return StepsViewState(
      status: StepsViewStatus.ready,
      stats: StepStats(days: days),
    );
  }

  factory StepsViewState.denied() {
    return const StepsViewState(
      status: StepsViewStatus.denied,
      stats: StepStats(days: []),
      message:
          'Allow access to Steps in your health settings to see daily statistics.',
    );
  }

  factory StepsViewState.unavailable() {
    return const StepsViewState(
      status: StepsViewStatus.unavailable,
      stats: StepStats(days: []),
      message:
          'Step data is not available on this device. On Android, install or update Health Connect.',
    );
  }

  factory StepsViewState.error(Object error) {
    return StepsViewState(
      status: StepsViewStatus.error,
      stats: const StepStats(days: []),
      message: 'Step statistics could not be loaded. ${error.toString()}',
    );
  }

  final StepsViewStatus status;
  final StepStats stats;
  final String? message;
}
