import 'package:equatable/equatable.dart';

/// Verify reset OTP response model
class VerifyResetOtpResponseModel extends Equatable {
  final String resetToken;
  final String message;

  const VerifyResetOtpResponseModel({
    required this.resetToken,
    required this.message,
  });

  factory VerifyResetOtpResponseModel.fromJson(Map<String, dynamic> json) =>
      VerifyResetOtpResponseModel(
        resetToken: json['resetToken'] as String,
        message: json['message'] as String,
      );

  Map<String, dynamic> toJson() => {
        'resetToken': resetToken,
        'message': message,
      };

  @override
  List<Object?> get props => [resetToken, message];
}