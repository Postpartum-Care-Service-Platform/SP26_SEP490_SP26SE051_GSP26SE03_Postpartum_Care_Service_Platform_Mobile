/// Amenity Service Entity
/// Domain model for amenity service data
class AmenityServiceEntity {
  /// Service ID
  final int id;
  
  /// Service name
  final String name;
  
  /// Service description
  final String? description;
  
  /// Created at timestamp
  final DateTime createdAt;
  
  /// Updated at timestamp
  final DateTime updatedAt;
  
  /// Is active
  final bool isActive;

  const AmenityServiceEntity({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  /// Create a copy with updated fields
  AmenityServiceEntity copyWith({
    int? id,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return AmenityServiceEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
