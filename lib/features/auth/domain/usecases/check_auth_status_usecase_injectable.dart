import 'package:injectable/injectable.dart';
import '../repositories/auth_repository.dart';

@injectable
class CheckAuthStatusUseCaseInjectable {
  final AuthRepository authRepository;

  CheckAuthStatusUseCaseInjectable(this.authRepository);

  Future<bool> call() async {
    return await authRepository.isLoggedIn();
  }
}
