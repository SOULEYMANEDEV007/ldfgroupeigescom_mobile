import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';

/// Gestionnaire du Token JWT et de la session utilisateur locale.
///
/// 🛠️ **DÉVELOPPEUR FUTUR** :
/// Cette classe est utilisée pour stocker (SharedPreferences) le Token
/// après un succès d'API sur `/auth/login`. L'intercepteur lira le token ici.
@lazySingleton
class TokenManager {
  static const String _tokenKey = 'LDF_ACCESS_TOKEN';
  static const String _userNameKey = 'LDF_USER_NAME';

  final SharedPreferences _prefs;

  TokenManager(this._prefs);

  /// 💾 Sauvegarde les identifiants de session après le login
  Future<void> saveSession(String token, String userName) async {
    await _prefs.setString(_tokenKey, token);
    await _prefs.setString(_userNameKey, userName);
  }

  /// 🗝️ Récupère le Token JWT (retourne null si non connecté)
  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  /// 👤 Récupère le nom de l'utilisateur connecté
  String? getUserName() {
    return _prefs.getString(_userNameKey);
  }

  /// 🧹 Efface la session (Déconnexion)
  Future<void> clearSession() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userNameKey);
  }

  /// 🧐 Vérifie si l'utilisateur possède un token valide
  bool get isAuthenticated => getToken() != null && getToken()!.isNotEmpty;
}
