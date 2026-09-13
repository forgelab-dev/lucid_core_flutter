import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart' show LucidL10n;
import '../../core/core.dart';
import '../buttons/lucid_button.dart';

/// L'état d'erreur générique : une seule définition, réutilisée partout où
/// un chargement peut échouer, pour ne jamais dupliquer ce texte ou ce
/// visuel d'un écran à l'autre.
///
/// Les textes par défaut viennent de [LucidL10n] (`somethingWentWrong`,
/// `tryAgainLater`) ; ils se dégradent proprement en français si le widget
/// est utilisé sans [LucidApp]/délégués de localisation installés.
class LucidErrorState extends StatelessWidget {
  const LucidErrorState({super.key, this.icon = Icons.error_outline, this.title, this.message, this.onRetry});

  final IconData icon;
  final String? title;
  final String? message;
  final VoidCallback? onRetry;

  /// Construit un [LucidErrorState] à partir d'une [LucidAbstractException]
  /// déjà levée par un service (API, auth, storage...), pour ne pas
  /// reformuler son message à la main à chaque écran.
  factory LucidErrorState.fromException(LucidAbstractException exception, {VoidCallback? onRetry}) {
    return LucidErrorState(message: exception.message, onRetry: onRetry);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = LucidL10n.of(context);
    final colors = context.colors;
    // Dégradé de surface issu du thème (tokens gradientStart/gradientEnd) ;
    // repli sur la teinte erreur si le thème ne les définit pas.
    final theme = context.currentTheme;
    final gradientStart = theme.gradientStart ?? colors.error.withValues(alpha: 0.16);
    final gradientEnd = theme.gradientEnd ?? colors.error.withValues(alpha: 0.05);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        // Entrée douce (fondu + léger zoom) à chaque apparition de l'état.
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          tween: Tween(begin: 0, end: 1),
          builder: (context, t, child) => Opacity(
            opacity: t,
            child: Transform.scale(scale: 0.94 + 0.06 * t, child: child),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [gradientStart, gradientEnd],
                  ),
                  border: Border.all(color: colors.error.withValues(alpha: 0.2)),
                ),
                child: Icon(icon, size: 36, color: colors.error),
              ),
              const SizedBox(height: 20),
              Text(
                title ?? l10n?.somethingWentWrong ?? 'Une erreur est survenue',
                style: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message ?? l10n?.tryAgainLater ?? 'Veuillez réessayer plus tard',
                style: context.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant, height: 1.5),
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[const SizedBox(height: 24), LucidRetryButton(onPressed: onRetry!)],
            ],
          ),
        ),
      ),
    );
  }
}
