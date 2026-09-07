import 'package:equatable/equatable.dart';

import '../../../delivery/domain/entities/delivery.dart';

enum TourStatus { pending, inProgress, completed, cancelled }

/// Entité métier représentant une Tournée.
/// Une tournée contient plusieurs livraisons.
class TourEntity extends Equatable {
  final String id;
  final String reference;
  final DateTime date;
  final String agence;
  final String livreurName;
  final String vehiclePlate;
  final TourStatus status;
  final List<Delivery> deliveries;

  const TourEntity({
    required this.id,
    required this.reference,
    required this.date,
    required this.agence,
    required this.livreurName,
    required this.vehiclePlate,
    required this.status,
    required this.deliveries,
  });

  @override
  List<Object?> get props => [
    id,
    reference,
    date,
    agence,
    livreurName,
    vehiclePlate,
    status,
    deliveries,
  ];
}
