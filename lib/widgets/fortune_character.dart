import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum CharacterMood { happy, excited, sleepy, sad, waving }

class FortuneCharacter extends StatelessWidget {
  final double size;
  final CharacterMood mood;
  final Color? bodyColor;
  final Color? accentColor;

  const FortuneCharacter({
    super.key,
    this.size = 80,
    this.mood = CharacterMood.happy,
    this.bodyColor,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CharacterPainter(
          mood: mood,
          bodyColor: bodyColor ?? AppColors.accent,
          accentColor: accentColor ?? AppColors.primary,
        ),
      ),
    );
  }
}

class _CharacterPainter extends CustomPainter {
  final CharacterMood mood;
  final Color bodyColor;
  final Color accentColor;

  _CharacterPainter({
    required this.mood,
    required this.bodyColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final bodySize = size.width * 0.42;

    // Body — rounded square
    final bodyPaint = Paint()..color = bodyColor;
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + size.height * 0.02),
        width: bodySize * 1.8,
        height: bodySize * 1.6,
      ),
      Radius.circular(bodySize * 0.45),
    );
    canvas.drawRRect(bodyRect, bodyPaint);

    // Legs
    final legPaint = Paint()
      ..color = bodyColor
      ..strokeWidth = size.width * 0.07
      ..strokeCap = StrokeCap.round;

    final bodyBottom = center.dy + bodySize * 0.82;
    // Left leg
    canvas.drawLine(
      Offset(center.dx - bodySize * 0.4, bodyBottom),
      Offset(center.dx - bodySize * 0.45, bodyBottom + size.height * 0.12),
      legPaint,
    );
    // Right leg
    canvas.drawLine(
      Offset(center.dx + bodySize * 0.4, bodyBottom),
      Offset(center.dx + bodySize * 0.45, bodyBottom + size.height * 0.12),
      legPaint,
    );

    // Feet (small circles)
    final feetPaint = Paint()..color = accentColor;
    canvas.drawCircle(
      Offset(center.dx - bodySize * 0.45, bodyBottom + size.height * 0.14),
      size.width * 0.05,
      feetPaint,
    );
    canvas.drawCircle(
      Offset(center.dx + bodySize * 0.45, bodyBottom + size.height * 0.14),
      size.width * 0.05,
      feetPaint,
    );

    // Arms
    final armPaint = Paint()
      ..color = bodyColor
      ..strokeWidth = size.width * 0.06
      ..strokeCap = StrokeCap.round;

    final armY = center.dy + size.height * 0.02;

    if (mood == CharacterMood.waving) {
      // Left arm — resting
      canvas.drawLine(
        Offset(center.dx - bodySize * 0.88, armY),
        Offset(center.dx - bodySize * 1.1, armY + size.height * 0.1),
        armPaint,
      );
      // Right arm — waving up
      canvas.drawLine(
        Offset(center.dx + bodySize * 0.88, armY),
        Offset(center.dx + bodySize * 1.15, armY - size.height * 0.18),
        armPaint,
      );
      // Hand
      canvas.drawCircle(
        Offset(center.dx + bodySize * 1.15, armY - size.height * 0.2),
        size.width * 0.04,
        feetPaint,
      );
    } else if (mood == CharacterMood.excited) {
      // Both arms up
      canvas.drawLine(
        Offset(center.dx - bodySize * 0.88, armY),
        Offset(center.dx - bodySize * 1.1, armY - size.height * 0.18),
        armPaint,
      );
      canvas.drawLine(
        Offset(center.dx + bodySize * 0.88, armY),
        Offset(center.dx + bodySize * 1.1, armY - size.height * 0.18),
        armPaint,
      );
    } else {
      // Arms resting down
      canvas.drawLine(
        Offset(center.dx - bodySize * 0.88, armY),
        Offset(center.dx - bodySize * 1.05, armY + size.height * 0.12),
        armPaint,
      );
      canvas.drawLine(
        Offset(center.dx + bodySize * 0.88, armY),
        Offset(center.dx + bodySize * 1.05, armY + size.height * 0.12),
        armPaint,
      );
    }

    // Face — eyes
    final eyePaint = Paint()..color = Colors.white;
    final pupilPaint = Paint()..color = const Color(0xFF1A1B2E);
    final eyeY = center.dy - size.height * 0.04;
    final eyeSpacing = bodySize * 0.35;
    final eyeRadius = size.width * 0.075;

    // Eye whites
    canvas.drawCircle(
      Offset(center.dx - eyeSpacing, eyeY),
      eyeRadius,
      eyePaint,
    );
    canvas.drawCircle(
      Offset(center.dx + eyeSpacing, eyeY),
      eyeRadius,
      eyePaint,
    );

    if (mood == CharacterMood.sleepy) {
      // Sleepy — line eyes
      final sleepPaint = Paint()
        ..color = const Color(0xFF1A1B2E)
        ..strokeWidth = size.width * 0.03
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(center.dx - eyeSpacing - eyeRadius * 0.6, eyeY),
        Offset(center.dx - eyeSpacing + eyeRadius * 0.6, eyeY),
        sleepPaint,
      );
      canvas.drawLine(
        Offset(center.dx + eyeSpacing - eyeRadius * 0.6, eyeY),
        Offset(center.dx + eyeSpacing + eyeRadius * 0.6, eyeY),
        sleepPaint,
      );
    } else {
      // Normal pupils
      final pupilOffset = mood == CharacterMood.excited
          ? const Offset(0, -1)
          : Offset.zero;
      canvas.drawCircle(
        Offset(center.dx - eyeSpacing + pupilOffset.dx,
            eyeY + pupilOffset.dy),
        eyeRadius * 0.55,
        pupilPaint,
      );
      canvas.drawCircle(
        Offset(center.dx + eyeSpacing + pupilOffset.dx,
            eyeY + pupilOffset.dy),
        eyeRadius * 0.55,
        pupilPaint,
      );

      // Eye shine
      final shinePaint = Paint()..color = Colors.white;
      canvas.drawCircle(
        Offset(center.dx - eyeSpacing + eyeRadius * 0.2,
            eyeY - eyeRadius * 0.2),
        eyeRadius * 0.2,
        shinePaint,
      );
      canvas.drawCircle(
        Offset(center.dx + eyeSpacing + eyeRadius * 0.2,
            eyeY - eyeRadius * 0.2),
        eyeRadius * 0.2,
        shinePaint,
      );
    }

    // Mouth
    final mouthPaint = Paint()
      ..color = const Color(0xFF1A1B2E)
      ..strokeWidth = size.width * 0.025
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final mouthY = center.dy + size.height * 0.1;

    if (mood == CharacterMood.sad) {
      // Frown
      final mouthPath = Path()
        ..moveTo(center.dx - bodySize * 0.2, mouthY + size.height * 0.02)
        ..quadraticBezierTo(
          center.dx,
          mouthY - size.height * 0.03,
          center.dx + bodySize * 0.2,
          mouthY + size.height * 0.02,
        );
      canvas.drawPath(mouthPath, mouthPaint);
    } else if (mood == CharacterMood.excited) {
      // Big open smile
      mouthPaint.style = PaintingStyle.fill;
      final mouthPath = Path()
        ..moveTo(center.dx - bodySize * 0.25, mouthY - size.height * 0.01)
        ..quadraticBezierTo(
          center.dx,
          mouthY + size.height * 0.08,
          center.dx + bodySize * 0.25,
          mouthY - size.height * 0.01,
        );
      canvas.drawPath(mouthPath, mouthPaint);
    } else {
      // Normal smile
      final mouthPath = Path()
        ..moveTo(center.dx - bodySize * 0.2, mouthY)
        ..quadraticBezierTo(
          center.dx,
          mouthY + size.height * 0.06,
          center.dx + bodySize * 0.2,
          mouthY,
        );
      canvas.drawPath(mouthPath, mouthPaint);
    }

    // Blush cheeks for happy/excited
    if (mood == CharacterMood.happy || mood == CharacterMood.excited) {
      final blushPaint = Paint()
        ..color = const Color(0xFFFF9F9F).withValues(alpha: 0.4);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center.dx - bodySize * 0.6, mouthY - size.height * 0.01),
          width: size.width * 0.09,
          height: size.width * 0.06,
        ),
        blushPaint,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center.dx + bodySize * 0.6, mouthY - size.height * 0.01),
          width: size.width * 0.09,
          height: size.width * 0.06,
        ),
        blushPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_CharacterPainter oldDelegate) =>
      mood != oldDelegate.mood ||
      bodyColor != oldDelegate.bodyColor ||
      accentColor != oldDelegate.accentColor;
}
