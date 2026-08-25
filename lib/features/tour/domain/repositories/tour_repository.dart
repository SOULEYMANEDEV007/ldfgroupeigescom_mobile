import 'package:dartz/dartz.dart';
import '../entities/delivery.dart';

abstract class TourRepository {
  Future<Either<String, List<Delivery>>> getTours();
}
