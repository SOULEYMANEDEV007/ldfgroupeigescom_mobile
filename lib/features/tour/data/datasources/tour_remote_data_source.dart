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

    final now = DateTime.now();
    
    return [
      // Tournée 1 - En cours
      TourEntity(
        id: 'T-001',
        reference: 'TRN-2026-0830-01',
        date: now,
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
            status: DeliveryStatus.delivered,
            scheduledTime: now.add(const Duration(hours: 1)),
            notes: 'Appeler avant d\'arriver.',
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
            scheduledTime: now.add(const Duration(hours: 3)),
            notes: 'Dépôt à la guérite autorisé.',
          ),
        ],
      ),
      
      // Tournée 2 - Complétée
      TourEntity(
        id: 'T-002',
        reference: 'TRN-2026-0829-01',
        date: now.subtract(const Duration(days: 1)),
        agence: 'LDF-Cocody',
        livreurName: 'Kouassi Livreur',
        vehiclePlate: '5678 CD 02',
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
            address: 'Cocody, Deux Plateaux',
            phone: '07 08 09 10 11',
            status: DeliveryStatus.delivered,
            scheduledTime: now.subtract(const Duration(hours: 5)),
            notes: 'Livraison fournitures de bureau.',
          ),
          DeliveryModel(
            id: 'LDF-8941',
            tourId: 'T-002',
            clientCode: 'CL-004',
            clientName: 'Société COPACI',
            deliveryNoteNumber: 'BL-004',
            weight: 30.0,
            amount: 80000,
            address: 'Plateau, Rue des Banques',
            phone: '02 03 04 05 06',
            status: DeliveryStatus.delivered,
            scheduledTime: now.subtract(const Duration(hours: 3)),
            notes: '',
          ),
        ],
      ),
      
      // Tournée 3 - Programmée
      TourEntity(
        id: 'T-003',
        reference: 'TRN-2026-0830-02',
        date: now,
        agence: 'LDF-Yopougon',
        livreurName: 'Kouassi Livreur',
        vehiclePlate: '9012 EF 03',
        status: TourStatus.pending,
        deliveries: [
          DeliveryModel(
            id: 'LDF-8945',
            tourId: 'T-003',
            clientCode: 'CL-005',
            clientName: 'Restaurant Le Wafou',
            deliveryNoteNumber: 'BL-005',
            weight: 12.0,
            amount: 35000,
            address: 'Yopougon, Marché Sideci',
            phone: '09 10 11 12 13',
            status: DeliveryStatus.pending,
            scheduledTime: now.add(const Duration(hours: 6)),
            notes: 'Livraison urgente.',
          ),
          DeliveryModel(
            id: 'LDF-8946',
            tourId: 'T-003',
            clientCode: 'CL-006',
            clientName: 'Quincaillerie Moderne',
            deliveryNoteNumber: 'BL-006',
            weight: 45.0,
            amount: 120000,
            address: 'Yopougon, Millionnaire',
            phone: '03 04 05 06 07',
            status: DeliveryStatus.pending,
            scheduledTime: now.add(const Duration(hours: 7)),
            notes: 'Matériel fragile.',
          ),
          DeliveryModel(
            id: 'LDF-8947',
            tourId: 'T-003',
            clientCode: 'CL-007',
            clientName: 'École Internationale',
            deliveryNoteNumber: 'BL-007',
            weight: 20.0,
            amount: 60000,
            address: 'Yopougon, Ananeraie',
            phone: '04 05 06 07 08',
            status: DeliveryStatus.pending,
            scheduledTime: now.add(const Duration(hours: 8)),
            notes: '',
          ),
        ],
      ),
      
      // Tournée 4 - En cours
      TourEntity(
        id: 'T-004',
        reference: 'TRN-2026-0830-03',
        date: now,
        agence: 'LDF-Adjamé',
        livreurName: 'Kouassi Livreur',
        vehiclePlate: '3456 GH 04',
        status: TourStatus.inProgress,
        deliveries: [
          DeliveryModel(
            id: 'LDF-8948',
            tourId: 'T-004',
            clientCode: 'CL-008',
            clientName: 'Clinique des Mamelles',
            deliveryNoteNumber: 'BL-008',
            weight: 8.5,
            amount: 28000,
            address: 'Adjamé, Rue 12',
            phone: '06 07 08 09 10',
            status: DeliveryStatus.inProgress,
            scheduledTime: now.add(const Duration(hours: 2)),
            notes: 'Livrer au service pharmacie.',
          ),
        ],
      ),
      
      // Tournée 5 - Complétée
      TourEntity(
        id: 'T-005',
        reference: 'TRN-2026-0828-01',
        date: now.subtract(const Duration(days: 2)),
        agence: 'LDF-Marcory',
        livreurName: 'Kouassi Livreur',
        vehiclePlate: '7890 IJ 05',
        status: TourStatus.completed,
        deliveries: [
          DeliveryModel(
            id: 'LDF-8949',
            tourId: 'T-005',
            clientCode: 'CL-009',
            clientName: 'Supermarché Carrefour',
            deliveryNoteNumber: 'BL-009',
            weight: 100.0,
            amount: 350000,
            address: 'Marcory, Zone 4',
            phone: '08 09 10 11 12',
            status: DeliveryStatus.delivered,
            scheduledTime: now.subtract(const Duration(days: 2)),
            notes: '',
          ),
          DeliveryModel(
            id: 'LDF-8950',
            tourId: 'T-005',
            clientCode: 'CL-010',
            clientName: 'Hôtel Ivoire',
            deliveryNoteNumber: 'BL-010',
            weight: 75.0,
            amount: 250000,
            address: 'Plateau, Boulevard Carde',
            phone: '09 10 11 12 13',
            status: DeliveryStatus.delivered,
            scheduledTime: now.subtract(const Duration(days: 2, hours: -1)),
            notes: 'Livraison VIP.',
          ),
        ],
      ),
      
      // Tournée 6 - Programmée
      TourEntity(
        id: 'T-006',
        reference: 'TRN-2026-0830-04',
        date: now,
        agence: 'LDF-Abobo',
        livreurName: 'Kouassi Livreur',
        vehiclePlate: '2345 KL 06',
        status: TourStatus.pending,
        deliveries: [
          DeliveryModel(
            id: 'LDF-8951',
            tourId: 'T-006',
            clientCode: 'CL-011',
            clientName: 'Boulangerie du Nord',
            deliveryNoteNumber: 'BL-011',
            weight: 25.0,
            amount: 45000,
            address: 'Abobo, Gare',
            phone: '01 12 13 14 15',
            status: DeliveryStatus.pending,
            scheduledTime: now.add(const Duration(hours: 9)),
            notes: 'Livraison tôt le matin.',
          ),
        ],
      ),
      
      // Tournée 7 - En cours
      TourEntity(
        id: 'T-007',
        reference: 'TRN-2026-0830-05',
        date: now,
        agence: 'LDF-Port-Bouët',
        livreurName: 'Kouassi Livreur',
        vehiclePlate: '6789 MN 07',
        status: TourStatus.inProgress,
        deliveries: [
          DeliveryModel(
            id: 'LDF-8952',
            tourId: 'T-007',
            clientCode: 'CL-012',
            clientName: 'Entreprise Bouygues',
            deliveryNoteNumber: 'BL-012',
            weight: 90.0,
            amount: 400000,
            address: 'Port-Bouët, Zone Industrielle',
            phone: '02 13 14 15 16',
            status: DeliveryStatus.inProgress,
            scheduledTime: now.add(const Duration(hours: 4)),
            notes: 'Gros matériel - Prévoir aide.',
          ),
          DeliveryModel(
            id: 'LDF-8953',
            tourId: 'T-007',
            clientCode: 'CL-013',
            clientName: 'Hôpital Général',
            deliveryNoteNumber: 'BL-013',
            weight: 15.0,
            amount: 55000,
            address: 'Port-Bouët, Centre',
            phone: '03 14 15 16 17',
            status: DeliveryStatus.pending,
            scheduledTime: now.add(const Duration(hours: 5)),
            notes: 'Équipements médicaux fragiles.',
          ),
        ],
      ),
      
      // Tournée 8 - Complétée
      TourEntity(
        id: 'T-008',
        reference: 'TRN-2026-0827-01',
        date: now.subtract(const Duration(days: 3)),
        agence: 'LDF-Koumassi',
        livreurName: 'Kouassi Livreur',
        vehiclePlate: '1357 OP 08',
        status: TourStatus.completed,
        deliveries: [
          DeliveryModel(
            id: 'LDF-8954',
            tourId: 'T-008',
            clientCode: 'CL-014',
            clientName: 'Société SITARAIL',
            deliveryNoteNumber: 'BL-014',
            weight: 60.0,
            amount: 180000,
            address: 'Koumassi, Gare Ferroviaire',
            phone: '04 15 16 17 18',
            status: DeliveryStatus.delivered,
            scheduledTime: now.subtract(const Duration(days: 3)),
            notes: '',
          ),
        ],
      ),
      
      // Tournée 9 - Programmée
      TourEntity(
        id: 'T-009',
        reference: 'TRN-2026-0831-01',
        date: now.add(const Duration(days: 1)),
        agence: 'LDF-Songon',
        livreurName: 'Kouassi Livreur',
        vehiclePlate: '2468 QR 09',
        status: TourStatus.pending,
        deliveries: [
          DeliveryModel(
            id: 'LDF-8955',
            tourId: 'T-009',
            clientCode: 'CL-015',
            clientName: 'Plantation Palmeraie',
            deliveryNoteNumber: 'BL-015',
            weight: 40.0,
            amount: 95000,
            address: 'Songon, Route d\'Azagui',
            phone: '05 16 17 18 19',
            status: DeliveryStatus.pending,
            scheduledTime: now.add(const Duration(days: 1, hours: 2)),
            notes: 'Difficile d\'accès - 4x4 requis.',
          ),
        ],
      ),
      
      // Tournée 10 - Programmée
      TourEntity(
        id: 'T-010',
        reference: 'TRN-2026-0831-02',
        date: now.add(const Duration(days: 1)),
        agence: 'LDF-Bingerville',
        livreurName: 'Kouassi Livreur',
        vehiclePlate: '3579 ST 10',
        status: TourStatus.pending,
        deliveries: [
          DeliveryModel(
            id: 'LDF-8956',
            tourId: 'T-010',
            clientCode: 'CL-016',
            clientName: 'Université Alassane Ouattara',
            deliveryNoteNumber: 'BL-016',
            weight: 80.0,
            amount: 280000,
            address: 'Bingerville, Campus Universitaire',
            phone: '06 17 18 19 20',
            status: DeliveryStatus.pending,
            scheduledTime: now.add(const Duration(days: 1, hours: 3)),
            notes: 'Livraison bibliothèque centrale.',
          ),
          DeliveryModel(
            id: 'LDF-8957',
            tourId: 'T-010',
            clientCode: 'CL-017',
            clientName: 'Orphelinat Espoir',
            deliveryNoteNumber: 'BL-017',
            weight: 35.0,
            amount: 70000,
            address: 'Bingerville, Centre-Ville',
            phone: '07 18 19 20 21',
            status: DeliveryStatus.pending,
            scheduledTime: now.add(const Duration(days: 1, hours: 4)),
            notes: 'Don - Livraison gratuite.',
          ),
        ],
      ),
    ];
  }
}
