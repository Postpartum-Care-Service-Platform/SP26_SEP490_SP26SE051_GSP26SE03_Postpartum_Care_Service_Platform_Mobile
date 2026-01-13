import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_all_rooms.dart';
import '../../../domain/usecases/get_room_by_id.dart';
import '../../../domain/usecases/get_available_rooms.dart';
import 'room_event.dart';
import 'room_state.dart';

/// BLoC for managing room state
class RoomBloc extends Bloc<RoomEvent, RoomState> {
  final GetAllRooms getAllRooms;
  final GetRoomById getRoomById;
  final GetAvailableRooms getAvailableRooms;

  RoomBloc({
    required this.getAllRooms,
    required this.getRoomById,
    required this.getAvailableRooms,
  }) : super(const RoomInitial()) {
    // Register event handlers
    on<LoadAllRooms>(_onLoadAllRooms);
    on<LoadRoomById>(_onLoadRoomById);
    on<LoadAvailableRooms>(_onLoadAvailableRooms);
    on<RefreshRooms>(_onRefreshRooms);
  }

  /// Handle load all rooms
  Future<void> _onLoadAllRooms(
    LoadAllRooms event,
    Emitter<RoomState> emit,
  ) async {
    emit(const RoomLoading());

    try {
      final rooms = await getAllRooms();
      
      if (rooms.isEmpty) {
        emit(const RoomEmpty());
      } else {
        emit(RoomLoaded(rooms));
      }
    } catch (e) {
      emit(RoomError(e.toString()));
    }
  }

  /// Handle load room by ID
  Future<void> _onLoadRoomById(
    LoadRoomById event,
    Emitter<RoomState> emit,
  ) async {
    emit(const RoomLoading());

    try {
      final room = await getRoomById(event.roomId);
      emit(RoomDetailLoaded(room));
    } catch (e) {
      emit(RoomError(e.toString()));
    }
  }

  /// Handle load available rooms
  Future<void> _onLoadAvailableRooms(
    LoadAvailableRooms event,
    Emitter<RoomState> emit,
  ) async {
    emit(const RoomLoading());

    try {
      final rooms = await getAvailableRooms();
      
      if (rooms.isEmpty) {
        emit(const RoomEmpty());
      } else {
        emit(RoomLoaded(rooms));
      }
    } catch (e) {
      emit(RoomError(e.toString()));
    }
  }

  /// Handle refresh rooms
  Future<void> _onRefreshRooms(
    RefreshRooms event,
    Emitter<RoomState> emit,
  ) async {
    // Reload all rooms by default
    add(const LoadAllRooms());
  }
}
