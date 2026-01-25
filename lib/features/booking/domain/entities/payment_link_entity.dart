import 'package:equatable/equatable.dart';

/// Payment Link Entity - Domain layer
class PaymentLinkEntity extends Equatable {
  final String paymentUrl;
  final String orderCode;
  final String qrCode;
  final String transactionId;
  final int bookingId;
  final double amount;

  const PaymentLinkEntity({
    required this.paymentUrl,
    required this.orderCode,
    required this.qrCode,
    required this.transactionId,
    required this.bookingId,
    required this.amount,
  });

  @override
  List<Object?> get props => [
        paymentUrl,
        orderCode,
        qrCode,
        transactionId,
        bookingId,
        amount,
      ];
}
