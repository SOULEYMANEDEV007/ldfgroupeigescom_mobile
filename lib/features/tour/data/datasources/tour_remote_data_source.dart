import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/di/app_environments.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/token_manager.dart';
import '../../../delivery/data/models/delivery_model.dart';
import '../../../delivery/domain/entities/delivery.dart';
import '../../domain/entities/tour_entity.dart';
import '../models/tour_model.dart';

abstract class TourRemoteDataSource {
  Future<List<TourEntity>> getTours();
}

/// Implémentation réelle consommant l'API IGESCOM
/// `GET /api/flotte/convotournees/{code_agent}`
@LazySingleton(as: TourRemoteDataSource, env: [kRealEnv])
class RealTourRemoteDataSourceImpl implements TourRemoteDataSource {
  final Dio _dio;
  final TokenManager _tokenManager;

  RealTourRemoteDataSourceImpl(this._dio, this._tokenManager);

  @override
  Future<List<TourEntity>> getTours() async {
    final codeAgent = _tokenManager.getCodeAgent() ?? '9991317331';

    final response = await _dio.get(ApiEndpoints.tours(codeAgent));

    if (response.data is Map<String, dynamic>) {
      final rows = response.data['rows'] as List<dynamic>? ?? [];

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
