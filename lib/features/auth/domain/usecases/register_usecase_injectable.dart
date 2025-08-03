import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../entities/auth_token.dart';
import '../repositories/auth_repository.dart';
import '../../../../shared/errors/failures.dart';

@injectable
class RegisterUseCaseInjectable {
  final AuthRepository authRepository;

  RegisterUseCaseInjectable(this.authRepository);

  Future<Either<Failure, AuthToken>> call({
    required String name,
    required String email,
    required String username,
    required String password,
  }) async {
    // Validation
    if (name.isEmpty || email.isEmpty || username.isEmpty || password.isEmpty) {
      return const Left(ValidationFailure('Todos los campos son obligatorios'));
    }

    if (!_isValidEmail(email)) {
      return const Left(ValidationFailure('Formato de correo electrónico no válido'));
    }

    if (password.length < 6) {
      return const Left(
        ValidationFailure('La contraseña debe tener al menos 6 caracteres'),
      );
    }

    return await authRepository.register(
      name: name,
      email: email,
      username: username,
      password: password,
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }
}
