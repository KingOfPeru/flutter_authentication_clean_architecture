import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../di/injection.dart';
import '../../features/auth/infrastructure/datasources/auth_local_datasource.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;
  DioClient._internal();

  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  late final Dio _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: connectTimeout),
        receiveTimeout: const Duration(milliseconds: receiveTimeout),
        headers: ApiConstants.defaultHeaders,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
      ),
    )
    ..interceptors.addAll([
      if (kDebugMode)
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (obj) {
            debugPrint(obj.toString());
          },
        ),
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final localDataSource = getIt<AuthLocalDataSource>();
            final token = await localDataSource.getAuthToken();

            if (token != null && !token.toEntity().isExpired) {
              options.headers['Authorization'] = 'Bearer ${token.accessToken}';
            }
          } catch (e) {
            debugPrint('Error adding token to request: $e');
          }

          handler.next(options);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            try {
              final localDataSource = getIt<AuthLocalDataSource>();
              await localDataSource.clearAuthData();
            } catch (e) {
              debugPrint('Error clearing auth data: $e');
            }
          }

          handler.next(error);
        },
      ),
    ]);

  Dio get dio => _dio;
}
