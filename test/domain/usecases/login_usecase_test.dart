import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:albertopr_autenticacion_clean_architecture/features/auth/domain/repositories/auth_repository.dart';
import 'package:albertopr_autenticacion_clean_architecture/features/auth/domain/usecases/login_usecase_injectable.dart';
import 'package:albertopr_autenticacion_clean_architecture/features/auth/domain/entities/auth_token.dart';
import 'package:albertopr_autenticacion_clean_architecture/shared/errors/failures.dart';

import 'login_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late LoginUseCaseInjectable usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = LoginUseCaseInjectable(mockAuthRepository);
  });

  group('LoginUseCase', () {
    const tEmail = 'test@email.com';
    const tPassword = 'password123';
    final tToken = AuthToken(
      accessToken: 'access_token',
      expiresAt: DateTime(2025, 12, 31, 23, 59, 59),
    );

    test('debería retornar AuthToken cuando el login es exitoso', () async {
      when(
        mockAuthRepository.login(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenAnswer((_) async => Right(tToken));

      final result = await usecase(email: tEmail, password: tPassword);

      expect(result, Right(tToken));
      verify(mockAuthRepository.login(email: tEmail, password: tPassword));
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test(
      'debería retornar ValidationFailure cuando el email está vacío',
      () async {
        final result = await usecase(email: '', password: tPassword);

        expect(
          result,
          const Left(
            ValidationFailure(
              'Correo electrónico y contraseña son obligatorios',
            ),
          ),
        );
        verifyZeroInteractions(mockAuthRepository);
      },
    );

    test(
      'debería retornar ValidationFailure cuando la contraseña está vacía',
      () async {
        final result = await usecase(email: tEmail, password: '');

        expect(
          result,
          const Left(
            ValidationFailure(
              'Correo electrónico y contraseña son obligatorios',
            ),
          ),
        );
        verifyZeroInteractions(mockAuthRepository);
      },
    );

    test(
      'debería retornar ValidationFailure cuando el formato del email es inválido',
      () async {
        const tInvalidEmail = 'invalid_email';

        final result = await usecase(email: tInvalidEmail, password: tPassword);

        expect(
          result,
          const Left(
            ValidationFailure('Formato de correo electrónico no válido'),
          ),
        );
        verifyZeroInteractions(mockAuthRepository);
      },
    );

    test(
      'debería retornar Failure cuando la llamada al repositorio falla',
      () async {
        final Failure tFailure = ServerFailure('Server error');
        when(
          mockAuthRepository.login(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenAnswer((_) async => Left(tFailure));

        final result = await usecase(email: tEmail, password: tPassword);

        expect(result, Left(tFailure));
        verify(mockAuthRepository.login(email: tEmail, password: tPassword));
        verifyNoMoreInteractions(mockAuthRepository);
      },
    );
  });
}
