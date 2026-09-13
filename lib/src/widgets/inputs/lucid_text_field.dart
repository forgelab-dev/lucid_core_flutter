import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/l10n.dart' show LucidL10n;
import '../../core/core.dart';

enum _LucidFieldKind { plain, email, password }

/// Le seul champ de texte à utiliser dans un projet LucidForge : hérite
/// automatiquement du style défini par [LucidAppTheme.toThemeData]
/// (bordures, couleurs, padding), donc rien à re-styliser par écran.
///
/// [LucidTextField.email] et [LucidTextField.password] réutilisent la
/// validation déjà définie par `LucidStringExtensions`
/// (`isValidEmail`/`isStrongPassword`) et les messages déjà traduits dans
/// [LucidL10n], plutôt que de redéfinir des regex/textes à chaque formulaire.
///
/// Le champ mot de passe affiche un toggle de visibilité (œil) — accessible
/// via [LucidL10n.toggleVisibility] — sauf si un [suffixIcon] est fourni.
class LucidTextField extends StatefulWidget {
  const LucidTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.obscureText = false,
    this.enabled = true,
    this.autofocus = false,
    this.maxLines = 1,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.prefixIcon,
    this.suffixIcon,
    this.focusNode,
    this.validator,
    this.onChanged,
    this.onSubmitted,
  }) : _kind = _LucidFieldKind.plain,
       _requireStrongPassword = true;

  /// Champ email : clavier adapté, icône, et validation via
  /// `String.isValidEmail` (message d'erreur : [LucidL10n.invalidEmail]).
  const LucidTextField.email({
    super.key,
    this.controller,
    this.label,
    this.enabled = true,
    this.autofocus = false,
    this.textInputAction,
    this.focusNode,
    this.validator,
    this.onChanged,
    this.onSubmitted,
  }) : hint = null,
       errorText = null,
       obscureText = false,
       maxLines = 1,
       keyboardType = TextInputType.emailAddress,
       inputFormatters = null,
       prefixIcon = Icons.email_outlined,
       suffixIcon = null,
       _kind = _LucidFieldKind.email,
       _requireStrongPassword = true;

  /// Champ mot de passe : masqué, icône, et validation via
  /// `String.isStrongPassword` (message d'erreur : [LucidL10n.passwordTooWeak]),
  /// désactivable via [requireStrong].
  const LucidTextField.password({
    super.key,
    this.controller,
    this.label,
    this.enabled = true,
    this.autofocus = false,
    this.textInputAction,
    this.focusNode,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    bool requireStrong = true,
  }) : hint = null,
       errorText = null,
       obscureText = true,
       maxLines = 1,
       keyboardType = null,
       inputFormatters = null,
       prefixIcon = Icons.lock_outline,
       suffixIcon = null,
       _kind = _LucidFieldKind.password,
       _requireStrongPassword = requireStrong;

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final bool obscureText;
  final bool enabled;
  final bool autofocus;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final FocusNode? focusNode;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  final _LucidFieldKind _kind;
  final bool _requireStrongPassword;

  @override
  State<LucidTextField> createState() => _LucidTextFieldState();
}

class _LucidTextFieldState extends State<LucidTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  void didUpdateWidget(covariant LucidTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscureText != widget.obscureText) {
      _obscure = widget.obscureText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = LucidL10n.of(context);
    final isPassword = widget._kind == _LucidFieldKind.password;

    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      obscureText: _obscure,
      maxLines: _obscure ? 1 : widget.maxLines,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      inputFormatters: widget.inputFormatters,
      validator: widget.validator ?? _defaultValidator(l10n),
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        labelText: widget.label ?? _defaultLabel(l10n),
        hintText: widget.hint,
        errorText: widget.errorText,
        prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
        suffixIcon: isPassword && widget.suffixIcon == null ? _buildVisibilityToggle(l10n) : widget.suffixIcon,
      ),
    );
  }

  /// Toggle œil afficher/masquer, réservé au champ mot de passe quand aucun
  /// [suffixIcon] personnalisé n'est fourni.
  Widget _buildVisibilityToggle(LucidL10n? l10n) {
    final isVisible = !_obscure;
    return IconButton(
      onPressed: widget.enabled ? () => setState(() => _obscure = !_obscure) : null,
      isSelected: isVisible,
      icon: const Icon(Icons.visibility_off_outlined),
      selectedIcon: const Icon(Icons.visibility_outlined),
      tooltip: l10n?.toggleVisibility ?? 'Basculer la visibilité',
    );
  }

  String? _defaultLabel(LucidL10n? l10n) {
    switch (widget._kind) {
      case _LucidFieldKind.email:
        return l10n?.email ?? 'Email';
      case _LucidFieldKind.password:
        return l10n?.password ?? 'Mot de passe';
      case _LucidFieldKind.plain:
        return null;
    }
  }

  FormFieldValidator<String>? _defaultValidator(LucidL10n? l10n) {
    switch (widget._kind) {
      case _LucidFieldKind.email:
        return (value) {
          if (value == null || value.isEmpty) return null;
          return value.isValidEmail ? null : (l10n?.invalidEmail ?? 'Adresse email invalide');
        };
      case _LucidFieldKind.password:
        return (value) {
          if (value == null || value.isEmpty || !widget._requireStrongPassword) return null;
          return value.isStrongPassword ? null : (l10n?.passwordTooWeak ?? 'Mot de passe trop faible');
        };
      case _LucidFieldKind.plain:
        return null;
    }
  }
}
