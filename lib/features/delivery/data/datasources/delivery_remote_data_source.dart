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
    String? notes,
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
    return DeliveryModel(
      id: id,
      tourId: '',
      clientCode: '',
      clientName: 'Client',
      deliveryNoteNumber: id.startsWith('BL-') ? id : 'BL-$id',
      weight: 0.0,
      amount: 0.0,
      address: 'Abidjan',
      phone: '',
      status: DeliveryStatus.inProgress,
      scheduledTime: DateTime.now(),
      notes: '',
    );
  }

  @override
  Future<DeliveryModel> updateStatus(
    String id,
    DeliveryStatus status, {
    String? tourId,
    String? notes,
  }) async {
    // Si validation de livraison, envoi ou mise en file d'attente locale
    if (status == DeliveryStatus.delivered) {
      final cleanLigneId = id.trim();
      final cleanTournee =
          (tourId != null && tourId.isNotEmpty && tourId != 'N/A') ? tourId : '';
      if (cleanLigneId.isEmpty || cleanLigneId == 'N/A') {
        throw const ApiException(
          'Ligne de livraison introuvable : impossible de valider cette livraison.',
        );
      }

      try {
        await _dio.post(
          ApiEndpoints.validateDelivery(cleanLigneId),
          data: {
            'observation_livraison': notes ?? '',
            'tournee': cleanTournee,
          },
          options: Options(
            extra: {'noSessionExpire': true},
          ),
        );

        // ✅ Succès en ligne : retrait de la file d'attente et mise à jour locale
        await _localDataSource.removePendingDelivery(cleanLigneId);
        await _localDataSource.updateCachedDeliveryStatus(
          codeLigne: cleanLigneId,
          status: 'LIVREE',
          notes: notes,
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
        );
      }
    }

    return DeliveryModel(
      id: id,
      tourId: tourId ?? '',
      clientCode: '',
      clientName: '',
      deliveryNoteNumber: id.startsWith('BL-') ? id : 'BL-$id',
      weight: 0.0,
      amount: 0.0,
      address: '',
      phone: '',
      status: status,
      scheduledTime: DateTime.now(),
      notes: notes ?? '',
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
    String? notes,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final updated = DeliveryModel(
      id: id,
      tourId: tourId ?? 'TRN-1790866899713',
      clientCode: 'CIETIA',
      clientName: 'CIE',
      deliveryNoteNumber: id.startsWith('BL-') ? id : 'BL-$id',
      weight: 0.0,
      amount: 15.0,
      address: 'Abidjan',
      phone: '',
      status: status,
      scheduledTime: DateTime.now(),
      notes: notes ?? '',
    );
    _cache[id] = updated;
    return updated;
  }
}
