import 'package:dio/dio.dart';

/// Erreur métier/format remontée par la couche data (réponse API inattendue,
/// `status` différent de `success`, etc.). Le [message] est affichable tel quel.
class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

/// Convertit n'importe quelle erreur (Dio, parsing, métier) en un message
/// clair en français, affichable à l'utilisateur.
abstract class ApiErrorHandler {
  /// [unauthorizedMessage] permet de personnaliser le message d'un HTTP 401
  /// (ex: « Identifiant ou mot de passe incorrect » pour le login).
  static String message(Object error, {String? unauthorizedMessage}) {
    if (error is ApiException) return error.message;

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.transformTimeout:
          return 'Le serveur met trop de temps à répondre. Vérifiez votre connexion et réessayez.';
        case DioExceptionType.connectionError:
          return 'Impossible de joindre le serveur. Vérifiez votre connexion réseau.';
        case DioExceptionType.cancel:
          return 'La requête a été annulée.';
        case DioExceptionType.badCertificate:
          return 'Certificat de sécurité du serveur invalide.';
        case DioExceptionType.badResponse:
          return _fromStatus(error.response, unauthorizedMessage);
        case DioExceptionType.unknown:
          return 'Impossible de joindre le serveur. Vérifiez votre connexion réseau.';
      }
    }

    // Réponse JSON non conforme au contrat attendu
    if (error is FormatException || error is TypeError) {
      return 'Réponse inattendue du serveur. Veuillez réessayer.';
    }

    // Exceptions simples (ex: mocks) : on retire le préfixe technique.
    final text = error.toString().replaceFirst('Exception:', '').trim();
    return text.isEmpty ? 'Une erreur inattendue est survenue.' : text;
  }

  static String _fromStatus(Response<dynamic>? response, String? unauthorized) {
    final status = response?.statusCode ?? 0;
    switch (status) {
      case 400:
        return _serverMessage(response) ??
            'Requête invalide. Vérifiez les informations saisies.';
      case 401:
        return unauthorized ?? 'Votre session a expiré. Veuillez vous reconnecter.';
      case 403:
        return 'Accès refusé pour ce compte.';
      case 404:
        return 'Ressource introuvable sur le serveur.';
      case 409:
      case 422:
        return _serverMessage(response) ??
            'Cette opération ne peut pas être effectuée.';
      default:
        if (status >= 500) {
          return 'Erreur du serveur. Veuillez réessayer plus tard.';
        }
        return 'Erreur inattendue (code $status).';
    }
  }

  /// Extrait un message lisible du corps JSON (`message`, `detail` ou `error`).
  static String? _serverMessage(Response<dynamic>? response) {
    final data = response?.data;
    if (data is Map) {
      for (final key in const ['message', 'detail', 'error']) {
        final value = data[key];
        if (value is String && value.trim().isNotEmpty) return value.trim();
      }
    }
    return null;
  }
}
