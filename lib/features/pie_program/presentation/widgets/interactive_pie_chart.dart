import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/pie_time_block.dart';
import 'pie_chart_painter.dart';

class InteractivePieChart extends StatefulWidget {
  const InteractivePieChart({
    super.key,
    required this.blocks,
    required this.now,
    required this.onBoundaryResize,
    required this.onBlockTap,
    required this.onBlockLongPress,
  });

  final List<PieTimeBlock> blocks;
  final DateTime now;
  final Future<bool> Function(int boundaryIndex, int deltaMinutes) onBoundaryResize;
  final ValueChanged<PieTimeBlock> onBlockTap;
  final ValueChanged<PieTimeBlock> onBlockLongPress;

  @override
  State<InteractivePieChart> createState() => _InteractivePieChartState();
}

class _InteractivePieChartState extends State<InteractivePieChart> {
  int? _activeBoundary;
  int? _previousMinute;
  bool _resizeInFlight = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final square = math.min(constraints.maxWidth, constraints.maxHeight);
        final size = Size.square(square);

        return SizedBox(
          width: square,
          height: square,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (details) {
              final minute = _minuteFromPosition(details.localPosition, size);
              if (minute == null) {
                return;
              }
              final block = _findBlockByMinute(minute);
              if (block != null) {
                widget.onBlockTap(block);
              }
            },
            onLongPressStart: (details) {
              final minute = _minuteFromPosition(details.localPosition, size);
              if (minute == null) {
                return;
              }
              final block = _findBlockByMinute(minute);
              if (block != null) {
                HapticFeedback.mediumImpact();
                widget.onBlockLongPress(block);
              }
            },
            onPanStart: (details) {
              final boundary = _closestBoundary(details.localPosition, size);
              if (boundary != null) {
                setState(() => _activeBoundary = boundary);
                _previousMinute = _minuteFromPosition(details.localPosition, size);
              }
            },
            onPanUpdate: (details) {
              final active = _activeBoundary;
              if (active == null) {
                return;
              }
              final minute = _minuteFromPosition(details.localPosition, size);
              if (minute == null) {
                return;
              }
              final previous = _previousMinute;
              _previousMinute = minute;
              if (previous == null) {
                return;
              }

              int delta = minute - previous;
              if (delta > 720) {
                delta -= 1440;
              } else if (delta < -720) {
                delta += 1440;
              }
              if (delta == 0 || _resizeInFlight) {
                return;
              }

              _resizeInFlight = true;
              unawaited(
                widget.onBoundaryResize(active, delta).then((accepted) {
                  if (!accepted) {
                    HapticFeedback.selectionClick();
                  } else {
                    HapticFeedback.lightImpact();
                  }
                }).whenComplete(() {
                  _resizeInFlight = false;
                }),
              );
            },
            onPanEnd: (_) {
              setState(() => _activeBoundary = null);
              _previousMinute = null;
            },
            child: RepaintBoundary(
              child: CustomPaint(
                painter: PieChartPainter(
                  blocks: widget.blocks,
                  nowMinute: widget.now.hour * 60 + widget.now.minute,
                  activeBoundaryIndex: _activeBoundary,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  PieTimeBlock? _findBlockByMinute(int minute) {
    for (final block in widget.blocks) {
      if (minute >= block.startMinuteOfDay && minute < block.endMinuteOfDay) {
        return block;
      }
    }
    return null;
  }

  int? _closestBoundary(Offset position, Size size) {
    if (widget.blocks.length < 2) {
      return null;
    }

    final center = size.center(Offset.zero);
    final vector = position - center;
    final distance = vector.distance;
    final radius = size.shortestSide / 2;
    final inner = radius - 58;

    if (distance < inner - 18 || distance > radius + 22) {
      return null;
    }

    final angle = _angleFromPosition(vector);
    int? bestIndex;
    double smallest = double.infinity;

    for (int i = 0; i < widget.blocks.length - 1; i++) {
      final boundaryMinute = widget.blocks[i].endMinuteOfDay;
      final boundaryAngle = (boundaryMinute / 1440.0) * 2 * math.pi;
      final delta = _angleDistance(angle, boundaryAngle);
      if (delta < smallest) {
        smallest = delta;
        bestIndex = i;
      }
    }

    if (smallest <= 0.2) {
      return bestIndex;
    }
    return null;
  }

  int? _minuteFromPosition(Offset position, Size size) {
    final center = size.center(Offset.zero);
    final vector = position - center;
    final distance = vector.distance;
    final radius = size.shortestSide / 2;
    final inner = radius - 58;

    if (distance < inner || distance > radius + 24) {
      return null;
    }

    final angle = _angleFromPosition(vector);
    return ((angle / (2 * math.pi)) * 1440).round() % 1440;
  }

  double _angleFromPosition(Offset vector) {
    final raw = math.atan2(vector.dy, vector.dx) + math.pi / 2;
    if (raw < 0) {
      return raw + 2 * math.pi;
    }
    return raw;
  }

  double _angleDistance(double a, double b) {
    final d = (a - b).abs();
    return math.min(d, (2 * math.pi) - d);
  }
}
