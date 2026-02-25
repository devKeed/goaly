import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/pie_time_block.dart';
import 'pie_visuals.dart';

class PieBlockList extends StatelessWidget {
  const PieBlockList({
    super.key,
    required this.blocks,
    required this.onTap,
  });

  final List<PieTimeBlock> blocks;
  final ValueChanged<PieTimeBlock> onTap;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('HH:mm');

    return Column(
      children: blocks.map((block) {
        final start = formatter.format(block.startTime);
        final end = formatter.format(block.endTime);
        final progress = block.durationMinutes / (24 * 60);
        final colors = PieVisuals.gradientForCategory(block.category, block.color);

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: PieVisuals.surface,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => onTap(block),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        gradient: LinearGradient(colors: colors),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  block.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: PieVisuals.foreground,
                                  ),
                                ),
                              ),
                              if (block.isLocked)
                                const Icon(
                                  Icons.lock,
                                  size: 16,
                                  color: PieVisuals.subForeground,
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$start - $end  ·  ${block.durationMinutes}m',
                            style: const TextStyle(
                              fontSize: 12,
                              color: PieVisuals.subForeground,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: PieVisuals.subForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(growable: false),
    );
  }
}
