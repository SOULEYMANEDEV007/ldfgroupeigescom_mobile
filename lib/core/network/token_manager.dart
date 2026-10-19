import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';

import '../config/app_config.dart';

/// Gestionnaire du Token JWT et de la session utilisateur locale.
///
/// Stocke (SharedPreferences) les jetons et l'identité renvoyés par l'API de
/// login. [AuthInterceptor] lit le token ici ; en cas de 401, il appelle
/// [expireSession] pour forcer le retour à l'écran de connexion.
@lazySingleton
class TokenManager {
  static const String _tokenKey = 'LDF_ACCESS_TOKEN';
  static const String _refreshKey = 'LDF_REFRESH_TOKEN';
  static const String _userNameKey = 'LDF_USER_NAME';
  static const String _fullNameKey = 'LDF_FULL_NAME';
  static const String _userRoleKey = 'LDF_USER_ROLE';
  static const String _codeAgentKey = 'LDF_CODE_AGENT';
  static const String _agencyKey = 'LDF_AGENCY_CODE';
  static const String _userProfileDataKey = 'LDF_USER_PROFILE_DATA';

  final SharedPreferences _prefs;
  final StreamController<void> _sessionExpired =
      StreamController<void>.broadcast();

  TokenManager(this._prefs);

  /// 💾 Sauvegarde les données de profil enrichies
  Future<void> saveProfileData(Map<String, dynamic> data) async {
    await _prefs.setString(_userProfileDataKey, jsonEncode(data));
  }

  /// 📂 Récupère les données de profil sauvegardées
  Map<String, dynamic>? getProfileData() {
    final raw = _prefs.getString(_userProfileDataKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Émet un évènement quand la session est invalidée par le serveur (401).
  Stream<void> get onSessionExpired => _sessionExpired.stream;

  /// 💾 Sauvegarde les identifiants de session après le login
  Future<void> saveSession(
    String token,
    String userName, {
    String? refreshToken,
    String? codeAgent,
    String? agencyCode,
    String? fullName,
    String? role,
  }) async {
    await _prefs.setString(_tokenKey, token);
    await _prefs.setString(_userNameKey, userName);
    if (refreshToken != null) await _prefs.setString(_refreshKey, refreshToken);
    if (codeAgent != null) await _prefs.setString(_codeAgentKey, codeAgent);
    if (agencyCode != null) await _prefs.setString(_agencyKey, agencyCode);
    if (fullName != null) await _prefs.setString(_fullNameKey, fullName);
    if (role != null) await _prefs.setString(_userRoleKey, role);
  }

  /// 🔄 Met à jour les tokens suite à un rafraîchissement
  Future<void> updateTokens(String accessToken, {String? refreshToken}) async {
    await _prefs.setString(_tokenKey, accessToken);
    if (refreshToken != null) await _prefs.setString(_refreshKey, refreshToken);
  }

  /// 🗝️ Récupère le Token JWT (retourne null si non connecté)
  String? getToken() => _prefs.getString(_tokenKey);

  /// 🔁 Récupère le refresh token
  String? getRefreshToken() => _prefs.getString(_refreshKey);

  /// 👤 Récupère le nom d'utilisateur (login)
  String? getUserName() => _prefs.getString(_userNameKey);

  /// 👤 Récupère le nom complet de l'agent (ex: "CONVOYEUR TEST")
  String? getFullName() => _prefs.getString(_fullNameKey);

  /// 💼 Récupère le rôle ou intitulé fonctionnel
  String? getUserRole() => _prefs.getString(_userRoleKey);

  /// 🆔 Code agent (clé des endpoints `convotournees/{code_agent}`)
  String? getCodeAgent() => _prefs.getString(_codeAgentKey);

  /// 🏢 Code de l'agence de l'utilisateur
  String? getAgencyCode() => _prefs.getString(_agencyKey);

  /// 💾 Sauvegarde le nom complet
  Future<void> setFullName(String fullName) => _prefs.setString(_fullNameKey, fullName);

  /// 💾 Sauvegarde le rôle
  Future<void> setUserRole(String role) => _prefs.setString(_userRoleKey, role);

  /// 🧹 Efface la session (Déconnexion)
  Future<void> clearSession() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_refreshKey);
    await _prefs.remove(_userNameKey);
    await _prefs.remove(_fullNameKey);
    await _prefs.remove(_userRoleKey);
    await _prefs.remove(_codeAgentKey);
    await _prefs.remove(_agencyKey);
    await _prefs.remove(_userProfileDataKey);
  }

  /// ⏰ Invalide la session suite à un 401 et notifie l'application.
  Future<void> expireSession() async {
    await clearSession();
    if (!_sessionExpired.isClosed) _sessionExpired.add(null);
  }

  /// ⌛ Date d'expiration du token d'accès (claim `exp`), null si illisible
  /// (ex: faux JWT du mode mock).
  DateTime? get accessTokenExpiry {
    final token = getToken();
    if (token == null) return null;
    final parts = token.split('.');
    if (parts.length != 3) return null;
    try {
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final exp = (jsonDecode(payload) as Map<String, dynamic>)['exp'];
      if (exp is! num) return null;
      return DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000);
    } catch (_) {
      return null;
    }
  }

  /// `true` si le token d'accès est expiré (un token illisible est considéré valide).
  bool get isAccessTokenExpired {
    final expiry = accessTokenExpiry;
    return expiry != null && DateTime.now().isAfter(expiry);
  }

  /// 🧐 Vérifie si l'utilisateur possède un token présent et non expiré
  bool get isAuthenticated {
    final token = getToken();
    return token != null && token.isNotEmpty && !isAccessTokenExpired;
  }

  /// 📜 Décode les claims du JWT actuellement stocké
  Map<String, dynamic>? get jwtClaims {
    final token = getToken();
    if (token == null) return null;
    final parts = token.split('.');
    if (parts.length != 3) return null;
    try {
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final decoded = jsonDecode(payload);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  /// 🏢 `true` si le token possède le claim 'tenant' requis pour valider les tournées
  bool get hasTenantClaim {
    if (AppConfig.useMockApi) return true;
    final claims = jwtClaims;
    if (claims == null) return false;
    final tenant = claims['tenant']?.toString();
    return tenant != null && tenant.isNotEmpty;
  }
}
