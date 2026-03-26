import '../entities/room_entity.dart';
import '../repositories/room_repository.dart';

/// Use case to get all rooms
class GetAllRooms {
  final RoomRepository repository;

  GetAllRooms(this.repository);

  /// Execute the use case
  /// Returns list of all rooms
  Future<List<RoomEntity>> call() async {
    return await repository.getAllRooms();
  }
}
