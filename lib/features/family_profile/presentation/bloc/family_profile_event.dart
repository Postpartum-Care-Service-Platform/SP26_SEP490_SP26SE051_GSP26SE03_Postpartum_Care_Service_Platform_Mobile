part of 'family_profile_bloc.dart';

/// Events for FamilyProfileBloc
abstract class FamilyProfileEvent extends Equatable {
  const FamilyProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Load initial data (profiles + member types)
class FamilyProfileStarted extends FamilyProfileEvent {
  const FamilyProfileStarted();
}

/// Refresh data (pull-to-refresh)
class FamilyProfileRefreshed extends FamilyProfileEvent {
  const FamilyProfileRefreshed();
}

/// Create a new family profile
class FamilyProfileCreated extends FamilyProfileEvent {
  final CreateFamilyProfileRequestModel request;

  const FamilyProfileCreated(this.request);

  @override
  List<Object?> get props => [request];
}
