import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/di/app_environments.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_error_handler.dart';
import '../../../tour/data/datasources/tour_local_data_source.dart';
import '../../domain/entities/delivery.dart';
import '../models/delivery_model.dart';

abstract class DeliveryRemoteDataSource {
  Future<DeliveryModel> getDeliveryById(String id);
  Future<DeliveryModel> updateStatus(
    String id,
    DeliveryStatus status, {
    String? tourId,
    String? codeBl,
    String? notes,
    String? signedBy,
    String? signatureData,
  });
}

/// Implémentation réelle branchée sur l'API IGESCOM
@LazySingleton(as: DeliveryRemoteDataSource, env: [kRealEnv])
class RealDeliveryRemoteDataSourceImpl implements DeliveryRemoteDataSource {
  final Dio _dio;
  final TourLocalDataSource? _localDataSourceOverride;

  RealDeliveryRemoteDataSourceImpl(
    this._dio, {
    TourLocalDataSource? localDataSource,
  }) : _localDataSourceOverride = localDataSource;

  TourLocalDataSource get _localDataSource =>
      _localDataSourceOverride ?? getIt<TourLocalDataSource>();

  @override
  Future<DeliveryModel> getDeliveryById(String id) async {
    return _getRealDelivery(id);
  }

  /// Récupère la vraie livraison telle que renvoyée par l'API backend et enregistrée dans le cache
  DeliveryModel _getRealDelivery(
    String id, {
    DeliveryStatus? status,
    String? tourId,
    String? notes,
    String? signedBy,
    String? signatureData,
  }) {
    final cleanId = id.trim();
    final cachedRows = _localDataSource.getCachedTours();
    if (cachedRows != null) {
      for (final tour in cachedRows) {
        if (tour is! Map) continue;
        final currentTourId = tour['code_tournee']?.toString() ?? tourId ?? '';
        final lignes = tour['lignes'] ?? tour['deliveries'];
        if (lignes is! List) continue;

        for (final item in lignes) {
          if (item is! Map) continue;
          final map = Map<String, dynamic>.from(item);
          final ligneId =
              map['code_ligne']?.toString() ?? map['code_bl']?.toString();

          if (ligneId == cleanId || map['code_bl']?.toString() == cleanId) {
            if (!map.containsKey('code_tournee') ||
                map['code_tournee'] == null) {
              map['code_tournee'] = currentTourId;
            }
            if (status != null) {
              if (status == DeliveryStatus.delivered) {
                map['statut_livraison'] = 'LIVREE';
                map['date_livraison'] = DateTime.now().toIso8601String();
              } else if (status == DeliveryStatus.cancelled) {
                map['statut_livraison'] = 'REPORTEE';
                map['date_report'] = DateTime.now().toIso8601String();
                map['date_livraison'] = null;
              }
            }
            if (notes != null && notes.isNotEmpty) {
              map['observation_livraison'] = notes;
            }
            if (signedBy != null && signedBy.isNotEmpty) {
              map['signed_by'] = signedBy;
            }
            if (signatureData != null && signatureData.isNotEmpty) {
              map['signature_data'] = signatureData;
            }
            // 🛡️ Récupération depuis le store persistant de signatures si absent
            if (map['signed_by'] == null || map['signature_data'] == null) {
              final sigs = _localDataSource.getAllSavedSignatures();
              final saved = sigs[ligneId] ?? sigs[map['code_bl']?.toString()];
              if (saved != null) {
                if (saved['signed_by']?.isNotEmpty ?? false) {
                  map['signed_by'] ??= saved['signed_by'];
                }
                if (saved['signature_data']?.isNotEmpty ?? false) {
                  map['signature_data'] ??= saved['signature_data'];
                }
              }
            }
            return DeliveryModel.fromJson(map);
          }
        }
      }
    }

    final savedSig = _localDataSource.getAllSavedSignatures()[cleanId];
    return DeliveryModel(
      id: id,
      tourId: tourId ?? '',
      clientCode: '',
      clientName: 'Client',
      deliveryNoteNumber: id.startsWith('BL-') ? id : 'BL-$id',
      weight: 0.0,
      amount: 0.0,
      address: 'Abidjan',
      phone: '',
      status: status ?? DeliveryStatus.inProgress,
      scheduledTime: DateTime.now(),
      notes: notes ?? '',
      signedBy: signedBy ?? savedSig?['signed_by'],
      signatureData: signatureData ?? savedSig?['signature_data'],
    );
  }

