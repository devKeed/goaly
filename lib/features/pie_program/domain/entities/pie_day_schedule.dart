import 'pie_time_block.dart';

class PieDaySchedule {
  const PieDaySchedule({
    required this.date,
    required this.blocks,
    required this.createdAt,
    required this.updatedAt,
    required this.isArchived,
  });

  final DateTime date;
  final List<PieTimeBlock> blocks;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;

  int get totalMinutes =>
      blocks.fold<int>(0, (sum, block) => sum + block.durationMinutes);

  PieDaySchedule copyWith({
    DateTime? date,
    List<PieTimeBlock>? blocks,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isArchived,
  }) {
    return PieDaySchedule(
      date: date ?? this.date,
      blocks: blocks ?? this.blocks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isArchived': isArchived,
      'blocks': blocks.map((block) => block.toJson()).toList(growable: false),
    };
  }

  factory PieDaySchedule.fromJson(Map<String, dynamic> map) {
    return PieDaySchedule(
      date: DateTime.parse(map['date'] as String).toLocal(),
      createdAt: DateTime.parse(map['createdAt'] as String).toLocal(),
      updatedAt: DateTime.parse(map['updatedAt'] as String).toLocal(),
      isArchived: map['isArchived'] as bool,
      blocks: (map['blocks'] as List<dynamic>)
          .map(
            (raw) => PieTimeBlock.fromJson(
              Map<String, dynamic>.from(raw as Map),
            ),
          )
          .toList(growable: false),
    );
  }
}
