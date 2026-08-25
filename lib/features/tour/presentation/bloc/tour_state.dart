part of 'tour_cubit.dart';

abstract class TourState extends Equatable {
  const TourState();

  @override
  List<Object?> get props => [];
}

class TourInitial extends TourState {}

class TourLoading extends TourState {}

class TourLoaded extends TourState {
  final List<Delivery> tours;

  const TourLoaded(this.tours);

  @override
  List<Object?> get props => [tours];
}

class TourError extends TourState {
  final String message;

  const TourError(this.message);

  @override
  List<Object?> get props => [message];
}
