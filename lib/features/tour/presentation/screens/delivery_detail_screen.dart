import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/delivery.dart';

class DeliveryDetailScreen extends StatelessWidget {
  final Delivery delivery;

  const DeliveryDetailScreen({super.key, required this.delivery});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Commande #${delivery.id}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CARTE CLIENT & ADRESSE
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              delivery.clientName,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              delivery.phone,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // TODO: Lancer l'appel
                        },
                        icon: const Icon(
                          Icons.phone_in_talk,
                          color: AppColors.primary,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                  Text(
                    'Adresse de livraison',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.secondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          delivery.address,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // INFORMATIONS ADDITIONNELLES
            Text(
              'Informations Supplémentaires',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    'Heure prévue',
                    DateFormat('HH:mm').format(delivery.scheduledTime),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    'Statut actuel',
                    _getStatusLabel(delivery.status),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Notes',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    delivery.notes.isNotEmpty
                        ? delivery.notes
                        : 'Aucune note spécifiée.',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // OUTILS D'ACTIONS
            if (delivery.status != DeliveryStatus.delivered &&
                delivery.status != DeliveryStatus.cancelled)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  backgroundColor: delivery.status == DeliveryStatus.pending
                      ? AppColors
                            .secondary // LdF Yellow pour "Démarrer"
                      : AppColors.primary, // LdF Green pour "Terminer"
                  foregroundColor: delivery.status == DeliveryStatus.pending
                      ? Colors.black
                      : Colors.white,
                ),
                onPressed: () {
                  // TODO: Changer le statut de la livraison (Cubit/Bloc action)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        delivery.status == DeliveryStatus.pending
                            ? 'Vous avez démarré la livraison !'
                            : 'Livraison validée avec succès !',
                      ),
                    ),
                  );
                  context.pop();
                },
                child: Text(
                  delivery.status == DeliveryStatus.pending
                      ? 'Démarrer la course'
                      : 'Valider la livraison',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  String _getStatusLabel(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.pending:
        return 'En attente';
      case DeliveryStatus.inProgress:
        return 'En cours';
      case DeliveryStatus.delivered:
        return 'Livré';
      case DeliveryStatus.cancelled:
        return 'Annulé';
    }
  }
}
