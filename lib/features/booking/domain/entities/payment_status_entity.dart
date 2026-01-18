import 'package:equatable/equatable.dart';

/// Payment Status Entity - Domain layer
class PaymentStatusEntity extends Equatable {
  final String status; // Pending, Paid, Failed
  final double amount;
  final String transactionId;
  final int bookingId;
  final String bookingStatus; // Pending, Confirmed, Cancelled
  final bool contractCreated;
  final int? contractId;

  const PaymentStatusEntity({
    required this.status,
    required this.amount,
    required this.transactionId,
    required this.bookingId,
    required this.bookingStatus,
    required this.contractCreated,
    this.contractId,
  });

  @override
  List<Object?> get props => [
        status,
        amount,
        transactionId,
        bookingId,
        bookingStatus,
        contractCreated,
        contractId,
      ];
}
