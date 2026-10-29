import 'package:equatable/equatable.dart';

/// Entité représentant le profil personnel et professionnel d'un agent / livreur IGESCOM.
class UserProfile extends Equatable {
  final String codeAgent;
  final String username;
  final String nom;
  final String prenom;
  final String telephone;
  final String portable;
  final String adresse;
  final String dateNaissance;
  final String lieuNaissance;
  final String matricule;
  final String role;
  final String agency;
  final String agencyCode;
  final String? photoUrl;

  const UserProfile({
    required this.codeAgent,
    required this.username,
    required this.nom,
    required this.prenom,
    required this.telephone,
    required this.portable,
    required this.adresse,
    required this.dateNaissance,
    required this.lieuNaissance,
    required this.matricule,
    required this.role,
    required this.agency,
    required this.agencyCode,
    this.photoUrl,
  });

  String get nomComplet {
    if (nom.isNotEmpty && prenom.isNotEmpty) {
      return '$nom $prenom'.trim();
    }
    return nom.isNotEmpty ? nom : (prenom.isNotEmpty ? prenom : username);
  }

  UserProfile copyWith({
    String? codeAgent,
    String? username,
    String? nom,
    String? prenom,
    String? telephone,
    String? portable,
    String? adresse,
    String? dateNaissance,
    String? lieuNaissance,
    String? matricule,
    String? role,
    String? agency,
    String? agencyCode,
    String? photoUrl,
  }) {
    return UserProfile(
      codeAgent: codeAgent ?? this.codeAgent,
      username: username ?? this.username,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      telephone: telephone ?? this.telephone,
      portable: portable ?? this.portable,
      adresse: adresse ?? this.adresse,
      dateNaissance: dateNaissance ?? this.dateNaissance,
      lieuNaissance: lieuNaissance ?? this.lieuNaissance,
      matricule: matricule ?? this.matricule,
      role: role ?? this.role,
      agency: agency ?? this.agency,
      agencyCode: agencyCode ?? this.agencyCode,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  @override
  List<Object?> get props => [
        codeAgent,
        username,
        nom,
        prenom,
        telephone,
        portable,
        adresse,
        dateNaissance,
        lieuNaissance,
        matricule,
        role,
        agency,
        agencyCode,
        photoUrl,
      ];
}
