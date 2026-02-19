import 'package:equatable/equatable.dart';
import '../../domain/entities/package_type_entity.dart';

/// Package Type model - Data layer
class PackageTypeModel extends Equatable {
  final int id;
  final String name;
  final bool isActive;

  const PackageTypeModel({
    required this.id,
    required this.name,
    required this.isActive,
  });

  factory PackageTypeModel.fromJson(Map<String, dynamic> json) {
    return PackageTypeModel(
      id: json['id'] as int,
      name: json['name'] as String,
      isActive: json['isActive'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isActive': isActive,
    };
  }

  PackageTypeEntity toEntity() {
    return PackageTypeEntity(
      id: id,
      name: name,
      isActive: isActive,
    );
  }

  @override
  List<Object?> get props => [id, name, isActive];
}
