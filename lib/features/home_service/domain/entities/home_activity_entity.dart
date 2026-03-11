import 'package:equatable/equatable.dart';

/// Home Activity Entity - Domain layer
class HomeActivityEntity extends Equatable {
  final int id;
  final String name;
  final String description;
  final double? price;
  final String target; // Mom, Baby, Both
  final int activityTypeId;
  final String activityTypeName;
  final int duration; // minutes
  final String status;

  const HomeActivityEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.target,
    required this.activityTypeId,
    required this.activityTypeName,
    required this.duration,
    required this.status,
  });

  bool get isActive => status.toLowerCase() == 'active';
  String get targetLabel {
    switch (target.toLowerCase()) {
      case 'mom':
        return 'Mẹ';
      case 'baby':
        return 'Bé';
      case 'both':
        return 'Cả hai';
      default:
        return target;
    }
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        target,
        activityTypeId,
        activityTypeName,
        duration,
        status,
      ];
}
