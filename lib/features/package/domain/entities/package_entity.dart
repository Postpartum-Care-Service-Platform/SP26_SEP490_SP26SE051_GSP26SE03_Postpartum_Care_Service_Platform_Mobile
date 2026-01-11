import 'package:equatable/equatable.dart';

/// Package entity - Domain layer
class PackageEntity extends Equatable {
  final int id;
  final String packageName;
  final String description;
  final int durationDays;
  final double basePrice;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PackageEntity({
    required this.id,
    required this.packageName,
    required this.description,
    required this.durationDays,
    required this.basePrice,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

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
