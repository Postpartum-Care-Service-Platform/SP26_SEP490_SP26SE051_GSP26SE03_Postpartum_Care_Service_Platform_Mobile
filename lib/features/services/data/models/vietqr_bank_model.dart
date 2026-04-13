import '../../domain/entities/vietqr_bank.dart';

class VietQrBankModel extends VietQrBank {
  const VietQrBankModel({
    required super.id,
    required super.name,
    required super.code,
    required super.bin,
    required super.shortName,
    required super.logo,
  });

  factory VietQrBankModel.fromJson(Map<String, dynamic> json) {
    return VietQrBankModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
      code: (json['code'] as String?) ?? '',
      bin: (json['bin'] as String?) ?? '',
      shortName: (json['shortName'] as String?) ?? '',
      logo: (json['logo'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'bin': bin,
      'shortName': shortName,
      'logo': logo,
    };
  }
}
