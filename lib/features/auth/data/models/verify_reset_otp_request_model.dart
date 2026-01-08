import 'package:equatable/equatable.dart';

/// Verify reset OTP request model
class VerifyResetOtpRequestModel extends Equatable {
  final String email;
  final String otp;

  const VerifyResetOtpRequestModel({
    required this.email,
    required this.otp,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'otp': otp,
      };

  @override
  List<Object?> get props => [email, otp];
}