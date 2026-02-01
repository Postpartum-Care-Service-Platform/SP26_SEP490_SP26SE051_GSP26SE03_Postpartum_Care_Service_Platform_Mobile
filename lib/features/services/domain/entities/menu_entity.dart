import 'package:equatable/equatable.dart';
import 'food_entity.dart';

/// Menu Entity - Domain layer
class MenuEntity extends Equatable {
  final int id;
  final int menuTypeId;
  final String menuTypeName;
  final String menuName;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<FoodEntity> foods;

  const MenuEntity({
    required this.id,
    required this.menuTypeId,
    required this.menuTypeName,
    required this.menuName,
    this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.foods = const [],
  });

  @override
  List<Object?> get props => [
        id,
        menuTypeId,
        menuTypeName,
        menuName,
        description,
        isActive,
        createdAt,
        updatedAt,
        foods,
      ];
}
