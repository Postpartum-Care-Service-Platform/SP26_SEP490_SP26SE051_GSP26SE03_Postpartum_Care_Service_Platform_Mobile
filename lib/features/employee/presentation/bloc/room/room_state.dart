import 'package:equatable/equatable.dart';
import '../../../domain/entities/room_entity.dart';

/// Base class for Room States
abstract class RoomState extends Equatable {
  const RoomState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class RoomInitial extends RoomState {
  const RoomInitial();
}

/// Loading state
class RoomLoading extends RoomState {
  const RoomLoading();
}

/// Loaded state with rooms list
class RoomLoaded extends RoomState {
  final List<RoomEntity> rooms;

  const RoomLoaded(this.rooms);

  @override
  List<Object?> get props => [rooms];
}

/// Single room detail loaded
class RoomDetailLoaded extends RoomState {
  final RoomEntity room;

  const RoomDetailLoaded(this.room);

  @override
  List<Object?> get props => [room];
}

/// Error state
class RoomError extends RoomState {
  final String message;

  const RoomError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Empty state (no rooms)
class RoomEmpty extends RoomState {
  const RoomEmpty();
}
