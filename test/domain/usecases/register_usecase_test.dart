import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:albertopr_autenticacion_clean_architecture/features/auth/domain/repositories/auth_repository.dart';
import 'package:albertopr_autenticacion_clean_architecture/features/auth/domain/usecases/register_usecase_injectable.dart';
import 'package:albertopr_autenticacion_clean_architecture/features/auth/domain/entities/auth_token.dart';
import 'package:albertopr_autenticacion_clean_architecture/shared/errors/failures.dart';

import 'register_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late RegisterUseCaseInjectable usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = RegisterUseCaseInjectable(mockAuthRepository);
  });

  group('RegisterUseCase', () {
    const tName = 'Test User';
    const tEmail = 'test@email.com';
    const tUsername = 'testuser';
    const tPassword = 'password123';

    final tToken = AuthToken(
      accessToken: 'access_token',
      expiresAt: DateTime(2025, 12, 31, 23, 59, 59),
    );

    test('debería retornar AuthToken cuando el registro es exitoso', () async {
      when(
        mockAuthRepository.register(
          name: anyNamed('name'),
          email: anyNamed('email'),
          username: anyNamed('username'),
          password: anyNamed('password'),
        ),
      ).thenAnswer((_) async => Right(tToken));

      final result = await usecase(
        name: tName,
        email: tEmail,
        username: tUsername,
        password: tPassword,
      );

      expect(result, Right(tToken));
      verify(
        mockAuthRepository.register(
          name: tName,
          email: tEmail,
          username: tUsername,
          password: tPassword,
        ),
      );
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test(
      'debería retornar ValidationFailure cuando el nombre está vacío',
      () async {
        final result = await usecase(
          name: '',
          email: tEmail,
          username: tUsername,
          password: tPassword,
        );

        expect(
          result,
          const Left(ValidationFailure('Todos los campos son obligatorios')),
        );
        verifyZeroInteractions(mockAuthRepository);
      },
    );

    test(
      'debería retornar ValidationFailure cuando el email está vacío',
      () async {
        final result = await usecase(
          name: tName,
          email: '',
          username: tUsername,
          password: tPassword,
        );

        expect(
          result,
          const Left(ValidationFailure('Todos los campos son obligatorios')),
        );
        verifyZeroInteractions(mockAuthRepository);
      },
    );

    test(
      'debería retornar ValidationFailure cuando el username está vacío',
      () async {
        final result = await usecase(
          name: tName,
          email: tEmail,
          username: '',
          password: tPassword,
        );

        expect(
          result,
          const Left(ValidationFailure('Todos los campos son obligatorios')),
        );
        verifyZeroInteractions(mockAuthRepository);
      },
    );

    test(
      'debería retornar ValidationFailure cuando la contraseña está vacía',
      () async {
        final result = await usecase(
          name: tName,
          email: tEmail,
          username: tUsername,
          password: '',
        );

        expect(
          result,
          const Left(ValidationFailure('Todos los campos son obligatorios')),
        );
        verifyZeroInteractions(mockAuthRepository);
      },
    );

    test(
      'debería retornar ValidationFailure cuando el formato del email es inválido',
      () async {
        const tInvalidEmail = 'invalid_email';

        final result = await usecase(
          name: tName,
          email: tInvalidEmail,
          username: tUsername,
          password: tPassword,
        );

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
      'debería retornar ValidationFailure cuando la contraseña es muy corta',
      () async {
        const tShortPassword = '123';

        final result = await usecase(
          name: tName,
          email: tEmail,
          username: tUsername,
          password: tShortPassword,
        );

        expect(
          result,
          const Left(
            ValidationFailure('La contraseña debe tener al menos 6 caracteres'),
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
          mockAuthRepository.register(
            name: anyNamed('name'),
            email: anyNamed('email'),
            username: anyNamed('username'),
            password: anyNamed('password'),
          ),
        ).thenAnswer((_) async => Left(tFailure));

        final result = await usecase(
          name: tName,
          email: tEmail,
          username: tUsername,
          password: tPassword,
        );

        expect(result, Left(tFailure));
        verify(
          mockAuthRepository.register(
            name: tName,
            email: tEmail,
            username: tUsername,
            password: tPassword,
          ),
        );
        verifyNoMoreInteractions(mockAuthRepository);
      },
    );
  });
}
