import 'package:equatable/equatable.dart';

class WalletTransactionModel extends Equatable {
  final int? id;
  final double amount;
  final String? type;
  final String? description;
  final DateTime? createdAt;
  final String? status;

  const WalletTransactionModel({
    this.id,
    required this.amount,
    this.type,
    this.description,
    this.createdAt,
    this.status,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      id: json['id'] as int?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: json['type'] as String?,
      description: json['description'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
      status: json['status'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, amount, type, description, createdAt, status];
}
