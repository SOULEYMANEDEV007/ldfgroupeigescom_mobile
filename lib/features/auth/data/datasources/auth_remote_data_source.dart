import 'package:injectable/injectable.dart';
import '../models/user_model.dart';
// import 'package:dio/dio.dart'; // Utile lors du branchement réel avec la vraie API

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
}

/// MOCK API : Simule le backend pour ne pas bloquer le développement Mobile.
/// Quand les vraies APIs seront prêtes, nous créerons un [RealAuthRemoteDataSourceImpl]
@LazySingleton(as: AuthRemoteDataSource)
class MockAuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<UserModel> login(String email, String password) async {
    // 1. On simule un temps de latence réseau (ex: serveur distant LdF)
    await Future.delayed(const Duration(seconds: 2));

    // 2. On vérifie des accès codés en dur pour la simulation
    if (email == 'livreur@ldf.ci' && password == '123456') {
      return const UserModel(
        id: 'LDF-999',
        name: 'Kouassi Livreur',
        email: 'livreur@ldf.ci',
        role: 'DRIVER_ROLE',
      );
    }

    // 3. Simulation des erreurs
    throw Exception(
      'Email ou mot de passe incorrect (Mock: livreur@ldf.ci / 123456)',
    );
  }
}
