import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/create_service_booking.dart';
import '../../../domain/repositories/amenity_ticket_repository.dart';
import 'amenity_ticket_event.dart';
import 'amenity_ticket_state.dart';

/// BLoC for managing amenity ticket/booking state
class AmenityTicketBloc extends Bloc<AmenityTicketEvent, AmenityTicketState> {
  final CreateServiceBooking createServiceBooking;
  final AmenityTicketRepository repository;

  AmenityTicketBloc({
    required this.createServiceBooking,
    required this.repository,
  }) : super(const AmenityTicketInitial()) {
    // Register event handlers
    on<CreateServiceBookingEvent>(_onCreateServiceBooking);
    on<LoadTicketsByCustomer>(_onLoadTicketsByCustomer);
    on<LoadMyAssignedTickets>(_onLoadMyAssignedTickets);
    on<LoadAllTickets>(_onLoadAllTickets);
    on<CancelTicketEvent>(_onCancelTicket);
    on<ConfirmTicketEvent>(_onConfirmTicket);
    on<CompleteTicketEvent>(_onCompleteTicket);
    on<UpdateTicketEvent>(_onUpdateTicket);
    on<LoadTicketById>(_onLoadTicketById);
    on<RefreshTickets>(_onRefreshTickets);
  }

  /// Handle create service booking
  Future<void> _onCreateServiceBooking(
    CreateServiceBookingEvent event,
    Emitter<AmenityTicketState> emit,
  ) async {
    emit(const AmenityTicketLoading());

    try {
      final tickets = await createServiceBooking(
        customerId: event.customerId,
        serviceIds: event.serviceIds,
        startTime: event.startTime,
        endTime: event.endTime,
        notes: event.notes,
      );
      
      emit(ServiceBookingCreated(tickets: tickets));
    } catch (e) {
      emit(AmenityTicketError(e.toString()));
    }
  }

  /// Handle load tickets by customer
  Future<void> _onLoadTicketsByCustomer(
    LoadTicketsByCustomer event,
    Emitter<AmenityTicketState> emit,
  ) async {
    emit(const AmenityTicketLoading());

    try {
      final tickets = await repository.getTicketsByCustomer(event.customerId);
      
      if (tickets.isEmpty) {
        emit(const AmenityTicketEmpty());
      } else {
        emit(AmenityTicketLoaded(tickets));
      }
    } catch (e) {
      emit(AmenityTicketError(e.toString()));
    }
  }

  /// Handle load my assigned tickets
  Future<void> _onLoadMyAssignedTickets(
    LoadMyAssignedTickets event,
    Emitter<AmenityTicketState> emit,
  ) async {
    emit(const AmenityTicketLoading());

    try {
      final tickets = await repository.getMyAssignedTickets();
      
      if (tickets.isEmpty) {
        emit(const AmenityTicketEmpty());
      } else {
        emit(AmenityTicketLoaded(tickets));
      }
    } catch (e) {
      emit(AmenityTicketError(e.toString()));
    }
  }

  /// Handle load all tickets
  Future<void> _onLoadAllTickets(
    LoadAllTickets event,
    Emitter<AmenityTicketState> emit,
  ) async {
    emit(const AmenityTicketLoading());

    try {
      final tickets = await repository.getAllTickets();
      
      if (tickets.isEmpty) {
        emit(const AmenityTicketEmpty());
      } else {
        emit(AmenityTicketLoaded(tickets));
      }
    } catch (e) {
      emit(AmenityTicketError(e.toString()));
    }
  }

  /// Handle cancel ticket
  Future<void> _onCancelTicket(
    CancelTicketEvent event,
    Emitter<AmenityTicketState> emit,
  ) async {
    final currentState = state;
    emit(const AmenityTicketLoading());

    try {
      final message = await repository.cancelTicket(event.ticketId);
      emit(AmenityTicketActionSuccess(message));
      
      // Reload tickets after action
      if (currentState is AmenityTicketLoaded) {
        add(const RefreshTickets());
      }
    } catch (e) {
      emit(AmenityTicketError(e.toString()));
      
      // Restore previous state
      if (currentState is AmenityTicketLoaded) {
        emit(currentState);
      }
    }
  }

  /// Handle confirm ticket
  Future<void> _onConfirmTicket(
    ConfirmTicketEvent event,
    Emitter<AmenityTicketState> emit,
  ) async {
    final currentState = state;
    emit(const AmenityTicketLoading());

    try {
      final message = await repository.confirmTicket(event.ticketId);
      emit(AmenityTicketActionSuccess(message));
      
      if (currentState is AmenityTicketLoaded) {
        add(const RefreshTickets());
      }
    } catch (e) {
      emit(AmenityTicketError(e.toString()));
      
      if (currentState is AmenityTicketLoaded) {
        emit(currentState);
      }
    }
  }

  /// Handle complete ticket
  Future<void> _onCompleteTicket(
    CompleteTicketEvent event,
    Emitter<AmenityTicketState> emit,
  ) async {
    final currentState = state;
    emit(const AmenityTicketLoading());

    try {
      final message = await repository.completeTicket(event.ticketId);
      emit(AmenityTicketActionSuccess(message));
      
      if (currentState is AmenityTicketLoaded) {
        add(const RefreshTickets());
      }
    } catch (e) {
      emit(AmenityTicketError(e.toString()));
      
      if (currentState is AmenityTicketLoaded) {
        emit(currentState);
      }
    }
  }

  /// Handle update ticket
  Future<void> _onUpdateTicket(
    UpdateTicketEvent event,
    Emitter<AmenityTicketState> emit,
  ) async {
    final currentState = state;
    emit(const AmenityTicketLoading());

    try {
      final ticket = await repository.updateTicket(
        ticketId: event.ticketId,
        amenityServiceId: event.amenityServiceId,
        startTime: event.startTime,
        endTime: event.endTime,
      );
      
      emit(TicketUpdated(ticket: ticket));
      
      // Reload tickets if we have a loaded state
      if (currentState is AmenityTicketLoaded) {
        add(const RefreshTickets());
      }
    } catch (e) {
      emit(AmenityTicketError(e.toString()));
      
      if (currentState is AmenityTicketLoaded) {
        emit(currentState);
      }
    }
  }

  /// Handle load ticket by ID
  Future<void> _onLoadTicketById(
    LoadTicketById event,
    Emitter<AmenityTicketState> emit,
  ) async {
    emit(const AmenityTicketLoading());

    try {
      final ticket = await repository.getTicketById(event.ticketId);
      emit(TicketLoaded(ticket));
    } catch (e) {
      emit(AmenityTicketError(e.toString()));
    }
  }

  /// Handle refresh tickets
  Future<void> _onRefreshTickets(
    RefreshTickets event,
    Emitter<AmenityTicketState> emit,
  ) async {
    // Reload my assigned tickets by default
    add(const LoadMyAssignedTickets());
  }
}
