import 'package:hive/hive.dart';

part 'goal.g.dart';

@HiveType(typeId: 0)
enum GoalType {
  @HiveField(0)
  boolean,
  @HiveField(1)
  counter,
  @HiveField(2)
  longTerm,
}

@HiveType(typeId: 1)
class Goal extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  final GoalType type;

  @HiveField(3)
  int target;

  @HiveField(4)
  int progress;

  @HiveField(5)
  final bool isDaily;

  @HiveField(6)
  final bool isWeekly;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  List<String> milestones;

  Goal({
    required this.id,
    required this.title,
    required this.type,
    this.target = 1,
    this.progress = 0,
    this.isDaily = false,
    this.isWeekly = false,
    DateTime? createdAt,
    List<String>? milestones,
  })  : createdAt = createdAt ?? DateTime.now(),
        milestones = milestones ?? [];

  bool get isCompleted => progress >= target;

  double get progressPercentage =>
      target > 0 ? (progress / target).clamp(0.0, 1.0) : 0.0;

  void increment() {
    if (progress < target) {
      progress++;
      save();
    }
  }

  void decrement() {
    if (progress > 0) {
      progress--;
      save();
    }
  }

  void toggle() {
    if (type == GoalType.boolean) {
      progress = progress == 0 ? 1 : 0;
      save();
    }
  }

  void reset() {
    progress = 0;
    save();
  }

  void addMilestone(String milestone) {
    milestones.add(milestone);
    progress = milestones.length;
    save();
  }

  void removeMilestone(int index) {
    if (index >= 0 && index < milestones.length) {
      milestones.removeAt(index);
      progress = milestones.length;
      save();
    }
  }
}
