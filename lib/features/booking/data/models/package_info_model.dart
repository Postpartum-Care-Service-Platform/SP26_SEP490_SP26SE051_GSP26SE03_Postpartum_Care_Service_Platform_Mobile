import '../../domain/entities/package_info_entity.dart';

/// Package Info Model - Data layer
class PackageInfoModel {
  final int id;
  final String packageName;
  final int durationDays;
  final double basePrice;
  final String roomTypeName;

  PackageInfoModel({
    required this.id,
    required this.packageName,
    required this.durationDays,
    required this.basePrice,
    required this.roomTypeName,
  });

  factory PackageInfoModel.fromJson(Map<String, dynamic> json) {
    return PackageInfoModel(
      id: json['id'] as int,
      packageName: json['packageName'] as String,
      durationDays: json['durationDays'] as int,
      basePrice: (json['basePrice'] as num).toDouble(),
      roomTypeName: json['roomTypeName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'packageName': packageName,
      'durationDays': durationDays,
      'basePrice': basePrice,
      'roomTypeName': roomTypeName,
    };
  }

  PackageInfoEntity toEntity() {
    return PackageInfoEntity(
      id: id,
      packageName: packageName,
      durationDays: durationDays,
      basePrice: basePrice,
      roomTypeName: roomTypeName,
    );
  }
}
