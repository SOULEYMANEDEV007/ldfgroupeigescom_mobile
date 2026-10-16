/// Regroupe tous les endpoints de l'API IGESCOM utilisés par l'application.
///
/// L'URL de base (`AppConfig.apiBaseUrl`, ex: `http://192.168.1.238`) est définie
/// dans le fichier `.env`. Les chemins ci-dessous incluent le préfixe `/api`.
///
/// ⚠️ Respecter les slashs finaux : le backend (Django) les attend tels quels.
class ApiEndpoints {
  ApiEndpoints._(); // Empêche l'instanciation

  // ===========================================================================
  // 🔐 AUTHENTIFICATION
  // ===========================================================================

  /// Connexion du livreur/convoyeur.
  /// Méthode: POST
  /// Body: `{ "nom_util": String, "mdpasse": String }`
  /// Réponse: `{ status, data: { agent{code_agent, nom_util, code_agce, code_fonct}, token, refresh } }`
  static const String login = '/api/metabase/mobile/livraison/login/';

  // ===========================================================================
  // 🚚 TOURNÉES & LIVRAISONS
  // ===========================================================================

  /// Liste des tournées du convoyeur (lignes de livraison incluses).
  /// Méthode: GET — [codeAgent] provient de la réponse du login.
  /// ⚠️ Pas de slash final.
  static String tours(String codeAgent) => '/api/flotte/convotournees/$codeAgent';

  /// Détail d'une tournée (même structure qu'un élément de [tours]).
  /// Méthode: GET — réponse dans `data`.
  static String tourDetail(String codeTournee) =>
      '/api/flotte/tournees/$codeTournee/';

  /// Planning d'une tournée.
  /// ⚠️ Retourne actuellement HTTP 401 même avec un token valide : non utilisé
  /// tant que le backend n'est pas corrigé (voir [tourDetail]).
  static String tourPlanning(String codeTournee, String codeAgent) =>
      '/api/flotte/tournees/$codeTournee/planning/$codeAgent/';

  /// Validation d'une livraison (ligne de tournée).
  /// Méthode: POST
  /// Body: `{ "observation_livraison": String, "tournee": code_tournee }`
  /// ⚠️ L'URL officielle backend est `/api/flotte/tournees/lignes/{code_bl}/valider-livraison/`.
  static String validateDelivery(String codeBl) =>
      '/api/flotte/tournees/lignes/$codeBl/valider-livraison/';

  /// Fallback alternatif avec code tournée dans l'URL si applicable.
  static String validateDeliveryWithTour(String codeTournee, String codeBl) =>
      '/api/flotte/tournees/$codeTournee/lignes/$codeBl/valider-livraison/';

  // ===========================================================================
  // 👤 PROFIL & COMPTE AGENT
  // ===========================================================================

  /// Rafraîchissement du Token JWT.
  /// Méthode: POST — Body: `{ "refresh": String }`
  /// Réponse: `{ "access": String, "refresh": String }`
  static const String refreshToken = '/api/login/token/refresh/';

  /// Détails du profil d'un agent.
  /// Méthode: GET — ⚠️ avec slash final.
  static String agentProfile(String codeAgent) =>
      '/api/profil/agents/$codeAgent/';

  /// Mise à jour des informations de profil de l'agent.
  /// Méthode: POST — ⚠️ avec slash final.
  static String updateAgentProfile(String codeAgent) =>
      '/api/profil/modificationagents/$codeAgent/';

  /// Modification du mot de passe de l'agent.
  /// Méthode: POST — ⚠️ avec slash final.
  /// Body: `{ "old": String, "new_mdp": String }`
  static String changePassword(String codeAgent) =>
      '/api/profil/ModificationAgentMDP/$codeAgent/';
}
