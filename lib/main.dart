import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/di/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser les données de localisation (nécessaire pour DateFormat avec locale)
  await initializeDateFormatting('fr_FR');

  // Initialisation de l'injection de dépendances (DI) via get_it et injectable
  await configureDependencies();

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
