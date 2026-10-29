import 'package:equatable/equatable.dart';
import 'delivery_line_item.dart';

enum DeliveryNoteStatus { emis, livre, retourne, echec }

/// Entité métier représentant le Bon de Livraison
class DeliveryNote extends Equatable {
  final String number;
  final DateTime generatedAt;
  final DateTime? validatedAt;
  final String clientName;
  final String clientCode;
  final String clientAddress;
  final String agence;
  final String livreurName;
  final String vehiclePlate;
  final List<DeliveryLineItem> items;
  final double totalAmount;
  final double totalWeight;
  final String? signatureUrl;
  final DeliveryNoteStatus status;

  final String? orderNumber;
  final String? compteContrib;
  final double? montTva;
  final double? montArsi;
  final String? signedBy;

  // ── Blocs récapitulatifs officiels IGESCOM ──
  final double montantHtCumule;
  final double totalTva;
  final double montantTtc;
  final double netAPayer;
  final double tvaBase;
  final double arsiBase;
  final String? observationRegul;

  const DeliveryNote({
    required this.number,
    required this.generatedAt,
    this.validatedAt,
    required this.clientName,
    required this.clientCode,
    required this.clientAddress,
    required this.agence,
    required this.livreurName,
    required this.vehiclePlate,
    required this.items,
    required this.totalAmount,
    required this.totalWeight,
    this.signatureUrl,
    required this.status,
    this.orderNumber,
    this.compteContrib,
    this.montTva,
    this.montArsi,
    this.signedBy,
    double? montantHtCumule,
    double? totalTva,
    double? montantTtc,
    double? netAPayer,
    double? tvaBase,
    double? arsiBase,
    this.observationRegul,
  }) : montantHtCumule = montantHtCumule ?? totalAmount,
       totalTva = totalTva ?? (montTva ?? 0.0),
       montantTtc = montantTtc ?? (totalAmount + (montTva ?? 0.0)),
       netAPayer = netAPayer ?? (totalAmount + (montTva ?? 0.0)),
       tvaBase = tvaBase ?? totalAmount,
       arsiBase = arsiBase ?? 0.0;

  @override
  List<Object?> get props => [
    number,
    generatedAt,
    validatedAt,
    clientName,
    clientCode,
    clientAddress,
    agence,
    livreurName,
    vehiclePlate,
    items,
    totalAmount,
    totalWeight,
    signatureUrl,
    status,
    orderNumber,
    compteContrib,
    montTva,
    montArsi,
    signedBy,
    montantHtCumule,
    totalTva,
    montantTtc,
    netAPayer,
    tvaBase,
    arsiBase,
    observationRegul,
  ];
}
