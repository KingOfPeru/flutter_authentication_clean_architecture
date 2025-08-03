import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../entities/auth_token.dart';
import '../../../../shared/errors/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthToken>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, AuthToken>> register({
    required String name,
    required String email,
    required String username,
    required String password,
  });

  Future<Either<Failure, Unit>> logout();

  Future<Either<Failure, User>> getCurrentUser();

  Future<Either<Failure, AuthToken>> refreshToken();

  Future<bool> isLoggedIn();

  Future<Either<Failure, Unit>> clearAuthData();
}
