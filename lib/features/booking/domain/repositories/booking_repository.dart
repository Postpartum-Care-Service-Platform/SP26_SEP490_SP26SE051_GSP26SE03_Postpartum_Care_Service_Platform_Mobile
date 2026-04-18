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
    required List<int> familyProfileIds,
  });

  /// Staff creates booking for a specific customer
  Future<BookingEntity> createBookingForCustomer({
    required String customerId,
    required int packageId,
    required int roomId,
    required DateTime startDate,
    required List<int> familyProfileIds,
    double? discountAmount,
  });

  /// Get booking by ID
  Future<BookingEntity> getBookingById(int id);

  /// Get all bookings for current user
  Future<List<BookingEntity>> getBookings();

  /// Cancel booking by ID
  Future<String> cancelBooking(int id);
  /// Get all bookings (for staff/admin)
  Future<List<BookingEntity>> getAllBookings();

  /// Create payment link for deposit
  Future<PaymentLinkEntity> createPaymentLink({
    required int bookingId,
    required String type, // Deposit or Remaining or Full
    bool isHomeService = false,
    String? staffId,
  });

  /// Check payment status by order code
  Future<PaymentStatusEntity> checkPaymentStatus(String orderCode);

  /// Staff/Admin: Confirm booking
  Future<String> confirmBooking(int id);

  /// Staff/Admin: Complete booking
  Future<String> completeBooking(int id);

}
