import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../domain/entities/pie_block_category.dart';
import '../../domain/entities/pie_insights.dart';
import 'pie_visuals.dart';

class PieInsightsPanel extends StatelessWidget {
  const PieInsightsPanel({super.key, required this.insights});

  final PieInsights insights;

  @override
  Widget build(BuildContext context) {
    final dailyEntries = insights.dailyCategoryPercentages.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final weeklyEntries = insights.weeklyAverageMinutes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Insights',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: PieVisuals.foreground,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Daily breakdown',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: PieVisuals.subForeground,
            ),
          ),
          const SizedBox(height: 8),
          ...dailyEntries.take(4).map((entry) {
            return _MetricBar(
              label: entry.key.label,
              valueLabel: '${entry.value.toStringAsFixed(0)}%',
              progress: (entry.value / 100).clamp(0, 1),
              color: PieVisuals.gradientForCategory(entry.key, 0xFF90A4AE).first,
            );
          }),
          const SizedBox(height: 12),
          const Text(
            'Weekly average',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: PieVisuals.subForeground,
            ),
          ),
          const SizedBox(height: 8),
          ...weeklyEntries.take(3).map((entry) {
            final hours = (entry.value / 60.0).toStringAsFixed(1);
            return _MetricBar(
              label: entry.key.label,
              valueLabel: '$hours h',
              progress: (entry.value / (24 * 60)).clamp(0, 1),
              color: PieVisuals.gradientForCategory(entry.key, 0xFF90A4AE).first,
            );
          }),
          const SizedBox(height: 12),
          Text(
            'Sleep trend: ${_sleepTrend(insights.sleepMinutesByDay)}',
            style: const TextStyle(
              fontSize: 12,
              color: PieVisuals.subForeground,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Productivity score: ${insights.productivityScore.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 14,
              color: PieVisuals.foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _sleepTrend(List<int> values) {
    if (values.isEmpty) {
      return 'No data';
    }

    final average = values.reduce((a, b) => a + b) / values.length;
    return '${(average / 60).toStringAsFixed(1)} h avg';
  }
}

class _MetricBar extends StatelessWidget {
  const _MetricBar({
    required this.label,
    required this.valueLabel,
    required this.progress,
    required this.color,
  });

  final String label;
  final String valueLabel;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: PieVisuals.subForeground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                color: color,
                backgroundColor: color.withValues(alpha: 0.18),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 44,
            child: Text(
              valueLabel,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 11,
                color: PieVisuals.foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
