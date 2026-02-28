import '../../domain/entities/create_customer_result_entity.dart';

class CreateCustomerResponseModel {
  final String accountId;
  final String email;
  final String? phone;
  final String? username;
  final String temporaryPassword;
  final String message;

  const CreateCustomerResponseModel({
    required this.accountId,
    required this.email,
    this.phone,
    this.username,
    required this.temporaryPassword,
    required this.message,
  });

  factory CreateCustomerResponseModel.fromJson(Map<String, dynamic> json) {
    return CreateCustomerResponseModel(
      accountId: (json['accountId'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: json['phone'] as String?,
      username: json['username'] as String?,
      temporaryPassword: (json['temporaryPassword'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
    );
  }

  CreateCustomerResultEntity toEntity() {
    return CreateCustomerResultEntity(
      accountId: accountId,
      email: email,
      phone: phone,
      username: username,
      temporaryPassword: temporaryPassword,
      message: message,
    );
  }
}

