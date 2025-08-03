import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/auth_token.dart';

part 'auth_token_model.g.dart';

@JsonSerializable()
class AuthTokenModel {
  @JsonKey(name: 'access_token')
  final String accessToken;

  @JsonKey(name: 'refresh_token')
  final String? refreshToken;

  @JsonKey(name: 'expires_at')
  final String expiresAt;

  const AuthTokenModel({
    required this.accessToken,
    this.refreshToken,
    required this.expiresAt,
  });

  factory AuthTokenModel.fromJson(Map<String, dynamic> json) =>
      _$AuthTokenModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthTokenModelToJson(this);

  AuthToken toEntity() => AuthToken(
    accessToken: accessToken,
    refreshToken: refreshToken,
    expiresAt: DateTime.parse(expiresAt),
  );

  factory AuthTokenModel.fromEntity(AuthToken token) => AuthTokenModel(
    accessToken: token.accessToken,
    refreshToken: token.refreshToken,
    expiresAt: token.expiresAt.toIso8601String(),
  );

  factory AuthTokenModel.mock() => AuthTokenModel(
    accessToken: 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
    refreshToken: 'mock_refresh_token',
    expiresAt: DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
  );
}
