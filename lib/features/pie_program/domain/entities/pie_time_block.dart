import 'pie_block_category.dart';

class PieTimeBlock {
  const PieTimeBlock({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.category,
    required this.color,
    required this.isRecurring,
    required this.isLocked,
    required this.createdAt,
  });

  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final PieBlockCategory category;
  final int color;
  final bool isRecurring;
  final bool isLocked;
  final DateTime createdAt;

  DateTime get _dayAnchor =>
      DateTime(startTime.year, startTime.month, startTime.day);

  int get startMinuteOfDay => startTime.difference(_dayAnchor).inMinutes;
  int get endMinuteOfDay => endTime.difference(_dayAnchor).inMinutes;
  int get durationMinutes => endMinuteOfDay - startMinuteOfDay;

  PieTimeBlock copyWith({
    String? id,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    PieBlockCategory? category,
    int? color,
    bool? isRecurring,
    bool? isLocked,
    DateTime? createdAt,
  }) {
    return PieTimeBlock(
      id: id ?? this.id,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      category: category ?? this.category,
      color: color ?? this.color,
      isRecurring: isRecurring ?? this.isRecurring,
      isLocked: isLocked ?? this.isLocked,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'category': category.name,
      'color': color,
      'isRecurring': isRecurring,
      'isLocked': isLocked,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PieTimeBlock.fromJson(Map<String, dynamic> map) {
    return PieTimeBlock(
      id: map['id'] as String,
      title: map['title'] as String,
      startTime: DateTime.parse(map['startTime'] as String).toLocal(),
      endTime: DateTime.parse(map['endTime'] as String).toLocal(),
      category: PieBlockCategory.values.byName(map['category'] as String),
      color: map['color'] as int,
      isRecurring: map['isRecurring'] as bool,
      isLocked: map['isLocked'] as bool,
      createdAt: DateTime.parse(map['createdAt'] as String).toLocal(),
    );
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      startTime,
      endTime,
      category,
      color,
      isRecurring,
      isLocked,
      createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is PieTimeBlock &&
        other.id == id &&
        other.title == title &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.category == category &&
        other.color == color &&
        other.isRecurring == isRecurring &&
        other.isLocked == isLocked &&
        other.createdAt == createdAt;
  }
}
