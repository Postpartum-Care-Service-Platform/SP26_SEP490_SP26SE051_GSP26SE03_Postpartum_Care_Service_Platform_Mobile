// lib/features/meal_plan/domain/entities/daily_meal_plan.dart
import 'package:equatable/equatable.dart';

import 'meal_item.dart';
import 'meal_slot.dart';

/// DailyMealPlan
/// - Represents a family's meal plan for a specific date.
class DailyMealPlan extends Equatable {
  final String id;
  final String familyId;
  final DateTime date;
  final Map<MealSlot, List<MealItem>> slots;

  const DailyMealPlan({
    required this.id,
    required this.familyId,
    required this.date,
    required this.slots,
  });

  /// Creates an empty plan for a family on a specific date.
  factory DailyMealPlan.empty({
    required String familyId,
    required DateTime date,
  }) {
    return DailyMealPlan(
      id: '${date.toIso8601String()}-$familyId',
      familyId: familyId,
      date: date,
      slots: {
        for (final slot in MealSlot.values) slot: <MealItem>[],
      },
    );
  }

  /// Adds a meal item to a specific slot.
  DailyMealPlan addMealToSlot(MealSlot slot, MealItem meal) {
    final updatedSlots = Map<MealSlot, List<MealItem>>.from(slots);
    updatedSlots[slot] = [...slots[slot] ?? [], meal];
    
    return copyWith(slots: updatedSlots);
  }

  /// Removes a meal item from a specific slot.
  DailyMealPlan removeMealFromSlot(MealSlot slot, String mealId) {
    final updatedSlots = Map<MealSlot, List<MealItem>>.from(slots);
    updatedSlots[slot] = [...slots[slot] ?? []]..removeWhere((m) => m.id == mealId);
    
    return copyWith(slots: updatedSlots);
  }

  /// Moves a meal item from one slot to another.
  DailyMealPlan moveMeal({
    required MealSlot fromSlot,
    required String mealId,
    required MealSlot toSlot,
  }) {
    final updatedSlots = Map<MealSlot, List<MealItem>>.from(slots);
    final meal = updatedSlots[fromSlot]?.firstWhere((m) => m.id == mealId);
    
    if (meal != null) {
      updatedSlots[fromSlot] = [...slots[fromSlot] ?? []]..removeWhere((m) => m.id == mealId);
      updatedSlots[toSlot] = [...slots[toSlot] ?? [], meal];
    }
    
    return copyWith(slots: updatedSlots);
  }

  /// Creates a copy of this plan with the given fields updated.
  DailyMealPlan copyWith({
    String? id,
    String? familyId,
    DateTime? date,
    Map<MealSlot, List<MealItem>>? slots,
  }) {
    return DailyMealPlan(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      date: date ?? this.date,
      slots: slots ?? this.slots,
    );
  }

  @override
  List<Object?> get props => [id, familyId, date, slots];
}