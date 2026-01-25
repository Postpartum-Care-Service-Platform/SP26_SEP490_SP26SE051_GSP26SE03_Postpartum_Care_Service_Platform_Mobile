import '../../domain/entities/menu_entity.dart';
import 'food_model.dart';

/// Menu Model - Data layer
class MenuModel extends MenuEntity {
  const MenuModel({
    required super.id,
    required super.menuTypeId,
    required super.menuTypeName,
    required super.menuName,
    super.description,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
    super.foods = const [],
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    final foodsList = json['foods'] as List<dynamic>? ?? [];
    return MenuModel(
      id: json['id'] as int,
      menuTypeId: json['menuTypeId'] as int,
      menuTypeName: json['menuTypeName'] as String,
      menuName: json['menuName'] as String,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      foods: foodsList
          .map((food) => FoodModel.fromJson(food as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'menuTypeId': menuTypeId,
      'menuTypeName': menuTypeName,
      'menuName': menuName,
      'description': description,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'foods': foods.map((food) => (food as FoodModel).toJson()).toList(),
    };
  }
}
