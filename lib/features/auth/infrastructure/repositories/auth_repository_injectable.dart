import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../shared/errors/failures.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';
import '../models/user_model.dart';

@Injectable(as: AuthRepository)
class AuthRepositoryInjectableImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryInjectableImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, AuthToken>> login({
    required String email,
    required String password,
  }) async {
    try {
      final tokenModel = await remoteDataSource.login(email, password);
      await localDataSource.saveAuthToken(tokenModel);

        final userModel = await remoteDataSource.getCurrentUser();
        await localDataSource.saveUser(userModel);

      return Right(tokenModel.toEntity());
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(
        ServerFailure('Error inesperado durante el inicio de sesión: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, AuthToken>> register({
    required String name,
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      final tokenModel = await remoteDataSource.register(
        name,
        email,
        username,
        password,
      );
      await localDataSource.saveAuthToken(tokenModel);

      final userModel = UserModel(
        id: DateTime.now().millisecondsSinceEpoch,
        name: name,
        email: email,
        username: username,
      );
      await localDataSource.saveUser(userModel);

      return Right(tokenModel.toEntity());
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Error inesperado durante el registro: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await localDataSource.clearAuthData();
      return const Right(unit);
    } catch (e) {
      return Left(
        CacheFailure('Falló al limpiar los datos de autenticación: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final localUser = await localDataSource.getUser();
      if (localUser != null) {
        return Right(localUser.toEntity());
      }

      final remoteUser = await remoteDataSource.getCurrentUser();
      await localDataSource.saveUser(remoteUser);
      return Right(remoteUser.toEntity());
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Falló al obtener el usuario actual: $e'));
    }
  }

  @override
  Future<Either<Failure, AuthToken>> refreshToken() async {
    try {
      final currentToken = await localDataSource.getAuthToken();
      if (currentToken == null) {
        return const Left(
          AuthenticationFailure('No hay token de renovación disponible'),
        );
      }

      final newTokenModel = await remoteDataSource.refreshToken(
        currentToken.refreshToken ?? '',
      );
      await localDataSource.saveAuthToken(newTokenModel);

      return Right(newTokenModel.toEntity());
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Falló al renovar el token: $e'));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final token = await localDataSource.getAuthToken();
      return token != null && !token.toEntity().isExpired;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Either<Failure, Unit>> clearAuthData() async {
    try {
      await localDataSource.clearAuthData();
      return const Right(unit);
    } catch (e) {
      return Left(
        CacheFailure('Falló al limpiar los datos de autenticación: $e'),
      );
    }
  }
}
