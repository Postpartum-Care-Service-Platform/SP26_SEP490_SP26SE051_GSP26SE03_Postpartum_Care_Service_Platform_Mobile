import 'dart:io';

/// Update family profile request model
class UpdateFamilyProfileRequestModel {
  final int? memberTypeId;
  final String fullName;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? address;
  final String? phoneNumber;
  final File? avatar;

  UpdateFamilyProfileRequestModel({
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
    if (phoneNumber != null) {
      data['PhoneNumber'] = phoneNumber!;
    }
    if (avatar != null) {
      data['Avatar'] = avatar!;
    }

    return data;
  }
}
