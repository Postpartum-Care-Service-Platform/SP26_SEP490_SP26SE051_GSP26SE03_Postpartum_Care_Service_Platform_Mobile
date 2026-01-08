import 'dart:io';

/// Create family profile request model
class CreateFamilyProfileRequestModel {
  final int? memberTypeId;
  final String fullName;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? address;
  final String? phoneNumber;
  final File? avatar;

  CreateFamilyProfileRequestModel({
    this.memberTypeId,
    required this.fullName,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.phoneNumber,
    this.avatar,
  });

  Map<String, dynamic> toFormData() {
    final Map<String, dynamic> data = {
      'FullName': fullName,
    };

    if (memberTypeId != null) {
      data['MemberTypeId'] = memberTypeId.toString();
    }
    if (dateOfBirth != null) {
      data['DateOfBirth'] = dateOfBirth!.toIso8601String().split('T')[0];
    }
    if (gender != null) {
      data['Gender'] = gender!;
    }
    if (address != null) {
      data['Address'] = address!;
    }
    if (phoneNumber != null && phoneNumber!.isNotEmpty) {
      data['PhoneNumber'] = phoneNumber!;
    }
    if (avatar != null) {
      data['Avatar'] = avatar!;
    }

    return data;
  }
}
