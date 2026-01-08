// lib/features/meal_plan/domain/entities/meal_item.dart
import 'package:flutter/foundation.dart';

/// MealItem
/// - Shared entity for both Family (planning) and Employee (view).
@immutable
class MealItem {
  final String id;
  final String name;
  final String description;

  const MealItem({
    required this.id,
    required this.name,
    required this.description,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is MealItem && other.id == id && other.name == name && other.description == description);
  }

  @override
  int get hashCode => Object.hash(id, name, description);
}
