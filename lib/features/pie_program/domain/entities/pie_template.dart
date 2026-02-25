import 'pie_template_block.dart';

class PieTemplate {
  const PieTemplate({
    required this.id,
    required this.blocks,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final List<PieTemplateBlock> blocks;
  final DateTime createdAt;
  final DateTime updatedAt;

  PieTemplate copyWith({
    String? id,
    List<PieTemplateBlock>? blocks,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PieTemplate(
      id: id ?? this.id,
      blocks: blocks ?? this.blocks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'blocks': blocks.map((block) => block.toJson()).toList(growable: false),
    };
  }

  factory PieTemplate.fromJson(Map<String, dynamic> map) {
    return PieTemplate(
      id: map['id'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String).toLocal(),
      updatedAt: DateTime.parse(map['updatedAt'] as String).toLocal(),
      blocks: (map['blocks'] as List<dynamic>)
          .map(
            (raw) => PieTemplateBlock.fromJson(
              Map<String, dynamic>.from(raw as Map),
            ),
          )
          .toList(growable: false),
    );
  }
}
