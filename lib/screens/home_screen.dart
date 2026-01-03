import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/goal.dart';
import '../services/storage_service.dart';
import '../widgets/goal_card.dart';

class HomeScreen extends StatefulWidget {
  final StorageService storageService;

  const HomeScreen({super.key, required this.storageService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _initializeMockData();
  }

  void _initializeMockData() {
    if (widget.storageService.getAllGoals().isEmpty) {
      // Daily goals
      widget.storageService.addGoal(Goal(
        id: _uuid.v4(),
        title: 'Morning meditation',
        type: GoalType.boolean,
        isDaily: true,
      ));
      widget.storageService.addGoal(Goal(
        id: _uuid.v4(),
        title: 'Drink water',
        type: GoalType.counter,
        target: 8,
        isDaily: true,
      ));
      widget.storageService.addGoal(Goal(
        id: _uuid.v4(),
        title: 'Read for 30 minutes',
        type: GoalType.boolean,
        isDaily: true,
      ));
      widget.storageService.addGoal(Goal(
        id: _uuid.v4(),
        title: 'No social media before noon',
        type: GoalType.boolean,
        isDaily: true,
      ));

      // Weekly goals
      widget.storageService.addGoal(Goal(
        id: _uuid.v4(),
        title: 'Gym sessions',
        type: GoalType.counter,
        target: 5,
        isWeekly: true,
      ));
      widget.storageService.addGoal(Goal(
        id: _uuid.v4(),
        title: 'Cook healthy meals',
        type: GoalType.counter,
        target: 4,
        isWeekly: true,
      ));
      widget.storageService.addGoal(Goal(
        id: _uuid.v4(),
        title: 'Call a friend or family',
        type: GoalType.counter,
        target: 2,
        isWeekly: true,
      ));

      // Long-term goals
      widget.storageService.addGoal(Goal(
        id: _uuid.v4(),
        title: 'Learn Spanish',
        type: GoalType.longTerm,
        target: 10,
        milestones: ['Completed Duolingo basics', 'Learned 100 words'],
      ));
      widget.storageService.addGoal(Goal(
        id: _uuid.v4(),
        title: 'Run a marathon',
        type: GoalType.longTerm,
        target: 5,
        milestones: ['Ran first 5K'],
      ));
      widget.storageService.addGoal(Goal(
        id: _uuid.v4(),
        title: 'Save \$10,000',
        type: GoalType.longTerm,
        target: 10,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(_getTitle()),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildGoalList(widget.storageService.getDailyGoals(), true),
          _buildGoalList(widget.storageService.getWeeklyGoals(), false),
          _buildLongTermList(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_view_week_outlined),
            selectedIcon: Icon(Icons.calendar_view_week),
            label: 'Weekly',
          ),
          NavigationDestination(
            icon: Icon(Icons.flag_outlined),
            selectedIcon: Icon(Icons.flag),
            label: 'Long Term',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGoalDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Today';
      case 1:
        return 'This Week';
      case 2:
        return 'Long Term Goals';
      default:
        return 'Fortune';
    }
  }

  Widget _buildGoalList(List<Goal> goals, bool isDaily) {
    if (goals.isEmpty) {
      return _buildEmptyState(isDaily ? 'daily' : 'weekly');
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: goals.length,
      itemBuilder: (context, index) {
        final goal = goals[index];
        return Dismissible(
          key: Key(goal.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red[400],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.delete, color: Colors.white),
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
          ),
        );
      },
    );
  }

  Widget _buildLongTermList() {
    final goals = widget.storageService.getLongTermGoals();

    if (goals.isEmpty) {
      return _buildEmptyState('long-term');
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: goals.length,
      itemBuilder: (context, index) {
        final goal = goals[index];
        return Dismissible(
          key: Key(goal.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red[400],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) {
            widget.storageService.deleteGoal(goal.id);
            setState(() {});
          },
          child: GoalCard(
            goal: goal,
            onTap: () => _showMilestoneDialog(context, goal),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String type) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flag_outlined,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No $type goals yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first goal',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context) {
    final titleController = TextEditingController();
    final targetController = TextEditingController(text: '1');
    GoalType selectedType = GoalType.boolean;

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
                  decoration: const InputDecoration(
                    labelText: 'Goal title',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                const Text('Type'),
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
                if (selectedType == GoalType.counter) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: targetController,
                    decoration: const InputDecoration(
                      labelText: 'Target',
                      border: OutlineInputBorder(),
                    ),
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
                  type: _currentIndex == 2 ? GoalType.longTerm : selectedType,
                  target: selectedType == GoalType.counter
                      ? int.tryParse(targetController.text) ?? 1
                      : 1,
                  isDaily: _currentIndex == 0,
                  isWeekly: _currentIndex == 1,
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

  void _showMilestoneDialog(BuildContext context, Goal goal) {
    final milestoneController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      goal.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: milestoneController,
                        decoration: const InputDecoration(
                          hintText: 'Add a milestone...',
                          border: OutlineInputBorder(),
                        ),
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
                      icon: const Icon(Icons.add),
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
                      color: Colors.grey,
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
                          leading: Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          title: Text(goal.milestones[index]),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20),
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
