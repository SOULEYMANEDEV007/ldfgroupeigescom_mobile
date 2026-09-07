import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../entities/dashboard_stats.dart';
import '../repositories/dashboard_repository.dart';

@injectable
class GetDashboardStatsUseCase {
  final DashboardRepository repository;
  GetDashboardStatsUseCase(this.repository);

  Future<Either<String, DashboardStats>> call() {
    return repository.getStats();
  }
}
