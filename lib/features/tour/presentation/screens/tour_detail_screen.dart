import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/app_dialogs.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../../../core/widgets/ldf_pattern_background.dart';
import '../../../dashboard/presentation/bloc/dashboard_cubit.dart';
import '../../../delivery/domain/entities/delivery.dart';
import '../../../delivery/presentation/bloc/delivery_cubit.dart';
import '../../domain/entities/tour_entity.dart';
import '../../data/datasources/tour_local_data_source.dart';

class TourDetailScreen extends StatefulWidget {
  final TourEntity tour;

  const TourDetailScreen({super.key, required this.tour});

  @override
  State<TourDetailScreen> createState() => _TourDetailScreenState();
}

class _TourDetailScreenState extends State<TourDetailScreen> {
  late List<Delivery> _deliveries;
  final _deliveryCubit = getIt<DeliveryCubit>();
  String? _validatingDeliveryId;

  @override
  void initState() {
    super.initState();
    _deliveries = List.from(widget.tour.deliveries);
  }

  @override
  void dispose() {
    _deliveryCubit.close();
    super.dispose();
  }

  Future<void> _handleValidateDelivery(Delivery delivery) async {
    final blNumber = delivery.deliveryNoteNumber.replaceFirst('BL-', '').trim();
    final confirmed = await AppDialogs.showDeliveryConfirmationDialog(
      context,
      blNumber: blNumber,
    );

    if (confirmed && mounted) {
      setState(() {
        _validatingDeliveryId = delivery.id;
      });
      await _deliveryCubit.validateDelivery(delivery, notes: '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final completedDeliveries = _deliveries
        .where((d) => d.status == DeliveryStatus.delivered)
        .length;
    final totalDeliveries = _deliveries.length;
    final progress = totalDeliveries > 0
        ? completedDeliveries / totalDeliveries
        : 0.0;

    return BlocProvider.value(
      value: _deliveryCubit,
      child: BlocListener<DeliveryCubit, DeliveryState>(
        listener: (context, state) {
          if (state is DeliveryUpdated) {
            final updatedId = state.delivery.id;
            setState(() {
              _validatingDeliveryId = null;
              final idx = _deliveries.indexWhere((d) => d.id == updatedId);
              if (idx != -1) {
                _deliveries[idx] = _deliveries[idx].copyWith(
                  status: DeliveryStatus.delivered,
                  scheduledTime: DateTime.now(),
                );
              }
            });
            final isOffline = getIt<TourLocalDataSource>().isPendingSync(
              updatedId,
            );
            AppFeedback.success(
              context,
              isOffline
                  ? 'Livraison enregistrée en local (mode hors-ligne).\nElle sera synchronisée dès le retour du réseau.'
                  : 'Livraison confirmée avec succès',
              title: isOffline
                  ? 'Enregistrée hors-ligne'
                  : 'Livraison confirmée',
            );
            try {
              getIt<DashboardCubit>().fetchStats();
            } catch (_) {}
          } else if (state is DeliveryError) {
            setState(() {
              _validatingDeliveryId = null;
            });
            AppFeedback.error(
              context,
              state.message,
              title: 'Validation impossible',
            );
          }
        },
        child: LdfPatternBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Column(
              children: [
                // ── AppBar standardisée ─────────────────────────────────────────────
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                      // ↑ STANDARD : horizontal 16px
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Ligne 1 : Bouton retour + Titre
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  AppIcons.back,
                                  color: Colors.white,
                                ),
                                onPressed: () => context.pop(),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 40,
                                  minHeight: 40,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.tour.displayName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Ligne 2 : Date · Heure · Référence
                          Row(
                            children: [
                              const Icon(
                                AppIcons.calendar,
                                color: AppColors.navBarYellow,
                                size: 14,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                DateFormat('dd MMM yyyy', 'fr_FR')
                                    .format(widget.tour.date),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (widget.tour.heureDepart.isNotEmpty) ...[
                                Text(
                                  ' · ',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontSize: 13,
                                  ),
                                ),
                                const Icon(
                                  AppIcons.clock,
                                  color: Colors.white,
                                  size: 13,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.tour.heureDepart,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                              Text(
                                ' · ',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                widget.tour.reference,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Ligne 3 : Véhicule · Nombre de livraisons
                          Row(
                            children: [
                              const Icon(
                                AppIcons.car,
                                color: AppColors.navBarYellow,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.tour.vehiclePlate,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                ' · ',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                '$totalDeliveries livraison${totalDeliveries > 1 ? 's' : ''}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Carte de progression ────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border, width: 0.8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '📊 Progression',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: progress == 1.0
                                    ? AppColors.successSoft
                                    : AppColors.primarySoft,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$completedDeliveries/$totalDeliveries livrées',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: progress == 1.0
                                      ? AppColors.success
                                      : AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: AppColors.border,
                            color: progress == 1.0
                                ? AppColors.success
                                : AppColors.primary,
                            minHeight: 10,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${(progress * 100).toStringAsFixed(0)}% complété',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Liste des livraisons ────────────────────────────────────────────
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    // ↑ STANDARD : padding 16px aligné avec l'AppBar
                    itemCount: _deliveries.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    // ↑ STANDARD : 12px entre les cartes
                    itemBuilder: (context, index) {
                      final delivery = _deliveries[index];
                      return _DeliveryListCard(
                        delivery: delivery,
                        index: index + 1,
                        total: totalDeliveries,
                        isValidating: _validatingDeliveryId == delivery.id,
                        onValidate: () => _handleValidateDelivery(delivery),
                        onTap: () async {
                          final result = await context.push(
                            '/delivery-detail',
                            extra: delivery,
                          );
                          /*if (result == true && mounted) {
                          setState(() {
                            _deliveries[index] = delivery.copyWith(
                              status: DeliveryStatus.delivered,
                              scheduledTime: DateTime.now(),
                            );
                          });
                          try {
                            getIt<DashboardCubit>().fetchStats();
                          } catch (_) {}
                        }*/
                          if (result is Delivery && mounted) {
                            setState(() {
                              _deliveries[index] =
                                  result; // Met à jour avec le vrai statut (Reprogrammé ou Livré)
                            });
                            try {
                              getIt<DashboardCubit>().fetchStats();
                            } catch (_) {}
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DeliveryListCard extends StatelessWidget {
  final Delivery delivery;
  final int index;
  final int total;
  final bool isValidating;
  final VoidCallback onValidate;
  final VoidCallback onTap;

  const _DeliveryListCard({
    required this.delivery,
    required this.index,
    required this.total,
    required this.isValidating,
    required this.onValidate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDelivered = delivery.status == DeliveryStatus.delivered;
    final isInProgress = delivery.status == DeliveryStatus.inProgress;

    return RepaintBoundary(
      // ↑ Optimise les performances en isolant le repaint
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isInProgress ? AppColors.primary : AppColors.border,
              width: isInProgress ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Indicateur de statut (barre verticale colorée)
              Container(
                width: 4,
                height: 54,
                decoration: BoxDecoration(
                  color: isDelivered
                      ? AppColors.success
                      : (delivery.status == DeliveryStatus.cancelled
                            ? AppColors.warning
                            : AppColors.textSecondary.withAlpha(80)),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),

              // Contenu principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ligne 1 : Nom client
                    Text(
                      delivery.clientName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Ligne 2 : Adresse
                    Row(
                      children: [
                        const Icon(
                          AppIcons.mapPin,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            delivery.address,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Ligne 3 : Heure + BL
                    Row(
                      children: [
                        const Icon(
                          AppIcons.clock,
                          size: 13,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          DateFormat('HH:mm').format(delivery.scheduledTime),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (delivery.deliveryNoteNumber.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              delivery.deliveryNoteNumber,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (delivery.status == DeliveryStatus.cancelled &&
                        delivery.notes.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warningSoft,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.warning.withAlpha(80),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          'Motif : ${delivery.notes}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.warning,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStatusBadge(delivery.status),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.border,
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      DateFormat('dd/MM/yyyy').format(delivery.scheduledTime),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),

              // Bouton d'action direct (Valider / Livrée) comme sur le web
              /*if (isDelivered)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.successSoft,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.success.withAlpha(60)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        AppIcons.checkCircle,
                        size: 13,
                        color: AppColors.success,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Livrée',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: isValidating ? null : onValidate,
                  icon: isValidating
                      ? const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(AppIcons.checkCircle, size: 13),
                  label: Text(isValidating ? '...' : 'Valider'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),*/
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(DeliveryStatus status) {
    final isPendingSync = getIt<TourLocalDataSource>().isPendingSync(
      delivery.id,
    );

    final (
      Color color,
      Color bgColor,
      IconData icon,
      String label,
    ) = switch (status) {
      DeliveryStatus.delivered =>
        isPendingSync
            ? (
                AppColors.warning,
                AppColors.warningSoft,
                AppIcons.cloudOff,
                'Livré (En attente sync)',
              )
            : (
                AppColors.success,
                AppColors.successSoft,
                AppIcons.checkCircle,
                'Livré',
              ),
      DeliveryStatus.cancelled => (
        AppColors.warning,
        AppColors.warningSoft,
        AppIcons.clock,
        'Reprogrammé',
      ),
      _ => (
        AppColors.textSecondary,
        AppColors.background,
        AppIcons.clock,
        'En attente',
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(70)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
