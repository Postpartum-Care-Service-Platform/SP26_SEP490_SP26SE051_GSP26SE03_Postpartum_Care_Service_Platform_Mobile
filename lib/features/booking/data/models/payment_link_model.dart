import '../../domain/entities/payment_link_entity.dart';

/// Payment Link Model - Data layer
class PaymentLinkModel {
  final String paymentUrl;
  final String orderCode;
  final String qrCode;
  final String transactionId;
  final int bookingId;
  final double amount;

  PaymentLinkModel({
    required this.paymentUrl,
    required this.orderCode,
    required this.qrCode,
    required this.transactionId,
    required this.bookingId,
    required this.amount,
  });

  factory PaymentLinkModel.fromJson(Map<String, dynamic> json) {
    return PaymentLinkModel(
      paymentUrl: json['paymentUrl'] as String,
      orderCode: json['orderCode'] as String,
      qrCode: json['qrCode'] as String,
      transactionId: json['transactionId'] as String,
      bookingId: json['bookingId'] as int,
      amount: (json['amount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentUrl': paymentUrl,
      'orderCode': orderCode,
      'qrCode': qrCode,
      'transactionId': transactionId,
      'bookingId': bookingId,
      'amount': amount,
    };
  }

  PaymentLinkEntity toEntity() {
    return PaymentLinkEntity(
      paymentUrl: paymentUrl,
      orderCode: orderCode,
      qrCode: qrCode,
      transactionId: transactionId,
      bookingId: bookingId,
      amount: amount,
    );
  }
}
