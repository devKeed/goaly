import 'pie_block_category.dart';

class PieTemplateBlock {
  const PieTemplateBlock({
    required this.id,
    required this.title,
    required this.startMinute,
    required this.endMinute,
    required this.category,
    required this.color,
    required this.isRecurring,
    required this.isLocked,
    required this.createdAt,
  });

  final String id;
  final String title;
  final int startMinute;
  final int endMinute;
  final PieBlockCategory category;
  final int color;
  final bool isRecurring;
  final bool isLocked;
  final DateTime createdAt;

  int get durationMinutes => endMinute - startMinute;

  PieTemplateBlock copyWith({
    String? id,
    String? title,
    int? startMinute,
    int? endMinute,
    PieBlockCategory? category,
    int? color,
    bool? isRecurring,
    bool? isLocked,
    DateTime? createdAt,
  }) {
    return PieTemplateBlock(
      id: id ?? this.id,
      title: title ?? this.title,
      startMinute: startMinute ?? this.startMinute,
      endMinute: endMinute ?? this.endMinute,
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
      'startMinute': startMinute,
      'endMinute': endMinute,
      'category': category.name,
      'color': color,
      'isRecurring': isRecurring,
      'isLocked': isLocked,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PieTemplateBlock.fromJson(Map<String, dynamic> map) {
    return PieTemplateBlock(
      id: map['id'] as String,
      title: map['title'] as String,
      startMinute: map['startMinute'] as int,
      endMinute: map['endMinute'] as int,
      category: PieBlockCategory.values.byName(map['category'] as String),
      color: map['color'] as int,
      isRecurring: map['isRecurring'] as bool,
      isLocked: map['isLocked'] as bool,
      createdAt: DateTime.parse(map['createdAt'] as String).toLocal(),
    );
  }
}
