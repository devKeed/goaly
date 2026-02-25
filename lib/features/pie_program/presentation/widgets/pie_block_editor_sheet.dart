import 'package:flutter/material.dart';

import '../../domain/entities/pie_block_category.dart';
import '../../domain/entities/pie_time_block.dart';
import 'pie_visuals.dart';

class PieBlockEditorResult {
  const PieBlockEditorResult({
    required this.action,
    required this.title,
    required this.category,
    required this.color,
  });

  final PieBlockEditorAction action;
  final String title;
  final PieBlockCategory category;
  final int color;
}

enum PieBlockEditorAction { save, delete, addAfter }

Future<PieBlockEditorResult?> showPieBlockEditorSheet({
  required BuildContext context,
  required PieTimeBlock block,
}) {
  return showModalBottomSheet<PieBlockEditorResult>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => _PieBlockEditorSheet(block: block),
  );
}

class _PieBlockEditorSheet extends StatefulWidget {
  const _PieBlockEditorSheet({required this.block});

  final PieTimeBlock block;

  @override
  State<_PieBlockEditorSheet> createState() => _PieBlockEditorSheetState();
}

class _PieBlockEditorSheetState extends State<_PieBlockEditorSheet> {
  late final TextEditingController _titleController;
  late PieBlockCategory _category;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.block.title);
    _category = widget.block.category;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final start = TimeOfDay.fromDateTime(widget.block.startTime).format(context);
    final end = TimeOfDay.fromDateTime(widget.block.endTime).format(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Edit Block',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: PieVisuals.foreground,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$start - $end',
            style: const TextStyle(
              color: PieVisuals.subForeground,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: PieBlockCategory.values.map((category) {
              final selected = _category == category;
              final color = PieVisuals.gradientForCategory(category, widget.block.color).first;
              return ChoiceChip(
                label: Text(category.label),
                selected: selected,
                selectedColor: color.withValues(alpha: 0.25),
                onSelected: (_) => setState(() => _category = category),
              );
            }).toList(growable: false),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop(
                      PieBlockEditorResult(
                        action: PieBlockEditorAction.delete,
                        title: _titleController.text.trim(),
                        category: _category,
                        color: PieVisuals.gradientForCategory(_category, widget.block.color).first.toARGB32(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop(
                      PieBlockEditorResult(
                        action: PieBlockEditorAction.addAfter,
                        title: _titleController.text.trim(),
                        category: _category,
                        color: PieVisuals.gradientForCategory(_category, widget.block.color).first.toARGB32(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Split/Add'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                final title = _titleController.text.trim();
                if (title.isEmpty) {
                  return;
                }
                Navigator.of(context).pop(
                  PieBlockEditorResult(
                    action: PieBlockEditorAction.save,
                    title: title,
                    category: _category,
                    color: PieVisuals.gradientForCategory(_category, widget.block.color).first.toARGB32(),
                  ),
                );
              },
              child: const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }
}
