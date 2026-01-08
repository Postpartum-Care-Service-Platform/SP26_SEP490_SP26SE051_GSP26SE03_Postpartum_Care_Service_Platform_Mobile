import 'package:equatable/equatable.dart';

/// Refresh token request model
class RefreshTokenRequestModel extends Equatable {
  final String refreshToken;

  const RefreshTokenRequestModel({
    required this.refreshToken,
  });

  Map<String, dynamic> toJson() => {
        'refreshToken': refreshToken,
      };

  @override
  List<Object?> get props => [refreshToken];
}
