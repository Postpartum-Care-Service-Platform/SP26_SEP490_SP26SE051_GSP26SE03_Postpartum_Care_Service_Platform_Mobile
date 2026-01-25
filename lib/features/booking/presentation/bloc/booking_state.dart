import 'package:equatable/equatable.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/entities/payment_link_entity.dart';
import '../../domain/entities/payment_status_entity.dart';
import '../../../package/domain/entities/package_entity.dart';
import '../../../employee/domain/entities/room_entity.dart';

/// Booking States
abstract class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class BookingInitial extends BookingState {
  const BookingInitial();
}

/// Loading state
class BookingLoading extends BookingState {
  const BookingLoading();
}

/// Step 1: Package selection loaded
class BookingPackagesLoaded extends BookingState {
  final List<PackageEntity> packages;
  final int? selectedPackageId;

  const BookingPackagesLoaded({
    required this.packages,
    this.selectedPackageId,
  });

  @override
  List<Object?> get props => [packages, selectedPackageId];
}

/// Step 2: Rooms loaded
class BookingRoomsLoaded extends BookingState {
  final List<RoomEntity> rooms;
  final int? selectedRoomId;

  const BookingRoomsLoaded({
    required this.rooms,
    this.selectedRoomId,
  });

  @override
  List<Object?> get props => [rooms, selectedRoomId];
}

/// Step 3: Date selected
class BookingDateSelected extends BookingState {
  final DateTime selectedDate;

  const BookingDateSelected(this.selectedDate);

  @override
  List<Object?> get props => [selectedDate];
}

/// Step 4: Summary ready
class BookingSummaryReady extends BookingState {
  final int packageId;
  final int roomId;
  final DateTime startDate;
  final PackageEntity package;
  final RoomEntity room;

  const BookingSummaryReady({
    required this.packageId,
    required this.roomId,
    required this.startDate,
    required this.package,
    required this.room,
  });

  @override
  List<Object?> get props => [
        packageId,
        roomId,
        startDate,
        package,
        room,
      ];
}

/// Booking created successfully
class BookingCreated extends BookingState {
  final BookingEntity booking;

  const BookingCreated(this.booking);

  @override
  List<Object?> get props => [booking];
}

/// Payment link created
class BookingPaymentLinkCreated extends BookingState {
  final PaymentLinkEntity paymentLink;

  const BookingPaymentLinkCreated(this.paymentLink);

  @override
  List<Object?> get props => [paymentLink];
}

/// Payment status checked
class BookingPaymentStatusChecked extends BookingState {
  final PaymentStatusEntity paymentStatus;

  const BookingPaymentStatusChecked(this.paymentStatus);

  @override
  List<Object?> get props => [paymentStatus];
}

/// Booking loaded by ID
class BookingLoaded extends BookingState {
  final BookingEntity booking;

  const BookingLoaded(this.booking);

  @override
  List<Object?> get props => [booking];
}

/// All bookings loaded
class BookingsLoaded extends BookingState {
  final List<BookingEntity> bookings;

  const BookingsLoaded(this.bookings);

  @override
  List<Object?> get props => [bookings];
}

/// Error state
class BookingError extends BookingState {
  final String message;

  const BookingError(this.message);

  @override
  List<Object?> get props => [message];
}
