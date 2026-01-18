import '../../domain/entities/booking_entity.dart';
import '../../domain/entities/payment_link_entity.dart';
import '../../domain/entities/payment_status_entity.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_datasource.dart';

/// Booking Repository Implementation
class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remoteDataSource;

  BookingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<BookingEntity> createBooking({
    required int packageId,
    required int roomId,
    required DateTime startDate,
  }) async {
    try {
      final model = await remoteDataSource.createBooking(
        packageId: packageId,
        roomId: roomId,
        startDate: startDate,
      );
      return model.toEntity();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<BookingEntity> getBookingById(int id) async {
    try {
      final model = await remoteDataSource.getBookingById(id);
      return model.toEntity();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<List<BookingEntity>> getBookings() async {
    try {
      final models = await remoteDataSource.getBookings();
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<PaymentLinkEntity> createPaymentLink({
    required int bookingId,
    required String type,
  }) async {
    try {
      final model = await remoteDataSource.createPaymentLink(
        bookingId: bookingId,
        type: type,
      );
      return model.toEntity();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<PaymentStatusEntity> checkPaymentStatus(String orderCode) async {
    try {
      final model = await remoteDataSource.checkPaymentStatus(orderCode);
      return model.toEntity();
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
