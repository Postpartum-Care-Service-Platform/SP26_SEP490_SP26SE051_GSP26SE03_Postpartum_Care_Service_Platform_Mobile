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

/// Load rooms for selection
class BookingLoadRooms extends BookingEvent {
  const BookingLoadRooms();
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

/// Create payment link
class BookingCreatePaymentLink extends BookingEvent {
  final String type; // Deposit or Remaining

  const BookingCreatePaymentLink(this.type);

  @override
  List<Object?> get props => [type];
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

/// Reset booking state
class BookingReset extends BookingEvent {
  const BookingReset();
}
