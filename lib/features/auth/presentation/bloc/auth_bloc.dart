import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/usecases/login_usecase_injectable.dart';
import '../../domain/usecases/register_usecase_injectable.dart';
import '../../domain/usecases/logout_usecase_injectable.dart';
import '../../domain/usecases/get_current_user_usecase_injectable.dart';
import '../../domain/usecases/check_auth_status_usecase_injectable.dart';

part 'auth_event.dart';
part 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCaseInjectable _loginUseCase;
  final RegisterUseCaseInjectable _registerUseCase;
  final LogoutUseCaseInjectable _logoutUseCase;
  final GetCurrentUserUseCaseInjectable _getCurrentUserUseCase;
  final CheckAuthStatusUseCaseInjectable _checkAuthStatusUseCase;

  AuthBloc(
    this._loginUseCase,
    this._registerUseCase,
    this._logoutUseCase,
    this._getCurrentUserUseCase,
    this._checkAuthStatusUseCase,
  ) : super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthStatusChecked>(_onStatusChecked);

    // Chequear el estado de autenticación al iniciar el bloc
    add(AuthStatusChecked());
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _loginUseCase(
      email: event.email,
      password: event.password,
    );

    if (result.isLeft()) {
      emit(AuthError(result.fold((failure) => failure.message, (_) => '')));
      return;
    }

    final token = result.fold((_) => null, (token) => token)!;
    final userResult = await _getCurrentUserUseCase();

    if (emit.isDone) return;

    userResult.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user: user, token: token)),
    );
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _registerUseCase(
      name: event.name,
      email: event.email,
      username: event.username,
      password: event.password,
    );

    if (result.isLeft()) {
      emit(AuthError(result.fold((failure) => failure.message, (_) => '')));
      return;
    }

    final token = result.fold((_) => null, (token) => token)!;
    final userResult = await _getCurrentUserUseCase();

    if (emit.isDone) return;

    userResult.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user: user, token: token)),
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _logoutUseCase();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthUnauthenticated()),
    );
  }

  Future<void> _onStatusChecked(
    AuthStatusChecked event,
    Emitter<AuthState> emit,
  ) async {
    final isLoggedIn = await _checkAuthStatusUseCase();

    if (isLoggedIn) {
      final userResult = await _getCurrentUserUseCase();
      userResult.fold(
        (_) => emit(AuthUnauthenticated()),
        (user) => emit(
          AuthAuthenticated(
            user: user,
            token: AuthToken(
              accessToken: 'existing_token',
              expiresAt: DateTime.now().add(const Duration(hours: 1)),
            ),
          ),
        ),
      );
    } else {
      emit(AuthUnauthenticated());
    }
  }
}
