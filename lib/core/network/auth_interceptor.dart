import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../config/app_config.dart';
import 'api_endpoints.dart';
import 'token_manager.dart';

/// Intercepteur global : injecte le JWT et gère le rafraîchissement transparent ou les 401.
@injectable
class AuthInterceptor extends Interceptor {
  final TokenManager _tokenManager;

  AuthInterceptor(this._tokenManager);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _tokenManager.getToken();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    super.onRequest(options, handler);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isLoginRequest = err.requestOptions.path.contains(ApiEndpoints.login);
    final isRefreshRequest =
        err.requestOptions.path.contains(ApiEndpoints.refreshToken);
    final isProfileRequest = err.requestOptions.path.contains('/profil/');
    final noSessionExpire = err.requestOptions.extra['noSessionExpire'] == true;
    final isInstanceTokenError = err.response?.data is Map &&
        (err.response?.data['detail']?.toString().toLowerCase().contains('instance') ??
            false);
    final hadSession = (_tokenManager.getToken() ?? '').isNotEmpty;

    // Un 401 sur le login = mauvais identifiants (géré par l'écran de login).
    // On n'invalide pas la session si l'endpoint est un endpoint profil web ou marqué noSessionExpire.
    if (err.response?.statusCode == 401 &&
        !isLoginRequest &&
        !isRefreshRequest &&
        !isProfileRequest &&
        !noSessionExpire &&
        !isInstanceTokenError &&
        hadSession) {
      final refreshToken = _tokenManager.getRefreshToken();

      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          // Tentative de rafraîchissement via instance Dio isolée (évite les boucles)
          final refreshDio = Dio(
            BaseOptions(
              baseUrl: AppConfig.apiBaseUrl,
              connectTimeout: AppConfig.connectTimeout,
              receiveTimeout: AppConfig.receiveTimeout,
              headers: {'Content-Type': 'application/json'},
            ),
          );

          final refreshResponse = await refreshDio.post(
            ApiEndpoints.refreshToken,
            data: {'refresh': refreshToken},
          );

          if (refreshResponse.statusCode == 200 &&
              refreshResponse.data is Map<String, dynamic>) {
            final data = refreshResponse.data as Map<String, dynamic>;
            final newAccessToken = data['access']?.toString();
            final newRefreshToken = data['refresh']?.toString();

            if (newAccessToken != null && newAccessToken.isNotEmpty) {
              await _tokenManager.updateTokens(
                newAccessToken,
                refreshToken: newRefreshToken,
              );

              // Rejouer la requête d'origine avec le nouveau token
              final options = err.requestOptions;
              options.headers['Authorization'] = 'Bearer $newAccessToken';

              final retryResponse = await refreshDio.fetch(options);
              return handler.resolve(retryResponse);
            }
          }
        } catch (_) {
          // Échec du refresh -> invalidation définitive de la session
        }
      }

      await _tokenManager.expireSession();
    }

    super.onError(err, handler);
  }
}
