// lib/features/meal_plan/domain/entities/meal_slot.dart

/// MealSlot
/// - Slots for a daily meal plan.
enum MealSlot {
  breakfast,
  lunch,
  dinner,
  snack,
}

extension MealSlotX on MealSlot {
  String get labelVi {
    switch (this) {
      case MealSlot.breakfast:
        return 'Bữa sáng';
      case MealSlot.lunch:
        return 'Bữa trưa';
      case MealSlot.dinner:
        return 'Bữa tối';
      case MealSlot.snack:
        return 'Bữa phụ';
    }
  }

  String get key {
    switch (this) {
      case MealSlot.breakfast:
        return 'breakfast';
      case MealSlot.lunch:
        return 'lunch';
      case MealSlot.dinner:
        return 'dinner';
      case MealSlot.snack:
        return 'snack';
    }
  }
}
