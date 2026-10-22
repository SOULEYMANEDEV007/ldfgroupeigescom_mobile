import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../entities/delivery.dart';
import '../repositories/delivery_repository.dart';

/// UseCase : Mettre à jour le statut d'une livraison.
@injectable
class UpdateDeliveryStatusUseCase {
  final DeliveryRepository repository;

  UpdateDeliveryStatusUseCase(this.repository);

  Future<Either<String, Delivery>> call(
    String id,
    DeliveryStatus status, {
    String? tourId,
    String? codeBl,
    String? notes,
  }) {
    return repository.updateStatus(
      id,
      status,
      tourId: tourId,
      codeBl: codeBl,
      notes: notes,
    );
  }
}
