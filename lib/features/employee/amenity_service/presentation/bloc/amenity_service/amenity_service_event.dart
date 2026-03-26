import 'package:equatable/equatable.dart';

/// Base class for AmenityService Events
abstract class AmenityServiceEvent extends Equatable {
  const AmenityServiceEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all amenity services
class LoadAllAmenityServices extends AmenityServiceEvent {
  const LoadAllAmenityServices();
}

/// Event to load amenity service by ID
class LoadAmenityServiceById extends AmenityServiceEvent {
  final int serviceId;

  const LoadAmenityServiceById(this.serviceId);

  @override
  List<Object?> get props => [serviceId];
}

/// Event to load active amenity services only
class LoadActiveAmenityServices extends AmenityServiceEvent {
  const LoadActiveAmenityServices();
}

/// Event to refresh amenity services
class RefreshAmenityServices extends AmenityServiceEvent {
  const RefreshAmenityServices();
}
