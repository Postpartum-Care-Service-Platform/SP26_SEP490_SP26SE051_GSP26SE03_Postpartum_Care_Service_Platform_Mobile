import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_menus_usecase.dart';
import '../../domain/usecases/get_menu_types_usecase.dart';
import '../../domain/usecases/get_my_menu_records_usecase.dart';
import '../../domain/usecases/get_my_menu_records_by_date_usecase.dart';
import '../../domain/usecases/create_menu_records_usecase.dart';
import '../../domain/usecases/update_menu_records_usecase.dart';
import '../../domain/usecases/delete_menu_record_usecase.dart';
import '../../domain/entities/menu_entity.dart';
import '../../domain/entities/menu_record_entity.dart';
import 'menu_event.dart';
import 'menu_state.dart';

/// Menu BloC
class MenuBloc extends Bloc<MenuEvent, MenuState> {
  final GetMenusUsecase getMenusUsecase;
  final GetMenuTypesUsecase getMenuTypesUsecase;
  final GetMyMenuRecordsUsecase getMyMenuRecordsUsecase;
  final GetMyMenuRecordsByDateUsecase getMyMenuRecordsByDateUsecase;
  final CreateMenuRecordsUsecase createMenuRecordsUsecase;
  final UpdateMenuRecordsUsecase updateMenuRecordsUsecase;
  final DeleteMenuRecordUsecase deleteMenuRecordUsecase;

  MenuBloc({
    required this.getMenusUsecase,
    required this.getMenuTypesUsecase,
    required this.getMyMenuRecordsUsecase,
    required this.getMyMenuRecordsByDateUsecase,
    required this.createMenuRecordsUsecase,
    required this.updateMenuRecordsUsecase,
    required this.deleteMenuRecordUsecase,
  }) : super(const MenuInitial()) {
    on<MenuLoadRequested>(_onMenuLoadRequested);
    on<MenuTypesLoadRequested>(_onMenuTypesLoadRequested);
    on<MyMenuRecordsLoadRequested>(_onMyMenuRecordsLoadRequested);
    on<MyMenuRecordsByDateLoadRequested>(_onMyMenuRecordsByDateLoadRequested);
    on<MenuRecordsCreateRequested>(_onMenuRecordsCreateRequested);
    on<MenuRecordsUpdateRequested>(_onMenuRecordsUpdateRequested);
    on<MenuRecordDeleteRequested>(_onMenuRecordDeleteRequested);
    on<MenuRecordsDeleteRequested>(_onMenuRecordsDeleteRequested);
    on<MenuRecordsSaveRequested>(_onMenuRecordsSaveRequested);
    on<MenuRefresh>(_onMenuRefresh);
  }

  Future<void> _onMenuLoadRequested(
    MenuLoadRequested event,
    Emitter<MenuState> emit,
  ) async {
    emit(const MenuLoading());
    try {
      // Load all data: menus, menu types, and all menu records
      final menus = await getMenusUsecase();
      final menuTypes = await getMenuTypesUsecase();
      // This calls /api/MenuRecord/my to get all menu records
      final myMenuRecords = await getMyMenuRecordsUsecase();

      emit(MenuLoaded(
        menus: menus,
        menuTypes: menuTypes,
        myMenuRecords: myMenuRecords,
      ));
    } catch (e) {
      emit(MenuError(e.toString()));
    }
  }

  Future<void> _onMenuTypesLoadRequested(
    MenuTypesLoadRequested event,
    Emitter<MenuState> emit,
  ) async {
    try {
      final menuTypes = await getMenuTypesUsecase();
      if (state is MenuLoaded) {
        emit((state as MenuLoaded).copyWith(menuTypes: menuTypes));
      } else {
        emit(MenuLoaded(
          menus: const [],
          menuTypes: menuTypes,
          myMenuRecords: const [],
        ));
      }
    } catch (e) {
      emit(MenuError(e.toString()));
    }
  }

