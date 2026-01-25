import '../../domain/entities/contract_entity.dart';

/// Contract Model - Data layer
class ContractModel {
  final int id;
  final String contractCode;
  final String status;
  final String? fileUrl;

  ContractModel({
    required this.id,
    required this.contractCode,
    required this.status,
    this.fileUrl,
  });

  factory ContractModel.fromJson(Map<String, dynamic> json) {
    return ContractModel(
      id: json['id'] as int,
      contractCode: json['contractCode'] as String,
      status: json['status'] as String,
      fileUrl: json['fileUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contractCode': contractCode,
      'status': status,
      'fileUrl': fileUrl,
    };
  }

  ContractEntity toEntity() {
    return ContractEntity(
      id: id,
      contractCode: contractCode,
      status: status,
      fileUrl: fileUrl,
    );
  }
}
