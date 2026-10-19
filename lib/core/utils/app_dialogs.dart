import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_icons.dart';

/// Nature d'un message affiché dans un popup.
enum _MessageKind { success, error, warning, info }

class AppDialogs {
  AppDialogs._(); // Non-instantiable

  /// File d'attente : garantit qu'un seul popup de message est affiché à la
  /// fois (les suivants s'affichent après fermeture du précédent).
  static Future<void> _tail = Future<void>.value();

  // ── Gabarit commun ────────────────────────────────────────────────────────

  /// Carte sobre : fine barre d'accent, titre avec petite icône, message,
  /// zone d'actions alignée à droite.
  static Widget _dialogShell({
    required BuildContext context,
    required Color accent,
    required IconData icon,
    required String title,
    required String message,
    required List<Widget> actions,
  }) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(height: 3, color: accent),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Row(
                children: [
                  Icon(icon, size: 20, color: accent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _primaryButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(96, 40),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onPressed,
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  static Widget _secondaryButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
        side: const BorderSide(color: AppColors.border),
        minimumSize: const Size(96, 40),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onPressed,
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  /// Affiche un popup de message (mis en file d'attente).
  /// [onConfirm] est appelé après fermeture, uniquement si le contexte est
  /// toujours valide. Le Future retourné se termine à la fermeture du popup.
  static Future<void> _showMessage(
    BuildContext context, {
    required _MessageKind kind,
    required String message,
    String? title,
    String? buttonLabel,
    bool barrierDismissible = true,
    VoidCallback? onConfirm,
  }) {
    final (Color accent, IconData icon, String defaultTitle, String defaultButton) =
        switch (kind) {
      _MessageKind.success => (
          AppColors.primary,
          AppIcons.checkCircle,
          'Opération réussie',
          'OK',
        ),
      _MessageKind.error => (
          AppColors.error,
          AppIcons.error,
          'Erreur',
          'Fermer',
        ),
      _MessageKind.warning => (
          AppColors.warning,
          AppIcons.alertTriangle,
          'Attention',
          'OK',
        ),
      _MessageKind.info => (
          AppColors.accentBlue,
          AppIcons.info,
          'Information',
          'OK',
        ),
    };

    var displayed = false;
    final next = _tail.then((_) async {
      if (!context.mounted) return;
      displayed = true;
      await showDialog<void>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (dialogContext) => _dialogShell(
          context: dialogContext,
          accent: accent,
          icon: icon,
          title: title ?? defaultTitle,
          message: message,
          actions: [
            _primaryButton(
              label: buttonLabel ?? defaultButton,
              color: accent,
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ],
        ),
      );
    });
    _tail = next.catchError((_) {});
    return next.then((_) {
      if (displayed) onConfirm?.call();
    });
  }

  // ── Popups de message ─────────────────────────────────────────────────────

  /// Dialog de succès professionnel.
  static Future<void> showSuccessDialog(
    BuildContext context,
    String message, {
    String? title,
    VoidCallback? onConfirm,
  }) {
    return _showMessage(
      context,
      kind: _MessageKind.success,
      message: message,
      title: title,
      barrierDismissible: onConfirm == null,
      onConfirm: onConfirm,
    );
  }

  /// Dialog d'erreur professionnel.
  static Future<void> showErrorDialog(
    BuildContext context,
    String message, {
    String? title,
  }) {
    return _showMessage(
      context,
      kind: _MessageKind.error,
      message: message,
      title: title,
    );
  }

  /// Dialog d'avertissement professionnel.
  static Future<void> showWarningDialog(
    BuildContext context,
    String message, {
    String? title,
  }) {
    return _showMessage(
      context,
      kind: _MessageKind.warning,
      message: message,
      title: title,
    );
  }

  /// Dialog informatif professionnel.
  static Future<void> showInfoDialog(
    BuildContext context,
    String message, {
    String? title,
  }) {
    return _showMessage(
      context,
      kind: _MessageKind.info,
      message: message,
      title: title,
    );
  }

  /// Dialog de confirmation professionnel (ex: Déconnexion).
  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
    required String cancelText,
    bool isDestructive = false,
  }) async {
    final accent = isDestructive ? AppColors.error : AppColors.primary;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => _dialogShell(
        context: dialogContext,
        accent: accent,
        icon: isDestructive ? AppIcons.alertTriangle : AppIcons.info,
        title: title,
        message: message,
        actions: [
          _secondaryButton(
            label: cancelText,
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
          const SizedBox(width: 10),
          _primaryButton(
            label: confirmText,
            color: accent,
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Dialogue de confirmation de livraison fidèle au portail IGESCOM
  static Future<bool> showDeliveryConfirmationDialog(
    BuildContext context, {
    required String blNumber,
  }) async {
    final cleanBl = blNumber.replaceFirst('BL-', '').replaceFirst('#', '').trim();
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Confirmation de livraison',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(false),
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(AppIcons.close, size: 18, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Voulez-vous confirmer la livraison du BL $cleanBl ?',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF64748B),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    onPressed: () => Navigator.of(context).pop(false),
                    icon: const Icon(AppIcons.close, size: 15),
                    label: const Text('Annuler', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                    icon: const Icon(AppIcons.checkCircle, size: 15),
                    label: const Text('Oui, valider', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return result ?? false;
  }
}
