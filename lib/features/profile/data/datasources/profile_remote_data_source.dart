import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/token_manager.dart';
import '../models/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getProfile(String codeAgent);
  Future<void> updateProfile(UserProfileModel profile);
  Future<void> changePassword(
    String codeAgent,
    String oldPassword,
    String newPassword,
  );
}

@LazySingleton(as: ProfileRemoteDataSource)
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio _dio;
  final TokenManager _tokenManager;

  ProfileRemoteDataSourceImpl(this._dio, this._tokenManager);

  @override
  Future<UserProfileModel> getProfile(String codeAgent) async {
    final username = _tokenManager.getUserName() ?? 'Livreur';
    final agencyCode = _tokenManager.getAgencyCode() ?? 'DGC';
    final savedFullName = _tokenManager.getFullName();
    final savedRole = _tokenManager.getUserRole() ?? 'CONVOYEUR - LIVREUR';

    // 1. Vérifier si des données personnalisées ont déjà été enregistrées localement
    final cachedData = _tokenManager.getProfileData();
    if (cachedData != null) {
      return UserProfileModel.fromApiJson(
        cachedData,
        defaultCodeAgent: codeAgent,
        defaultUsername: username,
        defaultAgency: 'DEPOT GRANDS COMPTES - $agencyCode',
        defaultAgencyCode: agencyCode,
        defaultRole: savedRole,
      );
    }

    // Extraction nom/prénom depuis savedFullName si disponible
    String defaultNom = 'CONVOYEUR';
    String defaultPrenom = 'TEST';
    if (savedFullName != null && savedFullName.isNotEmpty) {
      final parts = savedFullName.trim().split(' ');
      if (parts.isNotEmpty) defaultNom = parts.first;
      if (parts.length > 1) defaultPrenom = parts.sublist(1).join(' ');
    }

    return UserProfileModel(
      codeAgent: codeAgent,
      username: username,
      nom: defaultNom,
      prenom: defaultPrenom,
      telephone: '',
      portable: '',
      adresse: '',
      dateNaissance: '',
      lieuNaissance: '',
      matricule: codeAgent,
      role: savedRole,
      agency: 'DEPOT GRANDS COMPTES - $agencyCode',
      agencyCode: agencyCode,
    );
  }

  @override
  Future<void> updateProfile(UserProfileModel profile) async {
    // 1. Sauvegarde locale immédiate garantie
    await _tokenManager.saveProfileData(profile.toJson());
    if (profile.nomComplet.isNotEmpty) {
      await _tokenManager.setFullName(profile.nomComplet);
    }

    // 2. Synchronisation serveur protégée (ne provoque jamais d'expiration de session)
    try {
      await _dio.post(
        ApiEndpoints.updateAgentProfile(profile.codeAgent),
        data: profile.toUpdateJson(),
        options: Options(extra: {'noSessionExpire': true}),
      );
    } catch (_) {
      // Tolérance : mise à jour conservée en local si l'API est restreinte au portail web
    }
  }

  @override
  Future<void> changePassword(
    String codeAgent,
    String oldPassword,
    String newPassword,
  ) async {
    await _dio.post(
      ApiEndpoints.changePassword(codeAgent),
      data: {
        'old': oldPassword,
        'new_mdp': newPassword,
      },
      options: Options(extra: {'noSessionExpire': true}),
    );
  }
}
