import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/step_day_summary.dart';
import '../../domain/repositories/steps_repository.dart';
import '../providers/steps_providers.dart';
import 'steps_view_state.dart';

final stepsControllerProvider =
    AsyncNotifierProvider<StepsController, StepsViewState>(StepsController.new);

class StepsController extends AsyncNotifier<StepsViewState> {
  StepsRepository get _repository => ref.read(stepsRepositoryProvider);

  @override
  Future<StepsViewState> build() {
    return _load(requestPermission: true);
  }

  Future<void> refresh() async {
    final previous = state.valueOrNull;
    state = const AsyncLoading<StepsViewState>().copyWithPrevious(state);

    try {
      state = AsyncData(await _load(requestPermission: false));
    } catch (error, stackTrace) {
      if (previous != null) {
        state = AsyncData(StepsViewState.error(error));
      } else {
        state = AsyncError(error, stackTrace);
      }
    }
  }

  Future<void> retryAuthorization() async {
    state = const AsyncLoading<StepsViewState>().copyWithPrevious(state);
    state = AsyncData(await _load(requestPermission: true));
  }

  Future<void> openHealthConnectInstall() {
    return _repository.openHealthConnectInstall();
  }

  Future<StepsViewState> _load({required bool requestPermission}) async {
    try {
      final availability = await _repository.checkAvailability();
      if (availability != StepsAvailability.available) {
        return StepsViewState.unavailable();
      }

      if (requestPermission) {
        final authorized = await _repository.requestAuthorization();
        if (!authorized) {
          return StepsViewState.denied();
        }
      }

      final days = await _repository.loadRecentStepSummaries(
        anchorDate: DateTime.now(),
        days: 7,
        dailyGoal: StepDaySummary.defaultGoal,
      );
      return StepsViewState.ready(days);
    } catch (error) {
      return StepsViewState.error(error);
    }
  }
}
