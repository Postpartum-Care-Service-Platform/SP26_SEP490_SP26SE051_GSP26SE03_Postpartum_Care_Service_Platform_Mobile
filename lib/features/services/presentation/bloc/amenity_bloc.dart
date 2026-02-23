import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_amenity_services_usecase.dart';
import '../../domain/usecases/get_my_amenity_tickets_usecase.dart';
import '../../domain/usecases/create_amenity_ticket_usecase.dart';
import 'amenity_event.dart';
import 'amenity_state.dart';

/// Amenity BLoC
class AmenityBloc extends Bloc<AmenityEvent, AmenityState> {
  final GetAmenityServicesUsecase getAmenityServicesUsecase;
  final GetMyAmenityTicketsUsecase getMyAmenityTicketsUsecase;
  final CreateAmenityTicketUsecase createAmenityTicketUsecase;

  AmenityBloc({
    required this.getAmenityServicesUsecase,
    required this.getMyAmenityTicketsUsecase,
    required this.createAmenityTicketUsecase,
  }) : super(const AmenityInitial()) {
    on<AmenityServicesLoadRequested>(_onServicesLoadRequested);
    on<MyAmenityTicketsLoadRequested>(_onTicketsLoadRequested);
    on<AmenityTicketCreateRequested>(_onTicketCreateRequested);
    on<AmenityRefresh>(_onRefresh);
  }

  Future<void> _onServicesLoadRequested(
    AmenityServicesLoadRequested event,
    Emitter<AmenityState> emit,
  ) async {
    if (state is AmenityLoaded) {
      emit((state as AmenityLoaded).copyWith(isLoadingServices: true));
    } else {
      emit(const AmenityLoading());
    }

    try {
      final services = await getAmenityServicesUsecase();
      if (state is AmenityLoaded) {
        final currentState = state as AmenityLoaded;
        emit(currentState.copyWith(
          services: services,
          isLoadingServices: false,
        ));
      } else {
        emit(AmenityLoaded(
          services: services,
          tickets: const [],
          isLoadingServices: false,
        ));
      }
    } catch (e) {
      emit(AmenityError(e.toString()));
    }
  }

  Future<void> _onTicketsLoadRequested(
    MyAmenityTicketsLoadRequested event,
    Emitter<AmenityState> emit,
  ) async {
    if (state is AmenityLoaded) {
      emit((state as AmenityLoaded).copyWith(isLoadingTickets: true));
    } else {
      emit(const AmenityLoading());
    }

    try {
      final tickets = await getMyAmenityTicketsUsecase();
      if (state is AmenityLoaded) {
        final currentState = state as AmenityLoaded;
        emit(currentState.copyWith(
          tickets: tickets,
          isLoadingTickets: false,
        ));
      } else {
        emit(AmenityLoaded(
          services: const [],
          tickets: tickets,
          isLoadingTickets: false,
        ));
      }
    } catch (e) {
      emit(AmenityError(e.toString()));
    }
  }

  Future<void> _onTicketCreateRequested(
    AmenityTicketCreateRequested event,
    Emitter<AmenityState> emit,
  ) async {
    if (state is AmenityLoaded) {
      emit((state as AmenityLoaded).copyWith(isCreatingTicket: true));
    } else {
      emit(const AmenityLoading());
    }

    try {
      final ticket = await createAmenityTicketUsecase(
        amenityServiceId: event.amenityServiceId,
        startTime: event.startTime,
        endTime: event.endTime,
      );

      if (state is AmenityLoaded) {
        final currentState = state as AmenityLoaded;
        final updatedTickets = [ticket, ...currentState.tickets];
        emit(currentState.copyWith(
          tickets: updatedTickets,
          isCreatingTicket: false,
        ));
      } else {
        emit(AmenityLoaded(
          services: const [],
          tickets: [ticket],
          isCreatingTicket: false,
        ));
      }
    } catch (e) {
      emit(AmenityError(e.toString()));
    }
  }

  Future<void> _onRefresh(
    AmenityRefresh event,
    Emitter<AmenityState> emit,
  ) async {
    emit(const AmenityLoading());

    try {
      final services = await getAmenityServicesUsecase();
      final tickets = await getMyAmenityTicketsUsecase();

      emit(AmenityLoaded(
        services: services,
        tickets: tickets,
      ));
    } catch (e) {
      emit(AmenityError(e.toString()));
    }
  }
}
