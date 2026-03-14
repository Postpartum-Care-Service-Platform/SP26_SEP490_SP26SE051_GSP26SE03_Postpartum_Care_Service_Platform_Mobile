import '../../domain/entities/transaction_with_customer_entity.dart';

class TransactionWithCustomerModel {
  final String id;
  final int? bookingId;
  final double amount;
  final String? type;
  final String? paymentMethod;
  final DateTime transactionDate;
  final String status;
  final String? note;
  final String? customerId;
  final String? customerEmail;
  final String? customerUsername;

  TransactionWithCustomerModel({
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

  factory TransactionWithCustomerModel.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'] as Map<String, dynamic>?;
    return TransactionWithCustomerModel(
      id: json['id'].toString(),
      bookingId: json['bookingId'] as int?,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
      transactionDate: DateTime.parse(json['transactionDate'] as String),
      status: json['status'] as String,
      note: json['note'] as String?,
      customerId: customer?['id']?.toString(),
      customerEmail: customer?['email'] as String?,
      customerUsername: customer?['username'] as String?,
    );
  }

  TransactionWithCustomerEntity toEntity() {
    return TransactionWithCustomerEntity(
      id: id,
      bookingId: bookingId,
      amount: amount,
      type: type ?? '',
      paymentMethod: paymentMethod ?? '',
      transactionDate: transactionDate,
      status: status,
      note: note,
      customerId: customerId,
      customerEmail: customerEmail,
      customerUsername: customerUsername,
    );
  }
}

