import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 2)
enum TaskStatus {
  @HiveField(0)
  todo,
  @HiveField(1)
  inProgress,
  @HiveField(2)
  done,
}

@HiveType(typeId: 3)
class Task extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  TaskStatus status;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  int order;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.status = TaskStatus.todo,
    DateTime? createdAt,
    this.order = 0,
  }) : createdAt = createdAt ?? DateTime.now();

  void moveTo(TaskStatus newStatus) {
    status = newStatus;
    save();
  }
}
