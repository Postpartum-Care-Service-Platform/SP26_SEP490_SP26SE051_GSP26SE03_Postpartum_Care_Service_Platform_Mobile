import '../../domain/entities/room_entity.dart';
import '../../domain/entities/room_status.dart';
import '../../domain/repositories/room_repository.dart';
import '../datasources/room_remote_datasource.dart';

/// Implementation of RoomRepository
class RoomRepositoryImpl implements RoomRepository {
  final RoomRemoteDataSource remoteDataSource;

  RoomRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<RoomEntity>> getAllRooms() async {
    try {
      final models = await remoteDataSource.getAllRooms();
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<RoomEntity> getRoomById(int roomId) async {
    try {
      final model = await remoteDataSource.getRoomById(roomId);
      return model.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<RoomEntity>> getAvailableRooms() async {
    try {
      final allRooms = await getAllRooms();
      // Filter only available rooms
      return allRooms
          .where((room) => 
              room.status == RoomStatus.available && 
              room.isActive)
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
