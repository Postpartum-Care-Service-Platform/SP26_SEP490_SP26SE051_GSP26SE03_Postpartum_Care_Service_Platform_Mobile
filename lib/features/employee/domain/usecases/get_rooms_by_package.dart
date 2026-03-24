import '../entities/room_entity.dart';
import '../repositories/room_repository.dart';

class GetRoomsByPackage {
  final RoomRepository repository;

  GetRoomsByPackage(this.repository);

  Future<List<RoomEntity>> call(int packageId) {
    return repository.getRoomsByPackage(packageId);
  }
}
