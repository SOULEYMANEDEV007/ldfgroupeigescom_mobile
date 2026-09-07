import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/dashboard_stats.dart';
import '../../domain/usecases/get_dashboard_stats_usecase.dart';

part 'dashboard_state.dart';

@injectable
class DashboardCubit extends Cubit<DashboardState> {
  final GetDashboardStatsUseCase getStatsUseCase;

  DashboardCubit(this.getStatsUseCase) : super(DashboardInitial());

  Future<void> fetchStats() async {
    emit(DashboardLoading());
    final result = await getStatsUseCase();
    result.fold(
      (error) => emit(DashboardError(error)),
      (stats) => emit(DashboardLoaded(stats)),
    );
  }
}
