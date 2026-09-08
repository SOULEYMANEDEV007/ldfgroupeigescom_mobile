import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_gradients.dart';
import '../../../../core/constants/app_icons.dart';
import '../../domain/entities/history_entry.dart';
import '../bloc/history_cubit.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _HistoryView();
  }
}

class _HistoryView extends StatefulWidget {
  const _HistoryView();

  @override
  State<_HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<_HistoryView> {
  final _searchController = TextEditingController();
  HistoryStatus? _selectedStatus;
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    context.read<HistoryCubit>().applyFilters(
          status: _selectedStatus,
          query: _searchController.text,
          from: _fromDate,
          to: _toDate,
        );
  }

  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() => isFrom ? _fromDate = picked : _toDate = picked);
    _applyFilters();
  }

  void _clearAll() {
    setState(() {
      _searchController.clear();
      _selectedStatus = null;
      _fromDate = null;
      _toDate = null;
    });
    context.read<HistoryCubit>().clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Header gradient vert avec bouton retour ────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: AppGradients.primaryHeader,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                // ↑ STANDARD : horizontal 16px, vertical 12px, bottom 20px
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Barre titre avec retour ─────────────────────────────
                    Row(
                      children: [
                        // Bouton retour
                        IconButton(
                          onPressed: () => context.pop(),
                          icon: const Icon(
                            AppIcons.back,
                            color: Colors.white,
                            size: 22,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Historique',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  height: 1.2,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Toutes vos livraisons terminées',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Compteur résultats
                        BlocBuilder<HistoryCubit, HistoryState>(
                          builder: (context, state) {
                            if (state is! HistoryLoaded) {
                              return const SizedBox.shrink();
                            }
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(30),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${state.filtered.length} résultat(s)',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ── Barre de recherche ──────────────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (v) {
                          setState(() {});
                          _applyFilters();
                        },
                        decoration: InputDecoration(
                          hintText: 'Rechercher N° BL ou nom client…',
                          hintStyle: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 13),
                          prefixIcon: const Icon(AppIcons.search,
                              color: AppColors.textSecondary, size: 18),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(AppIcons.close,
                                      color: AppColors.textSecondary,
                                      size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                    _applyFilters();
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Filtres chips ─────────────────────────────────────────────────
          _FilterBar(
            selectedStatus: _selectedStatus,
            fromDate: _fromDate,
            toDate: _toDate,
            onStatusChanged: (s) {
              setState(() => _selectedStatus = s);
              _applyFilters();
            },
            onFromDate: () => _pickDate(true),
            onToDate: () => _pickDate(false),
            onClear: _clearAll,
          ),

          // ── Liste ─────────────────────────────────────────────────────────
          Expanded(
            child: BlocBuilder<HistoryCubit, HistoryState>(
              builder: (context, state) {
                if (state is HistoryLoading || state is HistoryInitial) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary));
                }

                if (state is HistoryError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(AppIcons.error,
                            color: AppColors.error, size: 48),
                        const SizedBox(height: 12),
                        Text('Erreur : ${state.message}',
                            style: const TextStyle(color: AppColors.error),
                            textAlign: TextAlign.center),
                      ],
                    ),
                  );
                }

                if (state is HistoryLoaded) {
                  if (state.filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(AppIcons.inbox,
                              size: 64,
                              color: AppColors.textSecondary.withAlpha(80)),
                          const SizedBox(height: 16),
                          const Text('Aucune livraison trouvée.',
                              style:
                                  TextStyle(color: AppColors.textSecondary)),
                          if (state.hasActiveFilters) ...[
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _clearAll,
                              child: const Text('Effacer les filtres',
                                  style:
                                      TextStyle(color: AppColors.primary)),
                            ),
                          ],
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () =>
                        context.read<HistoryCubit>().fetchHistory(),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      physics: const AlwaysScrollableScrollPhysics(),
                      // ↑ Permet le scroll même avec peu d'items
                      itemCount: state.filtered.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) => _HistoryCard(
                        entry: state.filtered[index],
                        onTap: () => context.push(
                          '/history-detail',
                          extra: state.filtered[index],
                        ),
                      ),
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Barre de filtres ─────────────────────────────────────────────────────────
class _FilterBar extends StatelessWidget {
  final HistoryStatus? selectedStatus;
  final DateTime? fromDate;
  final DateTime? toDate;
  final ValueChanged<HistoryStatus?> onStatusChanged;
  final VoidCallback onFromDate;
  final VoidCallback onToDate;
  final VoidCallback onClear;

  const _FilterBar({
    required this.selectedStatus,
    required this.fromDate,
    required this.toDate,
    required this.onStatusChanged,
    required this.onFromDate,
    required this.onToDate,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM');
    final hasAnyFilter =
        selectedStatus != null || fromDate != null || toDate != null;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      color: AppColors.background,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _StatusChip(
              label: 'Tous',
              selected: selectedStatus == null,
              color: AppColors.primary,
              onTap: () => onStatusChanged(null),
            ),
            const SizedBox(width: 8),
            _StatusChip(
              label: 'Livré',
              selected: selectedStatus == HistoryStatus.delivered,
              color: AppColors.success,
              onTap: () => onStatusChanged(
                selectedStatus == HistoryStatus.delivered
                    ? null
                    : HistoryStatus.delivered,
              ),
            ),
            const SizedBox(width: 8),
            _StatusChip(
              label: 'Échec',
              selected: selectedStatus == HistoryStatus.failed,
              color: AppColors.error,
              onTap: () => onStatusChanged(
                selectedStatus == HistoryStatus.failed
                    ? null
                    : HistoryStatus.failed,
              ),
            ),
            const SizedBox(width: 8),
            _DateChip(
              label: fromDate != null
                  ? 'Depuis ${fmt.format(fromDate!)}'
                  : 'Date début',
              active: fromDate != null,
              onTap: onFromDate,
            ),
            const SizedBox(width: 8),
            _DateChip(
              label: toDate != null
                  ? "Jusqu'au ${fmt.format(toDate!)}"
                  : 'Date fin',
              active: toDate != null,
              onTap: onToDate,
            ),
            if (hasAnyFilter) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onClear,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.errorSoft,
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: AppColors.error.withAlpha(80)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(AppIcons.close,
                          size: 13, color: AppColors.error),
                      SizedBox(width: 4),
                      Text(
                        'Effacer',
                        style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _StatusChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? color : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _DateChip(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primarySoft : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: active ? AppColors.primary : AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(AppIcons.calendar,
                size: 13,
                color: active
                    ? AppColors.primary
                    : AppColors.textSecondary),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: active
                    ? AppColors.primary
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Card historique (tappable) ───────────────────────────────────────────────
class _HistoryCard extends StatelessWidget {
  final HistoryEntry entry;
  final VoidCallback onTap;
  const _HistoryCard({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDelivered = entry.status == HistoryStatus.delivered;
    final statusColor = isDelivered ? AppColors.success : AppColors.error;
    final statusBg =
        isDelivered ? AppColors.successSoft : AppColors.errorSoft;
    final statusLabel = isDelivered ? 'Livré' : 'Échec';
    final statusIcon =
        isDelivered ? AppIcons.checkCircle : AppIcons.error;

    return RepaintBoundary(
      // ↑ Optimise les performances en isolant le repaint
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withAlpha(5),
                  blurRadius: 8,
                  offset: const Offset(0, 2)),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── N° BL + badge statut ────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(AppIcons.receipt,
                              size: 14, color: AppColors.primary),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          entry.deliveryNoteNumber,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon,
                              size: 13, color: statusColor),
                          const SizedBox(width: 4),
                          Text(statusLabel,
                              style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // ── Nom client ──────────────────────────────────────────
                Text(
                  entry.clientName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                ),
                const SizedBox(height: 4),

                // ── Adresse ─────────────────────────────────────────────
                Row(
                  children: [
                    const Icon(AppIcons.mapPin,
                        size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        entry.address,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                // ── Raison échec ─────────────────────────────────────────
                if (!isDelivered && entry.failureReason != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.errorSoft,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(AppIcons.info,
                            size: 13, color: AppColors.error),
                        const SizedBox(width: 5),
                        Text(
                          entry.failureReason!,
                          style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 12,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 10),

                // ── Pied de card : tournée (gauche) | montant + date (droite) ──
                // Deux blocs séparés pour éviter tout overflow
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Référence tournée — absorbe l'espace libre
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(AppIcons.route,
                              size: 13, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              entry.tourReference,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Bloc droit : montant + date empilés verticalement
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          NumberFormat.currency(
                            locale: 'fr_FR',
                            symbol: 'FCFA',
                            decimalDigits: 0,
                          ).format(entry.amount),
                          style: TextStyle(
                            color: isDelivered
                                ? AppColors.success
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('dd/MM/yy').format(entry.completedAt),
                          style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(width: 6),
                    const Icon(AppIcons.chevronRight,
                        size: 14, color: AppColors.textSecondary),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
