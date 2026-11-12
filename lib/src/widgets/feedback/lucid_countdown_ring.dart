import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// Un anneau qui se remplit avec le temps (ou toute part d'un tout), avec un
/// contenu au centre : le décompte d'une étape, un nombre de répétitions…
///
/// ```dart
/// LucidCountdownRing(
///   progress: controller.stepProgress ?? 0,
///   semanticLabel: 'Gainage',
///   semanticValue: '25 secondes restantes',
///   child: Text('0:25'),
/// )
/// ```
///
/// L'arc part du haut et tourne dans le sens des aiguilles d'une montre.
/// [progress] est ramené entre 0 et 1. Sans [color], l'anneau prend la couleur
/// principale du thème ; sans [trackColor], une teinte discrète de la surface.
///
/// Avec un [semanticLabel], le lecteur d'écran lit le libellé et
/// [semanticValue], pas le contenu du centre : y mettre un bouton suppose de
/// laisser [semanticLabel] vide.
class LucidCountdownRing extends StatelessWidget {
  const LucidCountdownRing({
    super.key,
    required this.progress,
    this.child,
    this.size = 240,
    this.strokeWidth = 12,
    this.color,
    this.trackColor,
    this.semanticLabel,
    this.semanticValue,
  }) : assert(size > 0 && strokeWidth > 0, 'size et strokeWidth sont positifs');

  /// Clé de la peinture de l'anneau, pour les tests.
  static const Key paintKey = ValueKey('lucid-countdown-ring');

  final double progress;
  final Widget? child;
  final double size;
  final double strokeWidth;
  final Color? color;
  final Color? trackColor;
  final String? semanticLabel;
  final String? semanticValue;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      container: true,
      label: semanticLabel,
      value: semanticValue,
      // Avec un libellé, l'anneau se lit seul : le décompte du centre
      // redirait la valeur.
      excludeSemantics: semanticLabel != null,
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          key: paintKey,
          painter: _RingPainter(
            progress: progress.isNaN ? 0 : progress.clamp(0, 1).toDouble(),
            strokeWidth: strokeWidth,
            color: color ?? scheme.primary,
            trackColor: trackColor ?? scheme.surfaceContainerHighest,
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
    required this.trackColor,
  });

  final double progress;
  final double strokeWidth;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final circle = rect.deflate(strokeWidth / 2);
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = trackColor;
    canvas.drawArc(circle, 0, 2 * math.pi, false, track);
    if (progress <= 0) return;
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(circle, -math.pi / 2, 2 * math.pi * progress, false, arc);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.strokeWidth != strokeWidth ||
      old.color != color ||
      old.trackColor != trackColor;
}
