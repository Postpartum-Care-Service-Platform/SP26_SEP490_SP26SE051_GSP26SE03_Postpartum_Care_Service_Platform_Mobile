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

  /// Get available rooms (legacy)
  /// Returns list of available rooms (status = Available)
  /// without checking date range.
  Future<List<RoomEntity>> getAvailableRooms();

  /// Get available rooms in a specific date range
  /// Used for customer booking to avoid overlapping reservations.
  Future<List<RoomEntity>> getAvailableRoomsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get rooms by package ID and booking date range
  Future<List<RoomEntity>> getRoomsByPackage({
    required int packageId,
    required DateTime startDate,
    required DateTime endDate,
  });
}
