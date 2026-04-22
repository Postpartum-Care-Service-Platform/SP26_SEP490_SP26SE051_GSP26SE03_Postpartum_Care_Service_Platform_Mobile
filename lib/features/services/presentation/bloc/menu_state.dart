import 'package:equatable/equatable.dart';
import '../../domain/entities/menu_entity.dart';
import '../../domain/entities/menu_type_entity.dart';
import '../../domain/entities/menu_record_entity.dart';
import '../../domain/entities/food_entity.dart';

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
  final List<MenuEntity> customizedMenus;
  final List<FoodEntity> foods;
  final Map<DateTime, List<MenuRecordEntity>> menuRecordsByDate;

  const MenuLoaded({
    required this.menus,
    required this.menuTypes,
    required this.myMenuRecords,
    this.customizedMenus = const [],
    this.foods = const [],
    this.menuRecordsByDate = const {},
  });

  @override
  List<Object?> get props => [
        menus,
        menuTypes,
        myMenuRecords,
        customizedMenus,
        foods,
        menuRecordsByDate,
      ];

  MenuLoaded copyWith({
    List<MenuEntity>? menus,
    List<MenuTypeEntity>? menuTypes,
    List<MenuRecordEntity>? myMenuRecords,
    List<MenuEntity>? customizedMenus,
    List<FoodEntity>? foods,
    Map<DateTime, List<MenuRecordEntity>>? menuRecordsByDate,
  }) {
    return MenuLoaded(
      menus: menus ?? this.menus,
      menuTypes: menuTypes ?? this.menuTypes,
      myMenuRecords: myMenuRecords ?? this.myMenuRecords,
      customizedMenus: customizedMenus ?? this.customizedMenus,
      foods: foods ?? this.foods,
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

/// Success state for custom menu creation
class CustomizedMenuCreateSuccess extends MenuLoaded {
  final MenuEntity newMenu;

  const CustomizedMenuCreateSuccess({
    required this.newMenu,
    required super.menus,
    required super.menuTypes,
    required super.myMenuRecords,
    super.customizedMenus,
    super.foods,
    super.menuRecordsByDate,
  });

  @override
  List<Object?> get props => [...super.props, newMenu];
}
