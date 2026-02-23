import '../../domain/entities/amenity_service_entity.dart';
import '../../../../core/utils/app_date_time_utils.dart';

/// Amenity Service Model - Data layer
class AmenityServiceModel extends AmenityServiceEntity {
  const AmenityServiceModel({
    required super.id,
    required super.managerId,
    required super.name,
    required super.description,
    required super.createdAt,
    required super.updatedAt,
    required super.isActive,
    super.imageUrl,
    required super.duration,
  });

  /// Create from JSON
  factory AmenityServiceModel.fromJson(Map<String, dynamic> json) {
    return AmenityServiceModel(
      id: json['id'] as int,
      managerId: json['managerId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      createdAt: AppDateTimeUtils.parseToVietnamTime(json['createdAt'] as String) ??
          DateTime.now(),
      updatedAt: AppDateTimeUtils.parseToVietnamTime(json['updatedAt'] as String) ??
          DateTime.now(),
      isActive: json['isActive'] as bool,
      imageUrl: json['imageUrl'] as String?,
      duration: int.tryParse(json['duration'] as String? ?? '0') ?? 0,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'managerId': managerId,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'imageUrl': imageUrl,
      'duration': duration.toString(),
    };
  }

  /// Convert to Entity
  AmenityServiceEntity toEntity() {
    return AmenityServiceEntity(
      id: id,
      managerId: managerId,
      name: name,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: isActive,
      imageUrl: imageUrl,
      duration: duration,
    );
  }
}
