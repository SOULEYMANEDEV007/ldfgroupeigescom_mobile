import 'package:equatable/equatable.dart';

/// Entité Métier: Représente un Livreur (User)
/// Cette classe est pure et indépendante de tout framework (Clean Architecture)
class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String role;
  // TODO: Ajoutez ici d'autres attributs si nécessaire (ex: phone, avatarUrl, etc.)

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  @override
  List<Object?> get props => [id, name, email, role];
}
