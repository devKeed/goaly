import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/steps_repository.dart';
import '../../infrastructure/repositories/health_steps_repository.dart';

final stepsRepositoryProvider = Provider<StepsRepository>((ref) {
  return HealthStepsRepository();
});
