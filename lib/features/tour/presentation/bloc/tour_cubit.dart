import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/delivery.dart';
import '../../domain/usecases/get_tours_usecase.dart';

part 'tour_state.dart';

@injectable
class TourCubit extends Cubit<TourState> {
  final GetToursUseCase getToursUseCase;

  TourCubit(this.getToursUseCase) : super(TourInitial());

  Future<void> fetchTours() async {
    emit(TourLoading());
    final result = await getToursUseCase();
    result.fold(
      (error) => emit(TourError(error)),
      (tours) => emit(TourLoaded(tours)),
    );
  }
}
