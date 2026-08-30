import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppGradients {
  /// Gradient principal des headers (vert foncé → vert LdF)
  static const LinearGradient primaryHeader = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primaryDark, AppColors.primary],
  );

  /// Gradient doux pour les cartes actives
  static const LinearGradient primarySubtle = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, AppColors.primaryLight],
  );

  /// Gradient jaune (splash, accents)
  static const LinearGradient yellow = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFE033), AppColors.navBarYellow],
  );

  /// Gradient succès (validation de livraison)
  static const LinearGradient success = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0EA572), AppColors.success],
  );

  /// Gradient erreur (signalement d'échec)
  static const LinearGradient error = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFDC2626), AppColors.error],
  );
}
