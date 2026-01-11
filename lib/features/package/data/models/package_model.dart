import 'package:equatable/equatable.dart';
import '../../domain/entities/package_entity.dart';

/// Package model - Data layer
class PackageModel extends Equatable {
  final int id;
  final String packageName;
  final String description;
  final int durationDays;
  final double basePrice;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PackageModel({
    required this.id,
    required this.packageName,
    required this.description,
    required this.durationDays,
    required this.basePrice,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: json['id'] as int,
      packageName: json['packageName'] as String,
      description: json['description'] as String,
      durationDays: json['durationDays'] as int,
      basePrice: (json['basePrice'] as num).toDouble(),
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'packageName': packageName,
      'description': description,
      'durationDays': durationDays,
      'basePrice': basePrice,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  PackageEntity toEntity() {
    return PackageEntity(
      id: id,
      packageName: packageName,
      description: description,
      durationDays: durationDays,
      basePrice: basePrice,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        packageName,
        description,
        durationDays,
        basePrice,
        isActive,
        createdAt,
        updatedAt,
      ];
}
