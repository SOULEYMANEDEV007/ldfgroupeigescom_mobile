import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Contrat de persistance locale des tournées pour le mode hors-ligne
abstract class TourLocalDataSource {
  /// Sauvegarde les lignes brutes de l'API dans le cache local
  Future<void> cacheTours(List<dynamic> rows);

  /// Récupère les données des tournées mises en cache
  List<dynamic>? getCachedTours();

  /// Date et heure de la dernière synchronisation réussie
  DateTime? getLastSyncTime();

  /// Indique si des données de tournée sont disponibles en cache
  bool get hasCachedTours;

  /// Efface le cache local
  Future<void> clearCache();

  // ── File d'attente de synchronisation hors-ligne (Queue) ──
  /// Ajoute une validation de livraison à synchroniser ultérieurement
  Future<void> enqueuePendingDelivery({
    required String codeLigne,
    required String tourId,
    String? notes,
  });

  /// Récupère la liste des validations en attente de synchronisation
  List<Map<String, dynamic>> getPendingDeliveries();

  /// Supprime une validation de la file d'attente (après synchronisation réussie)
  Future<void> removePendingDelivery(String codeLigne);

  /// Vérifie si une livraison est en attente de synchronisation avec le serveur
  bool isPendingSync(String codeLigne);

  /// Nombre de livraisons en attente de synchronisation
  int get pendingDeliveriesCount;

  // ── Mise à jour optimiste du cache local des tournées ──
  /// Met à jour le statut d'une livraison directement dans le cache JSON
  Future<void> updateCachedDeliveryStatus({
    required String codeLigne,
    required String status,
    String? notes,
    String? eventDate,
    String? signedBy,
    String? signatureData,
  });
}

/// Implémentation basée sur SharedPreferences (légère, sans dépendance native risquée)
class TourLocalDataSourceImpl implements TourLocalDataSource {
  static const String _cachedToursKey = 'LDF_CACHED_TOURS_ROWS';
  static const String _lastSyncTimeKey = 'LDF_TOURS_LAST_SYNC_TIME';
  static const String _pendingDeliveryQueueKey =
      'LDF_PENDING_DELIVERY_SYNC_QUEUE';

  final SharedPreferences _prefs;

  TourLocalDataSourceImpl(this._prefs);

  @override
  Future<void> cacheTours(List<dynamic> rows) async {
    final jsonStr = jsonEncode(rows);
    await _prefs.setString(_cachedToursKey, jsonStr);
    await _prefs.setString(_lastSyncTimeKey, DateTime.now().toIso8601String());
  }

  @override
  List<dynamic>? getCachedTours() {
    final raw = _prefs.getString(_cachedToursKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) return decoded;
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  DateTime? getLastSyncTime() {
    final raw = _prefs.getString(_lastSyncTimeKey);
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  @override
  bool get hasCachedTours {
    final raw = _prefs.getString(_cachedToursKey);
    return raw != null && raw.isNotEmpty;
  }

  @override
  Future<void> clearCache() async {
    await _prefs.remove(_cachedToursKey);
    await _prefs.remove(_lastSyncTimeKey);
  }

  @override
  Future<void> enqueuePendingDelivery({
    required String codeLigne,
    required String tourId,
    String? notes,
  }) async {
    final list = getPendingDeliveries();
    list.removeWhere((item) => item['code_ligne']?.toString() == codeLigne);
    list.add({
      'code_ligne': codeLigne,
      'tournee': tourId,
      'notes': notes ?? '',
      'timestamp': DateTime.now().toIso8601String(),
    });
    await _prefs.setString(_pendingDeliveryQueueKey, jsonEncode(list));
  }

  @override
  List<Map<String, dynamic>> getPendingDeliveries() {
    final raw = _prefs.getString(_pendingDeliveryQueueKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> removePendingDelivery(String codeLigne) async {
    final list = getPendingDeliveries();
    final initialCount = list.length;
    list.removeWhere((item) => item['code_ligne']?.toString() == codeLigne);
    if (list.length != initialCount) {
      await _prefs.setString(_pendingDeliveryQueueKey, jsonEncode(list));
    }
  }

  @override
  bool isPendingSync(String codeLigne) {
    final list = getPendingDeliveries();
    return list.any((item) => item['code_ligne']?.toString() == codeLigne);
  }

  @override
  int get pendingDeliveriesCount => getPendingDeliveries().length;

  @override
  Future<void> updateCachedDeliveryStatus({
    required String codeLigne,
    required String status,
    String? notes,
    String? eventDate,
    String? signedBy,
    String? signatureData,
  }) async {
    final raw = _prefs.getString(_cachedToursKey);
    if (raw == null || raw.isEmpty) return;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return;

      bool modified = false;
      final nowStr = eventDate ?? DateTime.now().toIso8601String();

      for (final tour in decoded) {
        if (tour is! Map) continue;
        final lignes = tour['lignes'] ?? tour['deliveries'];
        if (lignes is! List) continue;

        for (final ligne in lignes) {
          if (ligne is! Map) continue;
          final ligneId = ligne['code_ligne']?.toString() ??
              ligne['code_bl']?.toString() ??
              ligne['id']?.toString();
          if (ligneId == codeLigne) {
            ligne['statut_livraison'] = status;
            if (status == 'REPORTEE' || status == 'ECHEC') {
              ligne['date_report'] = nowStr;
              ligne['date_livraison'] = null;
            } else if (status == 'LIVREE') {
              ligne['date_livraison'] = nowStr;
            }
            if (notes != null && notes.isNotEmpty) {
              ligne['observation_livraison'] = notes;
            }
            if (signedBy != null && signedBy.isNotEmpty) {
              ligne['signed_by'] = signedBy;
            }
            if (signatureData != null && signatureData.isNotEmpty) {
              ligne['signature_data'] = signatureData;
            }
            modified = true;
          }
        }
      }

      if (modified) {
        await _prefs.setString(_cachedToursKey, jsonEncode(decoded));
      }
    } catch (_) {
      // Échec silencieux
    }
  }
}
