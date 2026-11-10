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
/// prévue suit son propre niveau : une prévision de dépassement se voit avant
/// le dépassement.
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

    Widget segment(Key key, double fraction, Color fill) =>
        TweenAnimationBuilder<double>(
          tween: Tween(end: fraction),
          duration: animate ? const Duration(milliseconds: 280) : Duration.zero,
          curve: Curves.easeOutCubic,
          builder: (context, widthFactor, _) => FractionallySizedBox(
            key: key,
            alignment: AlignmentDirectional.centerStart,
            widthFactor: widthFactor,
            heightFactor: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(color: fill, borderRadius: radius),
            ),
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
                segment(
                  projectedKey,
                  projectedFraction,
                  _colorFor(
                    levelOf(ahead, max, warningAt: warningAt),
                    colors,
                  ).withValues(alpha: 0.32),
                ),
              segment(
                valueKey,
                valueFraction,
                _colorFor(levelOf(value, max, warningAt: warningAt), colors),
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
