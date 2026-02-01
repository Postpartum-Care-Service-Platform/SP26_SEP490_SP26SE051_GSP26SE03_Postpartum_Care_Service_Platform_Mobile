import '../../domain/entities/menu_type_entity.dart';

/// Menu Type Model - Data layer
class MenuTypeModel extends MenuTypeEntity {
  const MenuTypeModel({
    required super.id,
    required super.name,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  factory MenuTypeModel.fromJson(Map<String, dynamic> json) {
    return MenuTypeModel(
      id: json['id'] as int,
      name: json['name'] as String,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
