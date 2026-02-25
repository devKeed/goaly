import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/goal.dart';
import '../models/task.dart';
import '../services/storage_service.dart';
import '../theme/app_colors.dart';
import '../widgets/fortune_character.dart';
import '../widgets/greeting_header.dart';
import '../widgets/section_header.dart';

class HomeScreen extends StatefulWidget {
  final StorageService storageService;
  final VoidCallback onNavigateToGoals;
  final VoidCallback onNavigateToPie;
  final VoidCallback onNavigateToTasks;

  const HomeScreen({
    super.key,
    required this.storageService,
    required this.onNavigateToGoals,
    required this.onNavigateToPie,
    required this.onNavigateToTasks,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _initializeMockData();
  }

  void _initializeMockData() {
    if (widget.storageService.getAllGoals().isEmpty) {
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

    if (widget.storageService.getAllTasks().isEmpty) {
      widget.storageService.addTask(Task(
        id: _uuid.v4(),
        title: 'Review PR #42',
        description: 'Check the new authentication flow',
        status: TaskStatus.todo,
        order: 0,
      ));
      widget.storageService.addTask(Task(
        id: _uuid.v4(),
        title: 'Fix login bug',
        description: 'Users getting logged out randomly',
        status: TaskStatus.todo,
        order: 1,
      ));
      widget.storageService.addTask(Task(
        id: _uuid.v4(),
        title: 'Update API docs',
        status: TaskStatus.inProgress,
        order: 0,
      ));
      widget.storageService.addTask(Task(
        id: _uuid.v4(),
        title: 'Deploy v2.1',
        description: 'Push to production',
        status: TaskStatus.inProgress,
        order: 1,
      ));
      widget.storageService.addTask(Task(
        id: _uuid.v4(),
        title: 'Setup CI/CD',
        status: TaskStatus.done,
        order: 0,
      ));
    }
  }

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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          children: [
            // Greeting
            const GreetingHeader(),
            const SizedBox(height: 12),

            // Today's Progress
            _ProgressCard(
              completed: completedDaily,
              total: totalDaily,
              onTap: widget.onNavigateToGoals,
            ),

            // Daily Goals Carousel
            SectionHeader(
              title: 'Daily Goals',
              onSeeAll: widget.onNavigateToGoals,
            ),
            if (dailyGoals.isEmpty)
              _EmptyCarouselCard(
                message: 'No daily goals yet',
                color: AppColors.cardBlue,
              )
            else
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: dailyGoals.length,
                  itemBuilder: (context, index) {
                    final goal = dailyGoals[index];
                    return _GoalCarouselCard(
                      goal: goal,
                      color: _goalCardColor(index),
                      accentColor: _goalCardAccent(index),
                      onTap: () {
                        goal.toggle();
                        setState(() {});
                      },
                    );
                  },
                ),
              ),

            // Pie Program Card
            SectionHeader(
              title: 'Your Schedule',
              onSeeAll: widget.onNavigateToPie,
            ),
            _PiePreviewCard(onTap: widget.onNavigateToPie),

            // Active Tasks Carousel
            SectionHeader(
              title: 'Active Tasks',
              onSeeAll: widget.onNavigateToTasks,
            ),
            if (activeTasks.isEmpty)
              _EmptyCarouselCard(
                message: 'All tasks done!',
                color: AppColors.cardGreen,
              )
            else
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: activeTasks.length,
                  itemBuilder: (context, index) {
                    final task = activeTasks[index];
                    return _TaskCarouselCard(task: task);
                  },
                ),
              ),

            // Long Term Goals
            if (longTermGoals.isNotEmpty) ...[
              SectionHeader(
                title: 'Long Term Goals',
                onSeeAll: widget.onNavigateToGoals,
              ),
              ...longTermGoals.map((goal) => _LongTermCard(goal: goal)),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Color _goalCardColor(int index) {
    const colors = [
      AppColors.cardGreen,
      AppColors.cardPink,
      AppColors.cardBlue,
      AppColors.cardOrange,
      AppColors.cardLavender,
    ];
    return colors[index % colors.length];
  }

  Color _goalCardAccent(int index) {
    const accents = [
      AppColors.cardGreenAccent,
      AppColors.cardPinkAccent,
      AppColors.cardBlueAccent,
      AppColors.cardOrangeAccent,
      AppColors.cardLavenderAccent,
    ];
    return accents[index % accents.length];
  }
}

