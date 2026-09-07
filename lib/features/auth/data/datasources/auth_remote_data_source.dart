import 'package:injectable/injectable.dart';
import '../models/user_model.dart';
// import 'package:dio/dio.dart'; // Utile lors du branchement réel avec la vraie API

import '../../../../core/network/token_manager.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String matricule, String agence, String password);
}

/// MOCK API : Simule le backend pour ne pas bloquer le développement Mobile.
/// Quand les vraies APIs seront prêtes, nous créerons un [RealAuthRemoteDataSourceImpl]
@LazySingleton(as: AuthRemoteDataSource)
class MockAuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final TokenManager _tokenManager;

  MockAuthRemoteDataSourceImpl(this._tokenManager);

  @override
  Future<UserModel> login(
    String matricule,
    String agence,
    String password,
  ) async {
    // 1. On simule un temps de latence réseau (ex: serveur distant LdF)
    await Future.delayed(const Duration(seconds: 2));

    // 2. On vérifie des accès codés en dur pour la simulation
    // On ignore l'agence mais on la réclame pour le mock
    if (matricule == 'LDF-999' && password == '123') {
      const user = UserModel(
        id: 'LDF-999',
        name: 'Kouassi Livreur',
        email: 'livreur@ldf.ci',
        role: 'DRIVER_ROLE',
      );

      // Simulation de la sauvegarde du token JWT renvoyé par l'API
      final pseudoJwt =
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.MockPayload.${DateTime.now().millisecondsSinceEpoch}';
      await _tokenManager.saveSession(pseudoJwt, user.name);

      return user;
    }

    // 3. Simulation des erreurs
    throw Exception(
      'Matricule ou mot de passe incorrect (Mock: LDF-999 / 123)',
    );
  }
}