  Future<void> _onMyMenuRecordsLoadRequested(
    MyMenuRecordsLoadRequested event,
    Emitter<MenuState> emit,
  ) async {
    try {
      final myMenuRecords = await getMyMenuRecordsUsecase();
      if (state is MenuLoaded) {
        emit((state as MenuLoaded).copyWith(myMenuRecords: myMenuRecords));
      } else {
        emit(MenuLoaded(
          menus: const [],
          menuTypes: const [],
          myMenuRecords: myMenuRecords,
        ));
      }
    } catch (e) {
      emit(MenuError(e.toString()));
    }
  }

  Future<void> _onMyMenuRecordsByDateLoadRequested(
    MyMenuRecordsByDateLoadRequested event,
    Emitter<MenuState> emit,
  ) async {
    try {
      // Normalize date to remove time component for consistent key matching
      final normalizedDate = DateTime(
        event.date.year,
        event.date.month,
        event.date.day,
      );
      final records = await getMyMenuRecordsByDateUsecase(normalizedDate);
      if (state is MenuLoaded) {
        final currentState = state as MenuLoaded;
        final updatedMap = Map<DateTime, List<MenuRecordEntity>>.from(
          currentState.menuRecordsByDate,
        );
        updatedMap[normalizedDate] = records;
        emit(currentState.copyWith(menuRecordsByDate: updatedMap));
      } else {
        emit(MenuLoaded(
          menus: const [],
          menuTypes: const [],
          myMenuRecords: const [],
          menuRecordsByDate: {normalizedDate: records},
        ));
      }
    } catch (e) {
      emit(MenuError(e.toString()));
    }
  }

  Future<void> _onMenuRecordsCreateRequested(
    MenuRecordsCreateRequested event,
    Emitter<MenuState> emit,
  ) async {
    try {
      final requestData = event.requests.map((req) => {
            'menuId': req.menuId,
            'name': req.name,
            'date': req.date.toIso8601String().split('T')[0],
          }).toList();

      final createdRecords = await createMenuRecordsUsecase(requestData);
      if (state is MenuLoaded) {
        final currentState = state as MenuLoaded;
        // Add newly created records to the existing list
        final updatedRecords = [
          ...currentState.myMenuRecords,
          ...createdRecords,
        ];
        emit(currentState.copyWith(myMenuRecords: updatedRecords));
      } else {
        emit(MenuLoaded(
          menus: const [],
          menuTypes: const [],
          myMenuRecords: createdRecords,
        ));
      }
    } catch (e) {
      emit(MenuError(e.toString()));
    }
  }

  Future<void> _onMenuRecordsUpdateRequested(
    MenuRecordsUpdateRequested event,
    Emitter<MenuState> emit,
  ) async {
    try {
      final requestData = event.requests.map((req) => {
            'id': req.id,
            'menuId': req.menuId,
            'name': req.name,
            'date': req.date.toIso8601String().split('T')[0],
          }).toList();

      final updatedRecords = await updateMenuRecordsUsecase(requestData);
      if (state is MenuLoaded) {
        final currentState = state as MenuLoaded;
        // Update existing records in the list
        final updatedList = currentState.myMenuRecords.map((record) {
          final updated = updatedRecords.firstWhere(
            (r) => r.id == record.id,
            orElse: () => record,
          );
          return updated;
        }).toList();
        emit(currentState.copyWith(myMenuRecords: updatedList));
      }
    } catch (e) {
      emit(MenuError(e.toString()));
    }
  }

  Future<void> _onMenuRecordDeleteRequested(
    MenuRecordDeleteRequested event,
    Emitter<MenuState> emit,
  ) async {
    try {
      await deleteMenuRecordUsecase(event.id);
      // Reload menu records from API to get latest data
      final myMenuRecords = await getMyMenuRecordsUsecase();
      if (state is MenuLoaded) {
        final currentState = state as MenuLoaded;
        emit(currentState.copyWith(myMenuRecords: myMenuRecords));
      }
    } catch (e) {
      emit(MenuError(e.toString()));
    }
  }

  Future<void> _onMenuRecordsDeleteRequested(
    MenuRecordsDeleteRequested event,
    Emitter<MenuState> emit,
  ) async {
    try {
      // Delete all records
      for (final id in event.ids) {
        await deleteMenuRecordUsecase(id);
      }
      // Reload menu records from API to get latest data
      final myMenuRecords = await getMyMenuRecordsUsecase();
      if (state is MenuLoaded) {
        final currentState = state as MenuLoaded;
        emit(currentState.copyWith(myMenuRecords: myMenuRecords));
      }
    } catch (e) {
      emit(MenuError(e.toString()));
    }
  }

