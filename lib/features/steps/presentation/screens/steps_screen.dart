import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../theme/app_colors.dart';
import '../../../../widgets/fitness_components.dart';
import '../../application/controllers/steps_controller.dart';
import '../../application/controllers/steps_view_state.dart';
import '../../domain/entities/step_day_summary.dart';
import '../../domain/entities/step_stats.dart';

class StepsScreen extends ConsumerWidget {
  const StepsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(stepsControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: asyncState.when(
        data: (state) => _StepsContent(state: state),
        loading: () => const _StepsLoadingState(),
        error: (error, _) => _StepsContent(state: StepsViewState.error(error)),
      ),
    );
  }
}

class _StepsContent extends ConsumerWidget {
  const _StepsContent({required this.state});

  final StepsViewState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.status != StepsViewStatus.ready) {
      return _StepsMessageState(state: state);
    }

    final stats = state.stats;
    final today = stats.today ?? StepDaySummary(date: DateTime.now(), steps: 0);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => ref.read(stepsControllerProvider.notifier).refresh(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          children: [
            FitnessHeader(
              title: 'Steps',
              subtitle: 'Activity',
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 10),
              trailing: IconButton(
                tooltip: 'Refresh',
                onPressed: () =>
                    ref.read(stepsControllerProvider.notifier).refresh(),
                icon: const Icon(Icons.refresh_rounded),
              ),
            ),
            _TodayStepsCard(today: today),
            const SizedBox(height: 16),
            _WeeklyChartCard(stats: stats),
            const SizedBox(height: 16),
            _StatsGrid(stats: stats),
          ],
        ),
      ),
    );
  }
}

class _TodayStepsCard extends StatelessWidget {
  const _TodayStepsCard({required this.today});

  final StepDaySummary today;

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat.decimalPattern();
    final progress = today.progressPercentage;

    return FitnessPanel(
      padding: const EdgeInsets.all(20),
      color: AppColors.surface,
      child: Row(
        children: [
          ActivityRingGroup(
            size: 116,
            strokeWidth: 12,
            rings: [
              ActivityRingSpec(
                progress: progress,
                color: AppColors.steps,
                trackColor: AppColors.steps.withValues(alpha: 0.15),
                label: 'Steps',
                value: numberFormat.format(today.steps),
              ),
            ],
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Text(
                  'goal',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Today',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  numberFormat.format(today.steps),
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    height: 0.98,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  today.isGoalMet
                      ? 'Daily goal reached'
                      : '${numberFormat.format(today.remainingSteps)} steps remaining',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: AppColors.surfaceVariant,
                    valueColor: const AlwaysStoppedAnimation(AppColors.steps),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyChartCard extends StatelessWidget {
  const _WeeklyChartCard({required this.stats});

  final StepStats stats;

  @override
  Widget build(BuildContext context) {
    final maxSteps = stats.days.fold<int>(
      stats.goal,
      (max, day) => day.steps > max ? day.steps : max,
    );
    final maxY = (maxSteps * 1.15)
        .clamp(stats.goal.toDouble(), double.infinity)
        .toDouble();

    return FitnessPanel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Last 7 days',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 190,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                minY: 0,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: stats.goal / 2,
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: AppColors.subtleDivider,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= stats.days.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            DateFormat.E().format(stats.days[index].date),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < stats.days.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: stats.days[i].steps.toDouble(),
                          width: 16,
                          borderRadius: BorderRadius.circular(5),
                          color: stats.days[i].isGoalMet
                              ? AppColors.stepsLight
                              : AppColors.steps,
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: maxY,
                            color: AppColors.surfaceVariant.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final day = stats.days[group.x.toInt()];
                      return BarTooltipItem(
                        '${NumberFormat.decimalPattern().format(day.steps)} steps',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final StepStats stats;

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat.decimalPattern();
    final bestDay = stats.bestDay;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.55,
      children: [
        _StatTile(
          label: 'Weekly total',
          value: numberFormat.format(stats.weeklyTotal),
          icon: Icons.directions_walk_rounded,
          color: AppColors.steps,
        ),
        _StatTile(
          label: 'Daily average',
          value: numberFormat.format(stats.dailyAverage),
          icon: Icons.show_chart_rounded,
          color: AppColors.schedule,
        ),
        _StatTile(
          label: 'Best day',
          value: bestDay == null ? '0' : numberFormat.format(bestDay.steps),
          icon: Icons.emoji_events_rounded,
          color: AppColors.primary,
        ),
        _StatTile(
          label: 'Goal',
          value: numberFormat.format(stats.goal),
          icon: Icons.flag_rounded,
          color: AppColors.cardPurpleAccent,
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return FitnessMetricTile(
      label: label,
      value: value,
      icon: icon,
      color: color,
    );
  }
}

class _StepsMessageState extends ConsumerWidget {
  const _StepsMessageState({required this.state});

  final StepsViewState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canInstallHealthConnect =
        state.status == StepsViewStatus.unavailable && Platform.isAndroid;

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.directions_walk_rounded,
                color: AppColors.steps,
                size: 56,
              ),
              const SizedBox(height: 18),
              Text(
                _titleFor(state.status),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.message ?? 'Step statistics are unavailable.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: () => ref
                    .read(stepsControllerProvider.notifier)
                    .retryAuthorization(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try again'),
              ),
              if (canInstallHealthConnect) ...[
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => ref
                      .read(stepsControllerProvider.notifier)
                      .openHealthConnectInstall(),
                  child: const Text('Open Health Connect'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _titleFor(StepsViewStatus status) {
    return switch (status) {
      StepsViewStatus.denied => 'Health access needed',
      StepsViewStatus.unavailable => 'Step data unavailable',
      StepsViewStatus.error => 'Could not load steps',
      StepsViewStatus.ready => 'Steps',
    };
  }
}

class _StepsLoadingState extends StatelessWidget {
  const _StepsLoadingState();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(child: Center(child: CircularProgressIndicator()));
  }
}
