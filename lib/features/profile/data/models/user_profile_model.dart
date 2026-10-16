import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.codeAgent,
    required super.username,
    required super.nom,
    required super.prenom,
    required super.telephone,
    required super.portable,
    required super.adresse,
    required super.dateNaissance,
    required super.lieuNaissance,
    required super.matricule,
    required super.role,
    required super.agency,
    required super.agencyCode,
    super.photoUrl,
  });

  /// Parse à partir de la réponse du backend `/api/profil/agents/{id}/`
  factory UserProfileModel.fromApiJson(
    Map<String, dynamic> json, {
    String? defaultCodeAgent,
    String? defaultUsername,
    String? defaultAgency,
    String? defaultAgencyCode,
    String? defaultRole,
  }) {
    final agent = (json['agent'] is Map<String, dynamic>)
        ? json['agent'] as Map<String, dynamic>
        : json;

    return UserProfileModel(
      codeAgent: agent['code_agent']?.toString() ??
          agent['mat_agent']?.toString() ??
          defaultCodeAgent ??
          '',
      username: agent['nom_util']?.toString() ?? defaultUsername ?? '',
      nom: agent['nom_agent']?.toString() ?? agent['nom']?.toString() ?? '',
      prenom: agent['pnom_agent']?.toString() ?? agent['prenom']?.toString() ?? '',
      telephone: agent['tel_agent']?.toString() ?? agent['telephone']?.toString() ?? '',
      portable: agent['portable_agent']?.toString() ?? agent['portable']?.toString() ?? '',
      adresse: agent['addr_agent']?.toString() ?? agent['adresse']?.toString() ?? '',
      dateNaissance: agent['dnais_agent']?.toString() ?? agent['datenaissance']?.toString() ?? '',
      lieuNaissance: agent['lnais_agent']?.toString() ?? agent['lieunaissance']?.toString() ?? '',
      matricule: agent['mat_agent']?.toString() ??
          agent['matricule']?.toString() ??
          defaultCodeAgent ??
          '',
      role: agent['role']?.toString() ?? defaultRole ?? 'CONVOYEUR - LIVREUR',
      agency: agent['agence']?.toString() ??
          defaultAgency ??
          'DEPOT GRANDS COMPTES',
      agencyCode: agent['code_agce']?.toString() ?? defaultAgencyCode ?? 'DGC',
      photoUrl: agent['photo_url']?.toString(),
    );
  }

  /// Prépare le body pour `POST /api/profil/modificationagents/{identifiant}/`
  Map<String, dynamic> toUpdateJson() => {
        'nom': nom,
        'prenom': prenom,
        'telephone': telephone,
        'portable': portable,
        'adresse': adresse,
        'lieunaissance': lieuNaissance,
        'datenaissance': dateNaissance,
        'matricule': matricule,
      };

  Map<String, dynamic> toJson() => {
        'code_agent': codeAgent,
        'nom_util': username,
        'nom_agent': nom,
        'pnom_agent': prenom,
        'tel_agent': telephone,
        'portable_agent': portable,
        'addr_agent': adresse,
        'dnais_agent': dateNaissance,
        'lnais_agent': lieuNaissance,
        'mat_agent': matricule,
        'role': role,
        'agence': agency,
        'code_agce': agencyCode,
        'photo_url': photoUrl,
      };
}
