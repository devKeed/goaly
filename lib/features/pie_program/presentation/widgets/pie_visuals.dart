import 'package:flutter/material.dart';

import '../../domain/entities/pie_block_category.dart';

class PieVisuals {
  static const Color surface = Color(0xFFF4F7FB);
  static const Color foreground = Color(0xFF10212E);
  static const Color subForeground = Color(0xFF5B6C7A);

  static List<Color> gradientForCategory(PieBlockCategory category, int fallbackColor) {
    switch (category) {
      case PieBlockCategory.sleep:
        return const [Color(0xFF3F51B5), Color(0xFF7986CB)];
      case PieBlockCategory.work:
        return const [Color(0xFF00897B), Color(0xFF26A69A)];
      case PieBlockCategory.focus:
        return const [Color(0xFF1976D2), Color(0xFF42A5F5)];
      case PieBlockCategory.fitness:
        return const [Color(0xFFD81B60), Color(0xFFEC407A)];
      case PieBlockCategory.meals:
        return const [Color(0xFFEF6C00), Color(0xFFFFA726)];
      case PieBlockCategory.commute:
        return const [Color(0xFF6D4C41), Color(0xFF8D6E63)];
      case PieBlockCategory.personal:
        return const [Color(0xFFF9A825), Color(0xFFFFD54F)];
      case PieBlockCategory.leisure:
        return const [Color(0xFF7B1FA2), Color(0xFFAB47BC)];
      case PieBlockCategory.other:
        final base = Color(fallbackColor);
        return [base.withValues(alpha: 0.92), base.withValues(alpha: 0.65)];
    }
  }
}
