import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../domain/entities/pie_block_category.dart';

class PieVisuals {
  static const Color surface = AppColors.surface;
  static const Color foreground = AppColors.textPrimary;
  static const Color subForeground = AppColors.textSecondary;

  static List<Color> gradientForCategory(
    PieBlockCategory category,
    int fallbackColor,
  ) {
    switch (category) {
      case PieBlockCategory.sleep:
        return const [Color(0xFF7C5CFF), Color(0xFFAB97FF)];
      case PieBlockCategory.work:
        return const [AppColors.steps, AppColors.stepsLight];
      case PieBlockCategory.focus:
        return const [AppColors.schedule, AppColors.scheduleLight];
      case PieBlockCategory.fitness:
        return const [AppColors.primary, AppColors.primaryLight];
      case PieBlockCategory.meals:
        return const [Color(0xFFFFB020), Color(0xFFFFD166)];
      case PieBlockCategory.commute:
        return const [Color(0xFF8A8A8A), Color(0xFFC2C2C2)];
      case PieBlockCategory.personal:
        return const [Color(0xFFE7F75E), Color(0xFFF4FF9B)];
      case PieBlockCategory.leisure:
        return const [Color(0xFFB88CFF), Color(0xFFD6BDFF)];
      case PieBlockCategory.other:
        final base = Color(fallbackColor);
        return [base.withValues(alpha: 0.92), base.withValues(alpha: 0.65)];
    }
  }
}
