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
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/history/data/datasources/history_mock_datasource.dart'
    as _histDs;
import '../../features/history/data/repositories_impl/history_repository_impl.dart'
    as _histRepo;
import '../../features/history/domain/repositories/history_repository.dart'
    as _histRepoAbs;
import '../../features/history/presentation/bloc/history_cubit.dart'
    as _histCubit;

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
import '../../features/delivery/data/datasources/delivery_remote_data_source.dart'
    as _i623;
import '../../features/delivery/data/repositories_impl/delivery_repository_impl.dart'
    as _i734;
import '../../features/delivery/domain/repositories/delivery_repository.dart'
    as _i1007;
import '../../features/delivery/domain/usecases/update_delivery_status_usecase.dart'
    as _i289;
import '../../features/delivery/presentation/bloc/delivery_cubit.dart' as _i235;
import '../../features/tour/data/datasources/tour_remote_data_source.dart'
    as _i536;
import '../../features/tour/data/repositories_impl/tour_repository_impl.dart'
    as _i318;
import '../../features/tour/domain/repositories/tour_repository.dart' as _i878;
import '../../features/tour/domain/usecases/get_tours_usecase.dart' as _i869;
import '../../features/tour/presentation/bloc/tour_cubit.dart' as _i195;
import '../network/auth_interceptor.dart' as _i908;
import '../network/dio_client.dart' as _i667;
import '../network/token_manager.dart' as _i374;
import 'register_module.dart' as _i291;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    final networkModule = _$NetworkModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i536.TourRemoteDataSource>(
      () => _i536.MockTourRemoteDataSourceImpl(),
    );
    gh.lazySingleton<_i878.TourRepository>(
      () => _i318.TourRepositoryImpl(gh<_i536.TourRemoteDataSource>()),
    );
    gh.lazySingleton<_i258.DashboardRemoteDataSource>(
      () => _i258.MockDashboardRemoteDataSourceImpl(),
    );
    gh.lazySingleton<_i623.DeliveryRemoteDataSource>(
      () => _i623.MockDeliveryRemoteDataSourceImpl(),
    );
    gh.lazySingleton<_i1007.DeliveryRepository>(
      () => _i734.DeliveryRepositoryImpl(gh<_i623.DeliveryRemoteDataSource>()),
    );
    gh.lazySingleton<_i374.TokenManager>(
      () => _i374.TokenManager(gh<_i460.SharedPreferences>()),
    );
    gh.factory<_i869.GetToursUseCase>(
      () => _i869.GetToursUseCase(gh<_i878.TourRepository>()),
    );
    gh.factory<_i908.AuthInterceptor>(
      () => _i908.AuthInterceptor(gh<_i374.TokenManager>()),
    );
    gh.lazySingleton<_i107.AuthRemoteDataSource>(
      () => _i107.MockAuthRemoteDataSourceImpl(gh<_i374.TokenManager>()),
    );
    gh.factory<_i289.UpdateDeliveryStatusUseCase>(
      () => _i289.UpdateDeliveryStatusUseCase(gh<_i1007.DeliveryRepository>()),
    );
    gh.factory<_i235.DeliveryCubit>(
      () => _i235.DeliveryCubit(gh<_i289.UpdateDeliveryStatusUseCase>()),
    );
    gh.lazySingleton<_i361.Dio>(
      () => networkModule.getDio(gh<_i908.AuthInterceptor>()),
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
    gh.lazySingleton<_i787.AuthRepository>(
      () => _i710.AuthRepositoryImpl(gh<_i107.AuthRemoteDataSource>()),
    );
    gh.factory<_i58.DashboardCubit>(
      () => _i58.DashboardCubit(gh<_i765.GetDashboardStatsUseCase>()),
    );
    gh.factory<_i188.LoginUseCase>(
      () => _i188.LoginUseCase(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i990.LoginBloc>(
      () => _i990.LoginBloc(gh<_i188.LoginUseCase>()),
    );

    // ── History (enregistrement manuel — pas de code gen nécessaire) ────────
    gh.lazySingleton<_histDs.HistoryMockDatasource>(
      () => _histDs.HistoryMockDatasource(),
    );
    gh.lazySingleton<_histRepoAbs.HistoryRepository>(
      () => _histRepo.HistoryRepositoryImpl(
          gh<_histDs.HistoryMockDatasource>()),
    );
    gh.factory<_histCubit.HistoryCubit>(
      () => _histCubit.HistoryCubit(gh<_histRepoAbs.HistoryRepository>()),
    );

    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}

class _$NetworkModule extends _i667.NetworkModule {}
