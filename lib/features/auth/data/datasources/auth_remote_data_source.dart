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

/// MOCK API : Simule le backend pour les démos (`USE_MOCK_API=true`).
@LazySingleton(as: AuthRemoteDataSource, env: [kMockEnv])
class MockAuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final TokenManager _tokenManager;

  MockAuthRemoteDataSourceImpl(this._tokenManager);

  @override
  Future<UserModel> login(String username, String password) async {
    // 1. On simule un temps de latence réseau (ex: serveur distant LdF)
    await Future.delayed(const Duration(seconds: 2));

    // 2. On vérifie des accès codés en dur pour la simulation
    if (username == 'LDF-999' && password == '123') {
      const user = UserModel(
        id: 'LDF-999',
        name: 'Kouassi Livreur',
        agencyCode: 'LDF-Plateau',
      );

      // Simulation de la sauvegarde du token JWT renvoyé par l'API
      final pseudoJwt =
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.MockPayload.${DateTime.now().millisecondsSinceEpoch}';
      await _tokenManager.saveSession(
        pseudoJwt,
        user.name,
        codeAgent: user.id,
        agencyCode: user.agencyCode,
      );

      return user;
    }

    // 3. Simulation des erreurs
    throw Exception('Identifiant ou mot de passe incorrect (Mock: LDF-999 / 123)');
  }
}

/// Implémentation RÉELLE : `POST /api/metabase/mobile/livraison/login/`
@LazySingleton(as: AuthRemoteDataSource, env: [kRealEnv])
class RealAuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;
  final TokenManager _tokenManager;

  RealAuthRemoteDataSourceImpl(this._dio, this._tokenManager);

  @override
  Future<UserModel> login(String username, String password) async {
    final response = await _dio.post<dynamic>(
      ApiEndpoints.login,
      data: {'nom_util': username, 'mdpasse': password},
    );

    final body = response.data;
    if (body is! Map<String, dynamic> || body['status'] != 'success') {
      throw const ApiException('Connexion refusée par le serveur.');
    }

    final data = body['data'] as Map<String, dynamic>;
    final user = UserModel.fromJson(data['agent'] as Map<String, dynamic>);
    final token = data['token'] as String?;
    if (token == null || token.isEmpty) {
      throw const ApiException('Réponse de connexion invalide (token manquant).');
    }

    await _tokenManager.saveSession(
      token,
      user.name,
      refreshToken: data['refresh'] as String?,
      codeAgent: user.id,
      agencyCode: user.agencyCode,
    );

    return user;
  }
}
