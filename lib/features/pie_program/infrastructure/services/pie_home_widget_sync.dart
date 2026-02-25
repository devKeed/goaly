import 'dart:convert';

import 'package:home_widget/home_widget.dart';

import '../../domain/entities/pie_day_schedule.dart';
import '../../domain/services/pie_rules_engine.dart';
import '../../domain/services/pie_time_utils.dart';

class PieHomeWidgetSync {
  static const String androidProviderName = 'PieProgramWidgetProvider';
  static const String iosWidgetName = 'PieProgramWidget';

  PieHomeWidgetSync(this._rulesEngine);

  final PieRulesEngine _rulesEngine;

  Future<void> sync(PieDaySchedule schedule, DateTime now) async {
    final current = _rulesEngine.currentBlock(schedule.blocks, now);
    final progress = _progress(schedule, now);

    String remaining = '0m';
    if (current != null) {
      final left = PieTimeUtils.minutesUntil(now, current.endTime);
      remaining = '${left}m';
    }

    final serializedBlocks = schedule.blocks
        .map(
          (block) => {
            'title': block.title,
            'start': block.startMinuteOfDay,
            'end': block.endMinuteOfDay,
            'color': block.color,
          },
        )
        .toList(growable: false);

    await Future.wait([
      HomeWidget.saveWidgetData<String>('pie_current_task', current?.title ?? 'No task'),
      HomeWidget.saveWidgetData<String>('pie_remaining', remaining),
      HomeWidget.saveWidgetData<double>('pie_progress', progress),
      HomeWidget.saveWidgetData<String>('pie_blocks_json', jsonEncode(serializedBlocks)),
      HomeWidget.saveWidgetData<String>('pie_last_updated', now.toIso8601String()),
    ]);

    await HomeWidget.updateWidget(
      androidName: androidProviderName,
      iOSName: iosWidgetName,
    );
  }

  double _progress(PieDaySchedule schedule, DateTime now) {
    final minute = PieTimeUtils.toMinutes(now);
    return minute / PieRulesEngine.minutesInDay;
  }
}
