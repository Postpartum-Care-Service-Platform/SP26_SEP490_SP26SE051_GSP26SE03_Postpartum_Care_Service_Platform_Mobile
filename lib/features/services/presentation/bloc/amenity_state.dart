import 'package:equatable/equatable.dart';
import '../../domain/entities/amenity_service_entity.dart';
import '../../domain/entities/amenity_ticket_entity.dart';

/// Amenity States
abstract class AmenityState extends Equatable {
  const AmenityState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AmenityInitial extends AmenityState {
  const AmenityInitial();
}

/// Loading state
class AmenityLoading extends AmenityState {
  const AmenityLoading();
}

/// Loaded state
class AmenityLoaded extends AmenityState {
  final List<AmenityServiceEntity> services;
  final List<AmenityTicketEntity> tickets;
  final bool isLoadingServices;
  final bool isLoadingTickets;
  final bool isCreatingTicket;

  const AmenityLoaded({
    required this.services,
    required this.tickets,
    this.isLoadingServices = false,
    this.isLoadingTickets = false,
    this.isCreatingTicket = false,
  });

  AmenityLoaded copyWith({
    List<AmenityServiceEntity>? services,
    List<AmenityTicketEntity>? tickets,
    bool? isLoadingServices,
    bool? isLoadingTickets,
    bool? isCreatingTicket,
  }) {
    return AmenityLoaded(
      services: services ?? this.services,
      tickets: tickets ?? this.tickets,
      isLoadingServices: isLoadingServices ?? this.isLoadingServices,
      isLoadingTickets: isLoadingTickets ?? this.isLoadingTickets,
      isCreatingTicket: isCreatingTicket ?? this.isCreatingTicket,
    );
  }

  @override
  List<Object?> get props => [
        services,
        tickets,
        isLoadingServices,
        isLoadingTickets,
        isCreatingTicket,
      ];
}

/// Error state
class AmenityError extends AmenityState {
  final String message;

  const AmenityError(this.message);

  @override
  List<Object?> get props => [message];
}
