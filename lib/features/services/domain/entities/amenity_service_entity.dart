import 'package:equatable/equatable.dart';

/// Amenity Service Entity - Domain layer
class AmenityServiceEntity extends Equatable {
  final int id;
  final String managerId;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final String? imageUrl;
  final int duration; // Duration in minutes

  const AmenityServiceEntity({
    required this.id,
    required this.managerId,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    this.imageUrl,
    required this.duration,
  });

  @override
  List<Object?> get props => [
        id,
        managerId,
        name,
        description,
        createdAt,
        updatedAt,
        isActive,
        imageUrl,
        duration,
      ];
}
