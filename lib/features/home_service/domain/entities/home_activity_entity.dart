import 'package:equatable/equatable.dart';

/// Home Activity Entity - Domain layer
class HomeActivityEntity extends Equatable {
  final int id;
  final String name;
  final String description;
  final double price;
  final int target; // 0 = mother, 1 = baby
  final int activityTypeId;
  final int duration; // minutes
  final int status;

  const HomeActivityEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.target,
    required this.activityTypeId,
    required this.duration,
    required this.status,
  });

  bool get isActive => status == 0;
  String get targetLabel => target == 0 ? 'Mẹ' : 'Bé';

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        target,
        activityTypeId,
        duration,
        status,
      ];
}
