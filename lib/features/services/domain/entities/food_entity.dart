import 'package:equatable/equatable.dart';

/// Food Entity - Domain layer
class FoodEntity extends Equatable {
  final int id;
  final String name;
  final String type;
  final String? description;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FoodEntity({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    this.imageUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        description,
        imageUrl,
        isActive,
        createdAt,
        updatedAt,
      ];
}
