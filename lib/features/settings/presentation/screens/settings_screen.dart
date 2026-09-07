import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_gradients.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/token_manager.dart';
import '../../../../core/utils/app_dialogs.dart';
import '../../../../core/utils/app_feedback.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Mock Settings States
  bool _offlineMode = false;
  bool _autoSync = true;
  bool _pushNotifications = true;
  bool _soundAlerts = true;
  bool _scheduleReminders = true;
  bool _routeOptimization = true;
  bool _biometrics = true;
  bool _photoProofRequired = true;

  String _selectedTheme = 'Clair (Standard LdF)';
  String _selectedLanguage = 'Français (Côte d\'Ivoire)';
  String _selectedGpsApp = 'Google Maps';
  String _selectedPhotoQuality = 'Moyenne (Recommandée)';

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await AppDialogs.showConfirmationDialog(
      context,
      title: 'Déconnexion',
      message:
          'Êtes-vous sûr de vouloir vous déconnecter de votre session ? Vos données de tournée locales sont enregistrées.',
      confirmText: 'Se déconnecter',
      cancelText: 'Annuler',
      isDestructive: true,
    );

    if (confirmed && context.mounted) {
      await getIt<TokenManager>().clearSession();
      if (context.mounted) {
        context.go('/login');
      }
    }
  }

  void _showSelectorDialog({
    required String title,
    required List<String> options,
    required String currentValue,
    required ValueChanged<String> onSelected,
  }) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              ...options.map((opt) {
                final isSelected = opt == currentValue;
                return ListTile(
                  title: Text(
                    opt,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(AppIcons.check, color: AppColors.primary)
                      : null,
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    onSelected(opt);
                    Navigator.of(context).pop();
                    AppFeedback.info(context, 'Paramètre "$opt" enregistré.');
                  },
                );
              }),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Fermer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = getIt<TokenManager>().getUserName() ?? 'Livreur LDF';

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
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(AppIcons.back, color: Colors.white),
                      onPressed: () => context.pop(),
                      tooltip: 'Retour',
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Paramètres',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Contenu Scrollable des Paramètres ────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              children: [
                // ── 1. Carte Profil Utilisateur ──────────────────────────────
                _buildUserProfileCard(userName),
                const SizedBox(height: 24),

                // ── 2. Section Préférences de l'application ───────────────────
                _buildSectionHeader('Préférences de l\'application'),
                const SizedBox(height: 8),
                _buildSettingsCard([
                  _buildSwitchTile(
                    icon: AppIcons.refresh,
                    title: 'Synchronisation automatique',
                    subtitle: 'Mise à jour en temps réel avec le serveur central',
                    value: _autoSync,
                    onChanged: (val) {
                      setState(() => _autoSync = val);
                      AppFeedback.info(
                        context,
                        val
                            ? 'Synchronisation auto activée.'
                            : 'Synchronisation auto suspendue.',
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    icon: AppIcons.cloudOff,
                    title: 'Mode Hors-Ligne forcé',
                    subtitle: 'Conserver les validations en cache local uniquement',
                    value: _offlineMode,
                    onChanged: (val) {
                      setState(() => _offlineMode = val);
                      AppFeedback.info(
                        context,
                        val
                            ? 'Mode hors-ligne activé.'
                            : 'Mode standard connecté activé.',
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildSelectableTile(
                    icon: AppIcons.sun,
                    title: 'Thème d\'affichage',
                    currentValue: _selectedTheme,
                    onTap: () {
                      _showSelectorDialog(
                        title: 'Thème de l\'interface',
                        options: [
                          'Clair (Standard LdF)',
                          'Sombre (Éco-batterie)',
                          'Automatique (Système)',
                        ],
                        currentValue: _selectedTheme,
                        onSelected: (val) => setState(() => _selectedTheme = val),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildSelectableTile(
                    icon: AppIcons.globe,
                    title: 'Langue de l\'application',
                    currentValue: _selectedLanguage,
                    onTap: () {
                      _showSelectorDialog(
                        title: 'Langue de l\'application',
                        options: [
                          'Français (Côte d\'Ivoire)',
                          'English (International)',
                        ],
                        currentValue: _selectedLanguage,
                        onSelected: (val) =>
                            setState(() => _selectedLanguage = val),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildSelectableTile(
                    icon: AppIcons.camera,
                    title: 'Qualité des photos justificatives',
                    currentValue: _selectedPhotoQuality,
                    onTap: () {
                      _showSelectorDialog(
                        title: 'Qualité de compression photo',
                        options: [
                          'Basse (Économie de données)',
                          'Moyenne (Recommandée)',
                          'Haute (Documents précis)',
                        ],
                        currentValue: _selectedPhotoQuality,
                        onSelected: (val) =>
                            setState(() => _selectedPhotoQuality = val),
                      );
                    },
                  ),
                ]),
                const SizedBox(height: 24),

                // ── 3. Section Notifications & Alertes ───────────────────────
                _buildSectionHeader('Notifications & Alertes'),
                const SizedBox(height: 8),
                _buildSettingsCard([
                  _buildSwitchTile(
                    icon: AppIcons.bellRing,
                    title: 'Notifications Push',
                    subtitle: 'Recevoir les nouvelles courses et modifications',
                    value: _pushNotifications,
                    onChanged: (val) {
                      setState(() => _pushNotifications = val);
                      AppFeedback.info(
                        context,
                        val
                            ? 'Notifications push activées.'
                            : 'Notifications push désactivées.',
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    icon: AppIcons.volume2,
                    title: 'Alertes sonores & vibrations',
                    subtitle: 'Émettre un signal lors d\'une alerte urgente',
                    value: _soundAlerts,
                    onChanged: (val) => setState(() => _soundAlerts = val),
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    icon: AppIcons.clock,
                    title: 'Rappels de créneaux',
                    subtitle: 'Avertissement 30 min avant expiration du créneau',
                    value: _scheduleReminders,
                    onChanged: (val) =>
                        setState(() => _scheduleReminders = val),
                  ),
                ]),
                const SizedBox(height: 24),

                // ── 4. Section Navigation & Tournées ─────────────────────────
                _buildSectionHeader('Navigation & Tournées'),
                const SizedBox(height: 8),
                _buildSettingsCard([
                  _buildSelectableTile(
                    icon: AppIcons.navigation,
                    title: 'Application GPS favorite',
                    currentValue: _selectedGpsApp,
                    onTap: () {
                      _showSelectorDialog(
                        title: 'Application GPS par défaut',
                        options: [
                          'Google Maps',
                          'Waze',
                          'Plan intégré OpenStreetMap',
                        ],
                        currentValue: _selectedGpsApp,
                        onSelected: (val) =>
                            setState(() => _selectedGpsApp = val),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    icon: AppIcons.route,
                    title: 'Optimisation de tournée automatique',
                    subtitle: 'Réorganiser l\'ordre des arrêts selon le trafic',
                    value: _routeOptimization,
                    onChanged: (val) =>
                        setState(() => _routeOptimization = val),
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    icon: AppIcons.camera,
                    title: 'Photo de preuve obligatoire',
                    subtitle: 'Exiger une capture lors de la validation client',
                    value: _photoProofRequired,
                    onChanged: (val) =>
                        setState(() => _photoProofRequired = val),
                  ),
                ]),
                const SizedBox(height: 24),

                // ── 5. Section Sécurité & Accès ──────────────────────────────
                _buildSectionHeader('Sécurité & Accès'),
                const SizedBox(height: 8),
                _buildSettingsCard([
                  _buildSwitchTile(
                    icon: AppIcons.fingerprint,
                    title: 'Authentification biométrique',
                    subtitle: 'Déverrouiller l\'app avec l\'empreinte digitale',
                    value: _biometrics,
                    onChanged: (val) {
                      setState(() => _biometrics = val);
                      AppFeedback.info(
                        context,
                        val
                            ? 'Biométrie activée pour votre compte.'
                            : 'Biométrie désactivée.',
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildNavigationTile(
                    icon: AppIcons.lock,
                    title: 'Modifier le code PIN de session',
                    onTap: () {
                      AppFeedback.info(
                        context,
                        'Fonctionnalité de changement de PIN disponible prochainement.',
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildNavigationTile(
                    icon: AppIcons.shieldCheck,
                    title: 'Sessions actives & Appareils autorisés',
                    onTap: () {
                      AppFeedback.info(
                        context,
                        'Appareil actif actuel : TECNO BF6 (ID: #023).',
                      );
                    },
                  ),
                ]),
                const SizedBox(height: 24),

                // ── 6. Section À propos & Support ─────────────────────────────
                _buildSectionHeader('À propos & Support'),
                const SizedBox(height: 8),
                _buildSettingsCard([
                  _buildNavigationTile(
                    icon: AppIcons.info,
                    title: 'Version de l\'application',
                    trailingText: 'v1.0.4 (Build 2026.09)',
                    onTap: () {
                      AppFeedback.info(
                        context,
                        'Igescom Mobile v1.0.4 — Dernière version installée.',
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildNavigationTile(
                    icon: AppIcons.pdf,
                    title: 'Conditions Générales d\'Utilisation (CGU)',
                    onTap: () {
                      AppFeedback.info(
                        context,
                        'Consultation des CGU logistiques LdF Groupe.',
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildNavigationTile(
                    icon: AppIcons.help,
                    title: 'Contacter le support logistique',
                    subtitle: 'Assistance 24/7 pour les chauffeurs-livreurs',
                    onTap: () {
                      AppFeedback.info(
                        context,
                        'Appel du support LdF (+225 27 20 00 00 00)…',
                      );
                    },
                  ),
                ]),
                const SizedBox(height: 32),

                // ── 7. Bouton Déconnexion avec Confirmation ───────────────────
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error, width: 1.5),
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => _handleLogout(context),
                  icon: const Icon(AppIcons.logout, color: AppColors.error),
                  label: const Text(
                    'Se déconnecter de l\'application',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    '© 2026 LdF Groupe CI • Tous droits réservés',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers de construction de l'interface ─────────────────────────────────

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          color: AppColors.textSecondary,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildUserProfileCard(String userName) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: const Icon(
              AppIcons.person,
              color: AppColors.primaryDark,
              size: 32,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.successSoft,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            AppIcons.check,
                            size: 10,
                            color: AppColors.success,
                          ),
                          SizedBox(width: 3),
                          Text(
                            'En service',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Chauffeur-Livreur • LDF Cocody',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Matricule : LDF-023',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primaryDark, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            activeTrackColor: AppColors.primary,
            activeThumbColor: Colors.white,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSelectableTile({
    required IconData icon,
    required String title,
    required String currentValue,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primaryDark, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    currentValue,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              AppIcons.chevronRight,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required String title,
    String? subtitle,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primaryDark, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailingText != null) ...[
              Text(
                trailingText,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 6),
            ],
            const Icon(
              AppIcons.chevronRight,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
