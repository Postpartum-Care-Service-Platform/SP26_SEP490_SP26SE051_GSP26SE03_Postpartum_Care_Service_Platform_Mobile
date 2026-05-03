import 'package:equatable/equatable.dart';

/// Refund Request entity - domain layer
class RefundRequestEntity extends Equatable {
  final int id;
  final int? bookingId;
  final String? customerId;
  final double? requestedAmount;
  final double? approvedAmount;
  final String bankName;
  final String accountNumber;
  final String accountHolder;
  final String reason;
  final String status;
  final String? adminNote;
  final String? approvedBy;
  final DateTime? createdAt;
  final DateTime? approvedAt;
  final DateTime? processedAt;

  const RefundRequestEntity({
    required this.id,
    this.bookingId,
    this.customerId,
    this.requestedAmount,
    this.approvedAmount,
    required this.bankName,
    required this.accountNumber,
    required this.accountHolder,
    required this.reason,
    required this.status,
    this.adminNote,
    this.approvedBy,
    this.createdAt,
    this.approvedAt,
    this.processedAt,
  });

  @override
  List<Object?> get props => [
        id,
        bookingId,
        customerId,
        requestedAmount,
        approvedAmount,
        bankName,
        accountNumber,
        accountHolder,
        reason,
        status,
        adminNote,
        approvedBy,
        createdAt,
        approvedAt,
        processedAt,
      ];
}
