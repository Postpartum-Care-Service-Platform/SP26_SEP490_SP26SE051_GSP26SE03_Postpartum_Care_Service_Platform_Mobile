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
    super.sentAt,
    super.fileUrl,
    super.images,
    super.checkinDate,
    super.checkoutDate,
    required super.status,
    required super.createdAt,
    super.customer,
    super.htmlContent,
    super.pdfContent,
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
      sentAt: json['sentAt'] != null
          ? DateTime.parse(json['sentAt'] as String)
          : null,
      fileUrl: json['fileUrl'] as String?,
      images: json['images'] != null
          ? (json['images'] as List).map((e) => e as String).toList()
          : null,
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
      htmlContent: json['htmlContent'] as String?,
      pdfContent: json['pdfContent'] as String?,
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
      'sentAt': sentAt?.toIso8601String(),
      'fileUrl': fileUrl,
      'images': images,
      'checkinDate': checkinDate?.toIso8601String(),
      'checkoutDate': checkoutDate?.toIso8601String(),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'customer': customer != null
          ? (customer as CustomerModel).toJson()
          : null,
      'htmlContent': htmlContent,
      'pdfContent': pdfContent,
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
      sentAt: sentAt,
      fileUrl: fileUrl,
      images: images,
      checkinDate: checkinDate,
      checkoutDate: checkoutDate,
      status: status,
      createdAt: createdAt,
      customer: customer,
      htmlContent: htmlContent,
      pdfContent: pdfContent,
    );
  }
}
