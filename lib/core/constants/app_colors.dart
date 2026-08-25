import 'package:flutter/material.dart';

class AppColors {
  /// Couleurs Principales - Librairie de France Groupe CI
  static const Color primary = Color(
    0xFF007A33,
  ); // Vert classique LdF (Couleur dominante)
  static const Color primaryLight = Color(
    0xFF33955C,
  ); // Vert plus clair pour certains états
  static const Color secondary = Color(
    0xFFFFC107,
  ); // Jaune LdF (Accents, icônes, alertes)

  /// Backgrounds et Surfaces
  static const Color background = Color(0xFFF8F9FA); // Gris/Blanc très clair
  static const Color surface = Colors.white; // Cartes et layouts

  /// Textes
  static const Color textPrimary = Color(
    0xFF1E293B,
  ); // Gris foncé (presque noir)
  static const Color textSecondary = Color(0xFF64748B); // Gris classique

  /// Touche de bleu (comme mentionné, pour certains détails)
  static const Color accentBlue = Color(0xFF2F80ED);

  /// Feedback (Succès, erreurs, etc.)
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFFFC107);

  /// Bordures et séparateurs
  static const Color border = Color(0xFFE2E8F0);
}
