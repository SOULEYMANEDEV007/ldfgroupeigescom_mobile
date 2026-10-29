import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// UseCase (Cas d'utilisation) : Gère une seule fonctionnalité métier spécifique (Connecter un livreur)
@injectable
class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<String, User>> call(String username, String password) {
    if (username.trim().isEmpty || password.isEmpty) {
      return Future.value(
        const Left('Veuillez renseigner votre identifiant et votre mot de passe.'),
      );
    }
    return repository.login(username.trim(), password);
  }
}
