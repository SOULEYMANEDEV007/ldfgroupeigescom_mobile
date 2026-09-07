import '../../domain/entities/dashboard_stats.dart';

class DashboardStatsModel extends DashboardStats {
  const DashboardStatsModel({
    required super.pendingDeliveries,
    required super.completedDeliveries,
    required super.nextDestination,
    required super.nextDeliveryId,
  });
}
