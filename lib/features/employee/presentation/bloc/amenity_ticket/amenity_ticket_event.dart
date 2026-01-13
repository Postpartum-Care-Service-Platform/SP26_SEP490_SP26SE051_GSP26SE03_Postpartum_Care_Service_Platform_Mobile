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
  final List<int> serviceIds;
  final DateTime startTime;
  final DateTime endTime;
  final String? notes;

  const CreateServiceBookingEvent({
    required this.customerId,
    required this.serviceIds,
    required this.startTime,
    required this.endTime,
    this.notes,
  });

  @override
  List<Object?> get props => [customerId, serviceIds, startTime, endTime, notes];
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

/// Event to refresh tickets
class RefreshTickets extends AmenityTicketEvent {
  const RefreshTickets();
}
