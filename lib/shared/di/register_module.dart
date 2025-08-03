import 'package:injectable/injectable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../network/dio_client.dart';

@module
abstract class RegisterModule {
  @singleton
  DioClient get dioClient => DioClient();

  @singleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();
}
