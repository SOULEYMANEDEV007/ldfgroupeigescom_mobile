import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/delivery.dart';
import '../../domain/usecases/update_delivery_status_usecase.dart';

part 'delivery_state.dart';

/// Cubit gérant le cycle de vie d'une livraison individuelle.
///
/// Responsabilités :
/// - Démarrer une livraison (pending → inProgress)
/// - Valider une livraison (inProgress → delivered)
/// - Signaler un échec    (inProgress → cancelled)
@injectable
class DeliveryCubit extends Cubit<DeliveryState> {
  final UpdateDeliveryStatusUseCase updateStatusUseCase;

  DeliveryCubit(this.updateStatusUseCase) : super(DeliveryInitial());

  Future<void> startDelivery(Delivery delivery) async {
    await _changeStatus(delivery, DeliveryStatus.inProgress);
  }

  Future<void> validateDelivery(Delivery delivery) async {
    await _changeStatus(delivery, DeliveryStatus.delivered);
  }

  Future<void> reportFailure(Delivery delivery) async {
    await _changeStatus(delivery, DeliveryStatus.cancelled);
  }

  Future<void> _changeStatus(Delivery delivery, DeliveryStatus status) async {
    emit(DeliveryUpdating(delivery));
    final result = await updateStatusUseCase(delivery.id, status);
    result.fold(
      (error) => emit(DeliveryUpdateError(delivery, error)),
      (updated) => emit(DeliveryUpdated(updated)),
    );
  }
}
