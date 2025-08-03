import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../entities/auth_token.dart';
import '../repositories/auth_repository.dart';
import '../../../../shared/errors/failures.dart';

@injectable
class LoginUseCaseInjectable {
  final AuthRepository authRepository;

  LoginUseCaseInjectable(this.authRepository);

  Future<Either<Failure, AuthToken>> call({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      return const Left(ValidationFailure('Correo electrónico y contraseña son obligatorios'));
    }

    if (!_isValidEmail(email)) {
      return const Left(ValidationFailure('Formato de correo electrónico no válido'));
    }

    return await authRepository.login(email: email, password: password);
  }

  bool _isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }
}
