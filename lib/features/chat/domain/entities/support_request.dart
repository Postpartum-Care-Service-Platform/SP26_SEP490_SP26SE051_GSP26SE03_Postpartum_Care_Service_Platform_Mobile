import 'package:equatable/equatable.dart';

class SupportRequestCustomer extends Equatable {
  final String id;
  final String email;
  final String username;
  final String? phone;
  final String? fullName;
  final String? avatarUrl;

  const SupportRequestCustomer({
    required this.id,
    required this.email,
    required this.username,
    this.phone,
    this.fullName,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, email, username, phone, fullName, avatarUrl];
}

class SupportRequest extends Equatable {
  final int id;
  final int conversationId;
  final String reason;
  final String status;
  final DateTime createdAt;
  final DateTime? assignedAt;
  final DateTime? resolvedAt;
  final SupportRequestCustomer? customer;
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

