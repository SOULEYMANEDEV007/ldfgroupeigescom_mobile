import 'package:equatable/equatable.dart';

/// Entité métier représentant un article dans le bon de livraison.
class DeliveryLineItem extends Equatable {
  final String reference;
  final String designation;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String unit;

  // Champs de BL de IGESCOM
  final String productCode;
  final String? barcode;
  final String? serialNumber;
  final double unitPriceHt;
  final double totalPriceHt;
  final String taxCode;
  final String arsiCode;

  const DeliveryLineItem({
    required this.reference,
    required this.designation,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.unit = 'colis',
    String? productCode,
    this.barcode,
    this.serialNumber,
    double? unitPriceHt,
    double? totalPriceHt,
    this.taxCode = '1',
    this.arsiCode = '0',
  }) : productCode = productCode ?? reference,
       unitPriceHt = unitPriceHt ?? unitPrice,
       totalPriceHt = totalPriceHt ?? totalPrice;

  @override
  List<Object?> get props => [
    reference,
    designation,
    quantity,
    unitPrice,
    totalPrice,
    unit,
    productCode,
    barcode,
    serialNumber,
    unitPriceHt,
    totalPriceHt,
    taxCode,
    arsiCode,
  ];
}
