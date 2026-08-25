import 'package:injectable/injectable.dart';
import '../models/dashboard_stats_model.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardStatsModel> getStats();
}

@LazySingleton(as: DashboardRemoteDataSource)
class MockDashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  @override
  Future<DashboardStatsModel> getStats() async {
    await Future.delayed(const Duration(seconds: 1)); // Mock latency
    return const DashboardStatsModel(
      pendingDeliveries: 15,
      completedDeliveries: 42,
      nextDestination: 'Treichville, Avenue 16',
      nextDeliveryId: 'LDF-8943',
    );
  }
}
