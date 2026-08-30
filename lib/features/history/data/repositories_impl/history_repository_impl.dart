import '../../domain/entities/history_entry.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/history_mock_datasource.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryMockDatasource _datasource;

  HistoryRepositoryImpl(this._datasource);

  @override
  Future<List<HistoryEntry>> getHistory() => _datasource.fetchHistory();
}
