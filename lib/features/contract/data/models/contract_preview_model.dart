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
    // Nếu có payload 'data' và nó là map (thường gặp khi wrap response)
    var payload = json;
    if (json.containsKey('data') && json['data'] is Map) {
      final dataMap = json['data'] as Map;
      if (dataMap.containsKey('contractCode') || dataMap.containsKey('htmlContent')) {
        payload = dataMap.cast<String, dynamic>();
      }
    }

    // Đọc an toàn (thử cả camelCase và PascalCase)
    String? getStr(String key) {
      final val = payload[key] ?? payload[key.substring(0, 1).toUpperCase() + key.substring(1)];
      return val?.toString();
    }

    return ContractPreviewModel(
      bookingId: _asInt(payload['bookingId']) ?? _asInt(payload['BookingId']) ?? 0,
      contractCode: getStr('contractCode') ?? '',
      htmlContent: getStr('htmlContent') ?? '',
      customerName: getStr('customerName')?.trim(),
      customerEmail: getStr('customerEmail')?.trim(),
      customerPhone: getStr('customerPhone')?.trim(),
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

