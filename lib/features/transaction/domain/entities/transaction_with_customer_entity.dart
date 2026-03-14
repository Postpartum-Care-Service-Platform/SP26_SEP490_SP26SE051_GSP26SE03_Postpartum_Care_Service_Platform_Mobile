import 'package:equatable/equatable.dart';

class TransactionWithCustomerEntity extends Equatable {
  final String id;
  final int? bookingId;
  final double amount;
  final String type;
  final String paymentMethod;
  final DateTime transactionDate;
  final String status;
  final String? note;
  final String? customerId;
  final String? customerEmail;
  final String? customerUsername;

  const TransactionWithCustomerEntity({
    required this.id,
    required this.bookingId,
    required this.amount,
    required this.type,
    required this.paymentMethod,
    required this.transactionDate,
    required this.status,
    required this.note,
    required this.customerId,
    required this.customerEmail,
    required this.customerUsername,
  });

  @override
  List<Object?> get props => [
        id,
        bookingId,
        amount,
        type,
        paymentMethod,
        transactionDate,
        status,
        note,
        customerId,
        customerEmail,
        customerUsername,
      ];
}

