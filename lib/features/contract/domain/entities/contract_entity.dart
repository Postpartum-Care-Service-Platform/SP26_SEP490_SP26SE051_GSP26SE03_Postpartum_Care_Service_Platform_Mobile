import 'package:equatable/equatable.dart';
import 'customer_entity.dart';

/// Contract Entity - Domain layer
class ContractEntity extends Equatable {
  final int id;
  final int bookingId;
  final String contractCode;
  final DateTime contractDate;
  final DateTime? effectiveFrom;
  final DateTime? effectiveTo;
  final DateTime? signedDate;
  final DateTime? sentAt;
  final String? fileUrl;
  final List<String>? images;
  final DateTime? checkinDate;
  final DateTime? checkoutDate;
  final String status; // Draft, Signed, etc.
  final DateTime createdAt;
  final CustomerEntity? customer;
  final String? htmlContent;
  final String? pdfContent;

  const ContractEntity({
    required this.id,
    required this.bookingId,
    required this.contractCode,
    required this.contractDate,
    this.effectiveFrom,
    this.effectiveTo,
    this.signedDate,
    this.sentAt,
    this.fileUrl,
    this.images,
    this.checkinDate,
    this.checkoutDate,
    required this.status,
    required this.createdAt,
    this.customer,
    this.htmlContent,
    this.pdfContent,
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
        sentAt,
        fileUrl,
        images,
        checkinDate,
        checkoutDate,
        status,
        createdAt,
        customer,
        htmlContent,
        pdfContent,
      ];
}
