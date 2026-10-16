import '../../domain/entities/user.dart';

/// Model d'implémentation de [User] : s'occupe de la sérialisation (JSON)
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.agencyCode,
    super.functionCode,
  });

  /// Création depuis l'objet `data.agent` renvoyé par l'API de login :
  /// `{ "code_agent": "...", "nom_util": "...", "code_agce": "...", "code_fonct": 1084 }`
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['code_agent'].toString(),
      name: json['nom_util'].toString(),
      agencyCode: (json['code_agce'] ?? '').toString(),
      functionCode: (json['code_fonct'] as num?)?.toInt(),
    );
  }

  /// Transformation vers JSON (même clés que l'API)
  Map<String, dynamic> toJson() {
    return {
      'code_agent': id,
      'nom_util': name,
      'code_agce': agencyCode,
      'code_fonct': functionCode,
    };
  }
}
