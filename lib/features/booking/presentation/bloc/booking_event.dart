import 'package:equatable/equatable.dart';

/// Booking Events
abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

/// Load packages for selection
class BookingLoadPackages extends BookingEvent {
  const BookingLoadPackages();
}

/// Select package
class BookingSelectPackage extends BookingEvent {
  final int packageId;

  const BookingSelectPackage(this.packageId);

  @override
  List<Object?> get props => [packageId];
}

/// Load family profiles for selection
class BookingLoadFamilyProfiles extends BookingEvent {
  final String? accountId;

  const BookingLoadFamilyProfiles({this.accountId});

  @override
  List<Object?> get props => [accountId];
}

/// Select family profiles
class BookingSelectFamilyProfiles extends BookingEvent {
  final List<int> familyProfileIds;

  const BookingSelectFamilyProfiles(this.familyProfileIds);

  @override
  List<Object?> get props => [familyProfileIds];
}

/// Load rooms for selection
class BookingLoadRooms extends BookingEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const BookingLoadRooms({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

/// Select room
class BookingSelectRoom extends BookingEvent {
  final int roomId;

  const BookingSelectRoom(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

/// Select check-in date
class BookingSelectDate extends BookingEvent {
  final DateTime date;

  const BookingSelectDate(this.date);

  @override
  List<Object?> get props => [date];
}

/// Create booking
class BookingCreateBooking extends BookingEvent {
  const BookingCreateBooking();
}

/// Staff: Create booking for a specific customer
class BookingCreateBookingForCustomer extends BookingEvent {
  final String customerId;
  final double? discountAmount;

  const BookingCreateBookingForCustomer(this.customerId, {this.discountAmount});

  @override
  List<Object?> get props => [customerId, discountAmount];
}

/// Staff: Ghi nhận thanh toán offline cho booking
class BookingCreateOfflinePayment extends BookingEvent {
  final int bookingId;
  final String customerId;
  final double amount;
  final String paymentMethod;
  final String? note;

  const BookingCreateOfflinePayment({
    required this.bookingId,
    required this.customerId,
    required this.amount,
    required this.paymentMethod,
    this.note,
  });

  @override
  List<Object?> get props => [
    bookingId,
    customerId,
    amount,
    paymentMethod,
    note,
  ];
}

/// Create payment link
class BookingCreatePaymentLink extends BookingEvent {
  final String type; // Deposit or Remaining or Full
  final int? bookingId;
  final bool isHomeService;
  final String? staffId;

  const BookingCreatePaymentLink(
    this.type, {
    this.bookingId,
    this.isHomeService = false,
    this.staffId,
  });

  @override
  List<Object?> get props => [type, bookingId, isHomeService, staffId];
}

/// Check payment status
class BookingCheckPaymentStatus extends BookingEvent {
  final String orderCode;

  const BookingCheckPaymentStatus(this.orderCode);

  @override
  List<Object?> get props => [orderCode];
}

/// Load booking by ID
class BookingLoadById extends BookingEvent {
  final int id;

  const BookingLoadById(this.id);

  @override
  List<Object?> get props => [id];
}

/// Load all bookings
class BookingLoadAll extends BookingEvent {
  const BookingLoadAll();
}

/// Cancel booking (e.g., user cancels payment)
class BookingCancelRequested extends BookingEvent {
  final int id;

  const BookingCancelRequested(this.id);

  @override
  List<Object?> get props => [id];
}

/// Reset booking state
class BookingReset extends BookingEvent {
  const BookingReset();
}
