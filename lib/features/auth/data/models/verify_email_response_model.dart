import 'package:equatable/equatable.dart';

/// Verify email response model
class VerifyEmailResponseModel extends Equatable {
  final String message;

  const VerifyEmailResponseModel({
    required this.message,
  });

  factory VerifyEmailResponseModel.fromJson(Map<String, dynamic> json) =>
      VerifyEmailResponseModel(
        message: json['message'] as String,
      );

  Map<String, dynamic> toJson() => {
        'message': message,
      };

  @override
  List<Object?> get props => [message];
}

