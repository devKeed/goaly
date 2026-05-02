import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortune/features/steps/application/controllers/steps_controller.dart';
import 'package:fortune/features/steps/application/controllers/steps_view_state.dart';
import 'package:fortune/features/steps/application/providers/steps_providers.dart';
import 'package:fortune/features/steps/domain/entities/step_day_summary.dart';
import 'package:fortune/features/steps/domain/repositories/steps_repository.dart';

void main() {
  test('loads ready state when health data is authorized', () async {
    final days = [
      StepDaySummary(date: DateTime(2026, 5, 1), steps: 8000),
      StepDaySummary(date: DateTime(2026, 5, 2), steps: 12000),
    ];
    final repository = _FakeStepsRepository(days: days);
    final container = _container(repository);
    addTearDown(container.dispose);

    final state = await container.read(stepsControllerProvider.future);

    expect(state.status, StepsViewStatus.ready);
    expect(state.stats.days, days);
    expect(repository.requestAuthorizationCount, 1);
  });

  test('returns denied state when authorization is rejected', () async {
    final repository = _FakeStepsRepository(authorized: false);
    final container = _container(repository);
    addTearDown(container.dispose);

    final state = await container.read(stepsControllerProvider.future);

    expect(state.status, StepsViewStatus.denied);
    expect(repository.loadCount, 0);
  });

  test('returns unavailable state without requesting permission', () async {
    final repository = _FakeStepsRepository(
      availability: StepsAvailability.unavailable,
    );
    final container = _container(repository);
    addTearDown(container.dispose);

    final state = await container.read(stepsControllerProvider.future);

    expect(state.status, StepsViewStatus.unavailable);
    expect(repository.requestAuthorizationCount, 0);
  });

  test('returns error state when loading steps throws', () async {
    final repository = _FakeStepsRepository(loadError: StateError('failed'));
    final container = _container(repository);
    addTearDown(container.dispose);

    final state = await container.read(stepsControllerProvider.future);

    expect(state.status, StepsViewStatus.error);
    expect(state.message, contains('failed'));
  });
}

ProviderContainer _container(_FakeStepsRepository repository) {
  return ProviderContainer(
    overrides: [stepsRepositoryProvider.overrideWithValue(repository)],
  );
}

class _FakeStepsRepository implements StepsRepository {
  _FakeStepsRepository({
    this.availability = StepsAvailability.available,
    this.authorized = true,
    this.days = const [],
    this.loadError,
  });

  final StepsAvailability availability;
  final bool authorized;
  final List<StepDaySummary> days;
  final Object? loadError;

  int requestAuthorizationCount = 0;
  int loadCount = 0;

  @override
  Future<StepsAvailability> checkAvailability() async => availability;

  @override
  Future<bool> requestAuthorization() async {
    requestAuthorizationCount++;
    return authorized;
  }

  @override
  Future<List<StepDaySummary>> loadRecentStepSummaries({
    required DateTime anchorDate,
    int days = 7,
    int dailyGoal = StepDaySummary.defaultGoal,
  }) async {
    loadCount++;
    final error = loadError;
    if (error != null) {
      throw error;
    }
    return this.days;
  }

  @override
  Future<void> openHealthConnectInstall() async {}
}
