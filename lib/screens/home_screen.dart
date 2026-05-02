import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../features/pie_program/application/controllers/pie_program_controller.dart';
import '../features/steps/application/controllers/steps_controller.dart';
import '../models/goal.dart';
import '../models/task.dart';
import '../services/storage_service.dart';
import '../theme/app_colors.dart';
import '../widgets/fitness_components.dart';
import '../widgets/section_header.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final StorageService storageService;
  final VoidCallback onNavigateToGoals;
  final VoidCallback onNavigateToPie;
  final VoidCallback onNavigateToTasks;
  final VoidCallback onNavigateToSteps;

  const HomeScreen({
    super.key,
    required this.storageService,
    required this.onNavigateToGoals,
    required this.onNavigateToPie,
    required this.onNavigateToTasks,
    required this.onNavigateToSteps,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final dailyGoals = widget.storageService.getDailyGoals();
    final completedDaily = dailyGoals.where((g) => g.isCompleted).length;
    final totalDaily = dailyGoals.length;
    final activeTasks = widget.storageService
        .getAllTasks()
        .where((t) => t.status != TaskStatus.done)
        .toList();
    final longTermGoals = widget.storageService.getLongTermGoals();

    final stepsState = ref.watch(stepsControllerProvider).valueOrNull;
    final todaySteps = stepsState?.stats.today;
    final stepProgress = todaySteps?.progressPercentage ?? 0;
    final stepValue = todaySteps == null
        ? '0'
        : NumberFormat.compact().format(todaySteps.steps);

    final pieState = ref.watch(pieProgramControllerProvider).valueOrNull;
    final scheduleProgress = pieState == null
        ? 0.0
        : ((pieState.now.hour * 60 + pieState.now.minute) / (24 * 60)).clamp(
            0.0,
            1.0,
          );
    final scheduleValue = pieState?.template == null
        ? 'Setup'
        : '${(scheduleProgress * 100).round()}%';

    final goalProgress = totalDaily == 0 ? 0.0 : completedDaily / totalDaily;
    final rings = [
      ActivityRingSpec(
        progress: goalProgress,
        color: AppColors.primary,
        trackColor: AppColors.primary.withValues(alpha: 0.17),
        label: 'Goals',
        value: '$completedDaily/$totalDaily',
      ),
      ActivityRingSpec(
        progress: scheduleProgress,
        color: AppColors.schedule,
        trackColor: AppColors.schedule.withValues(alpha: 0.16),
        label: 'Schedule',
        value: scheduleValue,
      ),
      ActivityRingSpec(
        progress: stepProgress,
        color: AppColors.steps,
        trackColor: AppColors.steps.withValues(alpha: 0.15),
        label: 'Steps',
        value: stepValue,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 26),
          children: [
            const FitnessHeader(title: 'Today', subtitle: 'Fortune'),
            _ActivitySummaryCard(
              rings: rings,
              completedGoals: completedDaily,
              totalGoals: totalDaily,
              steps: todaySteps?.steps ?? 0,
              onGoalsTap: widget.onNavigateToGoals,
              onPieTap: widget.onNavigateToPie,
              onStepsTap: widget.onNavigateToSteps,
            ),
            SectionHeader(
              title: 'Daily Goals',
              onSeeAll: widget.onNavigateToGoals,
            ),
            if (dailyGoals.isEmpty)
              _EmptyHorizontalCard(
                message: 'Add goals to fill your first ring.',
                icon: CupertinoIcons.flag_fill,
                color: AppColors.primary,
              )
            else
              SizedBox(
                height: 132,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: dailyGoals.length,
                  itemBuilder: (context, index) {
                    final goal = dailyGoals[index];
                    return _GoalCarouselCard(
                      goal: goal,
                      color: _goalAccent(index),
                      onTap: () {
                        goal.toggle();
                        setState(() {});
                      },
                    );
                  },
                ),
              ),
            SectionHeader(title: 'Schedule', onSeeAll: widget.onNavigateToPie),
            _FeatureCard(
              title: 'Pie Program',
              subtitle: pieState?.template == null
                  ? 'Set up your daily template'
                  : 'Keep the day moving',
              value: scheduleValue,
              icon: CupertinoIcons.chart_pie_fill,
              color: AppColors.schedule,
              onTap: widget.onNavigateToPie,
            ),
            SectionHeader(title: 'Steps', onSeeAll: widget.onNavigateToSteps),
            _FeatureCard(
              title: 'Daily Steps',
              subtitle: todaySteps?.isGoalMet == true
                  ? 'Daily goal reached'
                  : 'Toward ${NumberFormat.decimalPattern().format(todaySteps?.goal ?? 10000)}',
              value: NumberFormat.decimalPattern().format(
                todaySteps?.steps ?? 0,
              ),
              icon: Icons.directions_walk_rounded,
              color: AppColors.steps,
              onTap: widget.onNavigateToSteps,
            ),
            SectionHeader(
              title: 'Active Tasks',
              onSeeAll: widget.onNavigateToTasks,
            ),
            if (activeTasks.isEmpty)
              _EmptyHorizontalCard(
                message: 'All tasks are complete.',
                icon: CupertinoIcons.checkmark_circle_fill,
                color: AppColors.steps,
              )
            else
              SizedBox(
                height: 108,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: activeTasks.length,
                  itemBuilder: (context, index) {
                    return _TaskCarouselCard(task: activeTasks[index]);
                  },
                ),
              ),
            if (longTermGoals.isNotEmpty) ...[
              SectionHeader(
                title: 'Long Term',
                onSeeAll: widget.onNavigateToGoals,
              ),
              ...longTermGoals.map((goal) => _LongTermCard(goal: goal)),
            ],
          ],
        ),
      ),
    );
  }

  Color _goalAccent(int index) {
    const accents = [
      AppColors.primary,
      AppColors.schedule,
      AppColors.steps,
      AppColors.cardOrangeAccent,
      AppColors.cardPurpleAccent,
    ];
    return accents[index % accents.length];
  }
}

