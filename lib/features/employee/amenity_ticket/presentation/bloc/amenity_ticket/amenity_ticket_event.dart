import 'package:equatable/equatable.dart';

/// Base class for AmenityTicket Events
abstract class AmenityTicketEvent extends Equatable {
  const AmenityTicketEvent();

  @override
  List<Object?> get props => [];
}

/// Event to create service booking
class CreateServiceBookingEvent extends AmenityTicketEvent {
  final String customerId;
  final int amenityServiceId;
  final String date;
  final String startTime;
  final String endTime;

  const CreateServiceBookingEvent({
    required this.customerId,
    required this.amenityServiceId,
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object?> get props => [customerId, amenityServiceId, date, startTime, endTime];
}

/// Event to load tickets by customer
class LoadTicketsByCustomer extends AmenityTicketEvent {
  final String customerId;

  const LoadTicketsByCustomer(this.customerId);

  @override
  List<Object?> get props => [customerId];
}

/// Event to load my assigned tickets
class LoadMyAssignedTickets extends AmenityTicketEvent {
  const LoadMyAssignedTickets();
}

/// Event to load all tickets
class LoadAllTickets extends AmenityTicketEvent {
  const LoadAllTickets();
}

/// Event to cancel ticket
class CancelTicketEvent extends AmenityTicketEvent {
  final int ticketId;

  const CancelTicketEvent(this.ticketId);

  @override
  List<Object?> get props => [ticketId];
}

/// Event to confirm ticket
class ConfirmTicketEvent extends AmenityTicketEvent {
  final int ticketId;

  const ConfirmTicketEvent(this.ticketId);

  @override
  List<Object?> get props => [ticketId];
}

/// Event to complete ticket
class CompleteTicketEvent extends AmenityTicketEvent {
  final int ticketId;

  const CompleteTicketEvent(this.ticketId);

  @override
  List<Object?> get props => [ticketId];
}

/// Event to update ticket
class UpdateTicketEvent extends AmenityTicketEvent {
  final int ticketId;
  final int amenityServiceId;
  final DateTime startTime;
  final DateTime endTime;

  const UpdateTicketEvent({
    required this.ticketId,
    required this.amenityServiceId,
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object?> get props => [ticketId, amenityServiceId, startTime, endTime];
}

/// Event to load ticket by ID
class LoadTicketById extends AmenityTicketEvent {
  final int ticketId;

  const LoadTicketById(this.ticketId);

  @override
  List<Object?> get props => [ticketId];
}

/// Event to refresh tickets
class RefreshTickets extends AmenityTicketEvent {
  const RefreshTickets();
}
