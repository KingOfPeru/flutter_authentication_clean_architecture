import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:albertopr_autenticacion_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:albertopr_autenticacion_clean_architecture/features/auth/domain/entities/auth_token.dart';
import 'package:albertopr_autenticacion_clean_architecture/features/auth/domain/usecases/login_usecase_injectable.dart';
import 'package:albertopr_autenticacion_clean_architecture/features/auth/domain/usecases/register_usecase_injectable.dart';
import 'package:albertopr_autenticacion_clean_architecture/features/auth/domain/usecases/logout_usecase_injectable.dart';
import 'package:albertopr_autenticacion_clean_architecture/features/auth/domain/usecases/get_current_user_usecase_injectable.dart';
import 'package:albertopr_autenticacion_clean_architecture/features/auth/domain/usecases/check_auth_status_usecase_injectable.dart';
import 'package:albertopr_autenticacion_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:albertopr_autenticacion_clean_architecture/shared/errors/failures.dart';

import 'auth_bloc_test.mocks.dart';

@GenerateMocks([
  LoginUseCaseInjectable,
  RegisterUseCaseInjectable,
  LogoutUseCaseInjectable,
  GetCurrentUserUseCaseInjectable,
  CheckAuthStatusUseCaseInjectable,
])
void main() {
  late AuthBloc authBloc;
  late MockLoginUseCaseInjectable mockLoginUseCase;
  late MockRegisterUseCaseInjectable mockRegisterUseCase;
  late MockLogoutUseCaseInjectable mockLogoutUseCase;
  late MockGetCurrentUserUseCaseInjectable mockGetCurrentUserUseCase;
  late MockCheckAuthStatusUseCaseInjectable mockCheckAuthStatusUseCase;

  setUp(() {
    mockLoginUseCase = MockLoginUseCaseInjectable();
    mockRegisterUseCase = MockRegisterUseCaseInjectable();
    mockLogoutUseCase = MockLogoutUseCaseInjectable();
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCaseInjectable();
    mockCheckAuthStatusUseCase = MockCheckAuthStatusUseCaseInjectable();

    when(mockCheckAuthStatusUseCase()).thenAnswer((_) async => false);

    authBloc = AuthBloc(
      mockLoginUseCase,
      mockRegisterUseCase,
      mockLogoutUseCase,
      mockGetCurrentUserUseCase,
      mockCheckAuthStatusUseCase,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc', () {
    const tEmail = 'test@example.com';
    const tPassword = 'password123';
    const tName = 'Test User';
    const tUsername = 'testuser';

    final tUser = User(id: 1, name: tName, email: tEmail, username: tUsername);

    final tAuthToken = AuthToken(
      accessToken: 'access_token',
      expiresAt: DateTime(2025, 12, 31, 23, 59, 59),
    );

    group('AuthLoginRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emite [AuthLoading, AuthAuthenticated] cuando el login es exitoso',
        build: () {
          when(mockCheckAuthStatusUseCase()).thenAnswer((_) async => false);
          when(
            mockLoginUseCase(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenAnswer((_) async => Right(tAuthToken));
          when(
            mockGetCurrentUserUseCase(),
          ).thenAnswer((_) async => Right(tUser));
          return authBloc;
        },
        act:
            (bloc) => bloc.add(
              AuthLoginRequested(email: tEmail, password: tPassword),
            ),
        expect:
            () => [
              AuthLoading(),
              AuthAuthenticated(user: tUser, token: tAuthToken),
            ],
      );

      blocTest<AuthBloc, AuthState>(
        'emite [AuthLoading, AuthError] cuando el login falla',
        build: () {
          when(mockCheckAuthStatusUseCase()).thenAnswer((_) async => false);
          when(
            mockLoginUseCase(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenAnswer(
            (_) async => Left(ValidationFailure('Invalid credentials')),
          );
          return authBloc;
        },
        act:
            (bloc) => bloc.add(
              AuthLoginRequested(email: tEmail, password: tPassword),
            ),
        expect: () => [AuthLoading(), const AuthError('Invalid credentials')],
      );

      blocTest<AuthBloc, AuthState>(
        'emite [AuthLoading, AuthError] cuando getCurrentUser falla después del login exitoso',
        build: () {
          when(mockCheckAuthStatusUseCase()).thenAnswer((_) async => false);
          when(
            mockLoginUseCase(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenAnswer((_) async => Right(tAuthToken));
          when(
            mockGetCurrentUserUseCase(),
          ).thenAnswer((_) async => Left(ServerFailure('User not found')));
          return authBloc;
        },
        act:
            (bloc) => bloc.add(
              AuthLoginRequested(email: tEmail, password: tPassword),
            ),
        expect: () => [AuthLoading(), const AuthError('User not found')],
      );
    });

    group('AuthRegisterRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emite [AuthLoading, AuthAuthenticated] cuando el registro es exitoso',
        build: () {
          when(mockCheckAuthStatusUseCase()).thenAnswer((_) async => false);
          when(
            mockRegisterUseCase(
              name: anyNamed('name'),
              email: anyNamed('email'),
              username: anyNamed('username'),
              password: anyNamed('password'),
            ),
          ).thenAnswer((_) async => Right(tAuthToken));
          when(
            mockGetCurrentUserUseCase(),
          ).thenAnswer((_) async => Right(tUser));
          return authBloc;
        },
        act:
            (bloc) => bloc.add(
              AuthRegisterRequested(
                name: tName,
                email: tEmail,
                username: tUsername,
                password: tPassword,
              ),
            ),
        expect:
            () => [
              AuthLoading(),
              AuthAuthenticated(user: tUser, token: tAuthToken),
            ],
      );

      blocTest<AuthBloc, AuthState>(
        'emite [AuthLoading, AuthError] cuando el registro falla',
        build: () {
          when(mockCheckAuthStatusUseCase()).thenAnswer((_) async => false);
          when(
            mockRegisterUseCase(
              name: anyNamed('name'),
              email: anyNamed('email'),
              username: anyNamed('username'),
              password: anyNamed('password'),
            ),
          ).thenAnswer(
            (_) async => Left(ValidationFailure('Email already exists')),
          );
          return authBloc;
        },
        act:
            (bloc) => bloc.add(
              AuthRegisterRequested(
                name: tName,
                email: tEmail,
                username: tUsername,
                password: tPassword,
              ),
            ),
        expect: () => [AuthLoading(), const AuthError('Email already exists')],
      );
    });

    group('AuthLogoutRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emite [AuthLoading, AuthUnauthenticated] cuando el logout es exitoso',
        build: () {
          when(mockCheckAuthStatusUseCase()).thenAnswer((_) async => false);
          when(mockLogoutUseCase()).thenAnswer((_) async => Right(unit));
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthLogoutRequested()),
        expect: () => [AuthLoading(), AuthUnauthenticated()],
      );

      blocTest<AuthBloc, AuthState>(
        'emite [AuthLoading, AuthError] cuando el logout falla',
        build: () {
          when(mockCheckAuthStatusUseCase()).thenAnswer((_) async => false);
          when(
            mockLogoutUseCase(),
          ).thenAnswer((_) async => Left(ServerFailure('Logout failed')));
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthLogoutRequested()),
        expect: () => [AuthLoading(), const AuthError('Logout failed')],
      );
    });
  });
}
