import 'package:equatable/equatable.dart';

/// Transaction Entity - Domain layer
class TransactionEntity extends Equatable {
  final String id;
  final double amount;
  final String type; // Deposit, Remaining
  final String status; // Pending, Paid, Failed
  final String paymentMethod; // PayOS, etc.
  final DateTime transactionDate;

  const TransactionEntity({
    required this.id,
    required this.amount,
    required this.type,
    required this.status,
    required this.paymentMethod,
    required this.transactionDate,
  });

  @override
  List<Object?> get props => [
        id,
        amount,
        type,
        status,
        paymentMethod,
        transactionDate,
      ];
}
