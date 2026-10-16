import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../../features/history/data/datasources/history_mock_datasource.dart';
import '../../features/history/data/repositories_impl/history_repository_impl.dart';
import '../../features/history/domain/repositories/history_repository.dart';
import '../config/app_config.dart';
import 'app_environments.dart';
import 'injection.config.dart'; // Fichier généré par build_runner

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init', // default
  preferRelativeImports: true, // default
  asExtension: true, // default
)
Future<void> configureDependencies() async {
  // `real` = vraie API, `mock` = données de démo (cf. USE_MOCK_API dans .env)
  await getIt.init(environment: AppConfig.useMockApi ? kMockEnv : kRealEnv);
  
  // ⚠️ ENREGISTREMENT MANUEL POUR HISTORY (build_runner ne l'a pas généré)
  if (!getIt.isRegistered<HistoryMockDatasource>()) {
    getIt.registerLazySingleton<HistoryMockDatasource>(
      () => HistoryMockDatasource(),
    );
  }
  
  if (!getIt.isRegistered<HistoryRepository>()) {
    getIt.registerLazySingleton<HistoryRepository>(
      () => HistoryRepositoryImpl(getIt<HistoryMockDatasource>()),
    );
  }
}
