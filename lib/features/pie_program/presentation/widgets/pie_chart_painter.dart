import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/entities/pie_time_block.dart';
import 'pie_visuals.dart';

class PieChartPainter extends CustomPainter {
  PieChartPainter({
    required this.blocks,
    required this.nowMinute,
    required this.activeBoundaryIndex,
    this.ringThickness = 58,
  });

  final List<PieTimeBlock> blocks;
  final int nowMinute;
  final int? activeBoundaryIndex;
  final double ringThickness;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final innerRadius = radius - ringThickness;

    final outerRect = Rect.fromCircle(center: center, radius: radius);
    final innerRect = Rect.fromCircle(center: center, radius: innerRadius);

    final basePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius + 4, Paint()..color = Colors.black.withValues(alpha: 0.06));
    canvas.drawCircle(center, radius, basePaint);

    for (int index = 0; index < blocks.length; index++) {
      final block = blocks[index];
      final start = _minuteToRadians(block.startMinuteOfDay);
      final sweep = (block.durationMinutes / (24 * 60)) * 2 * math.pi;

      final path = Path()
        ..arcTo(outerRect, start, sweep, false)
        ..arcTo(innerRect, start + sweep, -sweep, false)
        ..close();

      final colors = PieVisuals.gradientForCategory(block.category, block.color);
      final fillPaint = Paint()
        ..style = PaintingStyle.fill
        ..shader = SweepGradient(
          startAngle: start,
          endAngle: start + sweep,
          colors: colors,
        ).createShader(outerRect);

      canvas.drawShadow(path, Colors.black.withValues(alpha: 0.12), 6, false);
      canvas.drawPath(path, fillPaint);

      final dividerPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.88)
        ..strokeWidth = 2;
      final dividerStart = _offsetAt(center, innerRadius, start + sweep);
      final dividerEnd = _offsetAt(center, radius, start + sweep);
      canvas.drawLine(dividerStart, dividerEnd, dividerPaint);

      if (activeBoundaryIndex == index) {
        final highlightPaint = Paint()
          ..color = Colors.white
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(dividerStart, dividerEnd, highlightPaint);
      }
    }

    final indicatorAngle = _minuteToRadians(nowMinute);
    final indicatorPaint = Paint()
      ..color = const Color(0xFF0A1A2B)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    final indicatorInner = _offsetAt(center, innerRadius - 8, indicatorAngle);
    final indicatorOuter = _offsetAt(center, radius + 10, indicatorAngle);
    canvas.drawLine(indicatorInner, indicatorOuter, indicatorPaint);

    canvas.drawCircle(
      center,
      5,
      Paint()..color = const Color(0xFF0A1A2B),
    );
  }

  double _minuteToRadians(int minuteOfDay) {
    return ((minuteOfDay / (24 * 60)) * 2 * math.pi) - (math.pi / 2);
  }

  Offset _offsetAt(Offset center, double radius, double angle) {
    return Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );
  }

  @override
  bool shouldRepaint(covariant PieChartPainter oldDelegate) {
    return oldDelegate.blocks != blocks ||
        oldDelegate.nowMinute != nowMinute ||
        oldDelegate.activeBoundaryIndex != activeBoundaryIndex;
  }
}
