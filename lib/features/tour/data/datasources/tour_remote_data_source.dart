import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/di/app_environments.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/token_manager.dart';
import '../../../delivery/data/models/delivery_model.dart';
import '../../../delivery/domain/entities/delivery.dart';
import '../../domain/entities/tour_entity.dart';
import '../models/tour_model.dart';

import '../../../../core/di/injection.dart';
import 'tour_local_data_source.dart';

abstract class TourRemoteDataSource {
  Future<List<TourEntity>> getTours();
}

/// Implémentation réelle consommant l'API IGESCOM
/// `GET /api/flotte/convotournees/{code_agent}`
@LazySingleton(as: TourRemoteDataSource, env: [kRealEnv])
class RealTourRemoteDataSourceImpl implements TourRemoteDataSource {
  final Dio _dio;
  final TokenManager _tokenManager;
  final TourLocalDataSource? _localDataSourceOverride;

  RealTourRemoteDataSourceImpl(
    this._dio,
    this._tokenManager, {
    TourLocalDataSource? localDataSource,
  }) : _localDataSourceOverride = localDataSource;

  TourLocalDataSource get _localDataSource =>
      _localDataSourceOverride ?? getIt<TourLocalDataSource>();

  /// Tente d'envoyer toutes les validations enregistrées hors-ligne au backend
  Future<void> syncPendingDeliveries() async {
    final pending = _localDataSource.getPendingDeliveries();
    if (pending.isEmpty) return;

    for (final item in List<Map<String, dynamic>>.from(pending)) {
      final codeLigne = item['code_ligne']?.toString();
      final tournee = item['tournee']?.toString() ?? '';
      final notes = item['notes']?.toString() ?? '';

      if (codeLigne == null || codeLigne.isEmpty) continue;

      try {
        await _dio.post(
          ApiEndpoints.validateDelivery(codeLigne),
          data: {
            'observation_livraison': notes,
            'tournee': tournee,
          },
          options: Options(
            extra: {'noSessionExpire': true},
          ),
        );
        // ✅ Synchronisation réussie : on retire de la file d'attente
        await _localDataSource.removePendingDelivery(codeLigne);
      } on DioException catch (e) {
        if (e.response != null && e.response!.statusCode != null) {
          final code = e.response!.statusCode!;
          // Si le backend répond 400 ou 404 (déjà validée ou commande clôturée),
          // on libère l'élément de la file pour ne pas bloquer les suivants
          if (code >= 400 && code < 500) {
            await _localDataSource.removePendingDelivery(codeLigne);
          }
        } else {
          // Erreur réseau (reconnexion interrompue) : interruption de la tentative
          break;
        }
      } catch (_) {
        // En cas d'erreur inattendue sur cet élément, continuer avec les autres
      }
    }
  }

  @override
  Future<List<TourEntity>> getTours() async {
    final codeAgent = _tokenManager.getCodeAgent() ?? '9991317331';

    try {
      // 🔄 1. Si des livraisons ont été validées hors-ligne, on tente de les synchroniser
      if (_localDataSource.pendingDeliveriesCount > 0) {
        try {
          await syncPendingDeliveries();
        } catch (_) {}
      }

      final response = await _dio.get(ApiEndpoints.tours(codeAgent));

      if (response.data is Map<String, dynamic>) {
        final rows = response.data['rows'] as List<dynamic>? ?? [];

        // 💾 Sauvegarde automatique dans le cache local
        if (rows.isNotEmpty) {
          try {
            // S'il reste des livraisons en file d'attente non synchronisées,
            // on conserve leur statut local 'LIVREE' pour éviter tout clignotement
            final pendingLignes = _localDataSource
                .getPendingDeliveries()
                .map((e) => e['code_ligne']?.toString())
                .whereType<String>()
                .toSet();

            if (pendingLignes.isNotEmpty) {
              for (final tour in rows) {
                if (tour is! Map) continue;
                final lignes = tour['lignes'] ?? tour['deliveries'];
                if (lignes is! List) continue;
                for (final ligne in lignes) {
                  if (ligne is! Map) continue;
                  final ligneId = ligne['code_ligne']?.toString() ??
                      ligne['code_bl']?.toString();
                  if (pendingLignes.contains(ligneId)) {
                    ligne['statut_livraison'] = 'LIVREE';
                    ligne['date_livraison'] =
                        DateTime.now().toIso8601String();
                  }
                }
              }
            }

            await _localDataSource.cacheTours(rows);
          } catch (_) {
            // Échec silencieux du cache pour ne pas bloquer l'affichage en ligne
          }
        }

        if (rows.isNotEmpty) {
          final first = rows.first;
          if (first is Map<String, dynamic>) {
            final convoyeur = first['convoyeur_info'];
            if (convoyeur is Map<String, dynamic> &&
                convoyeur['nom_complet'] != null) {
              final nom = convoyeur['nom_complet'].toString().trim();
              if (nom.isNotEmpty) {
                await _tokenManager.setFullName(nom);
              }
            }
          }
        }

        return rows
            .map((r) => TourModel.fromJson(r as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      // 🔄 Mode Hors-Ligne : En cas de coupure réseau ou erreur de connexion,
      // bascule automatique et transparente sur les tournées en cache local
      final cachedRows = _localDataSource.getCachedTours();
      if (cachedRows != null && cachedRows.isNotEmpty) {
        return cachedRows
            .map((r) => TourModel.fromJson(r as Map<String, dynamic>))
            .toList();
      }

      // Si aucun cache n'existe encore et que le réseau est indisponible,
      // on propage l'erreur pour qu'elle soit traduite en français clair par le Repository
      rethrow;
    }
  }
}

/// Implémentation Mock réservée aux démonstrations hors-ligne (`USE_MOCK_API=true`)
@LazySingleton(as: TourRemoteDataSource, env: [kMockEnv])
class MockTourRemoteDataSourceImpl implements TourRemoteDataSource {
  @override
  Future<List<TourEntity>> getTours() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final now = DateTime.now();

    return [
      TourEntity(
        id: 'TRN-1790866899713',
        reference: 'TRN-1790866899713',
        libelle: 'TEST MOB 1',
        date: now,
        heureDepart: '09:00',
        agence: 'DEPOT GRANDS COMPTES',
        chauffeurName: 'ABIRATOU KOROTOUM CISSE',
        livreurName: 'CONVOYEUR TEST',
        vehiclePlate: 'VEH001',
        status: TourStatus.inProgress,
        deliveries: [
          DeliveryModel(
            id: '70911',
            tourId: 'TRN-1790866899713',
            clientCode: 'CIETIA',
            clientName: 'CIE',
            deliveryNoteNumber: 'BL-66484211',
            weight: 0.0,
            amount: 15.0,
            address: 'Abidjan',
            phone: '',
            status: DeliveryStatus.delivered,
            scheduledTime: now,
            notes: '',
          ),
          DeliveryModel(
            id: '71011',
            tourId: 'TRN-1790866899713',
            clientCode: 'SIRTEST',
            clientName: 'SOCIETE IVOIRIENNE DE TEST',
            deliveryNoteNumber: 'BL-66480311',
            weight: 0.0,
            amount: 249.98,
            address: 'ABIDJAN',
            phone: '01020304',
            status: DeliveryStatus.pending,
            scheduledTime: now,
            notes: '',
          ),
        ],
      ),
    ];
  }
}
