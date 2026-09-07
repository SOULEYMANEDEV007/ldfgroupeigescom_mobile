import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/history_entry.dart';
import '../../domain/repositories/history_repository.dart';

part 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  final HistoryRepository _repository;

  HistoryCubit(this._repository) : super(const HistoryInitial());

  Future<void> fetchHistory() async {
    emit(const HistoryLoading());
    try {
      final entries = await _repository.getHistory();
      emit(HistoryLoaded(all: entries, filtered: entries));
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }

  /// Applique les filtres : statut, texte libre (N° BL ou nom client), plage de dates.
  void applyFilters({
    HistoryStatus? status,
    String? query,
    DateTime? from,
    DateTime? to,
  }) {
    final current = state;
    if (current is! HistoryLoaded) return;

    var result = current.all;

    if (status != null) {
      result = result.where((e) => e.status == status).toList();
    }

    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      result = result
          .where((e) =>
              e.deliveryNoteNumber.toLowerCase().contains(q) ||
              e.clientName.toLowerCase().contains(q))
          .toList();
    }

    if (from != null) {
      result = result
          .where((e) => e.completedAt.isAfter(
                from.subtract(const Duration(seconds: 1)),
              ))
          .toList();
    }

    if (to != null) {
      final endOfDay = DateTime(to.year, to.month, to.day, 23, 59, 59);
      result =
          result.where((e) => e.completedAt.isBefore(endOfDay)).toList();
    }

    emit(HistoryLoaded(
      all: current.all,
      filtered: result,
      activeStatus: status,
      activeQuery: query,
      activeFrom: from,
      activeTo: to,
    ));
  }

  void clearFilters() {
    final current = state;
    if (current is! HistoryLoaded) return;
    emit(HistoryLoaded(all: current.all, filtered: current.all));
  }
}
