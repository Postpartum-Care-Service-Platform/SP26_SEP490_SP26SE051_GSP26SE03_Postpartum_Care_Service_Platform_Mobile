import 'package:equatable/equatable.dart';
import '../../domain/entities/menu_record_entity.dart';

/// Menu Events
abstract class MenuEvent extends Equatable {
  const MenuEvent();

  @override
  List<Object?> get props => [];
}

/// Load menus event
class MenuLoadRequested extends MenuEvent {
  const MenuLoadRequested();
}

/// Load menu types event
class MenuTypesLoadRequested extends MenuEvent {
  const MenuTypesLoadRequested();
}

/// Load my menu records event
class MyMenuRecordsLoadRequested extends MenuEvent {
  const MyMenuRecordsLoadRequested();
}

/// Load my menu records by date event
class MyMenuRecordsByDateLoadRequested extends MenuEvent {
  final DateTime date;

  const MyMenuRecordsByDateLoadRequested(this.date);

  @override
  List<Object?> get props => [date];
}

/// Create menu records event
class MenuRecordsCreateRequested extends MenuEvent {
  final List<CreateMenuRecordRequest> requests;

  const MenuRecordsCreateRequested(this.requests);

  @override
  List<Object?> get props => [requests];
}

/// Update menu records event
class MenuRecordsUpdateRequested extends MenuEvent {
  final List<UpdateMenuRecordRequest> requests;

  const MenuRecordsUpdateRequested(this.requests);

  @override
  List<Object?> get props => [requests];
}

/// Delete menu record event
class MenuRecordDeleteRequested extends MenuEvent {
  final int id;

  const MenuRecordDeleteRequested(this.id);

  @override
  List<Object?> get props => [id];
}

/// Save menu records event (create or update based on existing records)
class MenuRecordsSaveRequested extends MenuEvent {
  final List<SaveMenuRecordRequest> requests;
  final List<MenuRecordEntity> existingRecords;

  const MenuRecordsSaveRequested({
    required this.requests,
    required this.existingRecords,
  });

  @override
  List<Object?> get props => [requests, existingRecords];
}

/// Refresh event
class MenuRefresh extends MenuEvent {
  const MenuRefresh();
}

/// Request model for creating menu records
class CreateMenuRecordRequest extends Equatable {
  final int menuId;
  final String name;
  final DateTime date;

  const CreateMenuRecordRequest({
    required this.menuId,
    required this.name,
    required this.date,
  });

  @override
  List<Object?> get props => [menuId, name, date];
}

/// Request model for updating menu records
class UpdateMenuRecordRequest extends Equatable {
  final int id;
  final int menuId;
  final String name;
  final DateTime date;

  const UpdateMenuRecordRequest({
    required this.id,
    required this.menuId,
    required this.name,
    required this.date,
  });

  @override
  List<Object?> get props => [id, menuId, name, date];
}

/// Request model for saving menu records (can be create or update)
class SaveMenuRecordRequest extends Equatable {
  final int? id; // null for create, not null for update
  final int menuId;
  final String name;
  final DateTime date;

  const SaveMenuRecordRequest({
    this.id,
    required this.menuId,
    required this.name,
    required this.date,
  });

  @override
  List<Object?> get props => [id, menuId, name, date];
}
