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
  Future<BookingEntity> createBookingForCustomer({
    required String customerId,
    required int packageId,
    required int roomId,
    required DateTime startDate,
    double? discountAmount,
  }) async {
    try {
      final model = await remoteDataSource.createBookingForCustomer(
        customerId: customerId,
        packageId: packageId,
        roomId: roomId,
        startDate: startDate,
        discountAmount: discountAmount,
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
  Future<List<BookingEntity>> getAllBookings() async {
    try {
      final models = await remoteDataSource.getAllBookings();
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

  @override
  Future<String> confirmBooking(int id) async {
    try {
      return await remoteDataSource.confirmBooking(id);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<String> completeBooking(int id) async {
    try {
      return await remoteDataSource.completeBooking(id);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<PaymentStatusEntity> createOfflinePayment({
    required int bookingId,
    required String customerId,
    required double amount,
    required String paymentMethod,
    String? note,
  }) async {
    try {
      final model = await remoteDataSource.createOfflinePayment(
        bookingId: bookingId,
        customerId: customerId,
        amount: amount,
        paymentMethod: paymentMethod,
        note: note,
      );
      return model.toEntity();
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
