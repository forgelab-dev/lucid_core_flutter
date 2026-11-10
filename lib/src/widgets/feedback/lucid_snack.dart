import 'package:flutter/material.dart';

/// Le message court du bas d'écran : une pastille compacte, ajustée à son
/// texte, au lieu du bandeau Material sur toute la largeur.
///
/// ```dart
/// LucidSnack.show(context, message: 'Dépense enregistrée.', icon: Icons.check_rounded);
///
/// // Avec une action, le message part quand même seul (6 s par défaut) :
/// LucidSnack.show(context, message: 'Opération supprimée.', actionLabel: 'Annuler', onAction: restore);
/// ```
///
/// Après un `await` ou un `pop`, capturez d'abord le [ScaffoldMessengerState]
/// et passez par [LucidSnack.showOn].
///
/// Les couleurs viennent de `SnackBarThemeData` (`backgroundColor`,
/// `contentTextStyle`, `actionTextColor`), à défaut des couleurs inverses du
/// [ColorScheme] : chaque app garde sa charte sans réglage supplémentaire.
abstract final class LucidSnack {
  /// Clé de la pastille, pour la retrouver dans les tests.
  static const Key pillKey = ValueKey('lucid-snack-pill');

  static const Duration _shortDuration = Duration(seconds: 4);
  static const Duration _actionDuration = Duration(seconds: 6);

  /// Affiche le message dans le [ScaffoldMessenger] de [context], en
  /// remplaçant celui qui serait déjà à l'écran.
  static void show(
    BuildContext context, {
    required String message,
    IconData? icon,
    Color? iconColor,
    String? actionLabel,
    VoidCallback? onAction,
    Duration? duration,
  }) {
    showOn(
      ScaffoldMessenger.of(context),
      message: message,
      icon: icon,
      iconColor: iconColor,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  /// Comme [show], sur un messager capturé avant un `await` ou un `pop`.
  static void showOn(
    ScaffoldMessengerState messenger, {
    required String message,
    IconData? icon,
    Color? iconColor,
    String? actionLabel,
    VoidCallback? onAction,
    Duration? duration,
  }) {
    final context = messenger.context;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final width = _measureWidth(
      Theme.of(context),
      MediaQuery.textScalerOf(context),
      message: message,
      hasIcon: icon != null,
      actionLabel: onAction != null ? actionLabel : null,
    );
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        bar(
          message: message,
          icon: icon,
          iconColor: iconColor,
          actionLabel: actionLabel,
          onAction: onAction,
          duration: duration,
          width: width.clamp(0, screenWidth - 2 * _screenMargin),
        ),
      );
  }

  static const double _maxWidth = 480;
  static const double _screenMargin = 16;
  static const double _iconSpace = 18 + 10;
  static const double _actionGap = 4;
  static const double _actionPadding = 14;

  static double _startPadding({required bool hasIcon}) => hasIcon ? 14 : 18;
  static double _endPadding({required bool hasAction}) => hasAction ? 4 : 18;

  static TextStyle _textStyle(ThemeData theme) {
    final foreground =
        theme.snackBarTheme.contentTextStyle?.color ??
        theme.colorScheme.onInverseSurface;
    return (theme.textTheme.bodyMedium ?? const TextStyle())
        .merge(theme.snackBarTheme.contentTextStyle)
        .copyWith(
          color: foreground,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.3,
        );
  }

  /// Largeur de la pastille. Le SnackBar flottant prend sinon toute la largeur
  /// de l'écran et, même transparent, avale les touchers autour de la
  /// pastille (un bouton dessous resterait visible mais inaccessible).
  static double _measureWidth(
    ThemeData theme,
    TextScaler textScaler, {
    required String message,
    required bool hasIcon,
    required String? actionLabel,
  }) {
    final style = _textStyle(theme);
    double measure(
      String text,
      TextStyle style,
      double maxWidth,
      int maxLines,
    ) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
        textScaler: textScaler,
        maxLines: maxLines,
      )..layout(maxWidth: maxWidth);
      final widest = painter.computeLineMetrics().fold(
        0.0,
        (w, line) => line.width > w ? line.width : w,
      );
      painter.dispose();
      return widest.ceilToDouble() + 1;
    }

