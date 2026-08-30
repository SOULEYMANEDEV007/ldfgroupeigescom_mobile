part of 'history_cubit.dart';

abstract class HistoryState extends Equatable {
  const HistoryState();
  @override
  List<Object?> get props => [];
}

class HistoryInitial extends HistoryState {
  const HistoryInitial();
}

class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

class HistoryLoaded extends HistoryState {
  final List<HistoryEntry> all;
  final List<HistoryEntry> filtered;
  final HistoryStatus? activeStatus;
  final String? activeQuery;
  final DateTime? activeFrom;
  final DateTime? activeTo;

  const HistoryLoaded({
    required this.all,
    required this.filtered,
    this.activeStatus,
    this.activeQuery,
    this.activeFrom,
    this.activeTo,
  });

  bool get hasActiveFilters =>
      activeStatus != null ||
      (activeQuery != null && activeQuery!.isNotEmpty) ||
      activeFrom != null ||
      activeTo != null;

  @override
  List<Object?> get props =>
      [all, filtered, activeStatus, activeQuery, activeFrom, activeTo];
}

class HistoryError extends HistoryState {
  final String message;
  const HistoryError(this.message);
  @override
  List<Object?> get props => [message];
}