  @override
  Future<DeliveryModel> updateStatus(
    String id,
    DeliveryStatus status, {
    String? tourId,
    String? codeBl,
    String? notes,
    String? signedBy,
    String? signatureData,
  }) async {
    // Si validation de livraison, envoi ou mise en file d'attente locale
    if (status == DeliveryStatus.delivered) {
      final cleanLigneId = id.trim();
      final cleanTournee =
          (tourId != null && tourId.isNotEmpty && tourId != 'N/A')
          ? tourId
          : '';
      if (cleanLigneId.isEmpty || cleanLigneId == 'N/A') {
        throw const ApiException(
          'Ligne de livraison introuvable : impossible de valider cette livraison.',
        );
      }

      try {
        final response = await _dio.post(
          ApiEndpoints.validateDelivery(cleanLigneId),
          data: {
            'observation_livraison': notes ?? '',
            'tournee': cleanTournee,
            if (signedBy != null && signedBy.isNotEmpty) 'signed_by': signedBy,
          },
          options: Options(extra: {'noSessionExpire': true}),
        );

        final serverDate = (response.data is Map &&
                response.data['data'] is Map &&
                response.data['data']['date_livraison'] != null)
            ? response.data['data']['date_livraison'].toString()
            : null;

        // ✅ Succès en ligne : retrait de la file d'attente et mise à jour locale
        await _localDataSource.removePendingDelivery(cleanLigneId);
        await _localDataSource.updateCachedDeliveryStatus(
          codeLigne: cleanLigneId,
          status: 'LIVREE',
          notes: notes,
          eventDate: serverDate,
          signedBy: signedBy,
          signatureData: signatureData,
        );
      } on DioException catch (e) {
        if (_isNetworkOfflineError(e)) {
          // 📦 Mode Hors-Ligne : Mise en file d'attente et mise à jour optimiste du cache local
          await _localDataSource.enqueuePendingDelivery(
            codeLigne: cleanLigneId,
            tourId: cleanTournee,
            notes: notes,
          );
          await _localDataSource.updateCachedDeliveryStatus(
            codeLigne: cleanLigneId,
            status: 'LIVREE',
            notes: notes,
            signedBy: signedBy,
            signatureData: signatureData,
          );
        } else {
          // Vraie erreur applicative serveur (401, 403, 500...), on propage
          rethrow;
        }
      } catch (e) {
        // En cas d'erreur de socket ou d'exception réseau non-Dio
        await _localDataSource.enqueuePendingDelivery(
          codeLigne: cleanLigneId,
          tourId: cleanTournee,
          notes: notes,
        );
        await _localDataSource.updateCachedDeliveryStatus(
          codeLigne: cleanLigneId,
          status: 'LIVREE',
          notes: notes,
          signedBy: signedBy,
          signatureData: signatureData,
        );
      }
    }

    // ⚠️ Si report / reprogrammation de livraison
    if (status == DeliveryStatus.cancelled) {
      final cleanLigneId = id.trim();
      final cleanTournee =
          (tourId != null && tourId.isNotEmpty && tourId != 'N/A')
          ? tourId
          : '';
      final cleanBl = (codeBl != null && codeBl.isNotEmpty)
          ? codeBl
          : cleanLigneId.replaceFirst('BL-', '').trim();

      if (cleanTournee.isEmpty) {
        throw const ApiException(
          'Code tournée introuvable : impossible de reporter cette livraison.',
        );
      }
      if (cleanBl.isEmpty) {
        throw const ApiException(
          'Numéro de BL introuvable : impossible de reporter cette livraison.',
        );
      }

      try {
        final response = await _dio.post(
          ApiEndpoints.reportDelivery(
            cleanTournee,
            cleanLigneId,
          ), // 👈 cleanLigneId au lieu de cleanBl
          data: {
            'tournee':
                cleanTournee, // 👈 'tournee' comme pour valider-livraison
            'code_tournee': cleanTournee, // Par sécurité
            'motif_report': notes ?? '',
          },
          options: Options(extra: {'noSessionExpire': true}),
        );

        final serverReportDate = (response.data is Map &&
                response.data['data'] is Map &&
                response.data['data']['date_report'] != null)
            ? response.data['data']['date_report'].toString()
            : null;

        // ✅ Succès en ligne : mise à jour du statut dans le cache local
        await _localDataSource.updateCachedDeliveryStatus(
          codeLigne: cleanLigneId,
          status: 'REPORTEE',
          notes: notes,
          eventDate: serverReportDate,
        );
      } on DioException catch (e) {
        if (_isNetworkOfflineError(e)) {
          // 📦 Mode Hors-Ligne : mise à jour optimiste du cache local
          await _localDataSource.updateCachedDeliveryStatus(
            codeLigne: cleanLigneId,
            status: 'REPORTEE',
            notes: notes,
          );
        } else {
          rethrow;
        }
      } catch (e) {
        await _localDataSource.updateCachedDeliveryStatus(
          codeLigne: cleanLigneId,
          status: 'REPORTEE',
          notes: notes,
        );
      }
    }

    return _getRealDelivery(
      id,
      status: status,
      tourId: tourId,
      notes: notes,
      signedBy: signedBy,
      signatureData: signatureData,
    );
  }

