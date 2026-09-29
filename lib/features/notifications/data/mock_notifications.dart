import '../domain/models/notification_item.dart';

List<NotificationItem> getInitialMockNotifications() {
  final now = DateTime.now();

  return [
    NotificationItem(
      id: 'notif-001',
      title: 'Nouvelle livraison assignée',
      message:
          'Une nouvelle commande (#CMD-4921) a été ajoutée à votre tournée Zone 4 (Pharmacie du Boulevard).',
      timestamp: now.subtract(const Duration(minutes: 8)),
      type: NotificationType.delivery,
      isRead: false,
      deliveryId: 'CMD-4921',
      blNumber: 'BL-2026-00492',
    ),
    NotificationItem(
      id: 'notif-002',
      title: 'Alerte Trafic - Boulevard VGE',
      message:
          'Ralentissement majeur signalé entre Treichville et Koumassi. Itinéraire alternatif conseillé par le régulateur.',
      timestamp: now.subtract(const Duration(minutes: 25)),
      type: NotificationType.alert,
      isRead: false,
    ),
    NotificationItem(
      id: 'notif-003',
      title: 'Livraison validée avec succès',
      message:
          'La commande #CMD-8832 pour SOCIÉTÉ ANONYME AFRIQUE a été confirmée et émargée par le client.',
      timestamp: now.subtract(const Duration(hours: 1, minutes: 15)),
      type: NotificationType.delivery,
      isRead: false,
      deliveryId: 'CMD-8832',
      blNumber: 'BL-2026-00452',
    ),
    NotificationItem(
      id: 'notif-004',
      title: 'Rappel d\'horaire de livraison',
      message:
          'Créneau prioritaire dans 30 min pour Supermarché Prima Center (BL-2026-00418).',
      timestamp: now.subtract(const Duration(hours: 2)),
      type: NotificationType.reminder,
      isRead: true,
      deliveryId: 'CMD-4180',
      blNumber: 'BL-2026-00418',
    ),
    NotificationItem(
      id: 'notif-005',
      title: 'Synchronisation serveur réussie',
      message:
          'Toutes vos preuves de livraison et signatures hors-ligne ont été synchronisées avec la base centrale IGESCOM.',
      timestamp: now.subtract(const Duration(hours: 3, minutes: 40)),
      type: NotificationType.system,
      isRead: true,
    ),
    NotificationItem(
      id: 'notif-006',
      title: 'Modification d\'instruction client',
      message:
          'Le client Librairie de France Plateau a spécifié : "Accès livraison par la rampe arrière bâtiment B".',
      timestamp: now.subtract(const Duration(hours: 5)),
      type: NotificationType.delivery,
      isRead: true,
      deliveryId: 'CMD-3001',
    ),
    NotificationItem(
      id: 'notif-007',
      title: 'Alerte météo - Fortes averses',
      message:
          'Pluies torrentielles prévues sur Abidjan Sud. Veuillez sécuriser les bâches de cargaison et réduire la vitesse.',
      timestamp: now.subtract(const Duration(days: 1, hours: 2)),
      type: NotificationType.alert,
      isRead: true,
    ),
    NotificationItem(
      id: 'notif-008',
      title: 'Mise à jour application disponible',
      message:
          'La version 1.0.4 d\'Igescom Mobile améliore la réactivité GPS et la capture de signature numérique.',
      timestamp: now.subtract(const Duration(days: 2)),
      type: NotificationType.system,
      isRead: true,
    ),
  ];
}
