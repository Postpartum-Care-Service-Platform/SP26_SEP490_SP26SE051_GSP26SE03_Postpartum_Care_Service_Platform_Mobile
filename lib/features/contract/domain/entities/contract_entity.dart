import 'package:equatable/equatable.dart';
import 'customer_entity.dart';

/// Contract Entity - Domain layer
class ContractEntity extends Equatable {
  final int id;
  final int bookingId;
  final String contractCode;
  final DateTime contractDate;
  final DateTime effectiveFrom;
  final DateTime effectiveTo;
  final DateTime? signedDate;
  final String? fileUrl;
  final DateTime? checkinDate;
  final DateTime? checkoutDate;
  final String status; // Draft, Signed, etc.
  final DateTime createdAt;
  final CustomerEntity? customer;

  const ContractEntity({
    required this.id,
    required this.bookingId,
    required this.contractCode,
    required this.contractDate,
    required this.effectiveFrom,
    required this.effectiveTo,
    this.signedDate,
    this.fileUrl,
    this.checkinDate,
    this.checkoutDate,
    required this.status,
    required this.createdAt,
    this.customer,
  });

  @override
  List<Object?> get props => [
        id,
        bookingId,
        contractCode,
        contractDate,
        effectiveFrom,
        effectiveTo,
        signedDate,
        fileUrl,
        checkinDate,
        checkoutDate,
        status,
        createdAt,
        customer,
      ];
}
