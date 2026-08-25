import 'package:equatable/equatable.dart';

class DashboardStats extends Equatable {
  final int pendingDeliveries;
  final int completedDeliveries;
  final String nextDestination;
  final String nextDeliveryId;

  const DashboardStats({
    required this.pendingDeliveries,
    required this.completedDeliveries,
    required this.nextDestination,
    required this.nextDeliveryId,
  });

  @override
  List<Object?> get props => [
    pendingDeliveries,
    completedDeliveries,
    nextDestination,
    nextDeliveryId,
  ];
}
