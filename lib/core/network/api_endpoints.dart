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

  /// Connexion ERP avec instance/tenant (indispensable pour les opérations de flotte/validation).
  /// Méthode: POST
  /// Body: `{ "nom_util": String, "mdpasse": String, "code_agce": String }`
  static const String erpLogin = '/api/login/';

  // ===========================================================================
  // 🚚 TOURNÉES & LIVRAISONS
  // ===========================================================================

  /// Liste des tournées du convoyeur (lignes de livraison incluses).
  /// Méthode: GET — [codeAgent] provient de la réponse du login.
  /// ⚠️ Pas de slash final.
  static String tours(String codeAgent) =>
      '/api/flotte/convotournees/$codeAgent';

  /// Détail d'une tournée (même structure qu'un élément de [tours]).
  /// Méthode: GET — réponse dans `data`.
  static String tourDetail(String codeTournee) =>
      '/api/flotte/tournees/$codeTournee/';

  /// Planning d'une tournée (contient les vrais articles du BL `lignes_bl`).
  /// Méthode: GET — `/api/flotte/tournees/{code_tournee}/planning/`
  /// ou avec code agent `/api/flotte/tournees/{code_tournee}/planning/{code_agent}/`.
  static String tourPlanning(String codeTournee, [String? codeAgent]) =>
      (codeAgent != null && codeAgent.isNotEmpty)
          ? '/api/flotte/tournees/$codeTournee/planning/$codeAgent/'
          : '/api/flotte/tournees/$codeTournee/planning/';

  /// Validation d'une livraison (ligne de tournée).
  /// Méthode: POST
  /// Body: `{ "observation_livraison": String, "tournee": String }`
  /// URL officielle backend : `/api/flotte/tournees/lignes/{code_ligne}/valider-livraison/`
  static String validateDelivery(String codeLigne) =>
      '/api/flotte/tournees/lignes/$codeLigne/valider-livraison/';

  // Reprogrammation d'une livraision (BL)
  static String reportDelivery(String codeTournee, String codeLigne) =>
      '/api/flotte/tournees/lignes/$codeLigne/reporter-livraison/';

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
