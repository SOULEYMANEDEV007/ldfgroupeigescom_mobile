import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/token_manager.dart';
import '../../../../core/utils/app_dialogs.dart';
import '../../../../core/utils/app_feedback.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Avatar & Name
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primary,
              child: Icon(AppIcons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              getIt<TokenManager>().getUserName() ?? 'Livreur LDF',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text('livreur@ldf.ci', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),

            // Options
            _buildProfileOption(
              context,
              icon: AppIcons.history,
              title: 'Historique des livraisons',
              onTap: () => context.push('/history'),
            ),
            const Divider(height: 1),
            _buildProfileOption(
              context,
              icon: AppIcons.settings,
              title: 'Paramètres du compte',
              onTap: () => context.push('/settings'),
            ),
            const Divider(height: 1),
            _buildProfileOption(
              context,
              icon: AppIcons.help,
              title: 'Support technique',
              onTap: () {
                AppFeedback.info(
                  context,
                  'Appel du support LdF (+225 27 20 00 00 00)…',
                );
              },
            ),
            const SizedBox(height: 40),

            // Logout Button
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                side: const BorderSide(color: AppColors.error, width: 1.5),
                foregroundColor: AppColors.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () async {
                final confirmed = await AppDialogs.showConfirmationDialog(
                  context,
                  title: 'Déconnexion',
                  message:
                      'Êtes-vous sûr de vouloir vous déconnecter de votre session ? Vos données locales sont synchronisées.',
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
              },
              icon: const Icon(AppIcons.logout),
              label: const Text(
                'Se déconnecter',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(
        AppIcons.chevronRight,
        size: 16,
        color: Colors.grey,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
    );
  }
}
