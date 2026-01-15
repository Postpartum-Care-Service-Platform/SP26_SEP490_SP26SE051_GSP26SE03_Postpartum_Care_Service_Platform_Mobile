import 'package:equatable/equatable.dart';

class SupportRequest extends Equatable {
  final int id;
  final int conversationId;
  final String reason;
  final String status;
  final DateTime createdAt;
  final DateTime? assignedAt;
  final DateTime? resolvedAt;
  final String? customer;
  final String? staff;

  const SupportRequest({
    required this.id,
    required this.conversationId,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.assignedAt,
    this.resolvedAt,
    this.customer,
    this.staff,
  });

  @override
  List<Object?> get props => [
        id,
        conversationId,
        reason,
        status,
        createdAt,
        assignedAt,
        resolvedAt,
        customer,
        staff,
      ];
}

