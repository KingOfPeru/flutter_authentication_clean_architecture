import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../models/auth_token_model.dart';
import '../../../../shared/network/dio_client.dart';
import '../../../../shared/constants/api_constants.dart';
import '../../../../shared/errors/failures.dart';
import 'auth_remote_datasource.dart';

@Injectable(as: AuthRemoteDataSource)
class AuthRemoteDataSourceInjectableImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

  int? _currentUserId;

  static const int _statusOk = 200;
  static const int _statusCreated = 201;
  static const int _statusUnauthorized = 401;
  static const int _statusNotFound = 404;

  AuthRemoteDataSourceInjectableImpl(this.dioClient);

  @override
  Future<AuthTokenModel> login(String email, String password) async {
    try {
      final usersResponse = await dioClient.dio.get(ApiConstants.users);

      if (usersResponse.statusCode == _statusOk) {
        final users = usersResponse.data as List;

        final matchingUser = users.cast<Map<String, dynamic>>().firstWhere(
          (user) => user['email'] == email && user['password'] == password,
          orElse: () => <String, dynamic>{},
        );

        if (matchingUser.isNotEmpty) {
          _currentUserId = matchingUser['id'];

          return AuthTokenModel(
            accessToken:
                'jwt_token_${matchingUser['id']}_${DateTime.now().millisecondsSinceEpoch}',
            refreshToken:
                'refresh_token_${matchingUser['id']}_${DateTime.now().millisecondsSinceEpoch}',
            expiresAt:
                DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
          );
        } else {
          throw const AuthenticationFailure('Correo o contraseña incorrectos');
        }
      } else {
        throw ServerFailure('Error del servidor: ${usersResponse.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkFailure('Tiempo de conexión agotado');
      } else if (e.type == DioExceptionType.connectionError) {
        throw const NetworkFailure(
          'No hay conexión a internet. Asegúrate de que el servidor JSON esté ejecutándose en localhost:3000',
        );
      } else if (e.response?.statusCode == _statusUnauthorized) {
        throw const AuthenticationFailure('Credenciales inválidas');
      } else {
        throw ServerFailure('Error del servidor: ${e.message}');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Error inesperado: $e');
    }
  }

  @override
  Future<AuthTokenModel> register(
    String name,
    String email,
    String username,
    String password,
  ) async {
    try {
      final existingUsersResponse = await dioClient.dio.get(ApiConstants.users);

      if (existingUsersResponse.statusCode == _statusOk) {
        final users = existingUsersResponse.data as List;

        final existingUser = users.cast<Map<String, dynamic>>().any(
          (user) => user['email'] == email,
        );

        if (existingUser) {
          throw const ValidationFailure(
            'Usuario ya registrado con este correo',
          );
        }
      }

      final newUser = {
        'name': name,
        'username': username,
        'email': email,
        'password': password,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      final response = await dioClient.dio.post(
        ApiConstants.users,
        data: newUser,
      );

      if (response.statusCode == _statusCreated) {
        final userData = response.data;

        _currentUserId = userData['id'];

        return AuthTokenModel(
          accessToken:
              'jwt_token_${userData['id']}_${DateTime.now().millisecondsSinceEpoch}',
          refreshToken:
              'refresh_token_${userData['id']}_${DateTime.now().millisecondsSinceEpoch}',
          expiresAt:
              DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
        );
      } else {
        throw ServerFailure('Falló el registro: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkFailure('Tiempo de conexión agotado');
      } else if (e.type == DioExceptionType.connectionError) {
        throw const NetworkFailure(
          'No hay conexión a internet. Asegúrate de que el servidor JSON esté ejecutándose en localhost:3000',
        );
      } else {
        throw ServerFailure('Error del servidor: ${e.message}');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Error inesperado: $e');
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      if (_currentUserId != null) {
        final userResponse = await dioClient.dio.get(
          '${ApiConstants.users}/$_currentUserId',
        );

        if (userResponse.statusCode == _statusOk) {
          return UserModel.fromJson(userResponse.data);
        }
      }

      // Si no se encontró el usuario actual, llamar al endpoint perfil
      final response = await dioClient.dio.get(
        '${ApiConstants.baseUrl}/profile',
      );

      if (response.statusCode == _statusOk) {
        return UserModel.fromJson(response.data);
      } else {
        throw ServerFailure(
          'Falló al obtener el perfil del usuario: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkFailure('Tiempo de conexión agotado');
      } else if (e.type == DioExceptionType.connectionError) {
        throw const NetworkFailure(
          'Sin conexión a internet. Asegúrate de que el servidor JSON esté ejecutándose en localhost:3000',
        );
      } else if (e.response?.statusCode == _statusNotFound) {
        throw const ServerFailure('Perfil de usuario no encontrado');
      } else {
        throw ServerFailure('Error del servidor: ${e.message}');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Error inesperado: $e');
    }
  }

  @override
  Future<AuthTokenModel> refreshToken(String refreshToken) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      return AuthTokenModel(
        accessToken: 'jwt_refreshed_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: 'refresh_new_${DateTime.now().millisecondsSinceEpoch}',
        expiresAt:
            DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
      );
    } catch (e) {
      throw ServerFailure('Falló la renovación del token: $e');
    }
  }
}
