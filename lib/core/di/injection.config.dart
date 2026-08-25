// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/auth/data/datasources/auth_remote_data_source.dart'
    as _i107;
import '../../features/auth/data/repositories_impl/auth_repository_impl.dart'
    as _i710;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/usecases/login_usecase.dart' as _i188;
import '../../features/auth/presentation/bloc/login_bloc.dart' as _i990;
import '../../features/dashboard/data/datasources/dashboard_remote_data_source.dart'
    as _i258;
import '../../features/dashboard/data/repositories_impl/dashboard_repository_impl.dart'
    as _i583;
import '../../features/dashboard/domain/repositories/dashboard_repository.dart'
    as _i665;
import '../../features/dashboard/domain/usecases/get_dashboard_stats_usecase.dart'
    as _i765;
import '../../features/dashboard/presentation/bloc/dashboard_cubit.dart'
    as _i58;
import '../../features/tour/data/datasources/tour_remote_data_source.dart'
    as _i536;
import '../../features/tour/data/repositories_impl/tour_repository_impl.dart'
    as _i318;
import '../../features/tour/domain/repositories/tour_repository.dart' as _i878;
import '../../features/tour/domain/usecases/get_tours_usecase.dart' as _i869;
import '../../features/tour/presentation/bloc/tour_cubit.dart' as _i195;
import '../network/dio_client.dart' as _i667;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final networkModule = _$NetworkModule();
    gh.lazySingleton<_i361.Dio>(() => networkModule.dio);
    gh.lazySingleton<_i536.TourRemoteDataSource>(
      () => _i536.MockTourRemoteDataSourceImpl(),
    );
    gh.lazySingleton<_i107.AuthRemoteDataSource>(
      () => _i107.MockAuthRemoteDataSourceImpl(),
    );
    gh.lazySingleton<_i878.TourRepository>(
      () => _i318.TourRepositoryImpl(gh<_i536.TourRemoteDataSource>()),
    );
    gh.lazySingleton<_i258.DashboardRemoteDataSource>(
      () => _i258.MockDashboardRemoteDataSourceImpl(),
    );
    gh.lazySingleton<_i787.AuthRepository>(
      () => _i710.AuthRepositoryImpl(gh<_i107.AuthRemoteDataSource>()),
    );
    gh.factory<_i869.GetToursUseCase>(
      () => _i869.GetToursUseCase(gh<_i878.TourRepository>()),
    );
    gh.factory<_i188.LoginUseCase>(
      () => _i188.LoginUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i665.DashboardRepository>(
      () =>
          _i583.DashboardRepositoryImpl(gh<_i258.DashboardRemoteDataSource>()),
    );
    gh.factory<_i765.GetDashboardStatsUseCase>(
      () => _i765.GetDashboardStatsUseCase(gh<_i665.DashboardRepository>()),
    );
    gh.factory<_i195.TourCubit>(
      () => _i195.TourCubit(gh<_i869.GetToursUseCase>()),
    );
    gh.factory<_i58.DashboardCubit>(
      () => _i58.DashboardCubit(gh<_i765.GetDashboardStatsUseCase>()),
    );
    gh.factory<_i990.LoginBloc>(
      () => _i990.LoginBloc(gh<_i188.LoginUseCase>()),
    );
    return this;
  }
}

class _$NetworkModule extends _i667.NetworkModule {}
