import 'package:equatable/equatable.dart';

/// Staff Schedule Events
abstract class StaffScheduleEvent extends Equatable {
  const StaffScheduleEvent();

  @override
  List<Object?> get props => [];
}

class LoadStaffSchedulesByDateRange extends StaffScheduleEvent {
  final String from;
  final String to;

  const LoadStaffSchedulesByDateRange({required this.from, required this.to});

  @override
  List<Object?> get props => [from, to];
}
