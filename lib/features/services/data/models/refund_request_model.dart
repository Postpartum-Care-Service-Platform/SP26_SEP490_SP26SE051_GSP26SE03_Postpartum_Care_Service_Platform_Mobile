import '../../domain/entities/refund_request_entity.dart';

/// Refund Request model - data layer
class RefundRequestModel extends RefundRequestEntity {
  const RefundRequestModel({
    required super.id,
    required super.bookingId,
    super.customerId,
    super.requestedAmount,
    super.approvedAmount,
    required super.bankName,
    required super.accountNumber,
    required super.accountHolder,
    required super.reason,
    required super.status,
    super.adminNote,
    super.approvedBy,
    super.createdAt,
    super.approvedAt,
    super.processedAt,
  });

  factory RefundRequestModel.fromJson(Map<String, dynamic> json) {
    final rawRequestedAmount = json['requestedAmount'];
    final requestedAmount =
        rawRequestedAmount is num ? rawRequestedAmount.toDouble() : null;

    final rawApprovedAmount = json['approvedAmount'];
    final approvedAmount =
        rawApprovedAmount is num ? rawApprovedAmount.toDouble() : null;

    return RefundRequestModel(
      id: json['id'] as int,
      bookingId: json['bookingId'] as int,
      customerId: json['customerId'] as String?,
      requestedAmount: requestedAmount,
      approvedAmount: approvedAmount,
      bankName: json['bankName'] as String? ?? '',
      accountNumber: json['accountNumber'] as String? ?? '',
      accountHolder: json['accountHolder'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      status: json['status'] as String? ?? '',
      adminNote: json['adminNote'] as String?,
      approvedBy: json['approvedBy'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      approvedAt: json['approvedAt'] != null
          ? DateTime.tryParse(json['approvedAt'] as String)
          : null,
      processedAt: json['processedAt'] != null
          ? DateTime.tryParse(json['processedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'bookingId': bookingId,
        'customerId': customerId,
        'requestedAmount': requestedAmount,
        'approvedAmount': approvedAmount,
        'bankName': bankName,
        'accountNumber': accountNumber,
        'accountHolder': accountHolder,
        'reason': reason,
        'status': status,
        'adminNote': adminNote,
        'approvedBy': approvedBy,
        'createdAt': createdAt?.toIso8601String(),
        'approvedAt': approvedAt?.toIso8601String(),
        'processedAt': processedAt?.toIso8601String(),
      };

  RefundRequestEntity toEntity() => RefundRequestEntity(
        id: id,
        bookingId: bookingId,
        customerId: customerId,
        requestedAmount: requestedAmount,
        approvedAmount: approvedAmount,
        bankName: bankName,
        accountNumber: accountNumber,
        accountHolder: accountHolder,
        reason: reason,
        status: status,
        adminNote: adminNote,
        approvedBy: approvedBy,
        createdAt: createdAt,
        approvedAt: approvedAt,
        processedAt: processedAt,
      );
}
