import 'package:flutter/material.dart';

class AppColors {
  // ─── Verts LdF ─────────────────────────────────────────────────────────────
  /// Vert foncé : headers, gradients dark
  static const Color primaryDark = Color(0xFF005C26);

  /// Vert LdF : couleur principale
  static const Color primary = Color(0xFF007A33);

  /// Vert clair : indicateurs, icônes actives
  static const Color primaryLight = Color(0xFF33955C);

  /// Vert très doux : fonds de cartes success
  static const Color primarySoft = Color(0xFFE8F5EE);

  // ─── Jaunes LdF ────────────────────────────────────────────────────────────
  /// Jaune vif : bottom navigation bar, accents forts
  static const Color navBarYellow = Color(0xFFFFD600);

  /// Jaune doux : icônes d'état, alertes légères
  static const Color secondary = Color(0xFFFFC107);

  /// Jaune très doux : fonds de cartes warning
  static const Color secondarySoft = Color(0xFFFFFBEB);

  // ─── Backgrounds & Surfaces ────────────────────────────────────────────────
  static const Color background = Color(0xFFF4F6F8);
  static const Color surface = Colors.white;
  static const Color surfaceElevated = Color(0xFFFFFFFF);

  // ─── Textes ────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textOnPrimary = Colors.white;
  static const Color textOnYellow = Color(0xFF1E293B);

  // ─── Sémantique (Stats, Feedback) ──────────────────────────────────────────
  /// Bleu : stat "Total du jour"
  static const Color accentBlue = Color(0xFF2F80ED);
  static const Color accentBlueSoft = Color(0xFFEFF6FF);

  /// Vert : stat "Livrées" / Succès
  static const Color success = Color(0xFF10B981);
  static const Color successSoft = Color(0xFFECFDF5);

  /// Orange : stat "En attente" / Warning
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningSoft = Color(0xFFFFFBEB);

  /// Rouge : stat "Échecs" / Erreur
  static const Color error = Color(0xFFEF4444);
  static const Color errorSoft = Color(0xFFFEF2F2);

  // ─── Bordures & Dividers ───────────────────────────────────────────────────
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);
}
