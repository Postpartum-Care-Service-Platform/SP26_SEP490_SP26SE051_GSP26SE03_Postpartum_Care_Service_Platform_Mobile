import 'package:equatable/equatable.dart';

class WalletModel extends Equatable {
  final int? id;
  final double balance;
  final String? accountId;

  const WalletModel({
    this.id,
    required this.balance,
    this.accountId,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] as int?,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      accountId: json['accountId'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, balance, accountId];
}
