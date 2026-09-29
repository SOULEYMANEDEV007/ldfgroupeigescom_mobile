import '../../domain/entities/delivery.dart';

/// Modèle de données pour la désérialisation JSON de l'API IgsCom.
class DeliveryModel extends Delivery {
  const DeliveryModel({
    required super.id,
    required super.tourId,
    required super.clientCode,
    required super.clientName,
    required super.deliveryNoteNumber,
    required super.weight,
    required super.amount,
    required super.address,
    required super.phone,
    required super.status,
    required super.scheduledTime,
    required super.notes,
  });

  factory DeliveryModel.fromJson(Map<String, dynamic> json) {
    return DeliveryModel(
      id: json['id'] as String,
      tourId: json['tour_id'] as String? ?? 'N/A',
      clientCode: json['client_code'] as String? ?? 'N/A',
      clientName: json['client_name'] as String,
      deliveryNoteNumber: json['delivery_note_number'] as String? ?? 'N/A',
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      address: json['address'] as String,
      phone: json['phone'] as String,
      status: _statusFromString(json['status'] as String),
      scheduledTime: DateTime.parse(json['scheduled_time'] as String),
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'tour_id': tourId,
    'client_code': clientCode,
    'client_name': clientName,
    'delivery_note_number': deliveryNoteNumber,
    'weight': weight,
    'amount': amount,
    'address': address,
    'phone': phone,
    'status': _statusToString(status),
    'scheduled_time': scheduledTime.toIso8601String(),
    'notes': notes,
  };

  static DeliveryStatus _statusFromString(String value) {
    switch (value) {
      case 'in_progress':
        return DeliveryStatus.inProgress;
      case 'delivered':
        return DeliveryStatus.delivered;
      case 'cancelled':
        return DeliveryStatus.cancelled;
      default:
        return DeliveryStatus.pending;
    }
  }

  static String _statusToString(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.inProgress:
        return 'in_progress';
      case DeliveryStatus.delivered:
        return 'delivered';
      case DeliveryStatus.cancelled:
        return 'cancelled';
      case DeliveryStatus.pending:
        return 'pending';
    }
  }
}
