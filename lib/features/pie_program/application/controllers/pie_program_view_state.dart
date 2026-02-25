import '../../domain/entities/pie_day_schedule.dart';
import '../../domain/entities/pie_insights.dart';
import '../../domain/entities/pie_template.dart';

class PieProgramViewState {
  const PieProgramViewState({
    required this.schedule,
    required this.template,
    required this.now,
    required this.insights,
    required this.motivationalText,
  });

  final PieDaySchedule schedule;
  final PieTemplate? template;
  final DateTime now;
  final PieInsights insights;
  final String motivationalText;

  PieProgramViewState copyWith({
    PieDaySchedule? schedule,
    PieTemplate? template,
    DateTime? now,
    PieInsights? insights,
    String? motivationalText,
  }) {
    return PieProgramViewState(
      schedule: schedule ?? this.schedule,
      template: template ?? this.template,
      now: now ?? this.now,
      insights: insights ?? this.insights,
      motivationalText: motivationalText ?? this.motivationalText,
    );
  }
}
