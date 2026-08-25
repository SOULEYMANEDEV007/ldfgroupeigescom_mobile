import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/delivery.dart';
import '../../domain/repositories/tour_repository.dart';
import '../datasources/tour_remote_data_source.dart';

@LazySingleton(as: TourRepository)
class TourRepositoryImpl implements TourRepository {
  final TourRemoteDataSource remoteDataSource;

  TourRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<String, List<Delivery>>> getTours() async {
    try {
      final tours = await remoteDataSource.getTours();
      return Right(tours);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
