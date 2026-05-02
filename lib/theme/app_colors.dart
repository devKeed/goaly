import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Activity palette
  static const Color primary = Color(0xFFFF2D55);
  static const Color primaryLight = Color(0xFFFF6482);
  static const Color accent = Color(0xFFB6FF00);
  static const Color accentLight = Color(0xFFD6FF5C);
  static const Color schedule = Color(0xFF32D7FF);
  static const Color scheduleLight = Color(0xFF7CE9FF);
  static const Color steps = Color(0xFFB6FF00);
  static const Color stepsLight = Color(0xFFD8FF66);

  // Backgrounds
  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF141414);
  static const Color surfaceElevated = Color(0xFF1C1C1E);
  static const Color surfaceVariant = Color(0xFF2C2C2E);
  static const Color groupedBackground = Color(0xFF0A0A0A);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB6B6BB);
  static const Color textTertiary = Color(0xFF74747A);

  // Dark category surfaces / accents
  static const Color cardGreen = Color(0xFF1B2A10);
  static const Color cardGreenAccent = steps;
  static const Color cardPink = Color(0xFF2D1019);
  static const Color cardPinkAccent = primary;
  static const Color cardBlue = Color(0xFF0E2630);
  static const Color cardBlueAccent = schedule;
  static const Color cardOrange = Color(0xFF2D210C);
  static const Color cardOrangeAccent = Color(0xFFFFB340);
  static const Color cardPurple = Color(0xFF1F1833);
  static const Color cardPurpleAccent = Color(0xFFA98BFF);
  static const Color cardLavender = Color(0xFF191727);
  static const Color cardLavenderAccent = Color(0xFFC9B8FF);

  // Status colors
  static const Color statusTodo = Color(0xFF242428);
  static const Color statusTodoText = Color(0xFFD1D1D6);
  static const Color statusInProgress = Color(0xFF0E2630);
  static const Color statusInProgressText = schedule;
  static const Color statusDone = Color(0xFF1B2A10);
  static const Color statusDoneText = steps;

  // Utility
  static const Color error = Color(0xFFFF453A);
  static const Color divider = Color(0xFF2C2C2E);
  static const Color subtleDivider = Color(0xFF202023);

  // Navigation
  static const Color navIndicator = Color(0xFF261017);
  static const Color navUnselected = Color(0xFF8E8E93);
}
