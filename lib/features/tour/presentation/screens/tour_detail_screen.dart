import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
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
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180.0,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Tournée ${tour.agence}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        tour.reference,
                        style: TextStyle(
                          color: Colors.white.withAlpha(200),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.directions_car_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            tour.vehiclePlate,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.white.withAlpha(50),
                          color: AppColors.navBarYellow,
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$completedDeliveries sur $totalDeliveries livraisons terminées',
                        style: TextStyle(
                          color: Colors.white.withAlpha(200),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final delivery = tour.deliveries[index];
                return _DeliveryListCard(delivery: delivery, index: index + 1);
              }, childCount: tour.deliveries.length),
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

  const _DeliveryListCard({required this.delivery, required this.index});

  @override
  Widget build(BuildContext context) {
    final isDelivered = delivery.status == DeliveryStatus.delivered;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.push('/delivery-detail', extra: delivery);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Indicateur visuel (Numéro + Ligne si on veut)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDelivered
                      ? AppColors.successSoft
                      : AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isDelivered
                      ? const Icon(
                          Icons.check_rounded,
                          color: AppColors.success,
                        )
                      : Text(
                          '$index',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      delivery.clientName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            delivery.address,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time_rounded, size: 12),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat(
                                  'HH:mm',
                                ).format(delivery.scheduledTime),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (delivery.deliveryNoteNumber.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accentBlueSoft,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'BL: ${delivery.deliveryNoteNumber}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.accentBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
