import 'package:equatable/equatable.dart';
import 'user_model.dart';

/// Login response model
class LoginResponseModel extends Equatable {
  final String accessToken;
  final String refreshToken;
  final String expiresAt;
  final UserModel user;

  const LoginResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      LoginResponseModel(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
        expiresAt: json['expiresAt'] as String,
        user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'expiresAt': expiresAt,
        'user': user.toJson(),
      };

  @override
  List<Object?> get props => [accessToken, refreshToken, expiresAt, user];
}

