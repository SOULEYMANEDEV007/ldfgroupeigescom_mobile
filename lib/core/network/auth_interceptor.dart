import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'token_manager.dart';

/// Intercepteur global : injecte le JWT et centralise la gestion des 401.
///
/// 🛠️ **DÉVELOPPEUR FUTUR** :
/// Cet intercepteur se branche sur `DioClient`.
/// - À chaque requête, on lit le token dans SharedPreferences et on l'injecte.
/// - Si l'API retourne HTTP 401 (Unauthorized), tu peux déclencher un Event/Stream
///   pour forcer l'interface à déconnecter l'utilisateur (go('/login')).
@injectable
class AuthInterceptor extends Interceptor {
  final TokenManager _tokenManager;

  AuthInterceptor(this._tokenManager);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _tokenManager.getToken();

    if (token != null && token.isNotEmpty) {
      // Injection du token d'autorisation
      options.headers['Authorization'] = 'Bearer $token';
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // TODO: Gérer l'expiration globale du token.
      // Par exemple, émettre un stream que le main_router ou app_bloc écoute
      // pour forcer `_tokenManager.clearSession()` et `context.go('/login')`.
    }
    super.onError(err, handler);
  }
}
