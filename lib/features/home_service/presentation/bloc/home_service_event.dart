import 'package:equatable/equatable.dart';
import '../../domain/entities/home_activity_entity.dart';
import '../../domain/entities/home_staff_entity.dart';

/// Home Service Booking Events
abstract class HomeServiceEvent extends Equatable {
  const HomeServiceEvent();

  @override
  List<Object?> get props => [];
}

/// Load home activities
class HomeServiceLoadActivities extends HomeServiceEvent {
  const HomeServiceLoadActivities();
}

/// Toggle activity selection (Step 1)
class HomeServiceToggleActivitySelection extends HomeServiceEvent {
  final HomeActivityEntity activity;

  const HomeServiceToggleActivitySelection({required this.activity});

  @override
  List<Object?> get props => [activity];
}

/// Select activity and add date
class HomeServiceSelectActivityAndDate extends HomeServiceEvent {
  final HomeActivityEntity activity;
  final DateTime date;

  const HomeServiceSelectActivityAndDate({
    required this.activity,
    required this.date,
  });

  @override
  List<Object?> get props => [activity, date];
}

/// Remove activity date
class HomeServiceRemoveActivityDate extends HomeServiceEvent {
  final HomeActivityEntity activity;
  final DateTime date;

  const HomeServiceRemoveActivityDate({
    required this.activity,
    required this.date,
  });

  @override
  List<Object?> get props => [activity, date];
}

/// Select time for activity date
class HomeServiceSelectTime extends HomeServiceEvent {
  final HomeActivityEntity activity;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;

  const HomeServiceSelectTime({
    required this.activity,
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object?> get props => [activity, date, startTime, endTime];
}

/// Load free staff for selected dates and times
class HomeServiceLoadFreeStaff extends HomeServiceEvent {
  const HomeServiceLoadFreeStaff();
}

/// Select staff
class HomeServiceSelectStaff extends HomeServiceEvent {
  final HomeStaffEntity staff;

  const HomeServiceSelectStaff(this.staff);

  @override
  List<Object?> get props => [staff];
}

/// Create booking
class HomeServiceCreateBooking extends HomeServiceEvent {
  const HomeServiceCreateBooking();
}

/// Create payment link
class HomeServiceCreatePaymentLink extends HomeServiceEvent {
  final String type; // Full

  const HomeServiceCreatePaymentLink({this.type = 'Full'});

  @override
  List<Object?> get props => [type];
}

/// Check payment status
class HomeServiceCheckPaymentStatus extends HomeServiceEvent {
  final String orderCode;

  const HomeServiceCheckPaymentStatus(this.orderCode);

  @override
  List<Object?> get props => [orderCode];
}

/// Cancel booking
class HomeServiceCancelBooking extends HomeServiceEvent {
  final int bookingId;

  const HomeServiceCancelBooking(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}

/// Reset state
class HomeServiceReset extends HomeServiceEvent {
  const HomeServiceReset();
}
