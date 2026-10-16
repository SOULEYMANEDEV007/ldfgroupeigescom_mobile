import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/api_error_handler.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/user_profile_model.dart';

@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  ProfileRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<String, UserProfile>> getProfile(String codeAgent) async {
    try {
      final profile = await _remoteDataSource.getProfile(codeAgent);
      return Right(profile);
    } on DioException catch (e) {
      return Left(ApiErrorHandler.message(e));
    } catch (e) {
      return Left('Impossible de charger le profil : $e');
    }
  }

  @override
  Future<Either<String, Unit>> updateProfile(UserProfile profile) async {
    try {
      final model = profile is UserProfileModel
          ? profile
          : UserProfileModel(
              codeAgent: profile.codeAgent,
              username: profile.username,
              nom: profile.nom,
              prenom: profile.prenom,
              telephone: profile.telephone,
              portable: profile.portable,
              adresse: profile.adresse,
              dateNaissance: profile.dateNaissance,
              lieuNaissance: profile.lieuNaissance,
              matricule: profile.matricule,
              role: profile.role,
              agency: profile.agency,
              agencyCode: profile.agencyCode,
              photoUrl: profile.photoUrl,
            );

      await _remoteDataSource.updateProfile(model);
      return const Right(unit);
    } on DioException catch (e) {
      return Left(ApiErrorHandler.message(e));
    } catch (e) {
      return Left('Erreur lors de la mise à jour : $e');
    }
  }

  @override
  Future<Either<String, Unit>> changePassword(
    String codeAgent,
    String oldPassword,
    String newPassword,
  ) async {
    try {
      await _remoteDataSource.changePassword(
        codeAgent,
        oldPassword,
        newPassword,
      );
      return const Right(unit);
    } on DioException catch (e) {
      return Left(ApiErrorHandler.message(e));
    } catch (e) {
      return Left('Erreur modification mot de passe : $e');
    }
  }
}
