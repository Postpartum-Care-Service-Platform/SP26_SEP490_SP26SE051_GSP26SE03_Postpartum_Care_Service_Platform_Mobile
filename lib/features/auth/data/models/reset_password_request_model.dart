import 'package:equatable/equatable.dart';

/// Reset password request model
class ResetPasswordRequestModel extends Equatable {
  final String resetToken;
  final String newPassword;
  final String confirmNewPassword;

  const ResetPasswordRequestModel({
    required this.resetToken,
    required this.newPassword,
    required this.confirmNewPassword,
  });

  Map<String, dynamic> toJson() => {
        'resetToken': resetToken,
        'newPassword': newPassword,
        'confirmNewPassword': confirmNewPassword,
      };

  @override
  List<Object?> get props => [resetToken, newPassword, confirmNewPassword];
}