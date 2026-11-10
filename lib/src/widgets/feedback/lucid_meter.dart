import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'lucid_privacy.dart';

/// Où en est une jauge par rapport à son maximum.
enum LucidMeterLevel { normal, warning, over }

/// Une jauge horizontale : ce qui est atteint sur un maximum (dépenses sur un
/// budget, pas sur un objectif…), et, au besoin, où l'on finira à ce rythme.
///
/// ```dart
/// LucidMeter(
///   value: 45000,
///   max: 60000,
///   projected: 72000, // prolonge la barre en plus clair
///   semanticLabel: 'Courses',
///   semanticValue: '45 000 F sur 60 000 F',
/// )
/// ```
///
/// La couleur dit le niveau : [color] tant qu'on reste sous [warningAt] du
/// maximum, [warningColor] ensuite, [overColor] au-delà du maximum. La partie
/// prévue est hachurée, dans la couleur de son propre niveau : une prévision de
/// dépassement se voit avant le dépassement, sans se confondre avec le fond.
///
/// Dans une [LucidPrivacyScope] en mode masqué, le lecteur d'écran lit la part
/// atteinte (« 75 % ») au lieu de [semanticValue], qui contient souvent des
/// montants. La jauge elle-même ne montre que des proportions.
class LucidMeter extends StatelessWidget {
  const LucidMeter({
    super.key,
    required this.value,
    required this.max,
    this.projected,
    this.warningAt = 0.8,
    this.color,
    this.warningColor,
    this.overColor,
    this.trackColor,
    this.height = 8,
    this.semanticLabel,
    this.semanticValue,
  }) : assert(max > 0, 'max doit être positif'),
       assert(
         warningAt > 0 && warningAt <= 1,
         'warningAt est une fraction du maximum, entre 0 et 1',
       );

  /// Clés de la partie atteinte et de la partie prévue, pour les tests.
  static const Key valueKey = ValueKey('lucid-meter-value');
  static const Key projectedKey = ValueKey('lucid-meter-projected');

  /// Couleur d'alerte par défaut : le [ColorScheme] n'a pas de rôle
  /// « avertissement ». Un ambre lisible sur fond clair comme sombre.
  static const Color defaultWarningColor = Color(0xFFD99A0B);

  final num value;
  final num max;

  /// Valeur attendue en fin de période ; ignorée si elle ne dépasse pas
  /// [value].
  final num? projected;

  /// Part du maximum à partir de laquelle la jauge passe en alerte.
  final double warningAt;

  /// Par défaut la couleur primaire du thème.
  final Color? color;

  /// Par défaut [defaultWarningColor].
  final Color? warningColor;

  /// Par défaut la couleur d'erreur du thème.
  final Color? overColor;

  /// Fond de la jauge ; par défaut `surfaceContainerHighest`.
  final Color? trackColor;
  final double height;

  /// Ce que mesure la jauge (« Courses »).
  final String? semanticLabel;

  /// La valeur lue au lecteur d'écran ; par défaut la part atteinte.
  final String? semanticValue;

  /// Le niveau de [value] sur [max] : utile à l'application pour colorer un
  /// texte voisin ou prévenir au franchissement d'un seuil.
  static LucidMeterLevel levelOf(num value, num max, {double warningAt = 0.8}) {
    if (value > max) return LucidMeterLevel.over;
    if (value >= max * warningAt) return LucidMeterLevel.warning;
    return LucidMeterLevel.normal;
  }

  Color _colorFor(LucidMeterLevel level, ColorScheme colors) => switch (level) {
    LucidMeterLevel.normal => color ?? colors.primary,
    LucidMeterLevel.warning => warningColor ?? defaultWarningColor,
    LucidMeterLevel.over => overColor ?? colors.error,
  };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final valueFraction = (value / max).clamp(0.0, 1.0).toDouble();
    final ahead = projected;
    final showProjected = ahead != null && ahead > value;
    final projectedFraction = showProjected
        ? (ahead / max).clamp(0.0, 1.0).toDouble()
        : 0.0;
    final radius = BorderRadius.circular(height / 2);
    final animate = !MediaQuery.disableAnimationsOf(context);

    Widget animated(Key key, double fraction, Widget child) =>
        TweenAnimationBuilder<double>(
          tween: Tween(end: fraction),
          duration: animate ? const Duration(milliseconds: 280) : Duration.zero,
          curve: Curves.easeOutCubic,
          child: child,
          builder: (context, widthFactor, child) => FractionallySizedBox(
            key: key,
            alignment: AlignmentDirectional.centerStart,
            widthFactor: widthFactor,
            heightFactor: 1,
            child: child,
          ),
        );

    return Semantics(
      container: true,
      label: semanticLabel,
      value: _semanticValue(context),
      excludeSemantics: true,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: trackColor ?? colors.surfaceContainerHighest,
            borderRadius: radius,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (showProjected)
                animated(
                  projectedKey,
                  projectedFraction,
                  _ProjectedSegment(
                    color: _colorFor(
                      levelOf(ahead, max, warningAt: warningAt),
                      colors,
                    ),
                    radius: radius,
                  ),
                ),
              animated(
                valueKey,
                valueFraction,
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: _colorFor(
                      levelOf(value, max, warningAt: warningAt),
                      colors,
                    ),
                    borderRadius: radius,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _semanticValue(BuildContext context) {
    final given = semanticValue;
    if (given != null && !LucidPrivacyScope.isHidden(context)) return given;
    final locale = Localizations.maybeLocaleOf(context)?.toLanguageTag();
    return NumberFormat.percentPattern(locale).format(value / max);
  }
}

/// La partie prévue : un voile léger de la couleur du niveau, barré de
/// hachures. Un aplat translucide se mélangeait au fond de la jauge (un rouge
/// sur bleu nuit devenait mauve) et se lisait comme le fond lui-même.
class _ProjectedSegment extends StatelessWidget {
  const _ProjectedSegment({required this.color, required this.radius});

  final Color color;
  final BorderRadius radius;

  /// Opacité du voile sous les hachures.
  static const double veil = 0.18;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: radius,
      child: DecoratedBox(
        decoration: BoxDecoration(color: color.withValues(alpha: veil)),
        child: CustomPaint(painter: _HatchPainter(color)),
      ),
    );
  }
}

class _HatchPainter extends CustomPainter {
  const _HatchPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..strokeWidth = 2;
    const gap = 6.0;
    // Des traits à 45°, de la gauche du segment jusqu'au-delà de sa droite.
    for (var x = -size.height; x < size.width; x += gap) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_HatchPainter old) => old.color != color;
}
