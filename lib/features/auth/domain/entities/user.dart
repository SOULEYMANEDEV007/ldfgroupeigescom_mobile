import 'package:equatable/equatable.dart';

/// Entité Métier: Représente l'agent connecté (livreur / convoyeur).
/// Cette classe est pure et indépendante de tout framework (Clean Architecture)
class User extends Equatable {
  /// Code agent (`code_agent`) : identifiant utilisé par les endpoints de tournées.
  final String id;

  /// Nom d'utilisateur de connexion (`nom_util`).
  final String name;

  /// Code de l'agence / dépôt de l'agent (`code_agce`).
  final String agencyCode;

  /// Code de la fonction de l'agent (`code_fonct`), si fourni.
  final int? functionCode;

  const User({
    required this.id,
    required this.name,
    required this.agencyCode,
    this.functionCode,
  });

  @override
  List<Object?> get props => [id, name, agencyCode, functionCode];
}
