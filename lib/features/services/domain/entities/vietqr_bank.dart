import 'package:equatable/equatable.dart';

class VietQrBank extends Equatable {
  final int id;
  final String name;
  final String code;
  final String bin;
  final String shortName;
  final String logo;

  const VietQrBank({
    required this.id,
    required this.name,
    required this.code,
    required this.bin,
    required this.shortName,
    required this.logo,
  });

  String get displayName => shortName.isNotEmpty ? shortName : name;

  @override
  List<Object?> get props => [id, name, code, bin, shortName, logo];
}
