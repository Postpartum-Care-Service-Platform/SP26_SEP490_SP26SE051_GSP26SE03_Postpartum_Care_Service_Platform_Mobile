class ContractPreviewModel {
  final int bookingId;
  final String contractCode;
  final String htmlContent;

  ContractPreviewModel({
    required this.bookingId,
    required this.contractCode,
    required this.htmlContent,
  });

  factory ContractPreviewModel.fromJson(Map<String, dynamic> json) {
    return ContractPreviewModel(
      bookingId: json['bookingId'] as int,
      contractCode: json['contractCode'] as String,
      htmlContent: json['htmlContent'] as String,
    );
  }
}

