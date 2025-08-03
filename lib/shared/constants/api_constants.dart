class ApiConstants {

  static const String localhostUrl = 'http://localhost:3000';
  static const String androidEmulatorUrl = 'http://10.0.2.2:3000';
  static const String realDeviceUrl =
      'http://192.168.18.31:3000'; // IP de tu máquina en la red local

  static String get baseUrl {
    return androidEmulatorUrl;
  }

  static String get login => '$baseUrl/auth/login';
  static String get register => '$baseUrl/auth/register';
  static String get refreshToken => '$baseUrl/auth/refresh';
  static String get currentUser => '$baseUrl/auth/user';

  static String get users => '$baseUrl/users';

  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
