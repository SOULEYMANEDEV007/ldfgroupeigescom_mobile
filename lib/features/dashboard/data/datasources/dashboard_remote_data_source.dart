import 'package:injectable/injectable.dart';

import '../../../../core/di/app_environments.dart';
import '../../../delivery/domain/entities/delivery.dart';
import '../../../tour/data/datasources/tour_remote_data_source.dart';
import '../../../tour/domain/entities/tour_entity.dart';
import '../models/dashboard_stats_model.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardStatsModel> getStats();
}

/// Implémentation réelle calculant les KPI à partir des tournées API
@LazySingleton(as: DashboardRemoteDataSource, env: [kRealEnv])
class RealDashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final TourRemoteDataSource _tourRemoteDataSource;

  RealDashboardRemoteDataSourceImpl(this._tourRemoteDataSource);

  @override
  Future<DashboardStatsModel> getStats() async {
    try {
      final tours = await _tourRemoteDataSource.getTours();

      int total = 0;
      int pending = 0;
      int completed = 0;
      int failed = 0;
      int activeToursCount = 0;
      String activeTourRef = '';
      String nextDest = 'Aucune course prévue';
      String nextId = '';

      for (final tour in tours) {
        final isActive = tour.status == TourStatus.inProgress ||
            tour.status == TourStatus.pending;
        if (isActive) {
          activeToursCount++;
          if (activeTourRef.isEmpty) {
            activeTourRef = tour.displayName;
          }
        }

        for (final delivery in tour.deliveries) {
          total++;
          if (delivery.status == DeliveryStatus.delivered) {
            completed++;
          } else if (delivery.status == DeliveryStatus.cancelled) {
            failed++;
          } else {
            pending++;
            if (nextId.isEmpty) {
              nextDest = delivery.address.isNotEmpty
                  ? '${delivery.clientName} (${delivery.address})'
                  : delivery.clientName;
              nextId = delivery.deliveryNoteNumber;
            }
          }
        }
      }

      if (activeTourRef.isEmpty && tours.isNotEmpty) {
        activeTourRef = tours.first.displayName;
      }

      return DashboardStatsModel(
        totalDeliveries: total,
        completedDeliveries: completed,
        pendingDeliveries: pending,
        failedDeliveries: failed,
        activeToursCount: activeToursCount,
        activeTourRef:
            activeTourRef.isNotEmpty ? activeTourRef : 'Aucune tournée',
        nextDestination: nextDest,
        nextDeliveryId: nextId,
      );
    } catch (_) {
      return const DashboardStatsModel(
        totalDeliveries: 0,
        completedDeliveries: 0,
        pendingDeliveries: 0,
        failedDeliveries: 0,
        activeToursCount: 0,
        activeTourRef: 'Aucune tournée',
        nextDestination: 'Aucune livraison en attente',
        nextDeliveryId: '',
      );
    }
  }
}

/// Implémentation Mock réservée aux démonstrations hors-ligne (`USE_MOCK_API=true`)
@LazySingleton(as: DashboardRemoteDataSource, env: [kMockEnv])
class MockDashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  @override
  Future<DashboardStatsModel> getStats() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const DashboardStatsModel(
      totalDeliveries: 6,
      completedDeliveries: 2,
      pendingDeliveries: 3,
      failedDeliveries: 1,
      activeToursCount: 1,
      activeTourRef: 'TRN-2026-0830',
      nextDestination: 'SOCIETE IVOIRIENNE DE TEST (ABIDJAN)',
      nextDeliveryId: 'BL-66480311',
    );
  }
}
