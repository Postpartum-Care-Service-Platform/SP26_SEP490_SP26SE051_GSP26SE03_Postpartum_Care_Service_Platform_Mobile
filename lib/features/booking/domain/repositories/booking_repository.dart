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

  /// Staff creates booking for a specific customer
  Future<BookingEntity> createBookingForCustomer({
    required String customerId,
    required int packageId,
    required int roomId,
    required DateTime startDate,
    double? discountAmount,
  });

  /// Get booking by ID
  Future<BookingEntity> getBookingById(int id);

  /// Get all bookings for current user
  Future<List<BookingEntity>> getBookings();

  /// Get all bookings (for staff/admin)
  Future<List<BookingEntity>> getAllBookings();

  /// Create payment link for deposit
  Future<PaymentLinkEntity> createPaymentLink({
    required int bookingId,
    required String type, // Deposit or Remaining
  });

  /// Check payment status by order code
  Future<PaymentStatusEntity> checkPaymentStatus(String orderCode);

  /// Staff/Admin: Confirm booking
  Future<String> confirmBooking(int id);

  /// Staff/Admin: Complete booking
  Future<String> completeBooking(int id);

  /// Staff ghi nhận thanh toán offline cho booking.
  Future<PaymentStatusEntity> createOfflinePayment({
    required int bookingId,
    required String customerId,
    required double amount,
    required String paymentMethod,
    String? note,
  });
}
