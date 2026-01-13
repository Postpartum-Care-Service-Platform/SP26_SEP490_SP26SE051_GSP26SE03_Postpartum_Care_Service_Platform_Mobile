import '../entities/room_entity.dart';
import '../repositories/room_repository.dart';

/// Use case to get room by ID
class GetRoomById {
  final RoomRepository repository;

  GetRoomById(this.repository);

  /// Execute the use case
  /// [roomId] - The ID of the room to retrieve
  /// Returns room entity
  Future<RoomEntity> call(int roomId) async {
    return await repository.getRoomById(roomId);
  }
}
