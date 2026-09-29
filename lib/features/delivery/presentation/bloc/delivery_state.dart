part of 'delivery_cubit.dart';

abstract class DeliveryState extends Equatable {
  const DeliveryState();

  @override
  List<Object?> get props => [];
}

class DeliveryInitial extends DeliveryState {}

/// Mise à jour en cours (afficher un loader sur le bouton)
class DeliveryUpdating extends DeliveryState {
  final Delivery delivery;
  const DeliveryUpdating(this.delivery);

  @override
  List<Object?> get props => [delivery];
}

/// Mise à jour réussie
class DeliveryUpdated extends DeliveryState {
  final Delivery delivery;
  
  const DeliveryUpdated(this.delivery);

  @override
  List<Object?> get props => [delivery];
}

/// Erreur lors de la mise à jour
class DeliveryError extends DeliveryState {
  final Delivery delivery;
  final String message;
  const DeliveryError(this.delivery, this.message);

  @override
  List<Object?> get props => [delivery, message];
}
