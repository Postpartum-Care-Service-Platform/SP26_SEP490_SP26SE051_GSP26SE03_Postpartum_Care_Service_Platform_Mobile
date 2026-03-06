import 'package:equatable/equatable.dart';
import '../../domain/entities/home_activity_entity.dart';
import '../../domain/entities/home_service_selection_entity.dart';
import '../../domain/entities/home_staff_entity.dart';
import '../../domain/entities/home_service_booking_entity.dart';
import '../../../booking/domain/entities/payment_link_entity.dart';
import '../../../booking/domain/entities/payment_status_entity.dart';

/// Home Service Booking States
abstract class HomeServiceState extends Equatable {
  const HomeServiceState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class HomeServiceInitial extends HomeServiceState {
  const HomeServiceInitial();
}

/// Loading state
class HomeServiceLoading extends HomeServiceState {
  const HomeServiceLoading();
}

/// Activities loaded
class HomeServiceActivitiesLoaded extends HomeServiceState {
  final List<HomeActivityEntity> activities;
  final List<HomeServiceSelectionEntity> selections;

  const HomeServiceActivitiesLoaded({
    required this.activities,
    required this.selections,
  });

  @override
  List<Object?> get props => [activities, selections];
}

/// Free staff loaded
class HomeServiceFreeStaffLoaded extends HomeServiceState {
  final List<HomeActivityEntity> activities;
  final List<HomeServiceSelectionEntity> selections;
  final List<HomeStaffEntity> staffList;
  final HomeStaffEntity? selectedStaff;

  const HomeServiceFreeStaffLoaded({
    required this.activities,
    required this.selections,
    required this.staffList,
    this.selectedStaff,
  });

  @override
  List<Object?> get props => [activities, selections, staffList, selectedStaff];
}

/// Summary ready (all selections made)
class HomeServiceSummaryReady extends HomeServiceState {
  final List<HomeActivityEntity> activities;
  final List<HomeServiceSelectionEntity> selections;
  final HomeStaffEntity staff;
  final double totalPrice;

  const HomeServiceSummaryReady({
    required this.activities,
    required this.selections,
    required this.staff,
    required this.totalPrice,
  });

  @override
  List<Object?> get props => [activities, selections, staff, totalPrice];
}

/// Booking created
class HomeServiceBookingCreated extends HomeServiceState {
  final HomeServiceBookingEntity booking;

  const HomeServiceBookingCreated(this.booking);

  @override
  List<Object?> get props => [booking];
}

/// Payment link created
class HomeServicePaymentLinkCreated extends HomeServiceState {
  final PaymentLinkEntity paymentLink;

  const HomeServicePaymentLinkCreated(this.paymentLink);

  @override
  List<Object?> get props => [paymentLink];
}

/// Payment status checked
class HomeServicePaymentStatusChecked extends HomeServiceState {
  final PaymentStatusEntity paymentStatus;

  const HomeServicePaymentStatusChecked(this.paymentStatus);

  @override
  List<Object?> get props => [paymentStatus];
}

/// Booking cancelled
class HomeServiceBookingCancelled extends HomeServiceState {
  final int bookingId;
  final String message;

  const HomeServiceBookingCancelled({
    required this.bookingId,
    required this.message,
  });

  @override
  List<Object?> get props => [bookingId, message];
}

/// Error state
class HomeServiceError extends HomeServiceState {
  final String message;

  const HomeServiceError(this.message);

  @override
  List<Object?> get props => [message];
}
