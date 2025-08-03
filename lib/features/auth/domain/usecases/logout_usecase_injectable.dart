import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../repositories/auth_repository.dart';
import '../../../../shared/errors/failures.dart';

@injectable
class LogoutUseCaseInjectable {
  final AuthRepository authRepository;

  LogoutUseCaseInjectable(this.authRepository);

  Future<Either<Failure, Unit>> call() async {
    return await authRepository.logout();
  }
}
