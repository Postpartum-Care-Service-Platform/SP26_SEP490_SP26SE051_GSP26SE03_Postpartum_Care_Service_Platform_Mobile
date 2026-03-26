import 'package:equatable/equatable.dart';
import '../../../domain/entities/amenity_ticket_entity.dart';

/// Base class for AmenityTicket States
abstract class AmenityTicketState extends Equatable {
  const AmenityTicketState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AmenityTicketInitial extends AmenityTicketState {
  const AmenityTicketInitial();
}

/// Loading state
class AmenityTicketLoading extends AmenityTicketState {
  const AmenityTicketLoading();
}

/// Loaded state with tickets list
class AmenityTicketLoaded extends AmenityTicketState {
  final List<AmenityTicketEntity> tickets;

  const AmenityTicketLoaded(this.tickets);

  @override
  List<Object?> get props => [tickets];
}

/// Booking created successfully
class ServiceBookingCreated extends AmenityTicketState {
  final List<AmenityTicketEntity> tickets;
  final String message;

  const ServiceBookingCreated({
    required this.tickets,
    this.message = 'Đặt dịch vụ thành công',
  });

  @override
  List<Object?> get props => [tickets, message];
}

/// Action success state (confirm/complete/cancel)
class AmenityTicketActionSuccess extends AmenityTicketState {
  final String message;

  const AmenityTicketActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// Error state
class AmenityTicketError extends AmenityTicketState {
  final String message;

  const AmenityTicketError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Empty state (no tickets)
class AmenityTicketEmpty extends AmenityTicketState {
  const AmenityTicketEmpty();
}

/// Ticket updated successfully
class TicketUpdated extends AmenityTicketState {
  final AmenityTicketEntity ticket;
  final String message;

  const TicketUpdated({
    required this.ticket,
    this.message = 'Cập nhật ticket thành công',
  });

  @override
  List<Object?> get props => [ticket, message];
}

/// Single ticket loaded
class TicketLoaded extends AmenityTicketState {
  final AmenityTicketEntity ticket;

  const TicketLoaded(this.ticket);

  @override
  List<Object?> get props => [ticket];
}