import 'package:material_ui/material_ui.dart';

/// La carte à utiliser dans un projet LucidForge : une surface du thème,
/// bordée d'un filet discret, aux coins de [CardThemeData.shape].
///
/// Deux variantes :
/// - [LucidCard] : contenu statique (un résumé, un bloc d'informations) ;
/// - [LucidCard.interactive] : toute la carte réagit au toucher (ondulation,
///   focus clavier, sémantique de bouton). Avec `onTap` nul, elle s'affiche
///   désactivée.
///
/// [selected] remplace le filet par un trait de la couleur `primary` : pour
/// une carte choisie dans une liste (profil, offre, option).
///
/// Ne dépend que de `Theme.of(context)`, pas de `LucidThemeProvider` : la
/// carte suit le thème clair ou sombre de n'importe quelle application.
class LucidCard extends StatelessWidget {
  /// Carte statique, sans réaction au toucher.
  const LucidCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.selected = false,
    this.color,
  }) : onTap = null,
       onLongPress = null,
       semanticLabel = null,
       _interactive = false;

  /// Carte entièrement cliquable. [semanticLabel] remplace, pour les lecteurs
  /// d'écran, le texte lu dans [child] quand celui-ci ne suffit pas.
  const LucidCard.interactive({
    super.key,
    required this.child,
    required this.onTap,
    this.onLongPress,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.selected = false,
    this.color,
    this.semanticLabel,
  }) : _interactive = true;

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  /// Met la carte en avant (trait `primary` de 2 px au lieu du filet).
  final bool selected;

  /// Fond de la carte ; par défaut `cardTheme.color`, sinon `colorScheme.surface`.
  final Color? color;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? semanticLabel;
  final bool _interactive;

  /// Rayon utilisé quand le thème ne définit pas de forme arrondie.
  static const double defaultRadius = 16;

  /// Opacité d'une carte interactive désactivée.
  static const double disabledOpacity = 0.5;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final radius = _radius(theme, Directionality.maybeOf(context));

    final shape = RoundedRectangleBorder(
      borderRadius: radius,
      side: selected ? BorderSide(color: colors.primary, width: 2) : BorderSide(color: colors.outlineVariant),
    );
    final background = color ?? theme.cardTheme.color ?? colors.surface;

    if (!_interactive) {
      return Padding(
        padding: margin,
        child: Material(
          color: background,
          shape: shape,
          clipBehavior: Clip.antiAlias,
          child: Padding(padding: padding, child: child),
        ),
      );
    }

    final enabled = onTap != null || onLongPress != null;
    final card = Material(
      color: background,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        customBorder: shape,
        // Avec [semanticLabel], le texte de la carte n'est pas lu en plus : on
        // l'exclut lui seul, pas l'InkWell, qui porte les actions toucher/focus.
        child: Padding(
          padding: padding,
          child: semanticLabel != null ? ExcludeSemantics(child: child) : child,
        ),
      ),
    );

    return Padding(
      padding: margin,
      // Une seule entrée pour les lecteurs d'écran : le bouton et le texte de
      // la carte fusionnés, ou [semanticLabel] s'il est fourni.
      child: MergeSemantics(
        child: Semantics(
          button: true,
          enabled: enabled,
          selected: selected,
          label: semanticLabel,
          child: enabled ? card : Opacity(opacity: disabledOpacity, child: card),
        ),
      ),
    );
  }

  BorderRadius _radius(ThemeData theme, TextDirection? direction) {
    final shape = theme.cardTheme.shape;
    if (shape is RoundedRectangleBorder) {
      return shape.borderRadius.resolve(direction);
    }
    return BorderRadius.circular(defaultRadius);
  }
}
