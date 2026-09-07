import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'auth_interceptor.dart';

@module
abstract class NetworkModule {
  @lazySingleton
  Dio getDio(AuthInterceptor authInterceptor) {
    final dio = Dio(
      BaseOptions(
        // TODO: Mettre l'URL réelle de l'API de IGS Com ici
        baseUrl: 'https://api.ldfgroupe.com/v1',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Injection de l'intercepteur JWT avant le logger
    dio.interceptors.add(authInterceptor);

    // Ajout d'intercepteurs pour logger les requêtes et réponses en mode debug
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
    );

    return dio;
  }
}
