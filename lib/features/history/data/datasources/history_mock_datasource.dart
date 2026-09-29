import 'package:injectable/injectable.dart';

import '../../domain/entities/history_entry.dart';

/// Datasource mock — remplacé par appel API réel en production.
@injectable
class HistoryMockDatasource {
  Future<List<HistoryEntry>> fetchHistory() async {
    // Simule un délai réseau
    await Future.delayed(const Duration(milliseconds: 600));

    final now = DateTime.now();

    return [
      HistoryEntry(
        id: 'H-001',
        deliveryNoteNumber: 'BL-2026-0451',
        clientName: 'SOCIÉTÉ AFRIQUE IMPORT',
        address: 'Treichville, Rue des Brasseurs',
        tourReference: 'TRN-2026-0828',
        amount: 45000,
        status: HistoryStatus.delivered,
        completedAt: now.subtract(const Duration(days: 0, hours: 3)),
      ),
      HistoryEntry(
        id: 'H-002',
        deliveryNoteNumber: 'BL-2026-0450',
        clientName: 'KOFFI FABRICE',
        address: 'Cocody, Avenue 16, Rue 12',
        tourReference: 'TRN-2026-0828',
        amount: 25000,
        status: HistoryStatus.failed,
        completedAt: now.subtract(const Duration(days: 0, hours: 5)),
        failureReason: 'Client absent',
      ),
      HistoryEntry(
        id: 'H-003',
        deliveryNoteNumber: 'BL-2026-0440',
        clientName: 'LIBRAIRIE CENTRALE CI',
        address: 'Plateau, Avenue Chardy',
        tourReference: 'TRN-2026-0827',
        amount: 78000,
        status: HistoryStatus.delivered,
        completedAt: now.subtract(const Duration(days: 1, hours: 2)),
      ),
      HistoryEntry(
        id: 'H-004',
        deliveryNoteNumber: 'BL-2026-0439',
        clientName: 'ÉCOLE PRIMAIRE PUBLIQUE BIÉTRY',
        address: 'Biétry, Route du Port',
        tourReference: 'TRN-2026-0827',
        amount: 12000,
        status: HistoryStatus.delivered,
        completedAt: now.subtract(const Duration(days: 1, hours: 4)),
      ),
      HistoryEntry(
        id: 'H-005',
        deliveryNoteNumber: 'BL-2026-0430',
        clientName: 'GROUPE SCOLAIRE EXCELLENCE',
        address: 'Yopougon, Rue des Écoles',
        tourReference: 'TRN-2026-0826',
        amount: 33000,
        status: HistoryStatus.failed,
        completedAt: now.subtract(const Duration(days: 2, hours: 1)),
        failureReason: 'Adresse introuvable',
      ),
      HistoryEntry(
        id: 'H-006',
        deliveryNoteNumber: 'BL-2026-0422',
        clientName: 'PHARMACIE MODERNE ADJAMÉ',
        address: 'Adjamé, Marché',
        tourReference: 'TRN-2026-0825',
        amount: 58000,
        status: HistoryStatus.delivered,
        completedAt: now.subtract(const Duration(days: 3, hours: 6)),
      ),
      HistoryEntry(
        id: 'H-007',
        deliveryNoteNumber: 'BL-2026-0415',
        clientName: 'MAIRIE DE KOUMASSI',
        address: 'Koumassi, Boulevard VGE',
        tourReference: 'TRN-2026-0824',
        amount: 95000,
        status: HistoryStatus.delivered,
        completedAt: now.subtract(const Duration(days: 4, hours: 3)),
      ),
      HistoryEntry(
        id: 'H-008',
        deliveryNoteNumber: 'BL-2026-0410',
        clientName: 'CENTRE CULTUREL ABOBO',
        address: 'Abobo, Rue de la Paix',
        tourReference: 'TRN-2026-0823',
        amount: 21000,
        status: HistoryStatus.failed,
        completedAt: now.subtract(const Duration(days: 5, hours: 2)),
        failureReason: 'Colis endommagé au départ',
      ),
    ];
  }
}
