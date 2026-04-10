import 'package:equatable/equatable.dart';
import '../../../domain/entities/refund_request_entity.dart';

/// Refund Request States
abstract class RefundRequestState extends Equatable {
  const RefundRequestState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class RefundRequestInitial extends RefundRequestState {
  const RefundRequestInitial();
}

/// Loading state
class RefundRequestLoading extends RefundRequestState {
  const RefundRequestLoading();
}

/// Refund request created successfully
class RefundRequestCreated extends RefundRequestState {
  final List<RefundRequestEntity> requests;

  const RefundRequestCreated({required this.requests});

  @override
  List<Object?> get props => [requests];
}

/// My refund requests loaded
class RefundRequestLoaded extends RefundRequestState {
  final List<RefundRequestEntity> requests;

  const RefundRequestLoaded({required this.requests});

  @override
  List<Object?> get props => [requests];
}

/// Error state
class RefundRequestError extends RefundRequestState {
  final String message;

  const RefundRequestError({required this.message});

  @override
  List<Object?> get props => [message];
}
