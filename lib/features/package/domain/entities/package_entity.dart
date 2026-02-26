import 'package:equatable/equatable.dart';
import '../../../care_plan/domain/entities/care_plan_entity.dart';

/// Package entity - Domain layer
class PackageEntity extends Equatable {
  final int id;
  final String packageName;
  final String description;
  final int? packageTypeId;
  final String? packageTypeName;
  final String? imageUrl;
  final int? durationDays;
  final double basePrice;
  final bool isActive;
  final String? createdBy;
  final String? createdByName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<CarePlanEntity>? carePlanDetails;

  const PackageEntity({
    required this.id,
    required this.packageName,
    required this.description,
    this.packageTypeId,
    this.packageTypeName,
    this.imageUrl,
    this.durationDays,
    required this.basePrice,
    required this.isActive,
    this.createdBy,
    this.createdByName,
    required this.createdAt,
    required this.updatedAt,
    this.carePlanDetails,
  });

  @override
  List<Object?> get props => [
        id,
        packageName,
        description,
        packageTypeId,
        packageTypeName,
        imageUrl,
        durationDays,
        basePrice,
        isActive,
        createdBy,
        createdByName,
        createdAt,
        updatedAt,
        carePlanDetails,
      ];
}
