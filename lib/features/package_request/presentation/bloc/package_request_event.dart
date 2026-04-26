import 'package:equatable/equatable.dart';
import '../../data/models/create_package_request_model.dart';

abstract class PackageRequestEvent extends Equatable {
  const PackageRequestEvent();

  @override
  List<Object?> get props => [];
}

class LoadPackageRequests extends PackageRequestEvent {
  const LoadPackageRequests();
}

class LoadPackageRequestDetail extends PackageRequestEvent {
  final int id;

  const LoadPackageRequestDetail(this.id);

  @override
  List<Object?> get props => [id];
}

class CreatePackageRequestEvent extends PackageRequestEvent {
  final CreatePackageRequestModel request;

  const CreatePackageRequestEvent(this.request);

  @override
  List<Object?> get props => [request];
}

class ApprovePackageRequest extends PackageRequestEvent {
  final int id;

  const ApprovePackageRequest(this.id);

  @override
  List<Object?> get props => [id];
}

class RejectPackageRequest extends PackageRequestEvent {
  final int id;

  const RejectPackageRequest(this.id);

  @override
  List<Object?> get props => [id];
}

class RequestRevisionPackageRequest extends PackageRequestEvent {
  final int id;
  final String feedback;

  const RequestRevisionPackageRequest(this.id, this.feedback);

  @override
  List<Object?> get props => [id, feedback];
}
