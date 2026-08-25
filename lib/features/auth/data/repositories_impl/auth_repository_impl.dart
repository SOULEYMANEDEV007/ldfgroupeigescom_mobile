import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

/// Implémentation réelle du contrat [AuthRepository]
@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<String, User>> login(String email, String password) async {
    try {
      final userModel = await remoteDataSource.login(email, password);
      // Optionnel : Ici nous pourrions sauvegarder le token en cache (ex: SharedPreferences / FlutterSecureStorage)
      return Right(userModel);
    } catch (e) {
      // Pour une vraie app, on parserait l'exception (DioException) pour un message clair
      return Left(e.toString().replaceAll('Exception:', '').trim());
    }
  }

  @override
  Future<void> logout() async {
    // Effacer les tokens dans le storage
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
