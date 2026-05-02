import 'package:flutter/material.dart';

import '../models/task.dart';
import '../theme/app_colors.dart';

class KanbanBoard extends StatelessWidget {
  final List<Task> tasks;
  final Function(Task task, TaskStatus newStatus) onTaskMoved;
  final Function(TaskStatus status) onAddTask;
  final Function(Task task) onTaskTap;
  final Function(Task task) onTaskDelete;

  const KanbanBoard({
    super.key,
    required this.tasks,
    required this.onTaskMoved,
    required this.onAddTask,
    required this.onTaskTap,
    required this.onTaskDelete,
  });

  List<Task> _getTasksForStatus(TaskStatus status) {
    return tasks.where((t) => t.status == status).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _KanbanColumn(
            title: 'To Do',
            status: TaskStatus.todo,
            tasks: _getTasksForStatus(TaskStatus.todo),
            onTaskMoved: onTaskMoved,
            onAddTask: () => onAddTask(TaskStatus.todo),
            onTaskTap: onTaskTap,
            onTaskDelete: onTaskDelete,
            color: AppColors.statusTodoText,
          ),
        ),
        Expanded(
          child: _KanbanColumn(
            title: 'In Progress',
            status: TaskStatus.inProgress,
            tasks: _getTasksForStatus(TaskStatus.inProgress),
            onTaskMoved: onTaskMoved,
            onAddTask: () => onAddTask(TaskStatus.inProgress),
            onTaskTap: onTaskTap,
            onTaskDelete: onTaskDelete,
            color: AppColors.statusInProgressText,
          ),
        ),
        Expanded(
          child: _KanbanColumn(
            title: 'Done',
            status: TaskStatus.done,
            tasks: _getTasksForStatus(TaskStatus.done),
            onTaskMoved: onTaskMoved,
            onAddTask: () => onAddTask(TaskStatus.done),
            onTaskTap: onTaskTap,
            onTaskDelete: onTaskDelete,
            color: AppColors.statusDoneText,
          ),
        ),
      ],
    );
  }
}

class _KanbanColumn extends StatelessWidget {
  final String title;
  final TaskStatus status;
  final List<Task> tasks;
  final Function(Task task, TaskStatus newStatus) onTaskMoved;
  final VoidCallback onAddTask;
  final Function(Task task) onTaskTap;
  final Function(Task task) onTaskDelete;
  final Color color;

  const _KanbanColumn({
    required this.title,
    required this.status,
    required this.tasks,
    required this.onTaskMoved,
    required this.onAddTask,
    required this.onTaskTap,
    required this.onTaskDelete,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<Task>(
      onWillAcceptWithDetails: (details) => details.data.status != status,
      onAcceptWithDetails: (details) => onTaskMoved(details.data, status),
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isHovering
                ? color.withValues(alpha: 0.1)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isHovering ? color : AppColors.divider,
              width: isHovering ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(7),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: color,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${tasks.length}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(6),
                  itemCount: tasks.length + 1,
                  itemBuilder: (context, index) {
                    if (index == tasks.length) {
                      return _AddTaskButton(onTap: onAddTask);
                    }
                    return _TaskCard(
                      task: tasks[index],
                      onTap: () => onTaskTap(tasks[index]),
                      onDelete: () => onTaskDelete(tasks[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _TaskCard({
    required this.task,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<Task>(
      data: task,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 120,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.divider),
          ),
          child: Text(
            task.title,
            style: const TextStyle(fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: _buildCard(context)),
      child: _buildCard(context),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 8),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 18),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  decoration: task.status == TaskStatus.done
                      ? TextDecoration.lineThrough
                      : null,
                  color: task.status == TaskStatus.done
                      ? AppColors.textTertiary
                      : AppColors.textPrimary,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (task.description != null && task.description!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  task.description!,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AddTaskButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddTaskButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 16, color: AppColors.textTertiary),
            const SizedBox(width: 4),
            Text(
              'Add',
              style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}