class _ActivitySummaryCard extends StatelessWidget {
  const _ActivitySummaryCard({
    required this.rings,
    required this.completedGoals,
    required this.totalGoals,
    required this.steps,
    required this.onGoalsTap,
    required this.onPieTap,
    required this.onStepsTap,
  });

  final List<ActivityRingSpec> rings;
  final int completedGoals;
  final int totalGoals;
  final int steps;
  final VoidCallback onGoalsTap;
  final VoidCallback onPieTap;
  final VoidCallback onStepsTap;

  @override
  Widget build(BuildContext context) {
    return FitnessPanel(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              ActivityRingGroup(
                rings: rings,
                size: 178,
                center: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Day',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${(rings.first.progress * 100).round()}%',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(child: RingLegend(rings: rings)),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _SummaryButton(
                  label: 'Goals',
                  value: '$completedGoals/$totalGoals',
                  color: AppColors.primary,
                  onTap: onGoalsTap,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryButton(
                  label: 'Pie',
                  value: rings[1].value,
                  color: AppColors.schedule,
                  onTap: onPieTap,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryButton(
                  label: 'Steps',
                  value: NumberFormat.compact().format(steps),
                  color: AppColors.steps,
                  onTap: onStepsTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryButton extends StatelessWidget {
  const _SummaryButton({
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.13),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalCarouselCard extends StatelessWidget {
  const _GoalCarouselCard({
    required this.goal,
    required this.color,
    required this.onTap,
  });

  final Goal goal;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FitnessPanel(
      onTap: onTap,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      color: AppColors.surfaceElevated,
      child: SizedBox(
        width: 156,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 27,
                  height: 27,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: goal.isCompleted ? color : Colors.transparent,
                    border: Border.all(color: color, width: 2),
                  ),
                  child: goal.isCompleted
                      ? const Icon(
                          CupertinoIcons.checkmark,
                          size: 16,
                          color: AppColors.background,
                        )
                      : null,
                ),
                const Spacer(),
                if (goal.type == GoalType.counter)
                  Text(
                    '${goal.progress}/${goal.target}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Text(
              goal.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                height: 1.13,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            if (goal.type == GoalType.counter) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: goal.progressPercentage,
                  minHeight: 5,
                  backgroundColor: AppColors.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FitnessPanel(
      onTap: onTap,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskCarouselCard extends StatelessWidget {
  const _TaskCarouselCard({required this.task});

  final Task task;

  Color get _statusColor {
    return switch (task.status) {
      TaskStatus.todo => AppColors.textSecondary,
      TaskStatus.inProgress => AppColors.schedule,
      TaskStatus.done => AppColors.steps,
    };
  }

  String get _statusLabel {
    return switch (task.status) {
      TaskStatus.todo => 'To Do',
      TaskStatus.inProgress => 'In Progress',
      TaskStatus.done => 'Done',
    };
  }

  @override
  Widget build(BuildContext context) {
    return FitnessPanel(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(15),
      color: AppColors.surfaceElevated,
      child: SizedBox(
        width: 184,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _statusLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: _statusColor,
              ),
            ),
            const Spacer(),
            Text(
              task.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                height: 1.13,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            if (task.description != null) ...[
              const SizedBox(height: 4),
              Text(
                task.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LongTermCard extends StatelessWidget {
  const _LongTermCard({required this.goal});

  final Goal goal;

  @override
  Widget build(BuildContext context) {
    return FitnessPanel(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.flag_fill,
            color: AppColors.cardPurpleAccent,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              goal.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (goal.target > 0)
            Text(
              '${goal.milestones.length}/${goal.target}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyHorizontalCard extends StatelessWidget {
  const _EmptyHorizontalCard({
    required this.message,
    required this.icon,
    required this.color,
  });

  final String message;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return FitnessPanel(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
