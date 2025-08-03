import '../models/user_model.dart';
import '../models/auth_token_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveAuthToken(AuthTokenModel token);
  Future<AuthTokenModel?> getAuthToken();
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> clearAuthData();
  Future<bool> hasAuthToken();
}
