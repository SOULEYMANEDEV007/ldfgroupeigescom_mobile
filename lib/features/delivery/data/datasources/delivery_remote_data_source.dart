import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/di/app_environments.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_error_handler.dart';
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

  RealDeliveryRemoteDataSourceImpl(this._dio);

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
    // Si validation de livraison, envoi de la requête au backend
    if (status == DeliveryStatus.delivered) {
      final cleanLigneId = id.trim();
      final cleanTournee =
          (tourId != null && tourId.isNotEmpty && tourId != 'N/A') ? tourId : '';
      if (cleanLigneId.isEmpty || cleanLigneId == 'N/A') {
        throw const ApiException(
          'Ligne de livraison introuvable : impossible de valider cette livraison.',
        );
      }

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
