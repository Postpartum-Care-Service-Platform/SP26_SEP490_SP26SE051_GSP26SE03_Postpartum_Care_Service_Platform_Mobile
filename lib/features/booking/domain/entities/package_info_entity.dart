import 'package:equatable/equatable.dart';

/// Package Info Entity - Domain layer (simplified package info in booking)
class PackageInfoEntity extends Equatable {
  final int id;
  final String packageName;
  final int durationDays;
  final double basePrice;
  final String roomTypeName;

  const PackageInfoEntity({
    required this.id,
    required this.packageName,
    required this.durationDays,
    required this.basePrice,
    required this.roomTypeName,
  });

  @override
  List<Object?> get props => [
        id,
        packageName,
        durationDays,
        basePrice,
        roomTypeName,
      ];
}
