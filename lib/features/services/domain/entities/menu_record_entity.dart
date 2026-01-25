import 'package:equatable/equatable.dart';

/// Menu Record Entity - Domain layer
/// Represents a menu selection by customer for a specific date
class MenuRecordEntity extends Equatable {
  final int id;
  final String accountId;
  final int menuId;
  final String name;
  final DateTime date;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MenuRecordEntity({
    required this.id,
    required this.accountId,
    required this.menuId,
    required this.name,
    required this.date,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        accountId,
        menuId,
        name,
        date,
        isActive,
        createdAt,
        updatedAt,
      ];
}
