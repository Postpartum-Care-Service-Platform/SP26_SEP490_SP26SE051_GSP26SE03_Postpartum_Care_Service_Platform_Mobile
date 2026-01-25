import 'package:equatable/equatable.dart';

/// Contract Entity - Domain layer
class ContractEntity extends Equatable {
  final int id;
  final String contractCode;
  final String status; // Draft, Signed, etc.
  final String? fileUrl;

  const ContractEntity({
    required this.id,
    required this.contractCode,
    required this.status,
    this.fileUrl,
  });

  @override
  List<Object?> get props => [id, contractCode, status, fileUrl];
}
