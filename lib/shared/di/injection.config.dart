// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:albertopr_autenticacion_clean_architecture/features/auth/domain/repositories/auth_repository.dart'
    as _i286;
import 'package:albertopr_autenticacion_clean_architecture/features/auth/domain/usecases/check_auth_status_usecase_injectable.dart'
    as _i470;
import 'package:albertopr_autenticacion_clean_architecture/features/auth/domain/usecases/get_current_user_usecase_injectable.dart'
    as _i497;
import 'package:albertopr_autenticacion_clean_architecture/features/auth/domain/usecases/login_usecase_injectable.dart'
    as _i700;
import 'package:albertopr_autenticacion_clean_architecture/features/auth/domain/usecases/logout_usecase_injectable.dart'
    as _i477;
import 'package:albertopr_autenticacion_clean_architecture/features/auth/domain/usecases/register_usecase_injectable.dart'
    as _i990;
import 'package:albertopr_autenticacion_clean_architecture/features/auth/infrastructure/datasources/auth_local_datasource.dart'
    as _i794;
import 'package:albertopr_autenticacion_clean_architecture/features/auth/infrastructure/datasources/auth_local_datasource_injectable.dart'
    as _i727;
import 'package:albertopr_autenticacion_clean_architecture/features/auth/infrastructure/datasources/auth_remote_datasource.dart'
    as _i291;
import 'package:albertopr_autenticacion_clean_architecture/features/auth/infrastructure/datasources/auth_remote_datasource_injectable.dart'
    as _i961;
import 'package:albertopr_autenticacion_clean_architecture/features/auth/infrastructure/repositories/auth_repository_injectable.dart'
    as _i785;
import 'package:albertopr_autenticacion_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart'
    as _i871;
import 'package:albertopr_autenticacion_clean_architecture/shared/di/register_module.dart'
    as _i678;
import 'package:albertopr_autenticacion_clean_architecture/shared/network/dio_client.dart'
    as _i298;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.singleton<_i298.DioClient>(() => registerModule.dioClient);
    gh.singleton<_i558.FlutterSecureStorage>(
      () => registerModule.secureStorage,
    );
    gh.factory<_i291.AuthRemoteDataSource>(
      () => _i961.AuthRemoteDataSourceInjectableImpl(gh<_i298.DioClient>()),
    );
    gh.factory<_i794.AuthLocalDataSource>(
      () => _i727.AuthLocalDataSourceInjectableImpl(
        gh<_i558.FlutterSecureStorage>(),
      ),
    );
    gh.factory<_i286.AuthRepository>(
      () => _i785.AuthRepositoryInjectableImpl(
        remoteDataSource: gh<_i291.AuthRemoteDataSource>(),
        localDataSource: gh<_i794.AuthLocalDataSource>(),
      ),
    );
    gh.factory<_i497.GetCurrentUserUseCaseInjectable>(
      () => _i497.GetCurrentUserUseCaseInjectable(gh<_i286.AuthRepository>()),
    );
    gh.factory<_i470.CheckAuthStatusUseCaseInjectable>(
      () => _i470.CheckAuthStatusUseCaseInjectable(gh<_i286.AuthRepository>()),
    );
    gh.factory<_i990.RegisterUseCaseInjectable>(
      () => _i990.RegisterUseCaseInjectable(gh<_i286.AuthRepository>()),
    );
    gh.factory<_i477.LogoutUseCaseInjectable>(
      () => _i477.LogoutUseCaseInjectable(gh<_i286.AuthRepository>()),
    );
    gh.factory<_i700.LoginUseCaseInjectable>(
      () => _i700.LoginUseCaseInjectable(gh<_i286.AuthRepository>()),
    );
    gh.factory<_i871.AuthBloc>(
      () => _i871.AuthBloc(
        gh<_i700.LoginUseCaseInjectable>(),
        gh<_i990.RegisterUseCaseInjectable>(),
        gh<_i477.LogoutUseCaseInjectable>(),
        gh<_i497.GetCurrentUserUseCaseInjectable>(),
        gh<_i470.CheckAuthStatusUseCaseInjectable>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i678.RegisterModule {}
