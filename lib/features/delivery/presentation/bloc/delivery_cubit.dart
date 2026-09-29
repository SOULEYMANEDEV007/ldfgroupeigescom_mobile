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

  /// Démarre une livraison
  Future<void> startDelivery(Delivery delivery) async {
    emit(DeliveryUpdating(delivery));

    try {
      final result = await updateStatusUseCase(
        delivery.id,
        DeliveryStatus.inProgress,
      );

      result.fold(
        (error) => emit(DeliveryError(delivery, error)),
        (updatedDelivery) => emit(DeliveryUpdated(updatedDelivery)),
      );
    } catch (e) {
      emit(DeliveryError(delivery, e.toString()));
    }
  }

  /// Valide une livraison avec signature et photos
  Future<void> validateDelivery(
    Delivery delivery, {
    String? notes,
    String? signatureUrl,
    List<String>? photoUrls,
  }) async {
    emit(DeliveryUpdating(delivery));

    try {
      final result = await updateStatusUseCase(
        delivery.id,
        DeliveryStatus.delivered,
      );

      result.fold(
        (error) => emit(DeliveryError(delivery, error)),
        (updatedDelivery) => emit(DeliveryUpdated(updatedDelivery)),
      );
    } catch (e) {
      emit(DeliveryError(delivery, e.toString()));
    }
  }

  /// Signale un échec de livraison
  Future<void> reportFailure(
    Delivery delivery, {
    required String reason,
    String? notes,
  }) async {
    emit(DeliveryUpdating(delivery));

    try {
      final result = await updateStatusUseCase(
        delivery.id,
        DeliveryStatus.cancelled,
      );

      result.fold(
        (error) => emit(DeliveryError(delivery, error)),
        (updatedDelivery) => emit(DeliveryUpdated(updatedDelivery)),
      );
    } catch (e) {
      emit(DeliveryError(delivery, e.toString()));
    }
  }
}
