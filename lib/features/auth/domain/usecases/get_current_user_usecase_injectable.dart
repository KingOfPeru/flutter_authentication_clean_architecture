import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';
import '../../../../shared/errors/failures.dart';

@injectable
class GetCurrentUserUseCaseInjectable {
  final AuthRepository authRepository;

  GetCurrentUserUseCaseInjectable(this.authRepository);

  Future<Either<Failure, User>> call() async {
    return await authRepository.getCurrentUser();
  }
}
