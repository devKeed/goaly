import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import 'pie_visuals.dart';

class PieCenterPanel extends StatelessWidget {
  const PieCenterPanel({
    super.key,
    required this.currentTime,
    required this.currentTask,
    required this.countdown,
    required this.microText,
  });

  final String currentTime;
  final String currentTask;
  final String countdown;
  final String microText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 182,
      height: 182,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surface,
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            currentTime,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: PieVisuals.foreground,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            currentTask,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: PieVisuals.foreground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            countdown,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: PieVisuals.subForeground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            microText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: PieVisuals.subForeground.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
