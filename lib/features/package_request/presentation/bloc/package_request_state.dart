import 'package:equatable/equatable.dart';
import '../../domain/entities/package_request_entity.dart';

abstract class PackageRequestState extends Equatable {
  const PackageRequestState();

  @override
  List<Object?> get props => [];
}

class PackageRequestInitial extends PackageRequestState {}

class PackageRequestLoading extends PackageRequestState {}

class PackageRequestsLoaded extends PackageRequestState {
  final List<PackageRequestEntity> requests;

  const PackageRequestsLoaded(this.requests);

  @override
  List<Object?> get props => [requests];
}

class PackageRequestDetailLoaded extends PackageRequestState {
  final PackageRequestEntity request;

  const PackageRequestDetailLoaded(this.request);

  @override
  List<Object?> get props => [request];
}

class PackageRequestCreated extends PackageRequestState {
  final PackageRequestEntity request;

  const PackageRequestCreated(this.request);

  @override
  List<Object?> get props => [request];
}

class PackageRequestActionLoading extends PackageRequestState {}

class PackageRequestActionSuccess extends PackageRequestState {
  final String message;

  const PackageRequestActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class PackageRequestError extends PackageRequestState {
  final String message;

  const PackageRequestError(this.message);

  @override
  List<Object?> get props => [message];
}
