import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortune/features/steps/application/providers/steps_providers.dart';
import 'package:fortune/features/steps/domain/entities/step_day_summary.dart';
import 'package:fortune/features/steps/domain/repositories/steps_repository.dart';
import 'package:fortune/features/steps/presentation/screens/steps_screen.dart';

void main() {
  testWidgets('shows loading state while steps are loading', (tester) async {
    final repository = _CompleterStepsRepository();

    await tester.pumpWidget(_app(repository));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows denied guidance when health access is denied', (
    tester,
  ) async {
    final repository = _FakeStepsRepository(authorized: false);

    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();

    expect(find.text('Health access needed'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('shows today and weekly statistics when data is ready', (
    tester,
  ) async {
    final repository = _FakeStepsRepository(
      days: [
        StepDaySummary(date: DateTime(2026, 4, 26), steps: 1000),
        StepDaySummary(date: DateTime(2026, 4, 27), steps: 2000),
        StepDaySummary(date: DateTime(2026, 4, 28), steps: 3000),
        StepDaySummary(date: DateTime(2026, 4, 29), steps: 4000),
        StepDaySummary(date: DateTime(2026, 4, 30), steps: 5000),
        StepDaySummary(date: DateTime(2026, 5, 1), steps: 15000),
        StepDaySummary(date: DateTime(2026, 5, 2), steps: 12345),
      ],
    );

    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();

    expect(find.text('Today'), findsOneWidget);
    expect(find.text('12,345'), findsOneWidget);
    expect(find.text('Last 7 days'), findsOneWidget);
    expect(find.text('Weekly total'), findsOneWidget);
    expect(find.text('Daily average'), findsOneWidget);
    expect(find.text('Best day'), findsOneWidget);
  });
}

Widget _app(StepsRepository repository) {
  return ProviderScope(
    overrides: [stepsRepositoryProvider.overrideWithValue(repository)],
    child: const MaterialApp(home: StepsScreen()),
  );
}

class _FakeStepsRepository implements StepsRepository {
  _FakeStepsRepository({this.authorized = true, this.days = const []});

  final bool authorized;
  final List<StepDaySummary> days;

  @override
  Future<StepsAvailability> checkAvailability() async {
    return StepsAvailability.available;
  }

  @override
  Future<bool> requestAuthorization() async => authorized;

  @override
  Future<List<StepDaySummary>> loadRecentStepSummaries({
    required DateTime anchorDate,
    int days = 7,
    int dailyGoal = StepDaySummary.defaultGoal,
  }) async {
    return this.days;
  }

  @override
  Future<void> openHealthConnectInstall() async {}
}

class _CompleterStepsRepository extends _FakeStepsRepository {
  final Completer<StepsAvailability> completer = Completer<StepsAvailability>();

  @override
  Future<StepsAvailability> checkAvailability() => completer.future;
}
