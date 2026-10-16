import 'package:equatable/equatable.dart';

import '../../../delivery/domain/entities/delivery.dart';

enum TourStatus { pending, inProgress, completed, cancelled }

/// Entité métier représentant une Tournée.
/// Une tournée contient plusieurs livraisons.
class TourEntity extends Equatable {
  final String id;
  final String reference;
  final String libelle;
  final DateTime date;
  final String heureDepart;
  final String agence;
  final String chauffeurName;
  final String livreurName;
  final String vehiclePlate;
  final TourStatus status;
  final List<Delivery> deliveries;

  const TourEntity({
    required this.id,
    required this.reference,
    this.libelle = '',
    required this.date,
    this.heureDepart = '',
    required this.agence,
    this.chauffeurName = '',
    required this.livreurName,
    required this.vehiclePlate,
    required this.status,
    required this.deliveries,
  });

  /// Nom convivial de la tournée (libellé métier prioritaire, ex: "TEST MOB 1")
  String get displayName =>
      libelle.isNotEmpty ? libelle : (reference.isNotEmpty ? reference : id);

  @override
  List<Object?> get props => [
    id,
    reference,
    libelle,
    date,
    heureDepart,
    agence,
    chauffeurName,
    livreurName,
    vehiclePlate,
    status,
    deliveries,
  ];
}
