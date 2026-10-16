import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/api_error_handler.dart';
import '../../../../core/network/token_manager.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

/// Implémentation réelle du contrat [AuthRepository]
@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final TokenManager _tokenManager;

  AuthRepositoryImpl(this.remoteDataSource, this._tokenManager);

  @override
  Future<Either<String, User>> login(String username, String password) async {
    try {
      final userModel = await remoteDataSource.login(username, password);
      return Right(userModel);
    } catch (e) {
      return Left(
        ApiErrorHandler.message(
          e,
          unauthorizedMessage: 'Identifiant ou mot de passe incorrect.',
        ),
      );
    }
  }

  @override
  Future<void> logout() => _tokenManager.clearSession();
}
