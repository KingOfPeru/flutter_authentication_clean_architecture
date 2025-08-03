import '../models/user_model.dart';
import '../models/auth_token_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthTokenModel> login(String email, String password);
  Future<AuthTokenModel> register(
    String name,
    String email,
    String username,
    String password,
  );
  Future<UserModel> getCurrentUser();
  Future<AuthTokenModel> refreshToken(String refreshToken);
}
