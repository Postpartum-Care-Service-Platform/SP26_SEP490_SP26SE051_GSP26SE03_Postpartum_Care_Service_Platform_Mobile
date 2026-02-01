import 'package:equatable/equatable.dart';

/// Feedback Type Entity - Domain layer
class FeedbackTypeEntity extends Equatable {
  final int id;
  final String name;
  final bool isActive;

  const FeedbackTypeEntity({
    required this.id,
    required this.name,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id, name, isActive];
}
