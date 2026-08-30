import 'package:injectable/injectable.dart';
import '../../../delivery/data/models/delivery_model.dart';
import '../../../delivery/domain/entities/delivery.dart';
import '../../domain/entities/tour_entity.dart';

abstract class TourRemoteDataSource {
  Future<List<TourEntity>> getTours();
}

@LazySingleton(as: TourRemoteDataSource)
class MockTourRemoteDataSourceImpl implements TourRemoteDataSource {
  @override
  Future<List<TourEntity>> getTours() async {
    await Future.delayed(const Duration(seconds: 1)); // Mock latency

    return [
      TourEntity(
        id: 'T-001',
        reference: 'TRN-2026-0830-01',
        date: DateTime.now(),
        agence: 'LDF-Plateau',
        livreurName: 'Kouassi Livreur',
        vehiclePlate: '1234 AB 01',
        status: TourStatus.inProgress,
        deliveries: [
          DeliveryModel(
            id: 'LDF-8943',
            tourId: 'T-001',
            clientCode: 'CL-001',
            clientName: 'Koffi Fabrice',
            deliveryNoteNumber: 'BL-001',
            weight: 15.5,
            amount: 25000,
            address: 'Treichville, Avenue 16, Rue 12',
            phone: '01 02 03 04 05',
            status: DeliveryStatus.inProgress,
            scheduledTime: DateTime.now().add(const Duration(hours: 1)),
            notes: 'Appeler avant d\'arriver. Livrer les rames de papier.',
          ),
          DeliveryModel(
            id: 'LDF-8944',
            tourId: 'T-001',
            clientCode: 'CL-002',
            clientName: 'Pharmacie de la Grâce',
            deliveryNoteNumber: 'BL-002',
            weight: 5.0,
            amount: 5000,
            address: 'Cocody, Angré 8ème Tranche',
            phone: '05 06 07 08 09',
            status: DeliveryStatus.pending,
            scheduledTime: DateTime.now().add(const Duration(hours: 3)),
            notes: 'Dépôt à la guérite autorisé.',
          ),
        ],
      ),
      TourEntity(
        id: 'T-002',
        reference: 'TRN-2026-0830-02',
        date: DateTime.now().subtract(const Duration(days: 1)),
        agence: 'LDF-Cocody',
        livreurName: 'Kouassi Livreur',
        vehiclePlate: '1234 AB 01',
        status: TourStatus.completed,
        deliveries: [
          DeliveryModel(
            id: 'LDF-8940',
            tourId: 'T-002',
            clientCode: 'CL-003',
            clientName: 'Lycée Classique',
            deliveryNoteNumber: 'BL-003',
            weight: 50.0,
            amount: 150000,
            address: 'Cocody',
            phone: '07 08 09 10 11',
            status: DeliveryStatus.delivered,
            scheduledTime: DateTime.now().subtract(const Duration(hours: 2)),
            notes: 'Livraison de fournitures de bureau.',
          ),
        ],
      ),
    ];
  }
}
