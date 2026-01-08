part of 'family_profile_bloc.dart';

/// State for FamilyProfileBloc
class FamilyProfileState extends Equatable {
  final bool isLoading;
  final List<FamilyProfileEntity> members;
  final List<MemberTypeModel> memberTypes;
  final String? errorMessage;

  const FamilyProfileState({
    required this.isLoading,
    required this.members,
    required this.memberTypes,
    this.errorMessage,
  });

  const FamilyProfileState.initial()
      : isLoading = false,
        members = const [],
        memberTypes = const [],
        errorMessage = null;

  FamilyProfileState copyWith({
    bool? isLoading,
    List<FamilyProfileEntity>? members,
    List<MemberTypeModel>? memberTypes,
    String? errorMessage,
  }) {
    return FamilyProfileState(
      isLoading: isLoading ?? this.isLoading,
      members: members ?? this.members,
      memberTypes: memberTypes ?? this.memberTypes,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        members,
        memberTypes,
        errorMessage,
      ];
}

