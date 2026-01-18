import '../../domain/entities/contract_entity.dart';
import 'customer_model.dart';

/// Contract Model - Data layer
class ContractModel extends ContractEntity {
  const ContractModel({
    required super.id,
    required super.bookingId,
    required super.contractCode,
    required super.contractDate,
    required super.effectiveFrom,
    required super.effectiveTo,
    super.signedDate,
    super.fileUrl,
    super.checkinDate,
    super.checkoutDate,
    required super.status,
    required super.createdAt,
    super.customer,
  });

  factory ContractModel.fromJson(Map<String, dynamic> json) {
    return ContractModel(
      id: json['id'] as int,
      bookingId: json['bookingId'] as int,
      contractCode: json['contractCode'] as String,
      contractDate: DateTime.parse(json['contractDate'] as String),
      effectiveFrom: DateTime.parse(json['effectiveFrom'] as String),
      effectiveTo: DateTime.parse(json['effectiveTo'] as String),
      signedDate: json['signedDate'] != null
          ? DateTime.parse(json['signedDate'] as String)
          : null,
      fileUrl: json['fileUrl'] as String?,
      checkinDate: json['checkinDate'] != null
          ? DateTime.parse(json['checkinDate'] as String)
          : null,
      checkoutDate: json['checkoutDate'] != null
          ? DateTime.parse(json['checkoutDate'] as String)
          : null,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      customer: json['customer'] != null
          ? CustomerModel.fromJson(json['customer'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'contractCode': contractCode,
      'contractDate': contractDate.toIso8601String(),
      'effectiveFrom': effectiveFrom.toIso8601String(),
      'effectiveTo': effectiveTo.toIso8601String(),
      'signedDate': signedDate?.toIso8601String(),
      'fileUrl': fileUrl,
      'checkinDate': checkinDate?.toIso8601String(),
      'checkoutDate': checkoutDate?.toIso8601String(),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'customer': customer != null
          ? (customer as CustomerModel).toJson()
          : null,
    };
  }

  ContractEntity toEntity() {
    return ContractEntity(
      id: id,
      bookingId: bookingId,
      contractCode: contractCode,
      contractDate: contractDate,
      effectiveFrom: effectiveFrom,
      effectiveTo: effectiveTo,
      signedDate: signedDate,
      fileUrl: fileUrl,
      checkinDate: checkinDate,
      checkoutDate: checkoutDate,
      status: status,
      createdAt: createdAt,
      customer: customer,
    );
  }
}
