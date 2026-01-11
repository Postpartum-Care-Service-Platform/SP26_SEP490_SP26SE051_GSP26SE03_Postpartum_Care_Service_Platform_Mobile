import 'package:equatable/equatable.dart';

/// Google sign-in request model
class GoogleSignInRequestModel extends Equatable {
  final String idToken;

  const GoogleSignInRequestModel({
    required this.idToken,
  });

  Map<String, dynamic> toJson() => {
        'idToken': idToken,
      };

  @override
  List<Object?> get props => [idToken];
}
