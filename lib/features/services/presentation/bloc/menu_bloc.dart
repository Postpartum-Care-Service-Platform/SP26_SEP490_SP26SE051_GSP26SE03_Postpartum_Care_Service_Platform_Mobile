import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_menus_usecase.dart';
import '../../domain/usecases/get_menu_types_usecase.dart';
import '../../domain/usecases/get_my_menu_records_usecase.dart';
import '../../domain/usecases/get_my_menu_records_by_date_usecase.dart';
import '../../domain/usecases/create_menu_records_usecase.dart';
import '../../domain/usecases/update_menu_records_usecase.dart';
import '../../domain/usecases/delete_menu_record_usecase.dart';
import '../../domain/usecases/get_customized_menus_usecase.dart';
import '../../domain/usecases/create_customized_menu_usecase.dart';
import '../../domain/usecases/get_foods_usecase.dart';
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
  final GetCustomizedMenusUseCase getCustomizedMenusUseCase;
  final CreateCustomizedMenuUseCase createCustomizedMenuUseCase;
  final GetFoodsUseCase getFoodsUseCase;

  MenuBloc({
    required this.getMenusUsecase,
    required this.getMenuTypesUsecase,
    required this.getMyMenuRecordsUsecase,
    required this.getMyMenuRecordsByDateUsecase,
    required this.createMenuRecordsUsecase,
    required this.updateMenuRecordsUsecase,
    required this.deleteMenuRecordUsecase,
    required this.getCustomizedMenusUseCase,
    required this.createCustomizedMenuUseCase,
    required this.getFoodsUseCase,
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
    on<CustomizedMenusLoadRequested>(_onCustomizedMenusLoadRequested);
    on<CustomizedMenuCreateRequested>(_onCustomizedMenuCreateRequested);
    on<FoodsLoadRequested>(_onFoodsLoadRequested);
    on<MenuRefresh>(_onMenuRefresh);
  }

  Future<void> _onMenuLoadRequested(
    MenuLoadRequested event,
    Emitter<MenuState> emit,
  ) async {
    emit(const MenuLoading());
    try {
      final menus = await getMenusUsecase();
      final menuTypes = await getMenuTypesUsecase();
      final myMenuRecords = await getMyMenuRecordsUsecase();
      final customizedMenus = await getCustomizedMenusUseCase();

      emit(MenuLoaded(
        menus: menus,
        menuTypes: menuTypes,
        myMenuRecords: myMenuRecords,
        customizedMenus: customizedMenus,
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
        final updatedById = <int, MenuRecordEntity>{
          for (final item in updatedRecords) item.id: item,
        };

        final updatedList = currentState.myMenuRecords
            .map((record) => updatedById[record.id] ?? record)
            .toList();

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
      for (final id in event.ids) {
        await deleteMenuRecordUsecase(id);
      }
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
      final createRequests = <Map<String, dynamic>>[];
      final updateRequests = <Map<String, dynamic>>[];
      final menus = state is MenuLoaded ? (state as MenuLoaded).menus : <MenuEntity>[];
      final allMenuRecords = await getMyMenuRecordsUsecase();

      for (final req in event.requests) {
        MenuEntity? menu;
        try {
          menu = menus.firstWhere((m) => m.id == req.menuId);
        } catch (e) {
          continue;
        }

        final menuTypeId = menu.menuTypeId;
        final normalizedDate = DateTime(req.date.year, req.date.month, req.date.day);
        
        MenuRecordEntity? existingRecord;
        try {
          existingRecord = allMenuRecords.firstWhere((r) {
            if (!r.isActive) return false;
            final recordDate = DateTime(r.date.year, r.date.month, r.date.day);
            if (recordDate.year != normalizedDate.year ||
                recordDate.month != normalizedDate.month ||
                recordDate.day != normalizedDate.day) {
              return false;
            }
            try {
              final recordMenu = menus.firstWhere((m) => m.id == r.menuId);
              return recordMenu.menuTypeId == menuTypeId;
            } catch (e) {
              return false;
            }
          });
        } catch (e) {
          existingRecord = null;
        }

        final requestData = {
          'menuId': req.menuId,
          'name': req.name,
          'date': req.date.toIso8601String().split('T')[0],
        };

        if (existingRecord != null && existingRecord.id > 0) {
          requestData['id'] = existingRecord.id;
          updateRequests.add(requestData);
        } else {
          createRequests.add(requestData);
        }
      }

      List<MenuRecordEntity> createdRecords = [];
      List<MenuRecordEntity> updatedRecords = [];

      if (createRequests.isNotEmpty) {
        createdRecords = await createMenuRecordsUsecase(createRequests);
      }
      if (updateRequests.isNotEmpty) {
        updatedRecords = await updateMenuRecordsUsecase(updateRequests);
      }

      if (state is MenuLoaded) {
        final currentState = state as MenuLoaded;
        final updatedList = [
          ...currentState.myMenuRecords.where((r) => !updateRequests.any((ur) => ur['id'] == r.id)),
          ...createdRecords,
          ...updatedRecords,
        ];
        emit(currentState.copyWith(myMenuRecords: updatedList));
      }
    } catch (e) {
      emit(MenuError(e.toString()));
    }
  }

  Future<void> _onCustomizedMenusLoadRequested(
    CustomizedMenusLoadRequested event,
    Emitter<MenuState> emit,
  ) async {
    try {
      final customizedMenus = await getCustomizedMenusUseCase();
      if (state is MenuLoaded) {
        emit((state as MenuLoaded).copyWith(customizedMenus: customizedMenus));
      } else {
        emit(MenuLoaded(
          menus: const [],
          menuTypes: const [],
          myMenuRecords: const [],
          customizedMenus: customizedMenus,
        ));
      }
    } catch (e) {
      emit(MenuError(e.toString()));
    }
  }

  Future<void> _onCustomizedMenuCreateRequested(
    CustomizedMenuCreateRequested event,
    Emitter<MenuState> emit,
  ) async {
    try {
      final newMenu = await createCustomizedMenuUseCase(event.request);
      if (state is MenuLoaded) {
        final currentState = state as MenuLoaded;
        final updatedCustomMenus = [...currentState.customizedMenus, newMenu];
        
        emit(CustomizedMenuCreateSuccess(
          newMenu: newMenu,
          menus: currentState.menus,
          menuTypes: currentState.menuTypes,
          myMenuRecords: currentState.myMenuRecords,
          customizedMenus: updatedCustomMenus,
          foods: currentState.foods,
          menuRecordsByDate: currentState.menuRecordsByDate,
        ));
      } else {
        emit(CustomizedMenuCreateSuccess(
          newMenu: newMenu,
          menus: const [],
          menuTypes: const [],
          myMenuRecords: const [],
          customizedMenus: [newMenu],
        ));
      }
    } catch (e) {
      emit(MenuError(e.toString()));
    }
  }

  Future<void> _onFoodsLoadRequested(
    FoodsLoadRequested event,
    Emitter<MenuState> emit,
  ) async {
    try {
      final foods = await getFoodsUseCase();
      if (state is MenuLoaded) {
        emit((state as MenuLoaded).copyWith(foods: foods));
      } else {
        emit(MenuLoaded(
          menus: const [],
          menuTypes: const [],
          myMenuRecords: const [],
          foods: foods,
        ));
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
      final customizedMenus = await getCustomizedMenusUseCase();

      emit(MenuLoaded(
        menus: menus,
        menuTypes: menuTypes,
        myMenuRecords: myMenuRecords,
        customizedMenus: customizedMenus,
      ));
    } catch (e) {
      emit(MenuError(e.toString()));
    }
  }
}
