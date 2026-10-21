import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/api_error_handler.dart';
import '../../domain/entities/tour_entity.dart';
import '../../domain/repositories/tour_repository.dart';
import '../datasources/tour_remote_data_source.dart';

@LazySingleton(as: TourRepository)
class TourRepositoryImpl implements TourRepository {
  final TourRemoteDataSource remoteDataSource;

  TourRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<String, List<TourEntity>>> getTours() async {
    try {
      final tours = await remoteDataSource.getTours();
      return Right(tours);
    } catch (e) {
      // 🛡️ Traduction en texte clair en français, sans fuite d'adresses IP ou d'erreurs backend
      return Left(ApiErrorHandler.message(e));
    }
  }
}
