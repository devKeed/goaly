import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../domain/entities/pie_block_category.dart';

class PieVisuals {
  static const Color surface = AppColors.background;
  static const Color foreground = AppColors.textPrimary;
  static const Color subForeground = AppColors.textSecondary;

  static List<Color> gradientForCategory(PieBlockCategory category, int fallbackColor) {
    switch (category) {
      case PieBlockCategory.sleep:
        return const [Color(0xFF6C5CE7), Color(0xFFA29BFE)];
      case PieBlockCategory.work:
        return const [Color(0xFF00C9A7), Color(0xFF55EFC4)];
      case PieBlockCategory.focus:
        return const [Color(0xFF4A90D9), Color(0xFF74B9FF)];
      case PieBlockCategory.fitness:
        return const [Color(0xFFFF6B9D), Color(0xFFFFB8D0)];
      case PieBlockCategory.meals:
        return const [Color(0xFFFF9F43), Color(0xFFFFD4A8)];
      case PieBlockCategory.commute:
        return const [Color(0xFF6D4C41), Color(0xFFA1887F)];
      case PieBlockCategory.personal:
        return const [Color(0xFFFFC312), Color(0xFFFFE082)];
      case PieBlockCategory.leisure:
        return const [Color(0xFFA29BFE), Color(0xFFD4CCFF)];
      case PieBlockCategory.other:
        final base = Color(fallbackColor);
        return [base.withValues(alpha: 0.92), base.withValues(alpha: 0.65)];
    }
  }
}
