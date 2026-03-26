import '../entities/room_entity.dart';
import '../repositories/room_repository.dart';

class GetRoomsByPackage {
  final RoomRepository repository;

  GetRoomsByPackage(this.repository);

  Future<List<RoomEntity>> call({
    required int packageId,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return repository.getRoomsByPackage(
      packageId: packageId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
