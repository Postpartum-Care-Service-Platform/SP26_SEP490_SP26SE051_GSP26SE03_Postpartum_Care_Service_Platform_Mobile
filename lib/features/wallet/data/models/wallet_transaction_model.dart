import 'package:equatable/equatable.dart';

class WalletTransactionModel extends Equatable {
  final int? id;
  final double amount;
  final String? type;
  final String? description;
  final DateTime? createdAt;
  final String? status;
  final String? packageName;


  const WalletTransactionModel({
    this.id,
    required this.amount,
    this.type,
    this.description,
    this.createdAt,
    this.status,
    this.packageName,
  });


  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      id: json['id'] as int?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: json['type'] as String?,
      description: (json['description'] ?? json['note']) as String?,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
      status: json['status'] as String?,
      packageName: json['bookingPackageName'] as String?,
    );

  }

  @override
  List<Object?> get props => [id, amount, type, description, createdAt, status, packageName];

}
