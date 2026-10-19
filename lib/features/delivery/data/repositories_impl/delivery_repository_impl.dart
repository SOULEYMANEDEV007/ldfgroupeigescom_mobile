import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/api_error_handler.dart';
import '../../domain/entities/delivery.dart';
import '../../domain/repositories/delivery_repository.dart';
import '../datasources/delivery_remote_data_source.dart';

@LazySingleton(as: DeliveryRepository)
class DeliveryRepositoryImpl implements DeliveryRepository {
  final DeliveryRemoteDataSource remoteDataSource;

  DeliveryRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<String, Delivery>> getDeliveryById(String id) async {
    try {
      final delivery = await remoteDataSource.getDeliveryById(id);
      return Right(delivery);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, Delivery>> updateStatus(
    String id,
    DeliveryStatus status, {
    String? tourId,
    String? notes,
  }) async {
    try {
      final updated = await remoteDataSource.updateStatus(
        id,
        status,
        tourId: tourId,
        notes: notes,
      );
      return Right(updated);
    } catch (e) {
      return Left(
        ApiErrorHandler.message(
          e,
          unauthorizedMessage:
              "Validation refusée par le serveur : ce compte n'est pas autorisé à valider cette livraison.",
        ),
      );
    }
  }
}
