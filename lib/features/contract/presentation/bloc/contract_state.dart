import 'package:equatable/equatable.dart';
import '../../domain/entities/contract_entity.dart';

/// Contract States
abstract class ContractState extends Equatable {
  const ContractState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ContractInitial extends ContractState {}

/// Loading state
class ContractLoading extends ContractState {}

/// Contract loaded successfully
class ContractLoaded extends ContractState {
  final ContractEntity contract;

  const ContractLoaded(this.contract);

  @override
  List<Object?> get props => [contract];
}

/// PDF exported successfully
class ContractPdfExported extends ContractState {
  final List<int> pdfBytes;
  final int contractId;

  const ContractPdfExported({
    required this.pdfBytes,
    required this.contractId,
  });

  @override
  List<Object?> get props => [pdfBytes, contractId];
}

/// Error state
class ContractError extends ContractState {
  final String message;

  const ContractError(this.message);

  @override
  List<Object?> get props => [message];
}
