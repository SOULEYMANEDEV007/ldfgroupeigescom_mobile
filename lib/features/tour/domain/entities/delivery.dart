import 'package:equatable/equatable.dart';

enum DeliveryStatus { pending, inProgress, delivered, cancelled }

class Delivery extends Equatable {
  final String id;
  final String clientName;
  final String address;
  final String phone;
  final DeliveryStatus status;
  final DateTime scheduledTime;
  final String notes;

  const Delivery({
    required this.id,
    required this.clientName,
    required this.address,
    required this.phone,
    required this.status,
    required this.scheduledTime,
    required this.notes,
  });

  @override
  List<Object?> get props => [
    id,
    clientName,
    address,
    phone,
    status,
    scheduledTime,
    notes,
  ];
}
