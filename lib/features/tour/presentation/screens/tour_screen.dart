import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_gradients.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/tour_entity.dart';
import '../bloc/tour_cubit.dart';

class TourScreen extends StatelessWidget {
  const TourScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<TourCubit>()..fetchTours(),
      child: const TourView(),
    );
  }
}

class TourView extends StatelessWidget {
  const TourView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Header fixe gradient vert ──────────────────────────────────────
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
                padding: const EdgeInsets.fromLTRB(20, 12, 8, 20),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mes Tournées',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Suivi de vos trajets de livraison',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Bouton filtre
                    BlocBuilder<TourCubit, TourState>(
                      builder: (context, state) => IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(30),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            AppIcons.filter,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        onPressed: () {
                          // TODO: Afficher le filtre
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Liste des tournées ─────────────────────────────────────────────
          Expanded(
            child: BlocBuilder<TourCubit, TourState>(
              builder: (context, state) {
                if (state is TourLoading || state is TourInitial) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  );
                }

                if (state is TourError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          AppIcons.error,
                          color: AppColors.error,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Erreur : ${state.message}',
                          style: const TextStyle(color: AppColors.error),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                if (state is TourLoaded) {
                  final tours = state.tours;
                  if (tours.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            AppIcons.truck,
                            size: 64,
                            color: AppColors.textSecondary.withAlpha(80),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucune tournée pour le moment.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async =>
                        context.read<TourCubit>().fetchTours(),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                      itemCount: tours.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 14),
                      itemBuilder: (context, index) =>
                          _TourCard(tour: tours[index]),
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

// ─── Card d'une tournée ───────────────────────────────────────────────────────
class _TourCard extends StatelessWidget {
  final TourEntity tour;
  const _TourCard({required this.tour});

  @override
  Widget build(BuildContext context) {
    final completedDeliveries =
        tour.deliveries.where((d) => d.status.name == 'delivered').length;
    final totalDeliveries = tour.deliveries.length;
    final progress =
        totalDeliveries > 0 ? completedDeliveries / totalDeliveries : 0.0;
    final progressLabel = '$completedDeliveries/$totalDeliveries livrées';

    final statusColor = _statusColor(tour.status);
    final statusBgColor = _statusBgColor(tour.status);
    final statusLabel = _statusLabel(tour.status);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => context.push('/tour-detail', extra: tour),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Bandeau supérieur coloré selon le statut ──────────────────
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Référence tournée
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            AppIcons.route,
                            size: 16,
                            color: statusColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          tour.reference,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    // Badge statut
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: statusColor.withAlpha(80), width: 1),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Corps de la card ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom de tournée
                    Text(
                      'Tournée ${tour.agence}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 6),

                    // Véhicule
                    Row(
                      children: [
                        const Icon(
                          AppIcons.car,
                          size: 15,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          tour.vehiclePlate,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),
                    const Divider(height: 1),
                    const SizedBox(height: 14),

                    // ── Progression ──────────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              AppIcons.truck,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              progressLabel,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const Icon(
                          AppIcons.chevronRight,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Barre de progression verte
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progress == 1.0
                              ? AppColors.success
                              : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(TourStatus s) => switch (s) {
        TourStatus.pending    => AppColors.warning,
        TourStatus.inProgress => AppColors.primary,
        TourStatus.completed  => AppColors.success,
        TourStatus.cancelled  => AppColors.error,
      };

  Color _statusBgColor(TourStatus s) => switch (s) {
        TourStatus.pending    => AppColors.warningSoft,
        TourStatus.inProgress => AppColors.primarySoft,
        TourStatus.completed  => AppColors.successSoft,
        TourStatus.cancelled  => AppColors.errorSoft,
      };

  String _statusLabel(TourStatus s) => switch (s) {
        TourStatus.pending    => 'Programmée',
        TourStatus.inProgress => 'En cours',
        TourStatus.completed  => 'Terminée',
        TourStatus.cancelled  => 'Annulée',
      };
}
