/// Regroupe tous les endpoints de l'application LdF Igescom Mobile.
///
/// 🛠️ **DÉVELOPPEUR FUTUR** :
/// L'URL de base est définie dans `DioClient` (actuellement mockée).
/// Lorsque le backend IGS Com sera prêt, tu n'auras qu'à mettre à jour
/// la chaîne de caractères correspondante ici.
class ApiEndpoints {
  ApiEndpoints._(); // Empêche l'instanciation

  // ===========================================================================
  // 🔐 AUTHENTIFICATION
  // ===========================================================================

  /// Endpoint de connexion.
  /// Méthode: POST
  /// Paramètres attendus (body): matricule, agence, password
  static const String login = '/auth/login';

  /// Endpoint pour se déconnecter (invalidation du token côté serveur).
  /// Méthode: POST
  static const String logout = '/auth/logout';

  /// Endpoint pour récupérer le profil de l'utilisateur connecté.
  /// Méthode: GET
  static const String me = '/auth/me';

  // ===========================================================================
  // 📦 DASHBOARD STRATEGIE
  // ===========================================================================

  /// Endpoint pour récupérer les KPI du dashboard (livraisons réussies, etc.)
  /// Méthode: GET
  static const String dashboardStats = '/dashboard/stats';

  // ===========================================================================
  // 🚚 TOURNÉES & LIVRAISONS
  // ===========================================================================

  /// Endpoint pour récupérer la liste des tournées/livraisons assignées.
  /// Méthode: GET
  static const String tours = '/tours';

  /// Endpoint pour mettre à jour le statut d'une livraison spécifique.
  /// Méthode: PATCH
  /// Paramètres dynamiques: [id] de la livraison.
  static String updateDeliveryStatus(String id) => '/deliveries/$id/status';
}
