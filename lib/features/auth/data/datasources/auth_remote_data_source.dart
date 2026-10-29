import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/di/app_environments.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_error_handler.dart';
import '../../../../core/network/token_manager.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String username, String password);
}

/// Authentification réelle via l'API LDF.
@LazySingleton(as: AuthRemoteDataSource, env: [kRealEnv])
class RealAuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;
  final TokenManager _tokenManager;

  RealAuthRemoteDataSourceImpl(this._dio, this._tokenManager);

  @override
  Future<UserModel> login(String username, String password) async {
    try {
      // 1. Appel de l'API d'authentification.
      final response = await _dio.post<dynamic>(
        ApiEndpoints.login,
        data: {'nom_util': username.trim(), 'mdpasse': password},
      );

      // 2. Vérification de la réponse.
      final body = response.data;

      if (body is! Map) {
        throw const ApiException('Réponse invalide du serveur.');
      }

      if (body['status'] != 'success') {
        throw ApiException(
          body['message']?.toString() ?? 'Échec de l’authentification.',
        );
      }

      // 3. Extraction des données.
      final rawData = body['data'];

      if (rawData is! Map) {
        throw const ApiException('Les données utilisateur sont absentes.');
      }

      final data = Map<String, dynamic>.from(rawData);
      final rawAgent = data['agent'];
      final rawToken = data['token'];

      if (rawAgent is! Map) {
        throw const ApiException(
          'Informations de l’agent absentes de la réponse.',
        );
      }

      if (rawToken is! String || rawToken.trim().isEmpty) {
        throw const ApiException('Le serveur n’a retourné aucun token valide.');
      }

      final agentData = Map<String, dynamic>.from(rawAgent);
      final user = UserModel.fromJson(agentData);
      String finalToken = rawToken.trim();
      String? finalRefresh = data['refresh']?.toString();

      // 4. Acquisition transparente du token ERP (claim 'tenant') pour débloquer la validation des livraisons
      try {
        final erpResponse = await _dio.post<dynamic>(
          ApiEndpoints.erpLogin,
          data: {
            'nom_util': username.trim(),
            'mdpasse': password,
            'code_agce': user.agencyCode,
          },
          options: Options(
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );
        final erpBody = erpResponse.data;
        if (erpBody is Map<String, dynamic> &&
            erpBody['data'] is Map<String, dynamic>) {
          final erpData = erpBody['data'] as Map<String, dynamic>;
          final erpToken = erpData['token']?.toString();
          if (erpToken != null && erpToken.isNotEmpty) {
            finalToken = erpToken;
            finalRefresh = erpData['refresh']?.toString() ?? finalRefresh;
          }
        }
      } catch (_) {
        // Si /api/login/ est inaccessible, on conserve le token de base
      }

      // 5. Sauvegarde persistante de la session.
      await _tokenManager.saveSession(
        finalToken,
        user.name,
        refreshToken: finalRefresh,
        codeAgent: user.id,
        agencyCode: user.agencyCode,
      );

      return user;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;

      String? serverMessage;

      if (responseData is Map && responseData['message'] != null) {
        serverMessage = responseData['message'].toString();
      }

      if (statusCode == 401) {
        throw ApiException(serverMessage ?? 'Identifiants incorrects.');
      }

      if (statusCode == 403) {
        throw ApiException(serverMessage ?? 'Accès refusé par le serveur.');
      }

      if (statusCode != null) {
        throw ApiException(
          serverMessage ?? 'Erreur serveur (HTTP $statusCode).',
        );
      }

      throw ApiException(
        'Impossible de joindre le serveur. '
        'Vérifie la connexion réseau.',
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Erreur lors de la connexion : $e');
    }
  }
}
