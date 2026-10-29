import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// 🎨 Widget d'arrière-plan signature « Librairie de France Groupe »
///
/// Affiche en filigrane très subtil les symboles du groupe :
/// 📚 Livres & Cahiers (Éducation)
/// 📰 Presse & Journaux
/// 💼 Maroquinerie & Cartables
/// 💻 Informatique & Bureautique
/// ✏️ Papeterie & Écriture
///
/// Teinté aux couleurs officielles LDF (Vert & Jaune doux).
/// Zéro lag : mis en cache via RepaintBoundary et non-bloquant (IgnorePointer).
class LdfPatternBackground extends StatelessWidget {
  final Widget child;
  final bool showPattern;

  const LdfPatternBackground({
    super.key,
    required this.child,
    this.showPattern = true,
  });

  // Palette de dégradée pour le background
  static const _ldfGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE6F4EA), Color(0xFFF3F8EE), Color(0xFFFFF6D4)],
  );

  @override
  Widget build(BuildContext context) {
    if (!showPattern) {
      return Container(color: AppColors.background, child: child);
    }

    return Container(
      decoration: const BoxDecoration(gradient: _ldfGradient),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Motif en filigrane vectoriel non-interactif ──
          const RepaintBoundary(
            child: IgnorePointer(
              child: CustomPaint(painter: _LdfBrandWatermarkPainter()),
            ),
          ),

          // ── Contenu principal par-dessus ──
          child,
        ],
      ),
    );
  }
}

/// Peintre vectoriel traçant le filigrane thématique LDF Groupe
class _LdfBrandWatermarkPainter extends CustomPainter {
  const _LdfBrandWatermarkPainter();

  // Les icônes représentatives des métiers de la Librairie de France Groupe
  static const List<IconData> _ldfIcons = [
    Icons.menu_book_rounded, // 📚 Livres (Éducation)
    Icons.newspaper_rounded, // 📰 Presse & Journaux
    Icons.backpack_outlined, // 🎒 Maroquinerie & Sacs de classe
    Icons.laptop_mac_rounded, // 💻 Informatique & Multimédia
    Icons.auto_stories_rounded, // 📖 Romans & Cahiers scolaires
    Icons.work_outline_rounded, // 💼 Maroquinerie d'affaires / Serviettes
    Icons.edit_note_rounded, // ✏️ Papeterie & Écriture
  ];

  @override
  void paint(Canvas canvas, Size size) {
    // Espacement régulier entre les symboles
    const double stepX = 85.0;
    const double stepY = 85.0;
    const double iconSize = 30.0;

    // Rotation légère (-12°) façon filigrane papier de luxe
    const double angle = -12.0 * math.pi / 180.0;

    int iconIndex = 0;
    int rowIndex = 0;

    for (double y = -20; y < size.height + 60; y += stepY) {
      // Décalage quinconce une ligne sur deux pour un rendu harmonieux
      final double offsetX = (rowIndex % 2 == 1) ? stepX / 2 : 0.0;

      for (double x = -20 + offsetX; x < size.width + 60; x += stepX) {
        final icon = _ldfIcons[iconIndex % _ldfIcons.length];

        // Alternance des couleurs officielles LDF Groupe avec opacités très douces
        final Color color = (iconIndex % 3 == 0)
            ? AppColors.navBarYellow.withValues(alpha: 0.09) // 💛 Jaune LdF
            : (iconIndex % 3 == 1)
            ? AppColors.primary.withValues(alpha: 0.055) // 💚 Vert LdF
            : AppColors.primaryLight.withValues(alpha: 0.045); // 🌿 Vert doux

        /*
        // Alternance franche Vert & Jaune Doré LDF pour une netteté chirurgicale
        final Color color = (iconIndex % 2 == 0)
            ? AppColors.primary.withValues(alpha: 0.16) // 💚 Vert LdF net (16%)
            : const Color(0xFFC98A00).withValues(alpha: 0.22); // 💛 Jaune Doré LDF net (22%)
            */

        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(angle);

        final textPainter = TextPainter(textDirection: TextDirection.ltr);
        textPainter.text = TextSpan(
          text: String.fromCharCode(icon.codePoint),
          style: TextStyle(
            fontSize: iconSize,
            fontFamily: icon.fontFamily,
            package: icon.fontPackage,
            color: color,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(-textPainter.width / 2, -textPainter.height / 2),
        );

        canvas.restore();

        iconIndex++;
      }
      rowIndex++;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
