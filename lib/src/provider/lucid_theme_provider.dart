import 'package:flutter/material.dart';

import '../core/core.dart';

class LucidThemeProvider extends StatefulWidget {
  const LucidThemeProvider({super.key, required this.child, this.themeNotifier});

  final Widget child;
  final LucidThemeNotifier? themeNotifier;

  static LucidThemeNotifier of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<_LucidThemeInheritedNotifier>();
    assert(provider != null, 'LucidThemeProvider not found in context');
    return provider!.notifier!;
  }

  static LucidThemeNotifier? maybeOf(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<_LucidThemeInheritedNotifier>();
    return provider?.notifier;
  }

  @override
  State<LucidThemeProvider> createState() => _LucidThemeProviderState();
}

class _LucidThemeProviderState extends State<LucidThemeProvider> with WidgetsBindingObserver {
  late LucidThemeNotifier _themeNotifier;
  Brightness? _lastBrightness;

  @override
  void initState() {
    super.initState();
    _themeNotifier = widget.themeNotifier ?? LucidThemeHelper.instance;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (widget.themeNotifier == null) {
      _themeNotifier.dispose();
    }
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    if (_lastBrightness != brightness && _themeNotifier.isSystemMode) {
      _lastBrightness = brightness;
      _themeNotifier.checkSystemBrightness();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _LucidThemeInheritedNotifier(notifier: _themeNotifier, child: widget.child);
  }
}

class _LucidThemeInheritedNotifier extends InheritedNotifier<LucidThemeNotifier> {
  const _LucidThemeInheritedNotifier({required LucidThemeNotifier super.notifier, required super.child});
}
