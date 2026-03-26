import 'package:equatable/equatable.dart';

/// Base class for Room Events
abstract class RoomEvent extends Equatable {
  const RoomEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all rooms
class LoadAllRooms extends RoomEvent {
  const LoadAllRooms();
}

/// Event to load room by ID
class LoadRoomById extends RoomEvent {
  final int roomId;

  const LoadRoomById(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

/// Event to load available rooms only
class LoadAvailableRooms extends RoomEvent {
  const LoadAvailableRooms();
}

/// Event to refresh rooms
class RefreshRooms extends RoomEvent {
  const RefreshRooms();
}
