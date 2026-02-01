import '../../domain/entities/menu_record_entity.dart';

/// Menu Record Model - Data layer
class MenuRecordModel extends MenuRecordEntity {
  const MenuRecordModel({
    required super.id,
    required super.accountId,
    required super.menuId,
    required super.name,
    required super.date,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  factory MenuRecordModel.fromJson(Map<String, dynamic> json) {
    return MenuRecordModel(
      id: json['id'] as int,
      accountId: json['accountId'] as String,
      menuId: json['menuId'] as int,
      name: json['name'] as String,
      date: DateTime.parse(json['date'] as String),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountId': accountId,
      'menuId': menuId,
      'name': name,
      'date': date.toIso8601String().split('T')[0],
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
