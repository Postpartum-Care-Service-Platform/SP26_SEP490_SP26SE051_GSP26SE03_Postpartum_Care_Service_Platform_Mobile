import 'package:equatable/equatable.dart';
import '../../domain/entities/menu_entity.dart';
import '../../domain/entities/menu_type_entity.dart';
import '../../domain/entities/menu_record_entity.dart';

/// Menu States
abstract class MenuState extends Equatable {
  const MenuState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class MenuInitial extends MenuState {
  const MenuInitial();
}

/// Loading state
class MenuLoading extends MenuState {
  const MenuLoading();
}

/// Loaded state
class MenuLoaded extends MenuState {
  final List<MenuEntity> menus;
  final List<MenuTypeEntity> menuTypes;
  final List<MenuRecordEntity> myMenuRecords;
  final Map<DateTime, List<MenuRecordEntity>> menuRecordsByDate;

  const MenuLoaded({
    required this.menus,
    required this.menuTypes,
    required this.myMenuRecords,
    this.menuRecordsByDate = const {},
  });

  @override
  List<Object?> get props => [
        menus,
        menuTypes,
        myMenuRecords,
        menuRecordsByDate,
      ];

  MenuLoaded copyWith({
    List<MenuEntity>? menus,
    List<MenuTypeEntity>? menuTypes,
    List<MenuRecordEntity>? myMenuRecords,
    Map<DateTime, List<MenuRecordEntity>>? menuRecordsByDate,
  }) {
    return MenuLoaded(
      menus: menus ?? this.menus,
      menuTypes: menuTypes ?? this.menuTypes,
      myMenuRecords: myMenuRecords ?? this.myMenuRecords,
      menuRecordsByDate: menuRecordsByDate ?? this.menuRecordsByDate,
    );
  }
}

/// Error state
class MenuError extends MenuState {
  final String message;

  const MenuError(this.message);

  @override
  List<Object?> get props => [message];
}