    var fixed =
        _startPadding(hasIcon: hasIcon) +
        _endPadding(hasAction: actionLabel != null);
    if (hasIcon) fixed += _iconSpace;
    if (actionLabel != null) {
      final label = measure(
        actionLabel,
        style.copyWith(fontWeight: FontWeight.w700),
        double.infinity,
        1,
      );
      fixed +=
          _actionGap + (label + 2 * _actionPadding).clamp(44, double.infinity);
    }
    return fixed + measure(message, style, _maxWidth - fixed, 2);
  }

  /// Le [SnackBar] lui-même, pour qui veut l'afficher à sa façon. Sans
  /// [width], il occupe toute la largeur et bloque les touchers autour de la
  /// pastille : [show] et [showOn] la calculent.
  static SnackBar bar({
    required String message,
    IconData? icon,
    Color? iconColor,
    String? actionLabel,
    VoidCallback? onAction,
    Duration? duration,
    double? width,
  }) {
    assert(
      (actionLabel == null) == (onAction == null),
      'actionLabel et onAction vont ensemble',
    );
    final hasAction = actionLabel != null && onAction != null;
    return SnackBar(
      // Le SnackBar ne sert que de porteur : transparent, sans ombre ni marge
      // intérieure. La pastille dessine tout.
      backgroundColor: Colors.transparent,
      elevation: 0,
      padding: EdgeInsets.zero,
      behavior: SnackBarBehavior.floating,
      width: width,
      showCloseIcon: false,
      // Avec une action, Flutter garderait le message tant qu'on ne le touche
      // pas : il part seul, l'action ayant simplement plus de temps.
      persist: false,
      duration: duration ?? (hasAction ? _actionDuration : _shortDuration),
      dismissDirection: DismissDirection.horizontal,
      content: _LucidSnackPill(
        message: message,
        icon: icon,
        iconColor: iconColor,
        actionLabel: hasAction ? actionLabel : null,
        onAction: hasAction ? onAction : null,
      ),
    );
  }
}

class _LucidSnackPill extends StatelessWidget {
  const _LucidSnackPill({
    required this.message,
    required this.icon,
    required this.iconColor,
    required this.actionLabel,
    required this.onAction,
  });

  final String message;
  final IconData? icon;
  final Color? iconColor;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final snackTheme = theme.snackBarTheme;
    final colors = theme.colorScheme;
    final background = snackTheme.backgroundColor ?? colors.inverseSurface;
    final actionColor = snackTheme.actionTextColor ?? colors.inversePrimary;
    final textStyle = LucidSnack._textStyle(theme);
    final foreground = textStyle.color!;
    final action = actionLabel;

    return Center(
      child: ConstrainedBox(
        key: LucidSnack.pillKey,
        constraints: const BoxConstraints(
          minHeight: 44,
          maxWidth: LucidSnack._maxWidth,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 18,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              start: LucidSnack._startPadding(hasIcon: icon != null),
              end: LucidSnack._endPadding(hasAction: action != null),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: iconColor ?? foreground),
                  const SizedBox(width: 10),
                ],
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      message,
                      style: textStyle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                if (action != null) ...[
                  const SizedBox(width: LucidSnack._actionGap),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: actionColor,
                      minimumSize: const Size(44, 40),
                      padding: const EdgeInsets.symmetric(
                        horizontal: LucidSnack._actionPadding,
                      ),
                      shape: const StadiumBorder(),
                      textStyle: textStyle.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      tapTargetSize: MaterialTapTargetSize.padded,
                    ),
                    onPressed: () {
                      onAction?.call();
                      ScaffoldMessenger.of(context).hideCurrentSnackBar(
                        reason: SnackBarClosedReason.action,
                      );
                    },
                    child: Text(action),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
