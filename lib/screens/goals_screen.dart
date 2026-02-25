import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/goal.dart';
import '../services/storage_service.dart';
import '../theme/app_colors.dart';
import '../widgets/fortune_character.dart';
import '../widgets/goal_card.dart';

class GoalsScreen extends StatefulWidget {
  final StorageService storageService;

  const GoalsScreen({super.key, required this.storageService});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  int _selectedTab = 0;
  final _uuid = const Uuid();

  static const _tabs = ['Daily', 'Weekly', 'Long Term'];

  List<Goal> get _currentGoals {
    switch (_selectedTab) {
      case 0:
        return widget.storageService.getDailyGoals();
      case 1:
        return widget.storageService.getWeeklyGoals();
      case 2:
        return widget.storageService.getLongTermGoals();
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Goals'),
      ),
      body: Column(
        children: [
          // Chip tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final selected = _selectedTab == i;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _tabs[i],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          // Goal list
          Expanded(
            child: _currentGoals.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _currentGoals.length,
                    itemBuilder: (context, index) {
                      final goal = _currentGoals[index];
                      return Dismissible(
                        key: Key(goal.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete_rounded,
                              color: Colors.white),
                        ),
                        onDismissed: (_) {
                          widget.storageService.deleteGoal(goal.id);
                          setState(() {});
                        },
                        child: GoalCard(
                          goal: goal,
                          onToggle: () {
                            goal.toggle();
                            setState(() {});
                          },
                          onIncrement: () {
                            goal.increment();
                            setState(() {});
                          },
                          onDecrement: () {
                            goal.decrement();
                            setState(() {});
                          },
                          onTap: goal.type == GoalType.longTerm
                              ? () => _showMilestoneSheet(context, goal)
                              : null,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGoalDialog(context),
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
            mood: CharacterMood.sad,
            bodyColor: AppColors.cardBlue,
            accentColor: AppColors.cardBlueAccent,
          ),
          const SizedBox(height: 20),
          const Text(
            'No goals yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap + to add your first goal!',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context) {
    final titleController = TextEditingController();
    final targetController = TextEditingController(text: '1');
    GoalType selectedType =
        _selectedTab == 2 ? GoalType.longTerm : GoalType.boolean;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('New Goal'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(hintText: 'Goal title'),
                  autofocus: true,
                ),
                if (_selectedTab != 2) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Type',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<GoalType>(
                    segments: const [
                      ButtonSegment(
                        value: GoalType.boolean,
                        label: Text('Yes/No'),
                      ),
                      ButtonSegment(
                        value: GoalType.counter,
                        label: Text('Counter'),
                      ),
                    ],
                    selected: {selectedType},
                    onSelectionChanged: (set) {
                      setDialogState(() => selectedType = set.first);
                    },
                  ),
                ],
                if (selectedType == GoalType.counter) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: targetController,
                    decoration: const InputDecoration(hintText: 'Target count'),
                    keyboardType: TextInputType.number,
                  ),
                ],
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
                final goal = Goal(
                  id: _uuid.v4(),
                  title: titleController.text.trim(),
                  type: _selectedTab == 2 ? GoalType.longTerm : selectedType,
                  target: selectedType == GoalType.counter
                      ? int.tryParse(targetController.text) ?? 1
                      : 1,
                  isDaily: _selectedTab == 0,
                  isWeekly: _selectedTab == 1,
                );
                widget.storageService.addGoal(goal);
                setState(() {});
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showMilestoneSheet(BuildContext context, Goal goal) {
    final milestoneController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
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
                    Expanded(
                      child: Text(
                        goal.title,
                        style: const TextStyle(
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
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: milestoneController,
                        decoration:
                            const InputDecoration(hintText: 'Add a milestone...'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: () {
                        if (milestoneController.text.trim().isEmpty) return;
                        goal.addMilestone(milestoneController.text.trim());
                        milestoneController.clear();
                        setSheetState(() {});
                        setState(() {});
                      },
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (goal.milestones.isNotEmpty) ...[
                  const Text(
                    'Milestones',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: goal.milestones.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          dense: true,
                          leading: const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.accent,
                          ),
                          title: Text(goal.milestones[index]),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline_rounded,
                                size: 20),
                            onPressed: () {
                              goal.removeMilestone(index);
                              setSheetState(() {});
                              setState(() {});
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