  bool _isNetworkOfflineError(DioException e) {
    if (e.response != null) {
      // Le serveur a répondu (code HTTP émis) -> ce n'est pas une panne réseau
      return false;
    }
    // Pas de réponse HTTP du serveur -> connexion impossible, réseau coupé, timeout
    return true;
  }
}

/// Implémentation Mock réservée aux démonstrations hors-ligne (`USE_MOCK_API=true`)
@LazySingleton(as: DeliveryRemoteDataSource, env: [kMockEnv])
class MockDeliveryRemoteDataSourceImpl implements DeliveryRemoteDataSource {
  final Map<String, DeliveryModel> _cache = {};

  @override
  Future<DeliveryModel> getDeliveryById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final delivery = _cache[id];
    if (delivery == null) {
      return DeliveryModel(
        id: id,
        tourId: 'TRN-1790866899713',
        clientCode: 'CIETIA',
        clientName: 'CIE',
        deliveryNoteNumber: 'BL-$id',
        weight: 0.0,
        amount: 15.0,
        address: 'Abidjan',
        phone: '',
        status: DeliveryStatus.inProgress,
        scheduledTime: DateTime.now(),
        notes: '',
      );
    }
    return delivery;
  }

  @override
  Future<DeliveryModel> updateStatus(
    String id,
    DeliveryStatus status, {
    String? tourId,
    String? codeBl,
    String? notes,
    String? signedBy,
    String? signatureData,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final updated = DeliveryModel(
      id: id,
      tourId: tourId ?? 'TRN-1790866899713',
      clientCode: 'CIETIA',
      clientName: 'CIE',
      deliveryNoteNumber: 'BL-$id',
      weight: 0.0,
      amount: 15.0,
      address: 'Abidjan',
      phone: '',
      status: status,
      scheduledTime: DateTime.now(),
      notes: notes ?? '',
      signedBy: signedBy,
      signatureData: signatureData,
    );
    _cache[id] = updated;
    return updated;
  }
}
