import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_gradients.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../domain/entities/delivery.dart';
import '../bloc/delivery_cubit.dart';

const _defaultLatLng = LatLng(5.3600, -4.0083);

class DeliveryDetailScreen extends StatelessWidget {
  final Delivery delivery;
  const DeliveryDetailScreen({super.key, required this.delivery});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DeliveryCubit>(),
      child: _DeliveryDetailView(delivery: delivery),
    );
  }
}

class _DeliveryDetailView extends StatelessWidget {
  final Delivery delivery;
  const _DeliveryDetailView({required this.delivery});

  @override
  Widget build(BuildContext context) {
    return BlocListener<DeliveryCubit, DeliveryState>(
      listener: (context, state) {
        if (state is DeliveryUpdated) {
          AppFeedback.success(context, 'Tournée démarrée !');
          context.pop();
        }
        if (state is DeliveryUpdateError) {
          AppFeedback.error(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            _DeliveryHeader(delivery: delivery),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoStrip(delivery: delivery),
                    _MapSection(delivery: delivery),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionLabel('Détails de la livraison'),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _KpiCard(
                                  icon: AppIcons.clock,
                                  iconColor: AppColors.accentBlue,
                                  iconBgColor: AppColors.accentBlueSoft,
                                  label: 'Heure prévue',
                                  value: DateFormat('HH:mm')
                                      .format(delivery.scheduledTime),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _KpiCard(
                                  icon: AppIcons.receipt,
                                  iconColor: AppColors.primary,
                                  iconBgColor: AppColors.primarySoft,
                                  label: 'N° BL',
                                  value: delivery.deliveryNoteNumber,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _KpiCard(
                                  icon: AppIcons.scale,
                                  iconColor: AppColors.warning,
                                  iconBgColor: AppColors.warningSoft,
                                  label: 'Volume/Poids',
                                  value: '${delivery.weight} kg',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _KpiCard(
                                  icon: AppIcons.wallet,
                                  iconColor: AppColors.success,
                                  iconBgColor: AppColors.successSoft,
                                  label: 'Montant',
                                  value: NumberFormat.currency(
                                    locale: 'fr_FR',
                                    symbol: 'FCFA',
                                    decimalDigits: 0,
                                  ).format(delivery.amount),
                                ),
                              ),
                            ],
                          ),

                          // ── Timeline de suivi ────────────────────────────
                          const SizedBox(height: 20),
                          _sectionLabel('Suivi de la livraison'),
                          const SizedBox(height: 10),
                          _StatusTimeline(status: delivery.status),

                          if (delivery.notes.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            _sectionLabel('Notes du client'),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.amber.withAlpha(20),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.amber.withAlpha(80)),
                              ),
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Icon(AppIcons.note,
                                      color: Colors.amber, size: 18),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      delivery.notes,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(height: 1.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  context.push('/delivery-note'),
                              icon: const Icon(AppIcons.pdf, size: 18),
                              label: const Text('Voir le Bon de Livraison'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(
                                    color: AppColors.primary),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _StickyActionBar(delivery: delivery),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) => Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.bold,
          fontSize: 11,
          letterSpacing: 1.2,
        ),
      );
}

// ─── Header ───────────────────────────────────────────────────────────────────
class _DeliveryHeader extends StatelessWidget {
  final Delivery delivery;
  const _DeliveryHeader({required this.delivery});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.primaryHeader),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(AppIcons.back,
                        color: Colors.white, size: 22),
                  ),
                  const Expanded(
                    child: Text(
                      'Détail livraison',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO: url_launcher tel:${delivery.phone}
                    },
                    child: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: const BoxDecoration(
                        color: AppColors.navBarYellow,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(AppIcons.phoneCall,
                          size: 20, color: AppColors.primaryDark),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(AppIcons.person,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DESTINATAIRE',
                            style: TextStyle(
                              color: Colors.white.withAlpha(160),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            delivery.clientName.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(AppIcons.mapPin,
                                  size: 13,
                                  color: AppColors.navBarYellow),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  delivery.address,
                                  style: TextStyle(
                                    color: Colors.white.withAlpha(200),
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(AppIcons.phone,
                                  size: 13,
                                  color: AppColors.navBarYellow),
                              const SizedBox(width: 4),
                              Text(
                                delivery.phone,
                                style: TextStyle(
                                  color: Colors.white.withAlpha(200),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
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
}

// ─── Info Strip ───────────────────────────────────────────────────────────────
class _InfoStrip extends StatelessWidget {
  final Delivery delivery;
  const _InfoStrip({required this.delivery});

  @override
  Widget build(BuildContext context) {
    final (statusLabel, statusColor, statusBg) = switch (delivery.status) {
      DeliveryStatus.pending =>
        ('En attente', AppColors.warning, AppColors.warningSoft),
      DeliveryStatus.inProgress =>
        ('En cours', AppColors.accentBlue, AppColors.accentBlueSoft),
      DeliveryStatus.delivered =>
        ('Livré ✓', AppColors.success, AppColors.successSoft),
      DeliveryStatus.cancelled =>
        ('Annulé', AppColors.error, AppColors.errorSoft),
    };

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(6),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _StripItem(
              label: 'État',
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(statusLabel,
                    style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11)),
              ),
            ),
          ),
          _VerticalDivider(),
          Expanded(
            child: _StripItem(
              label: 'Date planifiée',
              child: Text(
                DateFormat('dd/MM/yy\nHH:mm').format(delivery.scheduledTime),
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 12, height: 1.4),
              ),
            ),
          ),
          _VerticalDivider(),
          Expanded(
            child: _StripItem(
              label: 'Charge',
              child: Text(
                '${delivery.weight} kg',
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StripItem extends StatelessWidget {
  final String label;
  final Widget child;
  const _StripItem({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: AppColors.border,
    );
  }
}

// ─── Carte GPS ────────────────────────────────────────────────────────────────
class _MapSection extends StatelessWidget {
  final Delivery delivery;
  const _MapSection({required this.delivery});

  @override
  Widget build(BuildContext context) {
    const point = _defaultLatLng;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          FlutterMap(
            options: const MapOptions(
              initialCenter: point,
              initialZoom: 14.5,
              interactionOptions: InteractionOptions(
                flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.ldf.igescom_mobile',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: point,
                    width: 48,
                    height: 48,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 3)),
                        ],
                      ),
                      child: const Icon(AppIcons.truck,
                          color: Colors.white, size: 24),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withAlpha(160),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  const Icon(AppIcons.mapPin,
                      color: AppColors.navBarYellow, size: 15),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      delivery.address,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── KPI Card ─────────────────────────────────────────────────────────────────
class _KpiCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String label;
  final String value;
  const _KpiCard({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(height: 10),
          Text(label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  )),
          const SizedBox(height: 3),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

// ─── Barre d'actions sticky ───────────────────────────────────────────────────
class _StickyActionBar extends StatelessWidget {
  final Delivery delivery;
  const _StickyActionBar({required this.delivery});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeliveryCubit, DeliveryState>(
      builder: (context, state) {
        final isLoading = state is DeliveryUpdating;

        if (delivery.status == DeliveryStatus.delivered ||
            delivery.status == DeliveryStatus.cancelled) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: EdgeInsets.fromLTRB(16, 12, 16,
              MediaQuery.of(context).padding.bottom + 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withAlpha(18),
                  blurRadius: 16,
                  offset: const Offset(0, -3)),
            ],
          ),
          child: delivery.status == DeliveryStatus.pending
              ? ElevatedButton.icon(
                  onPressed: isLoading
                      ? null
                      : () => context
                          .read<DeliveryCubit>()
                          .startDelivery(delivery),
                  icon: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(AppIcons.play),
                  label: Text(isLoading
                      ? 'Démarrage...'
                      : 'Démarrer la livraison'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navBarYellow,
                    foregroundColor: AppColors.primaryDark,
                    minimumSize: const Size(double.infinity, 54),
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                )
              : Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: isLoading
                          ? null
                          : () => context.push('/delivery-failure',
                              extra: delivery),
                      icon: const Icon(AppIcons.alertTriangle, size: 17),
                      label: const Text('Signaler'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(
                            color: AppColors.error, width: 1.5),
                        minimumSize: const Size(0, 54),
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        textStyle: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isLoading
                            ? null
                            : () => context.push('/delivery-validation',
                                extra: delivery),
                        icon: const Icon(AppIcons.checkCircle, size: 18),
                        label: const Text('Confirmer comme Livré'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 54),
                          textStyle: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

// ─── Timeline de suivi de livraison ──────────────────────────────────────────
class _StatusTimeline extends StatelessWidget {
  final DeliveryStatus status;
  const _StatusTimeline({required this.status});

  // Retourne l'index courant de l'étape (0, 1, 2) ou -1 si annulé
  int get _stepIndex => switch (status) {
        DeliveryStatus.pending    => 0,
        DeliveryStatus.inProgress => 1,
        DeliveryStatus.delivered  => 2,
        DeliveryStatus.cancelled  => -1,
      };

  @override
  Widget build(BuildContext context) {
    // ── Cas annulé ────────────────────────────────────────────────────────
    if (status == DeliveryStatus.cancelled) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.errorSoft,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.error.withAlpha(60)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(AppIcons.cancelled,
                  color: AppColors.error, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Livraison annulée',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
      );
    }

    // ── Étapes ────────────────────────────────────────────────────────────
    const steps = [
      (AppIcons.pending,      'En attente',  'Programmée'),
      (AppIcons.truck,        'En transit',  'Prise en charge'),
      (AppIcons.packageCheck, 'Livré',       'Confirmée'),
    ];

    final current = _stepIndex;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(steps.length * 2 - 1, (i) {
          // ── Connecteur horizontal ──────────────────────────────────────
          if (i.isOdd) {
            final stepBefore = i ~/ 2;
            final isActive = current > stepBefore;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 18),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  height: 3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: isActive ? AppColors.primary : AppColors.border,
                  ),
                ),
              ),
            );
          }

          // ── Nœud d'étape ──────────────────────────────────────────────
          final idx = i ~/ 2;
          final isDone    = current >= idx;
          final isCurrent = current == idx;
          final (icon, title, subtitle) = steps[idx];

          final nodeColor   = isDone ? AppColors.primary : AppColors.border;
          final iconColor   = isDone ? Colors.white : AppColors.textSecondary;
          final titleColor  = isDone ? AppColors.primary : AppColors.textSecondary;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cercle avec icône
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: nodeColor,
                  shape: BoxShape.circle,
                  border: isCurrent && !isDone
                      ? Border.all(color: AppColors.primary, width: 2)
                      : null,
                  boxShadow: isDone
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(60),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Icon(icon, size: 17, color: iconColor),
              ),
              const SizedBox(height: 6),
              // Titre
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                  color: titleColor,
                  letterSpacing: 0.1,
                ),
              ),
              // Sous-titre discret
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9,
                  color: AppColors.textSecondary.withAlpha(160),
                  height: 1.3,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
