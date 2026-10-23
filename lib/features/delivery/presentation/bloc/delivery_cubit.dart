import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/delivery.dart';
import '../../domain/usecases/update_delivery_status_usecase.dart';

part 'delivery_state.dart';

/// Cubit gérant le cycle de vie d'une livraison individuelle.
@injectable
class DeliveryCubit extends Cubit<DeliveryState> {
  final UpdateDeliveryStatusUseCase updateStatusUseCase;

  DeliveryCubit(this.updateStatusUseCase) : super(DeliveryInitial());

  /// Démarre une livraison
  Future<void> startDelivery(Delivery delivery) async {
    if (isClosed) return;
    emit(DeliveryUpdating(delivery));

    try {
      final result = await updateStatusUseCase(
        delivery.id,
        DeliveryStatus.inProgress,
        tourId: delivery.tourId,
      );

      if (isClosed) return;

      result.fold(
        (error) => emit(DeliveryError(delivery, error)),
        (updatedDelivery) => emit(DeliveryUpdated(updatedDelivery)),
      );
    } catch (e) {
      if (isClosed) return;
      emit(DeliveryError(delivery, e.toString()));
    }
  }

  /// Valide une livraison avec signature et photos
  Future<void> validateDelivery(
    Delivery delivery, {
    String? notes,
    String? signedBy,
    String? signatureData,
    String? signatureUrl,
    List<String>? photoUrls,
  }) async {
    if (isClosed) return;
    emit(DeliveryUpdating(delivery));

    try {
      final result = await updateStatusUseCase(
        delivery.id,
        DeliveryStatus.delivered,
        tourId: delivery.tourId,
        notes: notes,
        signedBy: signedBy,
        signatureData: signatureData,
      );

      if (isClosed) return;

      result.fold(
        (error) => emit(DeliveryError(delivery, error)),
        (updatedDelivery) => emit(DeliveryUpdated(updatedDelivery)),
      );
    } catch (e) {
      if (isClosed) return;
      emit(DeliveryError(delivery, e.toString()));
    }
  }

  /// Signale un échec de livraison
  Future<void> reportFailure(
    Delivery delivery, {
    required String reason,
    String? notes,
  }) async {
    if (isClosed) return;
    emit(DeliveryUpdating(delivery));

    try {
      final cleanBl =
          delivery.deliveryNoteNumber.replaceFirst('BL-', '').trim();
      final motif = notes != null && notes.isNotEmpty
          ? '$reason - $notes'
          : reason;

      final result = await updateStatusUseCase(
        delivery.id,
        DeliveryStatus.cancelled,
        tourId: delivery.tourId,
        codeBl: cleanBl.isNotEmpty ? cleanBl : delivery.id,
        notes: motif,
      );

      if (isClosed) return;

      result.fold(
        (error) => emit(DeliveryError(delivery, error)),
        (updatedDelivery) => emit(DeliveryUpdated(updatedDelivery)),
      );
    } catch (e) {
      if (isClosed) return;
      emit(DeliveryError(delivery, e.toString()));
    }
  }
}