// ---------- Progress Card ----------

class _ProgressCard extends StatelessWidget {
  final int completed;
  final int total;
  final VoidCallback onTap;

  const _ProgressCard({
    required this.completed,
    required this.total,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? completed / total : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardGreen,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            // Progress ring
            SizedBox(
              width: 64,
              height: 64,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.4),
                    valueColor: const AlwaysStoppedAnimation(
                        AppColors.cardGreenAccent),
                    strokeCap: StrokeCap.round,
                  ),
                  Text(
                    '$completed/$total',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Today's Progress",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    completed == total && total > 0
                        ? 'All done! Great job!'
                        : '${total - completed} goals remaining',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (completed == total && total > 0)
              const FortuneCharacter(
                size: 50,
                mood: CharacterMood.excited,
                bodyColor: AppColors.cardGreenAccent,
                accentColor: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}

// ---------- Goal Carousel Card ----------

class _GoalCarouselCard extends StatelessWidget {
  final Goal goal;
  final Color color;
  final Color accentColor;
  final VoidCallback? onTap;

  const _GoalCarouselCard({
    required this.goal,
    required this.color,
    required this.accentColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: goal.isCompleted
                        ? accentColor
                        : Colors.white.withValues(alpha: 0.6),
                    border: goal.isCompleted
                        ? null
                        : Border.all(color: accentColor, width: 2),
                  ),
                  child: goal.isCompleted
                      ? const Icon(Icons.check_rounded,
                          size: 16, color: Colors.white)
                      : null,
                ),
                const Spacer(),
                if (goal.type == GoalType.counter)
                  Text(
                    '${goal.progress}/${goal.target}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Text(
              goal.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (goal.type == GoalType.counter) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: goal.progressPercentage,
                  minHeight: 4,
                  backgroundColor: Colors.white.withValues(alpha: 0.5),
                  valueColor: AlwaysStoppedAnimation(accentColor),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------- Pie Preview Card ----------

class _PiePreviewCard extends StatelessWidget {
  final VoidCallback onTap;

  const _PiePreviewCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardPurple,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            // Mini pie icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.pie_chart_rounded,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pie Program',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Manage your daily schedule',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Task Carousel Card ----------

class _TaskCarouselCard extends StatelessWidget {
  final Task task;

  const _TaskCarouselCard({required this.task});

  Color get _statusColor {
    switch (task.status) {
      case TaskStatus.todo:
        return AppColors.statusTodoText;
      case TaskStatus.inProgress:
        return AppColors.statusInProgressText;
      case TaskStatus.done:
        return AppColors.statusDoneText;
    }
  }

  Color get _statusBg {
    switch (task.status) {
      case TaskStatus.todo:
        return AppColors.statusTodo;
      case TaskStatus.inProgress:
        return AppColors.statusInProgress;
      case TaskStatus.done:
        return AppColors.statusDone;
    }
  }

  String get _statusLabel {
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
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _statusBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _statusLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _statusColor,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            task.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (task.description != null) ...[
            const SizedBox(height: 4),
            Text(
              task.description!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

// ---------- Long Term Card ----------

class _LongTermCard extends StatelessWidget {
  final Goal goal;

  const _LongTermCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.flag_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  goal.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                '${goal.milestones.length}/${goal.target}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
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
              valueColor:
                  const AlwaysStoppedAnimation(AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Empty Carousel Card ----------

class _EmptyCarouselCard extends StatelessWidget {
  final String message;
  final Color color;

  const _EmptyCarouselCard({required this.message, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
