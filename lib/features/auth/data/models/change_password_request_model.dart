import 'package:equatable/equatable.dart';

/// Change password request model
class ChangePasswordRequestModel extends Equatable {
  final String currentPassword;
  final String newPassword;
  final String confirmNewPassword;

  const ChangePasswordRequestModel({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmNewPassword,
  });

  Map<String, dynamic> toJson() => {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmNewPassword': confirmNewPassword,
      };

  @override
  List<Object?> get props => [currentPassword, newPassword, confirmNewPassword];
}
