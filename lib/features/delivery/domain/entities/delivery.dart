import 'package:equatable/equatable.dart';

import 'delivery_note.dart';

enum DeliveryStatus { pending, inProgress, delivered, cancelled }

/// Entité métier principale représentant une livraison.
///
/// Une [Delivery] appartient toujours à une tournée ([Tour]).
/// Hiérarchie : Dashboard → Tournée → Livraison → Bon de Livraison
class Delivery extends Equatable {
  final String id;
  final String tourId;
  final String clientCode;
  final String clientName;
  final String deliveryNoteNumber;
  final double weight;
  final double amount;
  final String address;
  final String phone;
  final DeliveryStatus status;
  final DateTime scheduledTime;
  final String notes;
  final DeliveryNote? deliveryNote;

  const Delivery({
    required this.id,
    required this.tourId,
    required this.clientCode,
    required this.clientName,
    required this.deliveryNoteNumber,
    required this.weight,
    required this.amount,
    required this.address,
    required this.phone,
    required this.status,
    required this.scheduledTime,
    required this.notes,
    this.deliveryNote,
  });

  /// Retourne une copie de la livraison avec un nouveau statut.
  Delivery copyWith({DeliveryStatus? status, DeliveryNote? deliveryNote}) {
    return Delivery(
      id: id,
      tourId: tourId,
      clientCode: clientCode,
      clientName: clientName,
      deliveryNoteNumber: deliveryNoteNumber,
      weight: weight,
      amount: amount,
      address: address,
      phone: phone,
      status: status ?? this.status,
      scheduledTime: scheduledTime,
      notes: notes,
      deliveryNote: deliveryNote ?? this.deliveryNote,
    );
  }

  @override
  List<Object?> get props => [
    id,
    tourId,
    clientCode,
    clientName,
    deliveryNoteNumber,
    weight,
    amount,
    address,
    phone,
    status,
    scheduledTime,
    notes,
    deliveryNote,
  ];
}
