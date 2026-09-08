import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_gradients.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../../../core/services/location_service.dart';
import '../../domain/entities/delivery.dart';
import '../bloc/delivery_cubit.dart';

const _defaultLatLng = LatLng(5.3600, -4.0083); // Abidjan, Côte d'Ivoire

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
        if (state is DeliveryError) {
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
                    // ── Timeline de suivi ────────────────────────────
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _sectionLabel('Suivi de la livraison'),
                    ),
                    const SizedBox(height: 10),
                    _CompactTimeline(status: delivery.status),
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
                                  value: DateFormat(
                                    'HH:mm',
                                  ).format(delivery.scheduledTime),
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
                                  color: Colors.amber.withAlpha(80),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    AppIcons.note,
                                    color: Colors.amber,
                                    size: 18,
                                  ),
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
                              onPressed: () => context.push(
                                '/delivery-note',
                                extra: delivery,
                              ),
                              icon: const Icon(AppIcons.pdf, size: 18),
                              label: const Text('Voir le Bon de Livraison'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(
                                  color: AppColors.primary,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
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
          child: Row(
            children: [
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      delivery.clientName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      delivery.phone,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  // TODO: url_launcher tel:${delivery.phone}
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppColors.navBarYellow,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    AppIcons.phoneCall,
                    size: 18,
                    color: AppColors.primaryDark,
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

// ─── Carte GPS ────────────────────────────────────────────────────────────────
class _MapSection extends StatefulWidget {
  final Delivery delivery;
  const _MapSection({required this.delivery});

  @override
  State<_MapSection> createState() => _MapSectionState();
}

class _MapSectionState extends State<_MapSection> {
  final _locationService = getIt<LocationService>();
  Position? _currentPosition;
  bool _isLoadingLocation = false;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    try {
      final position = await _locationService.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationError = e.toString();
          _isLoadingLocation = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Utiliser la position actuelle si disponible, sinon position par défaut
    final point = _currentPosition != null
        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
        : _defaultLatLng;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: point,
              initialZoom: 14.5,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        AppIcons.truck,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Indicateur de chargement
          if (_isLoadingLocation)
            Container(
              color: Colors.black.withAlpha(100),
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          // Erreur de localisation
          if (_locationError != null && !_isLoadingLocation)
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: Icon(
                  AppIcons.refresh,
                  color: AppColors.error,
                  size: 20,
                ),
                onPressed: _getCurrentLocation,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withAlpha(160), Colors.transparent],
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _currentPosition != null
                        ? AppIcons.navigation
                        : AppIcons.mapPin,
                    color: AppColors.navBarYellow,
                    size: 15,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _currentPosition != null
                          ? 'Position actuelle activée'
                          : widget.delivery.address,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
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
            offset: const Offset(0, 3),
          ),
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
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
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
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            MediaQuery.of(context).padding.bottom + 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(18),
                blurRadius: 16,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: delivery.status == DeliveryStatus.pending
              ? ElevatedButton.icon(
                  onPressed: isLoading
                      ? null
                      : () => context.read<DeliveryCubit>().startDelivery(
                          delivery,
                        ),
                  icon: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(AppIcons.play),
                  label: Text(
                    isLoading ? 'Démarrage...' : 'Démarrer la livraison',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navBarYellow,
                    foregroundColor: AppColors.primaryDark,
                    minimumSize: const Size(double.infinity, 54),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                )
              : Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: isLoading
                          ? null
                          : () => context.push(
                              '/delivery-failure',
                              extra: delivery,
                            ),
                      icon: const Icon(AppIcons.alertTriangle, size: 17),
                      label: const Text('Signaler'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(
                          color: AppColors.error,
                          width: 1.5,
                        ),
                        minimumSize: const Size(0, 54),
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isLoading
                            ? null
                            : () => context.push(
                                '/delivery-validation',
                                extra: delivery,
                              ),
                        icon: const Icon(AppIcons.checkCircle, size: 18),
                        label: const Text('Confirmer comme Livré'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 54),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
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
class _CompactTimeline extends StatelessWidget {
  final DeliveryStatus status;
  const _CompactTimeline({required this.status});

  @override
  Widget build(BuildContext context) {
    if (status == DeliveryStatus.cancelled) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.errorSoft,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(AppIcons.cancelled, color: AppColors.error, size: 16),
            const SizedBox(width: 8),
            const Text(
              'Livraison annulée',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    const steps = [
      (AppIcons.pending, 'Attente'),
      (AppIcons.truck, 'En cours'),
      (AppIcons.checkCircle, 'Livré'),
    ];

    final current = switch (status) {
      DeliveryStatus.pending => 0,
      DeliveryStatus.inProgress => 1,
      DeliveryStatus.delivered => 2,
      _ => 0,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final idx = i ~/ 2;
            return Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 14),
                height: 2,
                color: current > idx ? AppColors.primary : AppColors.border,
              ),
            );
          }
          final idx = i ~/ 2;
          final isActive = current >= idx;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : AppColors.border,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  steps[idx].$1,
                  size: 14,
                  color: isActive ? Colors.white : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                steps[idx].$2,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: current == idx
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: isActive ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
