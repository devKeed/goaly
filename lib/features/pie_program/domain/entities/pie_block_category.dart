enum PieBlockCategory {
  sleep,
  work,
  focus,
  fitness,
  meals,
  commute,
  personal,
  leisure,
  other,
}

extension PieBlockCategoryX on PieBlockCategory {
  String get label {
    switch (this) {
      case PieBlockCategory.sleep:
        return 'Sleep';
      case PieBlockCategory.work:
        return 'Work';
      case PieBlockCategory.focus:
        return 'Focus';
      case PieBlockCategory.fitness:
        return 'Fitness';
      case PieBlockCategory.meals:
        return 'Meals';
      case PieBlockCategory.commute:
        return 'Commute';
      case PieBlockCategory.personal:
        return 'Personal';
      case PieBlockCategory.leisure:
        return 'Leisure';
      case PieBlockCategory.other:
        return 'Other';
    }
  }

  double get productivityWeight {
    switch (this) {
      case PieBlockCategory.work:
      case PieBlockCategory.focus:
        return 1.0;
      case PieBlockCategory.fitness:
        return 0.65;
      case PieBlockCategory.sleep:
      case PieBlockCategory.meals:
        return 0.45;
      case PieBlockCategory.personal:
      case PieBlockCategory.commute:
      case PieBlockCategory.leisure:
      case PieBlockCategory.other:
        return 0.25;
    }
  }
}
