import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/pie_program_repository.dart';
import '../../domain/services/pie_insights_engine.dart';
import '../../domain/services/pie_rules_engine.dart';
import '../../infrastructure/repositories/hive_pie_program_repository.dart';
import '../../infrastructure/services/pie_background_scheduler.dart';
import '../../infrastructure/services/pie_home_widget_sync.dart';
import '../services/pie_daily_reset_service.dart';

final pieProgramRepositoryProvider = Provider<PieProgramRepository>((ref) {
  return HivePieProgramRepository();
});

final pieRulesEngineProvider = Provider<PieRulesEngine>((ref) {
  return PieRulesEngine();
});

final pieInsightsEngineProvider = Provider<PieInsightsEngine>((ref) {
  return PieInsightsEngine();
});

final pieHomeWidgetSyncProvider = Provider<PieHomeWidgetSync>((ref) {
  return PieHomeWidgetSync(ref.read(pieRulesEngineProvider));
});

final pieBackgroundSchedulerProvider = Provider<PieBackgroundScheduler>((ref) {
  return PieBackgroundScheduler();
});

final pieDailyResetServiceProvider = Provider<PieDailyResetService>((ref) {
  return PieDailyResetService(
    repository: ref.read(pieProgramRepositoryProvider),
    rulesEngine: ref.read(pieRulesEngineProvider),
  );
});
