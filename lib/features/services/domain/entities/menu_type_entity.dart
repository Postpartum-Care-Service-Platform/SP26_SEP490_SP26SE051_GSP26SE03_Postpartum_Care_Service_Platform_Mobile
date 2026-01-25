import 'package:equatable/equatable.dart';

/// Menu Type Entity - Domain layer
class MenuTypeEntity extends Equatable {
  final int id;
  final String name;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MenuTypeEntity({
    required this.id,
    required this.name,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        isActive,
        createdAt,
        updatedAt,
      ];
}
