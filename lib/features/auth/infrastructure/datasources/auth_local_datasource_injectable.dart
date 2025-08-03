import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_token_model.dart';
import '../models/user_model.dart';
import 'auth_local_datasource.dart';

@Injectable(as: AuthLocalDataSource)
class AuthLocalDataSourceInjectableImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;

  static const String _authTokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  AuthLocalDataSourceInjectableImpl(this.secureStorage);

  @override
  Future<void> saveAuthToken(AuthTokenModel token) async {
    final tokenJson = json.encode(token.toJson());
    await secureStorage.write(key: _authTokenKey, value: tokenJson);
  }

  @override
  Future<AuthTokenModel?> getAuthToken() async {
    final tokenJson = await secureStorage.read(key: _authTokenKey);
    if (tokenJson != null) {
      final tokenMap = json.decode(tokenJson) as Map<String, dynamic>;
      return AuthTokenModel.fromJson(tokenMap);
    }
    return null;
  }

  @override
  Future<void> saveUser(UserModel user) async {
    final userJson = json.encode(user.toJson());
    await secureStorage.write(key: _userKey, value: userJson);
  }

  @override
  Future<UserModel?> getUser() async {
    final userJson = await secureStorage.read(key: _userKey);
    if (userJson != null) {
      final userMap = json.decode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(userMap);
    }
    return null;
  }

  @override
  Future<void> clearAuthData() async {
    await Future.wait([
      secureStorage.delete(key: _authTokenKey),
      secureStorage.delete(key: _userKey),
    ]);
  }

  @override
  Future<bool> hasAuthToken() async {
    final token = await getAuthToken();
    return token != null && !token.toEntity().isExpired;
  }
}
