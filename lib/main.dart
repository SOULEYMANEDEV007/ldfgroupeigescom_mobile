import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/di/injection.dart';
// import 'core/offline/offline.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser les données de localisation (nécessaire pour DateFormat avec locale)
  await initializeDateFormatting('fr_FR');

  // Initialiser Hive pour le stockage offline
  // await _initializeHive();

  // Initialisation de l'injection de dépendances (DI) via get_it et injectable
  await configureDependencies();

  runApp(const LdfMobileApp());
}

/// Initialise Hive et enregistre tous les adapters nécessaires.
/// 
/// IMPORTANT : Cette fonction doit être appelée AVANT configureDependencies()
/// car les modules DI ont besoin d'accéder aux boxes Hive.
// Future<void> _initializeHive() async {
//   // Initialiser Hive avec Flutter
//   await Hive.initFlutter();

//   // Enregistrer tous les adapters générés par build_runner
//   // Note : Les fichiers .g.dart doivent être générés avec :
//   // flutter pub run build_runner build --delete-conflicting-outputs
//   Hive.registerAdapter(PendingActionAdapter());
//   Hive.registerAdapter(OfflineDeliveryAdapter());
//   Hive.registerAdapter(OfflineTourAdapter());
//   Hive.registerAdapter(OfflineUserAdapter());
//   Hive.registerAdapter(OfflineHistoryEntryAdapter());

//   // Ouvrir toutes les boxes nécessaires
//   await Future.wait([
//     Hive.openBox<PendingAction>(HiveBoxes.pendingActions),
//     Hive.openBox<OfflineDelivery>(HiveBoxes.deliveries),
//     Hive.openBox<OfflineTour>(HiveBoxes.tours),
//     Hive.openBox<OfflineUser>(HiveBoxes.user),
//     Hive.openBox<OfflineHistoryEntry>(HiveBoxes.history),
//   ]);

//   debugPrint('✅ Hive initialisé avec succès');
//   debugPrint('   - ${HiveBoxes.pendingActions}: ${Hive.box<PendingAction>(HiveBoxes.pendingActions).length} entrées');
//   debugPrint('   - ${HiveBoxes.deliveries}: ${Hive.box<OfflineDelivery>(HiveBoxes.deliveries).length} entrées');
//   debugPrint('   - ${HiveBoxes.tours}: ${Hive.box<OfflineTour>(HiveBoxes.tours).length} entrées');
//   debugPrint('   - ${HiveBoxes.user}: ${Hive.box<OfflineUser>(HiveBoxes.user).length} entrées');
//   debugPrint('   - ${HiveBoxes.history}: ${Hive.box<OfflineHistoryEntry>(HiveBoxes.history).length} entrées');
// }

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
