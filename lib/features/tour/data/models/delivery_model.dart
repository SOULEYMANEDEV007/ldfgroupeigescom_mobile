import '../../domain/entities/delivery.dart';

class DeliveryModel extends Delivery {
  const DeliveryModel({
    required super.id,
    required super.clientName,
    required super.address,
    required super.phone,
    required super.status,
    required super.scheduledTime,
    required super.notes,
  });
}
