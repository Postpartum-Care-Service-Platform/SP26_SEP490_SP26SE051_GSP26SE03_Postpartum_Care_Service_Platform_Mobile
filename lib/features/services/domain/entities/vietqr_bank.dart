import 'package:equatable/equatable.dart';

class VietQrBank extends Equatable {
  final int id;
  final String name;
  final String code;
  final String bin;
  final String shortName;
  final String logo;
  final String? appId;
  final String? deeplink;

  const VietQrBank({
    required this.id,
    required this.name,
    required this.code,
    required this.bin,
    required this.shortName,
    required this.logo,
    this.appId,
    this.deeplink,
  });

  String get displayName => shortName.isNotEmpty ? shortName : name;

  @override
  List<Object?> get props => [id, name, code, bin, shortName, logo, appId, deeplink];
}
