import '../../domain/entities/amenity_service_entity.dart';

/// AmenityService Data Model
/// Maps to API response structure
class AmenityServiceModel {
  final int id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final String? imageUrl;
  final String? duration;

  AmenityServiceModel({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.duration,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  /// Convert from JSON
  factory AmenityServiceModel.fromJson(Map<String, dynamic> json) {
    return AmenityServiceModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      duration: json['duration']?.toString(), // Ensure it's a string
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'duration': duration,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  /// Convert to Entity
  AmenityServiceEntity toEntity() {
    return AmenityServiceEntity(
      id: id,
      name: name,
      description: description,
      imageUrl: imageUrl,
      duration: duration,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: isActive,
    );
  }

  /// Create from Entity
  factory AmenityServiceModel.fromEntity(AmenityServiceEntity entity) {
    return AmenityServiceModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      imageUrl: entity.imageUrl,
      duration: entity.duration,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isActive: entity.isActive,
    );
  }
}
