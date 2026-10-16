import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../config/app_config.dart';
import 'auth_interceptor.dart';

@module
abstract class NetworkModule {
  @lazySingleton
  Dio getDio(AuthInterceptor authInterceptor) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Injection de l'intercepteur JWT avant le logger
    dio.interceptors.add(authInterceptor);

    // Logs requêtes/réponses uniquement hors release.
    // Les en-têtes (Authorization) ne sont pas journalisés et les secrets
    // (mot de passe, tokens) sont masqués dans les corps.
    if (!kReleaseMode) {
      dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: false,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
          logPrint: (object) => debugPrint(_redact(object.toString())),
        ),
      );
    }

    return dio;
  }
}

final RegExp _secrets = RegExp(
  r'(mdpasse|password|token|refresh)(["\x27]?\s*[:=]\s*["\x27]?)[^,}"\x27\s]+',
  caseSensitive: false,
);

String _redact(String text) =>
    text.replaceAllMapped(_secrets, (m) => '${m[1]}${m[2]}***');
