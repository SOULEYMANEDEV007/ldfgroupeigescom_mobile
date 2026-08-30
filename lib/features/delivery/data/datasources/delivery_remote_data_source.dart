import 'package:injectable/injectable.dart';
import '../models/delivery_model.dart';
import '../../domain/entities/delivery.dart';

abstract class DeliveryRemoteDataSource {
  Future<DeliveryModel> getDeliveryById(String id);
  Future<DeliveryModel> updateStatus(String id, DeliveryStatus status);
}

/// Implémentation Mock — sera remplacée par l'intégration API IgsCom.
@LazySingleton(as: DeliveryRemoteDataSource)
class MockDeliveryRemoteDataSourceImpl implements DeliveryRemoteDataSource {
  // Simule une base de données locale
  final Map<String, DeliveryModel> _cache = {
    'LDF-8943': DeliveryModel(
      id: 'LDF-8943',
      tourId: 'TR-001',
      clientCode: 'CL-001',
      clientName: 'Koffi Fabrice',
      deliveryNoteNumber: 'BL-001',
      weight: 15.5,
      amount: 25000,
      address: 'Treichville, Avenue 16, Rue 12',
      phone: '01 02 03 04 05',
      status: DeliveryStatus.inProgress,
      scheduledTime: DateTime.now().add(const Duration(hours: 1)),
      notes: "Appeler avant d'arriver. Livrer les rames de papier.",
    ),
    'LDF-8944': DeliveryModel(
      id: 'LDF-8944',
      tourId: 'TR-001',
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
  };

  @override
  Future<DeliveryModel> getDeliveryById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final delivery = _cache[id];
    if (delivery == null) throw Exception('Livraison $id introuvable.');
    return delivery;
  }

  @override
  Future<DeliveryModel> updateStatus(String id, DeliveryStatus status) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final existing = _cache[id];
    if (existing == null) throw Exception('Livraison $id introuvable.');
    final updated = DeliveryModel(
      id: existing.id,
      tourId: existing.tourId,
      clientCode: existing.clientCode,
      clientName: existing.clientName,
      deliveryNoteNumber: existing.deliveryNoteNumber,
      weight: existing.weight,
      amount: existing.amount,
      address: existing.address,
      phone: existing.phone,
      status: status,
      scheduledTime: existing.scheduledTime,
      notes: existing.notes,
    );
    _cache[id] = updated;
    return updated;
  }
}
