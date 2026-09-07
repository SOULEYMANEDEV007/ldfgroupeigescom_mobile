import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_icons.dart';

/// Centralise tous les feedbacks visuels non-bloquants de l'application.
///
/// Utilisation :
/// ```dart
/// AppFeedback.success(context, 'Livraison validée !');
/// AppFeedback.error(context, 'Connexion échouée.');
/// AppFeedback.warning(context, 'Champ manquant.');
/// AppFeedback.info(context, 'Synchronisation en cours…');
/// ```
class AppFeedback {
  AppFeedback._(); // Non-instantiable

  // ── Helpers internes ──────────────────────────────────────────────────────

  static void _show(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required IconData icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: duration,
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  // ── API Publique ──────────────────────────────────────────────────────────

  /// Feedback de succès (fond vert LdF).
  static void success(BuildContext context, String message) {
    _show(
      context,
      message: message,
      backgroundColor: AppColors.primary,
      icon: AppIcons.checkCircle,
    );
  }

  /// Feedback d'erreur (fond rouge).
  static void error(BuildContext context, String message) {
    _show(
      context,
      message: message,
      backgroundColor: AppColors.error,
      icon: AppIcons.error,
    );
  }

  /// Feedback d'avertissement (fond ambre).
  static void warning(BuildContext context, String message) {
    _show(
      context,
      message: message,
      backgroundColor: AppColors.warning,
      icon: AppIcons.alertTriangle,
    );
  }

  /// Feedback informatif (fond ardoise foncé).
  static void info(BuildContext context, String message) {
    _show(
      context,
      message: message,
      backgroundColor: const Color(0xFF1E293B),
      icon: AppIcons.info,
    );
  }
}
