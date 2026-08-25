import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

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
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              'Kouassi Fabrice',
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
              icon: Icons.history_rounded,
              title: 'Historique des livraisons',
              onTap: () {
                // TODO: Naviguer vers l'historique
              },
            ),
            const Divider(height: 1),
            _buildProfileOption(
              context,
              icon: Icons.settings_rounded,
              title: 'Paramètres du compte',
              onTap: () {
                // TODO: Naviguer vers les paramètres
              },
            ),
            const Divider(height: 1),
            _buildProfileOption(
              context,
              icon: Icons.help_outline_rounded,
              title: 'Support technique',
              onTap: () {
                // TODO: Contacter le support
              },
            ),
            const SizedBox(height: 40),

            // Logout Button
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                side: const BorderSide(color: Colors.redAccent),
                foregroundColor: Colors.redAccent,
              ),
              onPressed: () {
                // TODO: Logique de déconnexion via BLoC/AuthRepository
                context.go('/login');
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text(
                'Se déconnecter',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: Colors.grey,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
    );
  }
}
