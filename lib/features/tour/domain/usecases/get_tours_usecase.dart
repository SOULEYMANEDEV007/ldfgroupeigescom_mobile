import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../entities/tour_entity.dart';
import '../repositories/tour_repository.dart';

@injectable
class GetToursUseCase {
  final TourRepository repository;
  GetToursUseCase(this.repository);

  Future<Either<String, List<TourEntity>>> call() {
    return repository.getTours();
  }
}
