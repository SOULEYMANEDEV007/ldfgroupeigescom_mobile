import 'package:equatable/equatable.dart';

/// Entité métier représentant un article dans le bon de livraison.
class DeliveryLineItem extends Equatable {
  final String reference;
  final String designation;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String unit;

  const DeliveryLineItem({
    required this.reference,
    required this.designation,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.unit = 'colis',
  });

  @override
  List<Object?> get props => [
    reference,
    designation,
    quantity,
    unitPrice,
    totalPrice,
    unit,
  ];
}
