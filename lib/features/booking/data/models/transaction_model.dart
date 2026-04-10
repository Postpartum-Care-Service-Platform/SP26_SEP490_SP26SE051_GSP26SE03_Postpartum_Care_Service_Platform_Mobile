import '../../domain/entities/transaction_entity.dart';

/// Transaction Model - Data layer
class TransactionModel {
  final String id;
  final double amount;
  final String type;
  final String status;
  final String paymentMethod;
  final DateTime transactionDate;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.status,
    required this.paymentMethod,
    required this.transactionDate,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: (json['id'] as String?) ?? '',
      amount: ((json['amount'] as num?) ?? 0).toDouble(),
      type: (json['type'] as String?) ?? '',
      status: (json['status'] as String?) ?? '',
      paymentMethod: (json['paymentMethod'] as String?) ?? '',
      transactionDate:
          DateTime.tryParse((json['transactionDate'] as String?) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'type': type,
      'status': status,
      'paymentMethod': paymentMethod,
      'transactionDate': transactionDate.toIso8601String(),
    };
  }

  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      amount: amount,
      type: type,
      status: status,
      paymentMethod: paymentMethod,
      transactionDate: transactionDate,
    );
  }
}
