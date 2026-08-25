import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// UseCase (Cas d'utilisation) : Gère une seule fonctionnalité métier spécifique (Connecter un livreur)
@injectable
class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<String, User>> call(String email, String password) {
    if (email.isEmpty || password.isEmpty) {
      return Future.value(const Left("Veuillez remplir tous les champs."));
    }
    return repository.login(email, password);
  }
}
