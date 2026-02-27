class CreateCustomerRequestModel {
  final String email;
  final String? phone;
  final String? username;

  const CreateCustomerRequestModel({
    required this.email,
    this.phone,
    this.username,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'phone': phone,
      'username': username,
    };
  }
}

