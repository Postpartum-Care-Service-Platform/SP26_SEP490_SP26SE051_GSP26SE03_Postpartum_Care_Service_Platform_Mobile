import '../entities/room_entity.dart';

/// Room Repository Interface
/// Defines contract for room data operations
abstract class RoomRepository {
  /// Get all rooms
  /// Returns list of all rooms
  Future<List<RoomEntity>> getAllRooms();

  /// Get room by ID
  /// [roomId] - The ID of the room to retrieve
  /// Returns room entity
  Future<RoomEntity> getRoomById(int roomId);

  /// Get available rooms
  /// Returns list of available rooms (status = Available)
  Future<List<RoomEntity>> getAvailableRooms();
}
