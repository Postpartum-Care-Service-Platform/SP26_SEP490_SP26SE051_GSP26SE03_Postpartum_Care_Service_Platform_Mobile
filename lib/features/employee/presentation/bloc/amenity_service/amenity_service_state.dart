import 'package:equatable/equatable.dart';
import '../../../domain/entities/amenity_service_entity.dart';

/// Base class for AmenityService States
abstract class AmenityServiceState extends Equatable {
  const AmenityServiceState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AmenityServiceInitial extends AmenityServiceState {
  const AmenityServiceInitial();
}

/// Loading state
class AmenityServiceLoading extends AmenityServiceState {
  const AmenityServiceLoading();
}

/// Loaded state with services list
class AmenityServiceLoaded extends AmenityServiceState {
  final List<AmenityServiceEntity> services;

  const AmenityServiceLoaded(this.services);

  @override
  List<Object?> get props => [services];
}

/// Single service detail loaded
class AmenityServiceDetailLoaded extends AmenityServiceState {
  final AmenityServiceEntity service;

  const AmenityServiceDetailLoaded(this.service);

  @override
  List<Object?> get props => [service];
}

/// Error state
class AmenityServiceError extends AmenityServiceState {
  final String message;

  const AmenityServiceError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Empty state (no services)
class AmenityServiceEmpty extends AmenityServiceState {
  const AmenityServiceEmpty();
}
