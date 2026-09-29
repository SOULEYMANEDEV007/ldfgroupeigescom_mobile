import 'package:dartz/dartz.dart';
import '../entities/delivery.dart';

/// Contrat du repository pour la gestion des livraisons individuelles.
///
/// Couvre les opérations métier propres à une livraison :
/// - Chargement d'une livraison par ID
/// - Mise à jour du statut (démarrage, validation, signalement d'échec)
abstract class DeliveryRepository {
  Future<Either<String, Delivery>> getDeliveryById(String id);
  Future<Either<String, Delivery>> updateStatus(
    String id,
    DeliveryStatus status,
  );
}
