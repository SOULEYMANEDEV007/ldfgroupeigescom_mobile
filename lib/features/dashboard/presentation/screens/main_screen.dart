import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';

class MainScreen extends StatelessWidget {
  final Widget child;
  const MainScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();

    int currentIndex = 0;
    if (location.startsWith('/tour')) {
      currentIndex = 1;
    } else if (location.startsWith('/profile')) {
      currentIndex = 2;
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: _LdfNavBar(currentIndex: currentIndex),
    );
  }
}

// ─── Bottom NavigationBar personnalisée — jaune LdF ───────────────────────────
class _LdfNavBar extends StatelessWidget {
  final int currentIndex;
  const _LdfNavBar({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Material(
      color: AppColors.navBarYellow,
      surfaceTintColor: Colors.transparent,
      elevation: 12,
      shadowColor: Colors.black.withAlpha(50),
      child: SizedBox(
        // 74 px de zone cliquable + safe area système en dessous (ergonomie tablette)
        height: 74 + bottomInset,
        child: Column(
          children: [
            // ── Séparateur fin vert foncé en haut ─────────────────────────
            Container(height: 1, color: AppColors.primaryDark.withAlpha(35)),
            // ── Contenu centré sur 74 px ───────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _NavItem(
                      icon: AppIcons.home,
                      label: 'Accueil',
                      selected: currentIndex == 0,
                      onTap: () => context.go('/dashboard'),
                    ),
                    _NavItem(
                      icon: AppIcons.truck,
                      label: 'Tournées',
                      selected: currentIndex == 1,
                      onTap: () => context.go('/tour'),
                    ),
                    _NavItem(
                      icon: AppIcons.profile,
                      label: 'Profil',
                      selected: currentIndex == 2,
                      onTap: () => context.go('/profile'),
                    ),
                  ],
                ),
              ),
            ),
            // ── Espace safe area système ───────────────────────────────────
            if (bottomInset > 0) SizedBox(height: bottomInset),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Vert foncé LdF très net et contrasté sur le fond jaune
    final iconColor =
        selected ? AppColors.primaryDark : AppColors.primaryDark.withAlpha(195);
    final labelColor =
        selected ? AppColors.primaryDark : AppColors.primaryDark.withAlpha(195);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pill indicateur derrière l'icône quand actif
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primaryDark.withAlpha(28)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, color: iconColor, size: 27),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                package: null,
                color: labelColor,
                fontSize: 14.0,
                fontWeight:
                    selected ? FontWeight.w900 : FontWeight.w700,
                letterSpacing: 0.2,
                height: 1.1,
                leadingDistribution: TextLeadingDistribution.even,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
