import 'package:injectable/injectable.dart';
import '../models/delivery_model.dart';
import '../../domain/entities/delivery.dart';

abstract class TourRemoteDataSource {
  Future<List<DeliveryModel>> getTours();
}

@LazySingleton(as: TourRemoteDataSource)
class MockTourRemoteDataSourceImpl implements TourRemoteDataSource {
  @override
  Future<List<DeliveryModel>> getTours() async {
    await Future.delayed(const Duration(seconds: 1)); // Mock latency

    return [
      DeliveryModel(
        id: 'LDF-8943',
        clientName: 'Koffi Fabrice',
        address: 'Treichville, Avenue 16, Rue 12',
        phone: '01 02 03 04 05',
        status: DeliveryStatus.inProgress,
        scheduledTime: DateTime.now().add(const Duration(hours: 1)),
        notes: 'Appeler avant d\'arriver. Livrer les rames de papier.',
      ),
      DeliveryModel(
        id: 'LDF-8944',
        clientName: 'Pharmacie de la Grâce',
        address: 'Cocody, Angré 8ème Tranche',
        phone: '05 06 07 08 09',
        status: DeliveryStatus.pending,
        scheduledTime: DateTime.now().add(const Duration(hours: 3)),
        notes: 'Dépôt à la guérite autorisé.',
      ),
      DeliveryModel(
        id: 'LDF-8940',
        clientName: 'Lycée Classique',
        address: 'Cocody',
        phone: '07 08 09 10 11',
        status: DeliveryStatus.delivered,
        scheduledTime: DateTime.now().subtract(const Duration(hours: 2)),
        notes: 'Livraison de fournitures de bureau.',
      ),
    ];
  }
}
