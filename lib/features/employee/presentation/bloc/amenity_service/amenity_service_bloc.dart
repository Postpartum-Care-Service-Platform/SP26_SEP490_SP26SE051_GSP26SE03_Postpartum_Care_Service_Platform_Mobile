import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_all_amenity_services.dart';
import '../../../domain/usecases/get_amenity_service_by_id.dart';
import '../../../domain/usecases/get_active_amenity_services.dart';
import 'amenity_service_event.dart';
import 'amenity_service_state.dart';

/// BLoC for managing amenity service state
class AmenityServiceBloc extends Bloc<AmenityServiceEvent, AmenityServiceState> {
  final GetAllAmenityServices getAllAmenityServices;
  final GetAmenityServiceById getAmenityServiceById;
  final GetActiveAmenityServices getActiveAmenityServices;

  AmenityServiceBloc({
    required this.getAllAmenityServices,
    required this.getAmenityServiceById,
    required this.getActiveAmenityServices,
  }) : super(const AmenityServiceInitial()) {
    // Register event handlers
    on<LoadAllAmenityServices>(_onLoadAllAmenityServices);
    on<LoadAmenityServiceById>(_onLoadAmenityServiceById);
    on<LoadActiveAmenityServices>(_onLoadActiveAmenityServices);
    on<RefreshAmenityServices>(_onRefreshAmenityServices);
  }

  /// Handle load all amenity services
  Future<void> _onLoadAllAmenityServices(
    LoadAllAmenityServices event,
    Emitter<AmenityServiceState> emit,
  ) async {
    emit(const AmenityServiceLoading());

    try {
      final services = await getAllAmenityServices();
      
      if (services.isEmpty) {
        emit(const AmenityServiceEmpty());
      } else {
        emit(AmenityServiceLoaded(services));
      }
    } catch (e) {
      emit(AmenityServiceError(e.toString()));
    }
  }

  /// Handle load amenity service by ID
  Future<void> _onLoadAmenityServiceById(
    LoadAmenityServiceById event,
    Emitter<AmenityServiceState> emit,
  ) async {
    emit(const AmenityServiceLoading());

    try {
      final service = await getAmenityServiceById(event.serviceId);
      emit(AmenityServiceDetailLoaded(service));
    } catch (e) {
      emit(AmenityServiceError(e.toString()));
    }
  }

  /// Handle load active amenity services
  Future<void> _onLoadActiveAmenityServices(
    LoadActiveAmenityServices event,
    Emitter<AmenityServiceState> emit,
  ) async {
    emit(const AmenityServiceLoading());

    try {
      final services = await getActiveAmenityServices();
      
      if (services.isEmpty) {
        emit(const AmenityServiceEmpty());
      } else {
        emit(AmenityServiceLoaded(services));
      }
    } catch (e) {
      emit(AmenityServiceError(e.toString()));
    }
  }

  /// Handle refresh amenity services
  Future<void> _onRefreshAmenityServices(
    RefreshAmenityServices event,
    Emitter<AmenityServiceState> emit,
  ) async {
    // Reload all services by default
    add(const LoadAllAmenityServices());
  }
}
