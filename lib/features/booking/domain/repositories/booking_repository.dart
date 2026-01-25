import '../entities/booking_entity.dart';
import '../entities/payment_link_entity.dart';
import '../entities/payment_status_entity.dart';

/// Booking Repository Interface
abstract class BookingRepository {
  /// Create a new booking
  Future<BookingEntity> createBooking({
    required int packageId,
    required int roomId,
    required DateTime startDate,
  });

  /// Get booking by ID
  Future<BookingEntity> getBookingById(int id);

  /// Get all bookings for current user
  Future<List<BookingEntity>> getBookings();

  /// Create payment link for deposit
  Future<PaymentLinkEntity> createPaymentLink({
    required int bookingId,
    required String type, // Deposit or Remaining
  });

  /// Check payment status by order code
  Future<PaymentStatusEntity> checkPaymentStatus(String orderCode);
}
