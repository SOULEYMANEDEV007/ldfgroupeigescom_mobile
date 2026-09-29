import 'package:equatable/equatable.dart';

enum HistoryStatus { delivered, failed }

/// Une entrée dans l'historique des livraisons terminées (succès ou échec).
class HistoryEntry extends Equatable {
  final String id;
  final String deliveryNoteNumber; // N° BL
  final String clientName;
  final String address;
  final String tourReference;
  final double amount;
  final HistoryStatus status;
  final DateTime completedAt;
  final String? failureReason; // renseigné si status == failed

  const HistoryEntry({
    required this.id,
    required this.deliveryNoteNumber,
    required this.clientName,
    required this.address,
    required this.tourReference,
    required this.amount,
    required this.status,
    required this.completedAt,
    this.failureReason,
  });

  @override
  List<Object?> get props => [
        id,
        deliveryNoteNumber,
        clientName,
        address,
        tourReference,
        amount,
        status,
        completedAt,
        failureReason,
      ];
}
