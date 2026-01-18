import '../../domain/entities/payment_status_entity.dart';

/// Payment Status Model - Data layer
class PaymentStatusModel {
  final String status;
  final double amount;
  final String transactionId;
  final int bookingId;
  final String bookingStatus;
  final bool contractCreated;
  final int? contractId;

  PaymentStatusModel({
    required this.status,
    required this.amount,
    required this.transactionId,
    required this.bookingId,
    required this.bookingStatus,
    required this.contractCreated,
    this.contractId,
  });

  factory PaymentStatusModel.fromJson(Map<String, dynamic> json) {
    return PaymentStatusModel(
      status: json['status'] as String,
      amount: (json['amount'] as num).toDouble(),
      transactionId: json['transactionId'] as String,
      bookingId: json['bookingId'] as int,
      bookingStatus: json['bookingStatus'] as String,
      contractCreated: json['contractCreated'] as bool,
      contractId: json['contractId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'amount': amount,
      'transactionId': transactionId,
      'bookingId': bookingId,
      'bookingStatus': bookingStatus,
      'contractCreated': contractCreated,
      'contractId': contractId,
    };
  }

  PaymentStatusEntity toEntity() {
    return PaymentStatusEntity(
      status: status,
      amount: amount,
      transactionId: transactionId,
      bookingId: bookingId,
      bookingStatus: bookingStatus,
      contractCreated: contractCreated,
      contractId: contractId,
    );
  }
}
