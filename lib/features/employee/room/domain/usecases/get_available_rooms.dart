import '../entities/room_entity.dart';
import '../repositories/room_repository.dart';

/// Use case to get available rooms
class GetAvailableRooms {
  final RoomRepository repository;

  GetAvailableRooms(this.repository);

  /// Execute the use case
  /// Returns list of available rooms
  Future<List<RoomEntity>> call() async {
    return await repository.getAvailableRooms();
  }
}
