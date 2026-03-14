import '../entities/room_entity.dart';
import '../repositories/room_repository.dart';

/// Use case to get available rooms within a date range
class GetAvailableRoomsByDateRange {
  final RoomRepository repository;

  GetAvailableRoomsByDateRange(this.repository);

  /// Execute the use case
  /// Returns list of available rooms between [startDate] and [endDate]
  Future<List<RoomEntity>> call({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return repository.getAvailableRoomsByDateRange(
      startDate: startDate,
      endDate: endDate,
    );
  }
}

