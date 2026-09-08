import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../domain/entities/tour_entity.dart';
import '../../../delivery/domain/entities/delivery.dart';

class TourDetailScreen extends StatelessWidget {
  final TourEntity tour;

  const TourDetailScreen({super.key, required this.tour});

  @override
  Widget build(BuildContext context) {
    final completedDeliveries = tour.deliveries
        .where((d) => d.status.name == 'delivered')
        .length;
    final totalDeliveries = tour.deliveries.length;
    final progress = totalDeliveries > 0
        ? completedDeliveries / totalDeliveries
        : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── AppBar standardisée ─────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
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
                            'Tournée ${tour.agence}',
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
                          tour.reference,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          ' · ',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
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
                          tour.vehiclePlate,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          ' · ',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '$totalDeliveries livraison${totalDeliveries > 1 ? 's' : ''}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
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
                    color: Colors.black.withOpacity(0.04),
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
              itemCount: tour.deliveries.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              // ↑ STANDARD : 12px entre les cartes
              itemBuilder: (context, index) {
                final delivery = tour.deliveries[index];
                return _DeliveryListCard(
                  delivery: delivery,
                  index: index + 1,
                  total: totalDeliveries,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryListCard extends StatelessWidget {
  final Delivery delivery;
  final int index;
  final int total;

  const _DeliveryListCard({
    required this.delivery,
    required this.index,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final isDelivered = delivery.status == DeliveryStatus.delivered;
    final isInProgress = delivery.status == DeliveryStatus.inProgress;
    final isPending = delivery.status == DeliveryStatus.pending;

    return RepaintBoundary(
      // ↑ Optimise les performances en isolant le repaint
      child: GestureDetector(
        onTap: () => context.push('/delivery-detail', extra: delivery),
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
              color: Colors.black.withOpacity(0.04),
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
              height: 50,
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
                  // Ligne 1 : Nom client + Badge statut
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          delivery.clientName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isDelivered
                              ? AppColors.successSoft
                              : isInProgress
                                  ? AppColors.primarySoft
                                  : AppColors.warningSoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isDelivered
                              ? 'Livré ✓'
                              : isInProgress
                                  ? 'En cours'
                                  : 'En attente',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isDelivered
                                ? AppColors.success
                                : isInProgress
                                    ? AppColors.primary
                                    : AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
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
                  const SizedBox(height: 6),
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
                      const SizedBox(width: 12),
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
                            'BL: ${delivery.deliveryNoteNumber}',
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

            // Chevron
            const Icon(
              AppIcons.chevronRight,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
      ),
    );
  }
}
