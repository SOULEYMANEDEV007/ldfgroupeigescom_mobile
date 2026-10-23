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
  });

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
  ];
}
