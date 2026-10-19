import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_icons.dart';
import 'app_dialogs.dart';

/// Centralise tous les retours visuels de l'application.
///
/// Par défaut, les messages sont affichés dans un **popup** (voir [AppDialogs]).
/// Les confirmations mineures et très fréquentes (ex. réglages) utilisent
/// [AppFeedback.toast], un message discret non bloquant.
///
/// Utilisation :
/// ```dart
/// AppFeedback.success(context, 'Livraison validée !');
/// AppFeedback.error(context, 'Connexion échouée.', title: 'Connexion impossible');
/// AppFeedback.warning(context, 'Champ manquant.');
/// AppFeedback.info(context, 'Synchronisation en cours…');
/// AppFeedback.toast(context, 'Paramètre enregistré.');
/// ```
class AppFeedback {
  AppFeedback._(); // Non-instantiable

  // ── Popups (par défaut) ───────────────────────────────────────────────────

  /// Popup de succès. Le Future se termine à la fermeture du popup.
  static Future<void> success(
    BuildContext context,
    String message, {
    String? title,
  }) {
    return AppDialogs.showSuccessDialog(context, message, title: title);
  }

  /// Popup d'erreur.
  static Future<void> error(
    BuildContext context,
    String message, {
    String? title,
  }) {
    return AppDialogs.showErrorDialog(context, message, title: title);
  }

  /// Popup d'avertissement.
  static Future<void> warning(
    BuildContext context,
    String message, {
    String? title,
  }) {
    return AppDialogs.showWarningDialog(context, message, title: title);
  }

  /// Popup informatif.
  static Future<void> info(
    BuildContext context,
    String message, {
    String? title,
  }) {
    return AppDialogs.showInfoDialog(context, message, title: title);
  }

  // ── Toast discret (confirmations mineures) ────────────────────────────────

  /// Message bref non bloquant, réservé aux confirmations mineures.
  static void toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFF1E293B),
          behavior: SnackBarBehavior.floating,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          content: Row(
            children: [
              const Icon(AppIcons.checkCircle,
                  color: AppColors.navBarYellow, size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
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
}
