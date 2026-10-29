import '../../domain/entities/dashboard_stats.dart';

class DashboardStatsModel extends DashboardStats {
  const DashboardStatsModel({
    super.totalDeliveries = 0,
    required super.completedDeliveries,
    required super.pendingDeliveries,
    super.failedDeliveries = 0,
    super.activeToursCount = 0,
    super.activeTourRef = '',
    required super.nextDestination,
    required super.nextDeliveryId,
  });
}
