import 'package:dartz/dartz.dart';
import '../entities/delivery.dart';

/// Contrat du repository pour la gestion des livraisons individuelles.
abstract class DeliveryRepository {
  Future<Either<String, Delivery>> getDeliveryById(String id);
  Future<Either<String, Delivery>> updateStatus(
    String id,
    DeliveryStatus status, {
    String? tourId,
    String? codeBl,
    String? notes,
  });
}
