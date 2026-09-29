import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_gradients.dart';
import '../../../../core/network/token_manager.dart';
import '../../../../core/di/injection.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _fadeIn = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );

    _progress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
    );

    _controller.forward().then((_) {
      if (mounted) {
        final isAuthenticated = getIt<TokenManager>().isAuthenticated;
        if (isAuthenticated) {
          context.go('/dashboard');
        } else {
          context.go('/login');
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.yellow),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: FadeTransition(
              opacity: _fadeIn,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),

                  // Logo LdF
                  ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Image.asset(
                      'assets/logo/ldfgroupe-icon-app.webp',
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Nom de l'app
                  Text(
                    'Igescom Mobile',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Tagline
                  Text(
                    'Livraison · Suivi · Terrain',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primaryDark.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Barre de progression verte animée
                  Column(
                    children: [
                      AnimatedBuilder(
                        animation: _progress,
                        builder: (context, child) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: LinearProgressIndicator(
                              value: _progress.value,
                              minHeight: 5,
                              backgroundColor: AppColors.primaryDark.withValues(
                                alpha: 0.15,
                              ),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primaryDark,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'LdF Groupe CI',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primaryDark.withValues(alpha: 0.55),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
