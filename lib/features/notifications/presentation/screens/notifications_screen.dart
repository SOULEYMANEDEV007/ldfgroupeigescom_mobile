import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_gradients.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../data/mock_notifications.dart';
import '../../domain/models/notification_item.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<NotificationItem> _notifications;
  String _searchQuery = '';
  String _selectedFilter = 'Toutes';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = [
    'Toutes',
    'Non lues',
    'Livraisons',
    'Alertes',
    'Système',
  ];

  @override
  void initState() {
    super.initState();
    _notifications = getInitialMockNotifications();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  List<NotificationItem> get _filteredNotifications {
    return _notifications.where((notif) {
      // Filtre par catégorie
      if (_selectedFilter == 'Non lues' && notif.isRead) {
        return false;
      } else if (_selectedFilter == 'Livraisons' &&
          notif.type != NotificationType.delivery) {
        return false;
      } else if (_selectedFilter == 'Alertes' &&
          notif.type != NotificationType.alert) {
        return false;
      } else if (_selectedFilter == 'Système' &&
          (notif.type != NotificationType.system &&
              notif.type != NotificationType.reminder)) {
        return false;
      }

      // Filtre par recherche textuelle
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesTitle = notif.title.toLowerCase().contains(query);
        final matchesMessage = notif.message.toLowerCase().contains(query);
        final matchesBl =
            notif.blNumber?.toLowerCase().contains(query) ?? false;
        final matchesId =
            notif.deliveryId?.toLowerCase().contains(query) ?? false;
        if (!matchesTitle && !matchesMessage && !matchesBl && !matchesId) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void _markAllAsRead() {
    setState(() {
      for (var n in _notifications) {
        n.isRead = true;
      }
    });
    AppFeedback.success(
      context,
      'Toutes les notifications ont été marquées comme lues.',
    );
  }

  void _deleteNotification(NotificationItem item) {
    setState(() {
      _notifications.remove(item);
    });

    AppFeedback.info(
      context,
      'Notification supprimée.',
    );
  }

  void _showNotificationDetail(NotificationItem item) {
    if (!item.isRead) {
      setState(() {
        item.isRead = true;
      });
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNotificationIcon(item.type, size: 22, padding: 10),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTimestamp(item.timestamp),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              Text(
                item.message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
              ),
              if (item.blNumber != null || item.deliveryId != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        AppIcons.receipt,
                        color: AppColors.primaryDark,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Réf : ${item.blNumber ?? item.deliveryId}',
                        style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.border),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Fermer'),
                    ),
                  ),
                  if (item.deliveryId != null) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Navigation vers le bon de livraison si dispo
                          context.push('/delivery-note');
                        },
                        child: const Text('Consulter'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) {
      return 'À l\'instant';
    } else if (diff.inMinutes < 60) {
      return 'Il y a ${diff.inMinutes} min';
    } else if (diff.inHours < 24 && dt.day == now.day) {
      return 'Aujourd\'hui à ${DateFormat('HH:mm').format(dt)}';
    } else if (diff.inDays < 2) {
      return 'Hier à ${DateFormat('HH:mm').format(dt)}';
    } else {
      return DateFormat('dd/MM/yyyy à HH:mm').format(dt);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredNotifications;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Header Vert LdF Dégradé ─────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(gradient: AppGradients.primaryHeader),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                child: Column(
                  children: [
                    // Barre navigation
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(AppIcons.back, color: Colors.white),
                          onPressed: () => context.pop(),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                'Notifications',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              if (_unreadCount > 0) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.navBarYellow,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '$_unreadCount',
                                    style: const TextStyle(
                                      color: AppColors.primaryDark,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (_unreadCount > 0)
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                            ),
                            onPressed: _markAllAsRead,
                            icon: const Icon(
                              AppIcons.checkCheck,
                              size: 16,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Tout lire',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // ── Champ de recherche ──────────────────────────────────
                    Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.trim();
                          });
                        },
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Rechercher une notification, BL, client…',
                          hintStyle: TextStyle(
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.6,
                            ),
                            fontSize: 13.5,
                          ),
                          prefixIcon: const Icon(
                            AppIcons.search,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    AppIcons.close,
                                    size: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Filtres de Catégories (Chips horizontaux) ───────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = filter == _selectedFilter;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          filter,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ── Liste des Notifications ou État Vide ────────────────────────────
          Expanded(
            child: filteredList.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    itemCount: filteredList.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      return _buildNotificationCard(item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ── Carte Notification ─────────────────────────────────────────────────────
  Widget _buildNotificationCard(NotificationItem item) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _deleteNotification(item),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(AppIcons.trash, color: Colors.white, size: 22),
      ),
      child: InkWell(
        onTap: () => _showNotificationDetail(item),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: item.isRead ? Colors.white : AppColors.primarySoft,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: item.isRead
                  ? AppColors.border
                  : AppColors.primary.withValues(alpha: 0.35),
              width: item.isRead ? 0.8 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icône thématisée
              _buildNotificationIcon(item.type),
              const SizedBox(width: 12),

              // Contenu
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontWeight: item.isRead
                                  ? FontWeight.w600
                                  : FontWeight.w800,
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (!item.isRead) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: item.isRead
                            ? AppColors.textSecondary
                            : AppColors.textPrimary.withValues(alpha: 0.85),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatTimestamp(item.timestamp),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (item.blNumber != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: AppColors.border,
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              item.blNumber!,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDark,
                              ),
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
      ),
    );
  }

  // ── Icône selon le type de notification ────────────────────────────────────
  Widget _buildNotificationIcon(
    NotificationType type, {
    double size = 18,
    double padding = 8,
  }) {
    IconData icon;
    Color iconColor;
    Color bgColor;

    switch (type) {
      case NotificationType.delivery:
        icon = AppIcons.truck;
        iconColor = AppColors.primary;
        bgColor = AppColors.primarySoft;
        break;
      case NotificationType.alert:
        icon = AppIcons.alertTriangle;
        iconColor = AppColors.error;
        bgColor = AppColors.errorSoft;
        break;
      case NotificationType.reminder:
        icon = AppIcons.clock;
        iconColor = AppColors.warning;
        bgColor = AppColors.warningSoft;
        break;
      case NotificationType.system:
        icon = AppIcons.info;
        iconColor = AppColors.accentBlue;
        bgColor = AppColors.accentBlueSoft;
        break;
    }

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: iconColor, size: size),
    );
  }

  // ── État Vide ──────────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                AppIcons.inbox,
                color: AppColors.primary,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Aucun résultat trouvé'
                  : 'Aucune notification',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Aucune notification ne correspond à "$_searchQuery". Essayez un autre terme.'
                  : 'Vous êtes à jour ! Aucune nouvelle alerte pour le moment.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            if (_searchQuery.isNotEmpty || _selectedFilter != 'Toutes') ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  minimumSize: const Size(180, 44),
                ),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                    _selectedFilter = 'Toutes';
                  });
                },
                icon: const Icon(AppIcons.refresh, size: 16),
                label: const Text('Réinitialiser les filtres'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
