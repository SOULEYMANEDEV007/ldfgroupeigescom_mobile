import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/main_screen.dart';
import '../../features/delivery/domain/entities/delivery.dart';
import '../../features/delivery/presentation/screens/delivery_detail_screen.dart';
import '../../features/delivery/presentation/screens/delivery_failure_screen.dart';
import '../../features/delivery/presentation/screens/delivery_note_screen.dart';
import '../../features/delivery/presentation/screens/delivery_validation_screen.dart';
import '../../features/tour/domain/entities/tour_entity.dart';
import '../../features/history/presentation/screens/history_screen.dart';
import '../../features/history/presentation/screens/history_detail_screen.dart';
import '../../features/history/domain/entities/history_entry.dart';
import '../../features/history/presentation/bloc/history_cubit.dart';
import '../../core/di/injection.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/tour/presentation/screens/tour_detail_screen.dart';
import '../../features/tour/presentation/screens/tour_screen.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainScreen(child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/tour',
            builder: (context, state) => const TourScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/delivery-detail',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final delivery = state.extra as Delivery;
          return DeliveryDetailScreen(delivery: delivery);
        },
      ),
      GoRoute(
        path: '/delivery-validation',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final delivery = state.extra as Delivery;
          return DeliveryValidationScreen(delivery: delivery);
        },
      ),
      GoRoute(
        path: '/delivery-failure',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final delivery = state.extra as Delivery;
          return DeliveryFailureScreen(delivery: delivery);
        },
      ),
      GoRoute(
        path: '/delivery-note',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final delivery = state.extra as Delivery?;
          return DeliveryNoteScreen(delivery: delivery);
        },
      ),
      GoRoute(
        path: '/tour-detail',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final tour = state.extra as TourEntity;
          return TourDetailScreen(tour: tour);
        },
      ),
      GoRoute(
        path: '/history',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          return BlocProvider(
            create: (_) => getIt<HistoryCubit>()..fetchHistory(),
            child: const HistoryScreen(),
          );
        },
      ),
      GoRoute(
        path: '/history-detail',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final entry = state.extra as HistoryEntry;
          return HistoryDetailScreen(entry: entry);
        },
      ),
      GoRoute(
        path: '/notifications',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
