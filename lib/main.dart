import 'package:flutter/material.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/di/injection.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de l'injection de dépendances (DI) via get_it et injectable
  configureDependencies();

  runApp(const LdfMobileApp());
}

class LdfMobileApp extends StatelessWidget {
  const LdfMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'LdF Igescom Mobile',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}