  Future<void> _onMenuRecordsSaveRequested(
    MenuRecordsSaveRequested event,
    Emitter<MenuState> emit,
  ) async {
    try {
      // Separate into create and update requests
      final createRequests = <Map<String, dynamic>>[];
      final updateRequests = <Map<String, dynamic>>[];

      // Get menus and all menu records from state to find menuTypeId
      final menus = state is MenuLoaded ? (state as MenuLoaded).menus : <MenuEntity>[];
      final allMenuRecords = state is MenuLoaded ? (state as MenuLoaded).myMenuRecords : <MenuRecordEntity>[];

      for (final req in event.requests) {
        // Find menu to get menuTypeId
        MenuEntity? menu;
        try {
          menu = menus.firstWhere((m) => m.id == req.menuId);
        } catch (e) {
          // Menu not found, skip
          continue;
        }

        // Find existing record by menuTypeId and date (one record per menuType per date)
        // Search in all menu records to ensure we don't miss any existing records
        final menuTypeId = menu.menuTypeId;
        final normalizedDate = DateTime(
          req.date.year,
          req.date.month,
          req.date.day,
        );
        
        MenuRecordEntity? existingRecord;
        try {
          existingRecord = allMenuRecords.firstWhere(
            (r) {
              if (!r.isActive) return false;
              
              // Normalize record date for comparison
              final recordDate = DateTime(
                r.date.year,
                r.date.month,
                r.date.day,
              );
              
              // Check if date matches
              if (recordDate.year != normalizedDate.year ||
                  recordDate.month != normalizedDate.month ||
                  recordDate.day != normalizedDate.day) {
                return false;
              }
              
              // Check if menuTypeId matches
              try {
                final recordMenu = menus.firstWhere((m) => m.id == r.menuId);
                return recordMenu.menuTypeId == menuTypeId;
              } catch (e) {
                return false;
              }
            },
          );
        } catch (e) {
          // No existing record found
          existingRecord = null;
        }

        final requestData = {
          'menuId': req.menuId,
          'name': req.name,
          'date': req.date.toIso8601String().split('T')[0],
        };

        if (existingRecord != null && existingRecord.id > 0) {
          // Update existing record (user changed menu for this meal type and date)
          requestData['id'] = existingRecord.id;
          updateRequests.add(requestData);
        } else {
          // Create new record (no existing record for this meal type and date)
          createRequests.add(requestData);
        }
      }

      // Execute create and update operations
      // Note: Both APIs support batch operations (multiple records in one request)
      // We separate create and update to call the appropriate API endpoints
      List<MenuRecordEntity> createdRecords = [];
      List<MenuRecordEntity> updatedRecords = [];

      // Create new records (batch operation)
      if (createRequests.isNotEmpty) {
        createdRecords = await createMenuRecordsUsecase(createRequests);
      }

      // Update existing records (batch operation)
      if (updateRequests.isNotEmpty) {
        updatedRecords = await updateMenuRecordsUsecase(updateRequests);
      }

      // Update state with new and updated records
      if (state is MenuLoaded) {
        final currentState = state as MenuLoaded;
        // Merge: remove old records that were updated, add new ones
        final updatedList = [
          ...currentState.myMenuRecords
              .where((r) => !updateRequests.any((ur) => ur['id'] == r.id)),
          ...createdRecords,
          ...updatedRecords,
        ];
        emit(currentState.copyWith(myMenuRecords: updatedList));
      }
    } catch (e) {
      emit(MenuError(e.toString()));
    }
  }

  Future<void> _onMenuRefresh(
    MenuRefresh event,
    Emitter<MenuState> emit,
  ) async {
    try {
      final menus = await getMenusUsecase();
      final menuTypes = await getMenuTypesUsecase();
      final myMenuRecords = await getMyMenuRecordsUsecase();

      emit(MenuLoaded(
        menus: menus,
        menuTypes: menuTypes,
        myMenuRecords: myMenuRecords,
      ));
    } catch (e) {
      emit(MenuError(e.toString()));
    }
  }
}
