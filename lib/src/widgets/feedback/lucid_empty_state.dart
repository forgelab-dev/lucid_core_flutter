import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart' show LucidL10n;
import '../../core/core.dart';

/// L'état vide générique : une seule définition, réutilisée partout où une
/// liste/collection peut être vide ([LucidListManager] y compris), pour ne
/// jamais dupliquer ce texte ou ce visuel d'un écran à l'autre.
///
/// Le texte par défaut vient de [LucidL10n] (`noResults`) ; il se dégrade
/// proprement en français si le widget est utilisé sans [LucidApp]/délégués
/// de localisation installés.
class LucidEmptyState extends StatelessWidget {
  const LucidEmptyState({super.key, this.icon = Icons.inbox_outlined, this.title, this.message, this.action});

  final IconData icon;
  final String? title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final l10n = LucidL10n.of(context);
    final colors = context.colors;
    final isDark = context.isDarkTheme;
    final accent = colors.tertiary;
    // Dégradé de surface issu du thème (tokens gradientStart/gradientEnd) ;
    // repli sur la teinte accent si le thème ne les définit pas.
    final theme = context.currentTheme;
    final gradientStart = theme.gradientStart ?? accent.withValues(alpha: 0.16);
    final gradientEnd = theme.gradientEnd ?? accent.withValues(alpha: 0.05);

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
              // Pastille or (ou navy en clair) : l'accent de la charte
              // « Or sur Nuit », réservé aux moments de respiration.
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
                  border: Border.all(color: accent.withValues(alpha: 0.18)),
                ),
                child: Icon(icon, size: 36, color: isDark ? accent : colors.primary),
              ),
              const SizedBox(height: 20),
              Text(
                title ?? l10n?.noResults ?? 'Aucun résultat',
                style: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              if (message != null) ...[
                const SizedBox(height: 8),
                Text(
                  message!,
                  style: context.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant, height: 1.5),
                  textAlign: TextAlign.center,
                ),
              ],
              if (action != null) ...[const SizedBox(height: 24), action!],
            ],
          ),
        ),
      ),
    );
  }
}
