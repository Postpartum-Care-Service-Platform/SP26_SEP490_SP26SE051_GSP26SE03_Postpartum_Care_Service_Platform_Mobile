class ContractPreviewModel {
  final int bookingId;
  final String contractCode;
  final String htmlContent;
  final String? customerName;
  final String? customerEmail;
  final String? customerPhone;

  ContractPreviewModel({
    required this.bookingId,
    required this.contractCode,
    required this.htmlContent,
    this.customerName,
    this.customerEmail,
    this.customerPhone,
  });

  factory ContractPreviewModel.fromJson(Map<String, dynamic> json) {
    final payload = _asMap(json['data']) ?? json;

    return ContractPreviewModel(
      bookingId: _asInt(payload['bookingId']) ?? 0,
      contractCode: (payload['contractCode'] as String?) ?? '',
      htmlContent: (payload['htmlContent'] as String?) ?? '',
      customerName: (payload['customerName'] as String?)?.trim(),
      customerEmail: (payload['customerEmail'] as String?)?.trim(),
      customerPhone: (payload['customerPhone'] as String?)?.trim(),
    );
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.cast<String, dynamic>();
    return null;
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}

