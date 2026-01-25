import '../../domain/entities/food_entity.dart';

/// Food Model - Data layer
class FoodModel extends FoodEntity {
  const FoodModel({
    required super.id,
    required super.name,
    required super.type,
    super.description,
    super.imageUrl,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  factory FoodModel.fromJson(Map<String, dynamic> json) {
    return FoodModel(
      id: json['id'] as int,
      name: json['name'] as String,
      type: json['type'] as String,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'description': description,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
