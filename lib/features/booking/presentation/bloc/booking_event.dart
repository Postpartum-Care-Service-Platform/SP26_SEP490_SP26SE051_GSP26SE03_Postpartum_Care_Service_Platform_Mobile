import 'package:equatable/equatable.dart';
import '../../../package/domain/entities/package_entity.dart';

/// Booking Events
abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

/// Load packages for selection
class BookingLoadPackages extends BookingEvent {
  final bool isPersonalized;
  const BookingLoadPackages({this.isPersonalized = false});

  @override
  List<Object?> get props => [isPersonalized];
}

/// Select package
class BookingSelectPackage extends BookingEvent {
  final int packageId;
  final PackageEntity? package;

  const BookingSelectPackage(this.packageId, {this.package});

  @override
  List<Object?> get props => [packageId, package];
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
  final List<int> familyProfileIds;
  final double? discountAmount;

  const BookingCreateBookingForCustomer({
    required this.customerId,
    required this.familyProfileIds,
    this.discountAmount,
  });

  @override
  List<Object?> get props => [customerId, familyProfileIds, discountAmount];
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

/// Select customer (for staff booking)
class BookingSelectCustomer extends BookingEvent {
  final dynamic customer;

  const BookingSelectCustomer(this.customer);

  @override
  List<Object?> get props => [customer];
}

/// Confirm booking completion (customer confirm check-out)
class BookingConfirmCompletion extends BookingEvent {
  final int id;

  const BookingConfirmCompletion(this.id);

  @override
  List<Object?> get props => [id];
}

/// Load booking system configuration (surcharge, deposit)
class BookingLoadConfig extends BookingEvent {
  const BookingLoadConfig();
}

/// Check center staff availability
class BookingCheckStaffAvailability extends BookingEvent {
  final DateTime from;
  final DateTime to;

  const BookingCheckStaffAvailability({required this.from, required this.to});

  @override
  List<Object?> get props => [from, to];
}
