import 'package:equatable/equatable.dart';

/// Verify email request model
class VerifyEmailRequestModel extends Equatable {
  final String email;
  final String otp;

  const VerifyEmailRequestModel({
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

