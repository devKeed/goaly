import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/task.dart';
import '../services/storage_service.dart';
import '../theme/app_colors.dart';
import '../widgets/fortune_character.dart';

class TasksScreen extends StatefulWidget {
  final StorageService storageService;

  const TasksScreen({super.key, required this.storageService});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  TaskStatus? _filter;
  final _uuid = const Uuid();

  List<Task> get _filteredTasks {
    final all = widget.storageService.getAllTasks();
    if (_filter == null) return all;
    return all.where((t) => t.status == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tasks'),
      ),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _filter == null,
                  onTap: () => setState(() => _filter = null),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'To Do',
                  selected: _filter == TaskStatus.todo,
                  color: AppColors.statusTodo,
                  selectedColor: AppColors.statusTodoText,
                  onTap: () => setState(() => _filter = TaskStatus.todo),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'In Progress',
                  selected: _filter == TaskStatus.inProgress,
                  color: AppColors.statusInProgress,
                  selectedColor: AppColors.statusInProgressText,
                  onTap: () => setState(() => _filter = TaskStatus.inProgress),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Done',
                  selected: _filter == TaskStatus.done,
                  color: AppColors.statusDone,
                  selectedColor: AppColors.statusDoneText,
                  onTap: () => setState(() => _filter = TaskStatus.done),
                ),
              ],
            ),
          ),
          // Task list
          Expanded(
            child: _filteredTasks.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = _filteredTasks[index];
                      return _TaskListItem(
                        task: task,
                        onStatusChange: () {
                          _cycleStatus(task);
                          setState(() {});
                        },
                        onTap: () => _showEditSheet(context, task),
                        onDelete: () {
                          widget.storageService.deleteTask(task.id);
                          setState(() {});
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FortuneCharacter(
            size: 100,
            mood: CharacterMood.waving,
            bodyColor: AppColors.cardOrange,
            accentColor: AppColors.cardOrangeAccent,
          ),
          const SizedBox(height: 20),
          const Text(
            'No tasks here',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap + to add a task!',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _cycleStatus(Task task) {
    switch (task.status) {
      case TaskStatus.todo:
        task.moveTo(TaskStatus.inProgress);
      case TaskStatus.inProgress:
        task.moveTo(TaskStatus.done);
      case TaskStatus.done:
        task.moveTo(TaskStatus.todo);
    }
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Task'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(hintText: 'Task title'),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                decoration:
                    const InputDecoration(hintText: 'Description (optional)'),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (titleController.text.trim().isEmpty) return;
              final tasksCount = widget.storageService
                  .getAllTasks()
                  .where((t) => t.status == TaskStatus.todo)
                  .length;
              final task = Task(
                id: _uuid.v4(),
                title: titleController.text.trim(),
                description: descController.text.trim().isEmpty
                    ? null
                    : descController.text.trim(),
                status: TaskStatus.todo,
                order: tasksCount,
              );
              widget.storageService.addTask(task);
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditSheet(BuildContext context, Task task) {
    final titleController = TextEditingController(text: task.title);
    final descController =
        TextEditingController(text: task.description ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Edit Task',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(hintText: 'Task title'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                decoration: const InputDecoration(hintText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) return;
                    task.title = titleController.text.trim();
                    task.description = descController.text.trim().isEmpty
                        ? null
                        : descController.text.trim();
                    task.save();
                    setState(() {});
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final Color? selectedColor;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    this.color,
    this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? (selectedColor ?? AppColors.primary)
              : (color ?? AppColors.surfaceVariant),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _TaskListItem extends StatelessWidget {
  final Task task;
  final VoidCallback onStatusChange;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _TaskListItem({
    required this.task,
    required this.onStatusChange,
    required this.onTap,
    required this.onDelete,
  });

  Color get _chipBg {
    switch (task.status) {
      case TaskStatus.todo:
        return AppColors.statusTodo;
      case TaskStatus.inProgress:
        return AppColors.statusInProgress;
      case TaskStatus.done:
        return AppColors.statusDone;
    }
  }

  Color get _chipText {
    switch (task.status) {
      case TaskStatus.todo:
        return AppColors.statusTodoText;
      case TaskStatus.inProgress:
        return AppColors.statusInProgressText;
      case TaskStatus.done:
        return AppColors.statusDoneText;
    }
  }

  String get _chipLabel {
    switch (task.status) {
      case TaskStatus.todo:
        return 'To Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.done:
        return 'Done';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: task.status == TaskStatus.done
                            ? AppColors.textTertiary
                            : AppColors.textPrimary,
                        decoration: task.status == TaskStatus.done
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (task.description != null &&
                        task.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: onStatusChange,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _chipBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _chipLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _chipText,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
