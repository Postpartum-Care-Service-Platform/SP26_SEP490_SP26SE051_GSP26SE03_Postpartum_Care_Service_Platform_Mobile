class CreateCustomerResultEntity {
  final String accountId;
  final String email;
  final String? phone;
  final String? username;
  final String temporaryPassword;
  final String message;

  const CreateCustomerResultEntity({
    required this.accountId,
    required this.email,
    this.phone,
    this.username,
    required this.temporaryPassword,
    required this.message,
  });
}

