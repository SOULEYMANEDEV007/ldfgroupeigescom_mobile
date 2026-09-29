import 'package:dartz/dartz.dart';
import '../entities/user.dart';

/// Interface du Repository d'Authentification
/// Le contrat métier : défini ce que la couche data DOIT implémenter
abstract class AuthRepository {
  /// Connecte l'utilisateur (livreur) avec son matricule, agence et mot de passe.
  /// Retourne un [String] en cas d'erreur métier ou [User] en cas de succès.
  Future<Either<String, User>> login(
    String matricule,
    String agence,
    String password,
  );

  /// Gère la déconnexion
  Future<void> logout();
}
