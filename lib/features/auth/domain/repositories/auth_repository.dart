import 'package:dartz/dartz.dart';
import '../entities/user.dart';

/// Interface du Repository d'Authentification
/// Le contrat métier : défini ce que la couche data DOIT implémenter
abstract class AuthRepository {
  /// Connecte l'utilisateur (livreur) avec son identifiant (`nom_util`) et son mot de passe.
  /// Retourne un [String] (message en français) en cas d'erreur ou [User] en cas de succès.
  Future<Either<String, User>> login(String username, String password);

  /// Gère la déconnexion (efface la session locale)
  Future<void> logout();
}
