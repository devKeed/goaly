import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:home_widget/home_widget.dart';
import 'package:workmanager/workmanager.dart';

import 'pie_home_widget_sync.dart';

const String pieWidgetRefreshTask = 'pie_widget_refresh_task';

@pragma('vm:entry-point')
void pieProgramWorkmanagerCallbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    if (taskName == pieWidgetRefreshTask) {
      await HomeWidget.updateWidget(
        androidName: PieHomeWidgetSync.androidProviderName,
        iOSName: PieHomeWidgetSync.iosWidgetName,
      );
    }

    return Future<bool>.value(true);
  });
}

class PieBackgroundScheduler {
  Future<void> initialize() async {
    await Workmanager().initialize(
      pieProgramWorkmanagerCallbackDispatcher,
    );
  }

  Future<void> schedulePeriodicWidgetRefresh() async {
    await Workmanager().registerPeriodicTask(
      pieWidgetRefreshTask,
      pieWidgetRefreshTask,
      frequency: const Duration(minutes: 15),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      constraints: Constraints(
        networkType: NetworkType.notRequired,
      ),
    );
  }
}
