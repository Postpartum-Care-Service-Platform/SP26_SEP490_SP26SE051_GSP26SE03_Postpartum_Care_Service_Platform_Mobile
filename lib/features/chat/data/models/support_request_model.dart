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
    DateTime? _parseDate(dynamic value) {
      if (value == null) return null;
      try {
        return DateTime.parse(value as String);
      } catch (_) {
        return null;
      }
    }

    return SupportRequestModel(
      id: json['id'] as int,
      conversationId: json['conversationId'] as int,
      reason: (json['reason'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      assignedAt: _parseDate(json['assignedAt']),
      resolvedAt: _parseDate(json['resolvedAt']),
      customer: json['customer']?.toString(),
      staff: json['staff']?.toString(),
    );
  }
}

