import 'package:dartz/dartz.dart';
import '../entities/tour_entity.dart';

abstract class TourRepository {
  Future<Either<String, List<TourEntity>>> getTours();
}
