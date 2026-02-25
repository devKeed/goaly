import 'package:flutter/material.dart';

import '../models/goal.dart';
import '../theme/app_colors.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final VoidCallback? onToggle;
  final VoidCallback? onTap;

  const GoalCard({
    super.key,
    required this.goal,
    this.onIncrement,
    this.onDecrement,
    this.onToggle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: goal.isCompleted
              ? AppColors.accent.withValues(alpha: 0.4)
              : AppColors.divider,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (goal.type) {
      case GoalType.boolean:
        return _buildBooleanContent();
      case GoalType.counter:
        return _buildCounterContent();
      case GoalType.longTerm:
        return _buildLongTermContent();
    }
  }

  Widget _buildBooleanContent() {
    return Row(
      children: [
        GestureDetector(
          onTap: onToggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: goal.isCompleted ? AppColors.accent : Colors.transparent,
              border: goal.isCompleted
                  ? null
                  : Border.all(color: AppColors.textTertiary, width: 2),
            ),
            child: goal.isCompleted
                ? const Icon(Icons.check_rounded,
                    size: 18, color: Colors.white)
                : null,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            goal.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              decoration:
                  goal.isCompleted ? TextDecoration.lineThrough : null,
              color: goal.isCompleted
                  ? AppColors.textTertiary
                  : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCounterContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                goal.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: goal.isCompleted
                      ? AppColors.accent
                      : AppColors.textPrimary,
                ),
              ),
            ),
            Row(
              children: [
                _CounterButton(
                  icon: Icons.remove_rounded,
                  onTap: goal.progress > 0 ? onDecrement : null,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '${goal.progress}/${goal.target}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: goal.isCompleted
                          ? AppColors.accent
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                _CounterButton(
                  icon: Icons.add_rounded,
                  onTap: goal.progress < goal.target ? onIncrement : null,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: goal.progressPercentage,
            minHeight: 6,
            backgroundColor: AppColors.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(
              goal.isCompleted ? AppColors.accent : AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLongTermContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.flag_rounded,
              size: 20,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                goal.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (goal.target > 0)
              Text(
                '${goal.milestones.length}/${goal.target}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
        if (goal.milestones.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...goal.milestones.take(3).map(
                (m) => Padding(
                  padding: const EdgeInsets.only(left: 28, bottom: 6),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 16,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          m,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          if (goal.milestones.length > 3)
            Padding(
              padding: const EdgeInsets.only(left: 28),
              child: Text(
                '+${goal.milestones.length - 3} more',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
        ],
        if (goal.target > 0) ...[
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: goal.progressPercentage,
              minHeight: 6,
              backgroundColor: AppColors.surfaceVariant,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ],
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _CounterButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surfaceVariant,
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? AppColors.primary : AppColors.textTertiary,
        ),
      ),
    );
  }
}
