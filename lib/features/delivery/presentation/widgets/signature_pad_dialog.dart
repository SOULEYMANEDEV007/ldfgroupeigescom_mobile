import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';

/// Résultat retourné après validation de la signature
class SignatureResult {
  final String signedBy;
  final String signatureData;

  const SignatureResult({
    required this.signedBy,
    required this.signatureData,
  });
}

/// Modale tactile d'émargement électronique pour tablette et mobile.
class SignaturePadDialog extends StatefulWidget {
  final String blNumber;
  final String initialClientName;

  const SignaturePadDialog({
    super.key,
    required this.blNumber,
    required this.initialClientName,
  });

  /// Affiche la modale d'émargement et retourne le résultat de signature
  static Future<SignatureResult?> show(
    BuildContext context, {
    required String blNumber,
    required String initialClientName,
  }) {
    return showDialog<SignatureResult>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => SignaturePadDialog(
        blNumber: blNumber,
        initialClientName: initialClientName,
      ),
    );
  }

  @override
  State<SignaturePadDialog> createState() => _SignaturePadDialogState();
}

class _SignaturePadDialogState extends State<SignaturePadDialog> {
  late final TextEditingController _nameController;
  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];
  Size _canvasSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialClientName.trim());
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _clearSignature() {
    setState(() {
      _strokes.clear();
      _currentStroke.clear();
    });
  }

  /// Sérialise les traits en coordonnées normalisées [0..1]
  String _serializeStrokes() {
    if (_strokes.isEmpty || _canvasSize.width <= 0 || _canvasSize.height <= 0) {
      return '';
    }

    final buffer = StringBuffer();
    for (int i = 0; i < _strokes.length; i++) {
      if (i > 0) buffer.write('|');
      final stroke = _strokes[i];
      for (int j = 0; j < stroke.length; j++) {
        if (j > 0) buffer.write(';');
        final p = stroke[j];
        final nx = (p.dx / _canvasSize.width).clamp(0.0, 1.0);
        final ny = (p.dy / _canvasSize.height).clamp(0.0, 1.0);
        buffer.write('${nx.toStringAsFixed(3)},${ny.toStringAsFixed(3)}');
      }
    }
    return buffer.toString();
  }

  void _confirm() {
    final signedBy = _nameController.text.trim();
    if (signedBy.isEmpty) return;
    if (_strokes.isEmpty) return;

    final signatureData = _serializeStrokes();
    Navigator.of(context).pop(
      SignatureResult(
        signedBy: signedBy,
        signatureData: signatureData,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasSignature = _strokes.isNotEmpty;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── En-tête ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      AppIcons.edit,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Émargement Client — ${widget.blNumber}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Faites signer le réceptionnaire avec le doigt ou un stylet',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(AppIcons.x, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Fermer',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Champ Nom du Réceptionnaire ──
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nom & Prénom du réceptionnaire *',
                  hintText: 'Ex: M. KOUASSI (Magasinier)',
                  prefixIcon: const Icon(AppIcons.user, size: 18),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Zone de Dessin Tactile (Signature Pad) ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'SIGNATURE MANUSCRITE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (hasSignature)
                    InkWell(
                      onTap: _clearSignature,
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        child: Row(
                          children: const [
                            Icon(AppIcons.rotateCcw, size: 13, color: AppColors.error),
                            SizedBox(width: 4),
                            Text(
                              'Effacer',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),

              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: hasSignature ? AppColors.primary : const Color(0xFFCBD5E1),
                    width: hasSignature ? 1.5 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      _canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
                      return Stack(
                        children: [
                          // Ligne de signature de base (en filigrane)
                          Positioned(
                            left: 20,
                            right: 20,
                            bottom: 40,
                            child: Container(
                              height: 1,
                              color: const Color(0xFFE2E8F0),
                            ),
                          ),
                          Positioned(
                            left: 20,
                            bottom: 22,
                            child: Row(
                              children: const [
                                Icon(AppIcons.edit, size: 12, color: Color(0xFF94A3B8)),
                                SizedBox(width: 5),
                                Text(
                                  'Signez à l\'intérieur du cadre',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF94A3B8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Surface de dessin
                          GestureDetector(
                            onPanStart: (details) {
                              setState(() {
                                _currentStroke = [details.localPosition];
                                _strokes.add(_currentStroke);
                              });
                            },
                            onPanUpdate: (details) {
                              setState(() {
                                _currentStroke.add(details.localPosition);
                              });
                            },
                            onPanEnd: (_) {
                              setState(() {
                                _currentStroke = [];
                              });
                            },
                            child: CustomPaint(
                              size: Size.infinite,
                              painter: _StrokesPainter(strokes: _strokes),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Boutons d'Action ──
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Annuler',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: hasSignature ? _confirm : null,
                      icon: const Icon(AppIcons.checkCircle, size: 18),
                      label: const Text('Valider & Émarger'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.3),
                        disabledForegroundColor: Colors.white70,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Painter fluide pour le dessin des traits de signature
class _StrokesPainter extends CustomPainter {
  final List<List<Offset>> strokes;

  _StrokesPainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0F2F64) // Bleu stylo officiel LdF
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 2.8
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.isEmpty) continue;
      if (stroke.length == 1) {
        canvas.drawCircle(stroke.first, 1.4, paint..style = PaintingStyle.fill);
        paint.style = PaintingStyle.stroke;
        continue;
      }

      final path = Path();
      path.moveTo(stroke.first.dx, stroke.first.dy);
      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StrokesPainter oldDelegate) => true;
}

/// Widget affichant une signature sérialisée sur n'importe quel conteneur (ex: PDF)
class SignatureViewer extends StatelessWidget {
  final String signatureData;
  final Color strokeColor;
  final double strokeWidth;

  const SignatureViewer({
    super.key,
    required this.signatureData,
    this.strokeColor = const Color(0xFF0F2F64),
    this.strokeWidth = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    if (signatureData.isEmpty) {
      return const SizedBox.shrink();
    }

    return CustomPaint(
      size: Size.infinite,
      painter: _SerializedSignaturePainter(
        data: signatureData,
        strokeColor: strokeColor,
        strokeWidth: strokeWidth,
      ),
    );
  }
}

class _SerializedSignaturePainter extends CustomPainter {
  final String data;
  final Color strokeColor;
  final double strokeWidth;

  _SerializedSignaturePainter({
    required this.data,
    required this.strokeColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || size.width <= 0 || size.height <= 0) return;

    final paint = Paint()
      ..color = strokeColor
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final strokeChunks = data.split('|');
    for (final chunk in strokeChunks) {
      if (chunk.isEmpty) continue;
      final pointChunks = chunk.split(';');
      if (pointChunks.isEmpty) continue;

      final points = <Offset>[];
      for (final pt in pointChunks) {
        final coords = pt.split(',');
        if (coords.length == 2) {
          final nx = double.tryParse(coords[0]) ?? 0.0;
          final ny = double.tryParse(coords[1]) ?? 0.0;
          points.add(Offset(nx * size.width, ny * size.height));
        }
      }

      if (points.isEmpty) continue;
      if (points.length == 1) {
        canvas.drawCircle(points.first, strokeWidth / 2, paint..style = PaintingStyle.fill);
        paint.style = PaintingStyle.stroke;
        continue;
      }

      final path = Path();
      path.moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SerializedSignaturePainter oldDelegate) =>
      oldDelegate.data != data;
}
