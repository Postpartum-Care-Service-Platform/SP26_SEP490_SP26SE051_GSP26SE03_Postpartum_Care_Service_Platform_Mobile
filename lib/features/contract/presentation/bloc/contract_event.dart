import 'package:equatable/equatable.dart';

/// Contract Events
abstract class ContractEvent extends Equatable {
  const ContractEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load contract by booking ID
class ContractLoadByBookingId extends ContractEvent {
  final int bookingId;

  const ContractLoadByBookingId(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}

/// Event to export contract PDF
class ContractExportPdf extends ContractEvent {
  final int contractId;

  const ContractExportPdf(this.contractId);

  @override
  List<Object?> get props => [contractId];
}
