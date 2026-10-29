import 'package:equatable/equatable.dart';

class DashboardStats extends Equatable {
  final int totalDeliveries;
  final int completedDeliveries;
  final int pendingDeliveries;
  final int failedDeliveries;
  final int activeToursCount;
  final String activeTourRef;
  final String nextDestination;
  final String nextDeliveryId;

  const DashboardStats({
    this.totalDeliveries = 0,
    required this.completedDeliveries,
    required this.pendingDeliveries,
    this.failedDeliveries = 0,
    this.activeToursCount = 0,
    this.activeTourRef = '',
    required this.nextDestination,
    required this.nextDeliveryId,
  });

  double get progressionRatio =>
      totalDeliveries > 0 ? (completedDeliveries / totalDeliveries).clamp(0.0, 1.0) : 0.0;

  @override
  List<Object?> get props => [
    totalDeliveries,
    completedDeliveries,
    pendingDeliveries,
    failedDeliveries,
    activeToursCount,
    activeTourRef,
    nextDestination,
    nextDeliveryId,
  ];
}
