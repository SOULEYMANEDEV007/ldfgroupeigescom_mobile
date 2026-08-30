import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_gradients.dart';
import '../../../../core/constants/app_icons.dart';
import '../../domain/entities/history_entry.dart';

class HistoryDetailScreen extends StatelessWidget {
  final HistoryEntry entry;
  const HistoryDetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final isDelivered = entry.status == HistoryStatus.delivered;
    final statusColor = isDelivered ? AppColors.success : AppColors.error;
    final statusBg = isDelivered ? AppColors.successSoft : AppColors.errorSoft;
    final statusLabel = isDelivered ? 'Livré avec succès' : 'Échec de livraison';
    final statusIcon = isDelivered ? AppIcons.packageCheck : AppIcons.packageX;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Header gradient vert ─────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: isDelivered
                  ? AppGradients.primaryHeader
                  : const LinearGradient(
                      colors: [Color(0xFFB91C1C), AppColors.error],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Barre titre + retour
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => context.pop(),
                          icon: const Icon(AppIcons.back,
                              color: Colors.white, size: 22),
                        ),
                        const Expanded(
                          child: Text(
                            'Détail historique',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Infos client
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(30),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(AppIcons.building,
                                color: Colors.white, size: 26),
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
                                  entry.clientName.toUpperCase(),
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
                                        size: 12,
                                        color: AppColors.navBarYellow),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        entry.address,
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
          ),

          // ── Contenu scrollable ───────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Bandeau statut final ───────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(14),
                      border:
                          Border.all(color: statusColor.withAlpha(60)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: statusColor.withAlpha(20),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(statusIcon,
                              size: 24, color: statusColor),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              statusLabel,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat(
                                'dd/MM/yyyy \'à\' HH:mm',
                              ).format(entry.completedAt),
                              style: TextStyle(
                                color: statusColor.withAlpha(180),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  _sectionLabel('Informations de livraison'),
                  const SizedBox(height: 10),

                  // ── Grille KPIs ────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _KpiCard(
                          icon: AppIcons.receipt,
                          iconColor: AppColors.primary,
                          iconBgColor: AppColors.primarySoft,
                          label: 'N° BL',
                          value: entry.deliveryNoteNumber,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _KpiCard(
                          icon: AppIcons.route,
                          iconColor: AppColors.accentBlue,
                          iconBgColor: AppColors.accentBlueSoft,
                          label: 'Tournée',
                          value: entry.tourReference,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
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
                          ).format(entry.amount),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _KpiCard(
                          icon: AppIcons.calendar,
                          iconColor: AppColors.warning,
                          iconBgColor: AppColors.warningSoft,
                          label: 'Date',
                          value: DateFormat('dd/MM/yyyy')
                              .format(entry.completedAt),
                        ),
                      ),
                    ],
                  ),

                  // ── Raison d'échec ─────────────────────────────────────
                  if (!isDelivered && entry.failureReason != null) ...[
                    const SizedBox(height: 20),
                    _sectionLabel("Raison de l'échec"),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.errorSoft,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.error.withAlpha(60)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(AppIcons.alertTriangle,
                              size: 18, color: AppColors.error),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              entry.failureReason!,
                              style: const TextStyle(
                                color: AppColors.error,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),
                  _sectionLabel('Adresse de livraison'),
                  const SizedBox(height: 10),

                  // ── Adresse ────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: AppColors.accentBlueSoft,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(AppIcons.mapPin,
                              color: AppColors.accentBlue, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            entry.address,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
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

  Widget _sectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.bold,
        fontSize: 11,
        letterSpacing: 1.2,
      ),
    );
  }
}

// ─── KPI Card réutilisable ────────────────────────────────────────────────────
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
              offset: const Offset(0, 2)),
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
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
