import 'package:equatable/equatable.dart';

/// Package Type entity - Domain layer
class PackageTypeEntity extends Equatable {
  final int id;
  final String name;
  final bool isActive;

  const PackageTypeEntity({
    required this.id,
    required this.name,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id, name, isActive];
}
