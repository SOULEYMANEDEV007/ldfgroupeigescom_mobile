import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Centralise tous les feedbacks visuels (SnackBars) de l'application.
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
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
      backgroundColor: AppColors.success,
      icon: Icons.check_circle_outline_rounded,
    );
  }

  /// Feedback d'erreur (fond rouge).
  static void error(BuildContext context, String message) {
    _show(
      context,
      message: message,
      backgroundColor: AppColors.error,
      icon: Icons.error_outline_rounded,
    );
  }

  /// Feedback d'avertissement (fond ambre).
  static void warning(BuildContext context, String message) {
    _show(
      context,
      message: message,
      backgroundColor: AppColors.warning,
      icon: Icons.warning_amber_rounded,
    );
  }

  /// Feedback informatif (fond gris foncé).
  static void info(BuildContext context, String message) {
    _show(
      context,
      message: message,
      backgroundColor: const Color(0xFF374151),
      icon: Icons.info_outline_rounded,
    );
  }
}
