import '../../domain/entities/support_request.dart';

class SupportRequestModel extends SupportRequest {
  const SupportRequestModel({
    required super.id,
    required super.conversationId,
    required super.reason,
    required super.status,
    required super.createdAt,
    super.assignedAt,
    super.resolvedAt,
    super.customer,
    super.staff,
  });

  factory SupportRequestModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      try {
        return DateTime.parse(value as String);
      } catch (_) {
        return null;
      }
    }

    SupportRequestCustomer? parseCustomer(dynamic value) {
      if (value == null) return null;
      if (value is Map<String, dynamic>) {
        return SupportRequestCustomer(
          id: value['id'] as String,
          email: (value['email'] ?? '').toString(),
          username: (value['username'] ?? '').toString(),
          phone: value['phone']?.toString(),
          fullName: value['fullName']?.toString(),
          avatarUrl: value['avatarUrl']?.toString(),
        );
      }
      return null;
    }

    return SupportRequestModel(
      id: json['id'] as int,
      conversationId: json['conversationId'] as int,
      reason: (json['reason'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      assignedAt: parseDate(json['assignedAt']),
      resolvedAt: parseDate(json['resolvedAt']),
      customer: parseCustomer(json['customer']),
      staff: json['staff']?.toString(),
    );
  }
}
