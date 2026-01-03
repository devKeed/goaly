import 'package:flutter/material.dart';
import '../models/goal.dart';

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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: goal.isCompleted
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (goal.type) {
      case GoalType.boolean:
        return _buildBooleanContent(context);
      case GoalType.counter:
        return _buildCounterContent(context);
      case GoalType.longTerm:
        return _buildLongTermContent(context);
    }
  }

  Widget _buildBooleanContent(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: goal.isCompleted
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
                width: 2,
              ),
              color: goal.isCompleted
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
            ),
            child: goal.isCompleted
                ? const Icon(Icons.check, size: 18, color: Colors.white)
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
              color: goal.isCompleted ? Colors.grey : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCounterContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
                  color: goal.isCompleted ? colorScheme.primary : null,
                ),
              ),
            ),
            Row(
              children: [
                _CounterButton(
                  icon: Icons.remove,
                  onTap: goal.progress > 0 ? onDecrement : null,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '${goal.progress} / ${goal.target}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: goal.isCompleted ? colorScheme.primary : null,
                    ),
                  ),
                ),
                _CounterButton(
                  icon: Icons.add,
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
            backgroundColor: Colors.grey.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              goal.isCompleted ? colorScheme.primary : colorScheme.secondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLongTermContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.flag_outlined,
              size: 20,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                goal.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (goal.target > 0)
              Text(
                '${goal.milestones.length} / ${goal.target}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
        if (goal.milestones.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...goal.milestones.take(3).map(
                (m) => Padding(
                  padding: const EdgeInsets.only(left: 28, bottom: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          m,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
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
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[500],
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
              backgroundColor: Colors.grey.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
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
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.1),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled
              ? Theme.of(context).colorScheme.primary
              : Colors.grey[400],
        ),
      ),
    );
  }
}
