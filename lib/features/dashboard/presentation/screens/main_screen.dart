import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

class MainScreen extends StatelessWidget {
  final Widget child;

  const MainScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Déterminons la route active pour mettre à jour la BottomNavigationBar
    final String location = GoRouterState.of(context).uri.toString();

    int currentIndex = 0;
    if (location.startsWith('/tour')) {
      currentIndex = 1;
    } else if (location.startsWith('/profile')) {
      currentIndex = 2;
    }

    return Scaffold(
      body: child, // Le contenu change en fonction de la route (ShellRoute)
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: (index) {
              if (index == 0) context.go('/dashboard');
              if (index == 1) context.go('/tour');
              if (index == 2) context.go('/profile');
            },
            backgroundColor: Colors.white,
            elevation: 0,
            indicatorColor: AppColors.primary.withValues(alpha: 0.1),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(
                  Icons.dashboard_rounded,
                  color: AppColors.primary,
                ),
                label: 'Accueil',
              ),
              NavigationDestination(
                icon: Icon(Icons.local_shipping_outlined),
                selectedIcon: Icon(
                  Icons.local_shipping_rounded,
                  color: AppColors.primary,
                ),
                label: 'Tournées',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(
                  Icons.person_rounded,
                  color: AppColors.primary,
                ),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
