import '../entities/history_entry.dart';

abstract class HistoryRepository {
  /// Retourne toutes les livraisons terminées du livreur connecté.
  Future<List<HistoryEntry>> getHistory();
}
