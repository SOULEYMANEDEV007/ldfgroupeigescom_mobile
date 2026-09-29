import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuration centralisée et typée de l'application via les variables d'environnement (.env).
abstract class AppConfig {
  /// URL de base de l'API REST IGESCOM / LDF Groupe.
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'https://api.ldfgroupe.com/v1';

  /// Timeout de connexion HTTP.
  static Duration get connectTimeout {
    final timeoutMs = int.tryParse(dotenv.env['CONNECT_TIMEOUT'] ?? '15000') ?? 15000;
    return Duration(milliseconds: timeoutMs);
  }

  /// Timeout de réception HTTP.
  static Duration get receiveTimeout {
    final timeoutMs = int.tryParse(dotenv.env['RECEIVE_TIMEOUT'] ?? '15000') ?? 15000;
    return Duration(milliseconds: timeoutMs);
  }

  /// Environnement actif (ex: development, staging, production).
  static String get appEnv => dotenv.env['APP_ENV'] ?? 'development';

  /// Nom de l'application.
  static String get appName => dotenv.env['APP_NAME'] ?? 'IGESCOM Mobile';

  /// Indique si l'application tourne en environnement de développement.
  static bool get isDevelopment => appEnv == 'development';

  /// Indique si l'application tourne en production.
  static bool get isProduction => appEnv == 'production';
}
