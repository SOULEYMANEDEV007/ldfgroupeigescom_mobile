import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../entities/delivery.dart';
import '../repositories/tour_repository.dart';

@injectable
class GetToursUseCase {
  final TourRepository repository;
  GetToursUseCase(this.repository);

  Future<Either<String, List<Delivery>>> call() {
    return repository.getTours();
  }
}
