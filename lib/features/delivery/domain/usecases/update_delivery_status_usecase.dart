import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../entities/delivery.dart';
import '../repositories/delivery_repository.dart';

/// UseCase : Mettre à jour le statut d'une livraison.
///
/// Utilisé lors de :
/// - [DeliveryValidationScreen] → DeliveryStatus.delivered
/// - [DeliveryFailureScreen]   → DeliveryStatus.cancelled
/// - [DeliveryDetailScreen]    → DeliveryStatus.inProgress (démarrage)
@injectable
class UpdateDeliveryStatusUseCase {
  final DeliveryRepository repository;
  UpdateDeliveryStatusUseCase(this.repository);

  Future<Either<String, Delivery>> call(String id, DeliveryStatus status) {
    return repository.updateStatus(id, status);
  }
}
