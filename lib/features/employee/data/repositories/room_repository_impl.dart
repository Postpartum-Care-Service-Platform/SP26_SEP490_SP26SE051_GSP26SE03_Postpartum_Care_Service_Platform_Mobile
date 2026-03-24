import '../../domain/entities/room_entity.dart';
import '../../domain/entities/room_status.dart';
import '../../domain/repositories/room_repository.dart';
import '../datasources/room_remote_datasource.dart';
import '../models/room_booking_period_model.dart';

/// Implementation of RoomRepository
class RoomRepositoryImpl implements RoomRepository {
  final RoomRemoteDataSource remoteDataSource;

  RoomRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<RoomEntity>> getAllRooms() async {
    try {
      final models = await remoteDataSource.getAllRooms();
      final bookingPeriods = await remoteDataSource.getRoomBookingPeriods();
      final rooms = models.map((model) => model.toEntity()).toList();
      final now = DateTime.now();

      final bookingMap = _groupBookingPeriodsByRoom(bookingPeriods);

      return rooms.map((room) {
        final periods = bookingMap[room.id] ?? [];
        final selectedPeriod = _selectRelevantPeriod(periods, now);
        if (selectedPeriod == null) {
          return room.copyWith(
            bookingId: null,
            bookingStartDate: null,
            bookingEndDate: null,
            isOccupied: false,
          );
        }

        final isOccupied = _isWithinBookingPeriod(
          now,
          selectedPeriod.startDate,
          selectedPeriod.endDate,
        );

        return room.copyWith(
          bookingId: selectedPeriod.bookingId,
          bookingStartDate: selectedPeriod.startDate,
          bookingEndDate: selectedPeriod.endDate,
          isOccupied: isOccupied,
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  Map<int, List<RoomBookingPeriodModel>> _groupBookingPeriodsByRoom(
    List<RoomBookingPeriodModel> periods,
  ) {
    final Map<int, List<RoomBookingPeriodModel>> result = {};
    for (final period in periods) {
      final list = result.putIfAbsent(period.roomId, () => []);
      list.add(period);
    }
    return result;
  }

  RoomBookingPeriodModel? _selectRelevantPeriod(
    List<RoomBookingPeriodModel> periods,
    DateTime now,
  ) {
    if (periods.isEmpty) {
      return null;
    }

    final current = periods.where((period) {
      return _isWithinBookingPeriod(now, period.startDate, period.endDate);
    }).toList();

    if (current.isNotEmpty) {
      current.sort((a, b) => a.startDate.compareTo(b.startDate));
      return current.first;
    }

    final upcoming = periods
        .where((period) => now.isBefore(period.startDate))
        .toList();
    if (upcoming.isEmpty) {
      return null;
    }

    upcoming.sort((a, b) => a.startDate.compareTo(b.startDate));
    return upcoming.first;
  }

  bool _isWithinBookingPeriod(
    DateTime now,
    DateTime startDate,
    DateTime endDate,
  ) {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
    return (now.isAtSameMomentAs(start) || now.isAfter(start)) &&
        (now.isAtSameMomentAs(end) || now.isBefore(end));
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
      return allRooms
          .where((room) => room.status == RoomStatus.available && room.isActive)
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<RoomEntity>> getAvailableRoomsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final models = await remoteDataSource.getAvailableRoomsByDateRange(
        startDate: startDate,
        endDate: endDate,
      );
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<RoomEntity>> getRoomsByPackage(int packageId) async {
    try {
      final models = await remoteDataSource.getRoomsByPackage(packageId);
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }
}
