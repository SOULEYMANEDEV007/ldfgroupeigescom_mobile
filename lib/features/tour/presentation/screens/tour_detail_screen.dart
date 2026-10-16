import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/app_dialogs.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../../dashboard/presentation/bloc/dashboard_cubit.dart';
import '../../../delivery/domain/entities/delivery.dart';
import '../../../delivery/presentation/bloc/delivery_cubit.dart';
import '../../domain/entities/tour_entity.dart';

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
      await _deliveryCubit.validateDelivery(
        delivery,
        notes: '',
      );
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
                );
              }
            });
            AppFeedback.success(context, 'Livraison confirmée avec succès');
            try {
              getIt<DashboardCubit>().fetchStats();
            } catch (_) {}
          } else if (state is DeliveryError) {
            setState(() {
              _validatingDeliveryId = null;
            });
            AppFeedback.error(context, state.message);
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
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
                              icon: const Icon(AppIcons.back, color: Colors.white),
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
                        // Ligne 2 : Référence · Plaque · Nombre de livraisons
                        Row(
                          children: [
                            Text(
                              widget.tour.reference,
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
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
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
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
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
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
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
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
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
                        if (result == true && mounted) {
                          setState(() {
                            _deliveries[index] = delivery.copyWith(
                              status: DeliveryStatus.delivered,
                            );
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
                      : isInProgress
                          ? AppColors.primary
                          : AppColors.warning,
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
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),

                    // Ligne 2 : Adresse
                    Row(
                      children: [
                        const Icon(
                          AppIcons.mapPin,
                          size: 13,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            delivery.address,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),

                    // Ligne 3 : Heure + BL
                    Row(
                      children: [
                        const Icon(
                          AppIcons.clock,
                          size: 12,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('HH:mm').format(delivery.scheduledTime),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (delivery.deliveryNoteNumber.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              delivery.deliveryNoteNumber,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Bouton d'action direct (Valider / Livrée) comme sur le web
              if (isDelivered)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.successSoft,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.success.withAlpha(60),
                    ),
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
                ),
            ],
          ),
        ),
      ),
    );
  }
}
