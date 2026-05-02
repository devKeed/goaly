import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class ActivityRingSpec {
  const ActivityRingSpec({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.label,
    required this.value,
  });

  final double progress;
  final Color color;
  final Color trackColor;
  final String label;
  final String value;
}

class ActivityRingGroup extends StatelessWidget {
  const ActivityRingGroup({
    super.key,
    required this.rings,
    this.size = 188,
    this.strokeWidth = 15,
    this.center,
  });

  final List<ActivityRingSpec> rings;
  final double size;
  final double strokeWidth;
  final Widget? center;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _ActivityRingPainter(
              rings: rings,
              strokeWidth: strokeWidth,
            ),
          ),
          if (center != null) center!,
        ],
      ),
    );
  }
}

class _ActivityRingPainter extends CustomPainter {
  _ActivityRingPainter({required this.rings, required this.strokeWidth});

  final List<ActivityRingSpec> rings;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final gap = strokeWidth + 7;

    for (var i = 0; i < rings.length; i++) {
      final ring = rings[i];
      final radius = maxRadius - (i * gap);
      if (radius <= strokeWidth) continue;

      final rect = Rect.fromCircle(center: center, radius: radius);
      final trackPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = ring.trackColor;
      final progressPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = ring.color;

      canvas.drawArc(rect, -math.pi / 2, math.pi * 2, false, trackPaint);
      canvas.drawArc(
        rect,
        -math.pi / 2,
        math.pi * 2 * ring.progress.clamp(0.0, 1.0),
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ActivityRingPainter oldDelegate) {
    return oldDelegate.rings != rings || oldDelegate.strokeWidth != strokeWidth;
  }
}

class RingLegend extends StatelessWidget {
  const RingLegend({super.key, required this.rings});

  final List<ActivityRingSpec> rings;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: rings
          .map(
            (ring) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: ring.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      ring.label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    ring.value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class FitnessPanel extends StatelessWidget {
  const FitnessPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.margin,
    this.color = AppColors.surface,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final panel = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.subtleDivider),
      ),
      child: child,
    );

    if (onTap == null) return panel;

    return GestureDetector(onTap: onTap, child: panel);
  }
}

class FitnessMetricTile extends StatelessWidget {
  const FitnessMetricTile({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    this.subtitle,
  });

  final String label;
  final String value;
  final String? subtitle;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return FitnessPanel(
      color: AppColors.surfaceElevated,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 19),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                height: 0.95,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class FitnessHeader extends StatelessWidget {
  const FitnessHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(20, 16, 20, 10),
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subtitle != null) ...[
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 34,
                    height: 1.02,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class FitnessEmptyState extends StatelessWidget {
  const FitnessEmptyState({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: FitnessPanel(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 31),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.35,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
