import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lucid_core_flutter/lucid_core_flutter.dart';

import 'demo_theme.dart';
import 'mock_api.dart';

/// Un scénario exécutable depuis l'interface.
class _Scenario {
  const _Scenario({
    required this.title,
    required this.summary,
    required this.route,
    required this.icon,
    this.useCache = false,
  });

  final String title;
  final String summary;
  final String route;
  final IconData icon;
  final bool useCache;
}

const List<_Scenario> _scenarios = <_Scenario>[
  _Scenario(
    title: 'Succès, puis cache',
    summary:
        'Le premier appel passe par le réseau. Relance : la réponse vient du cache.',
    route: MockRoutes.profile,
    icon: Icons.bolt_outlined,
    useCache: true,
  ),
  _Scenario(
    title: 'Retry sur 5xx',
    summary:
        'Deux 503 consécutifs, puis succès. RetryInterceptor rejoue la requête.',
    route: MockRoutes.flaky,
    icon: Icons.refresh,
  ),
  _Scenario(
    title: 'Jeton expiré (401)',
    summary:
        'Mappé en AuthenticationException et déclenche le rappel onUnauthorized.',
    route: MockRoutes.unauthorized,
    icon: Icons.lock_outline,
  ),
  _Scenario(
    title: 'Introuvable (404)',
    summary:
        'Erreur définitive : aucun rejeu. Le message du corps est perdu (voir README).',
    route: MockRoutes.notFound,
    icon: Icons.search_off,
  ),
  _Scenario(
    title: 'Délai dépassé',
    summary:
        'Échec transport sans réponse HTTP, rejoué puis mappé en NetworkException.',
    route: MockRoutes.timeout,
    icon: Icons.timer_off_outlined,
  ),
];

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  late final MockApiAdapter _adapter;
  late final LucidApiClient _client;

  final List<MockCall> _calls = <MockCall>[];

  _Scenario? _running;
  _Scenario? _lastRun;
  LucidApiClientResponse<dynamic>? _response;
  Duration _elapsed = Duration.zero;
  bool _unauthorizedFired = false;

  @override
  void initState() {
    super.initState();

    _adapter = MockApiAdapter(
      onCall: (MockCall call) {
        if (mounted) setState(() => _calls.add(call));
      },
    );

    _client = LucidApiClient(
      LucidApiClientConfig(
        baseUrl: 'https://api.demo.lucidforge.africa',
        retryAttempts: 3,
        // Raccourci par rapport aux 2 s par défaut : le rejeu doit rester
        // visible à l'écran sans faire patienter.
        retryDelay: const Duration(milliseconds: 300),
        cacheTimeout: const Duration(minutes: 1),
      ),
      onUnauthorized: () {
        if (mounted) setState(() => _unauthorizedFired = true);
      },
    );

    // Le cœur de la démonstration : on remplace le client réseau réel, pas les
    // intercepteurs. Toute la chaîne de LucidApiClient reste donc exercée.
    _client.dio.httpClientAdapter = _adapter;
  }

  @override
  void dispose() {
    _client.close(force: true);
    super.dispose();
  }

  Future<void> _run(_Scenario scenario) async {
    setState(() {
      _running = scenario;
      _lastRun = scenario;
      _response = null;
      _calls.clear();
      _unauthorizedFired = false;
    });

    final Stopwatch watch = Stopwatch()..start();
    final LucidApiClientResponse<dynamic> response = await _client.get<dynamic>(
      scenario.route,
      useCache: scenario.useCache,
    );
    watch.stop();

    if (!mounted) return;
    setState(() {
      _running = null;
      _response = response;
      _elapsed = watch.elapsed;
    });
  }

  Future<void> _reset() async {
    await _client.clearClassCache();
    _adapter.reset();

    if (!mounted) return;
    setState(() {
      _calls.clear();
      _response = null;
      _lastRun = null;
      _elapsed = Duration.zero;
      _unauthorizedFired = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const _Header(),
            const Divider(),
            Expanded(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final bool wide = constraints.maxWidth >= 860;
                  if (wide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        SizedBox(width: 380, child: _buildScenarios()),
                        const VerticalDivider(
                          color: DemoTokens.line,
                          width: 1,
                          thickness: 1,
                        ),
                        Expanded(child: _buildResult()),
                      ],
                    );
                  }
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _buildScenarios(shrinkWrap: true),
                        const Divider(),
                        _buildResult(shrinkWrap: true),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScenarios({bool shrinkWrap = false}) {
    return ListView.separated(
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
      padding: const EdgeInsets.all(DemoTokens.gapMd),
      itemCount: _scenarios.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: DemoTokens.gapSm),
      itemBuilder: (BuildContext context, int index) {
        if (index == _scenarios.length) {
          return Padding(
            padding: const EdgeInsets.only(top: DemoTokens.gapSm),
            child: OutlinedButton.icon(
              onPressed: _running == null ? _reset : null,
              icon: const Icon(Icons.restart_alt, size: 18),
              label: const Text('Vider le cache et les compteurs'),
            ),
          );
        }

        final _Scenario scenario = _scenarios[index];
        return _ScenarioCard(
          scenario: scenario,
          busy: identical(_running, scenario),
          disabled: _running != null,
          selected: identical(_lastRun, scenario),
          onRun: () => _run(scenario),
        );
      },
    );
  }

  Widget _buildResult({bool shrinkWrap = false}) {
    if (_running != null) {
      return const _CenteredState(
        icon: Icons.sync,
        title: 'Requête en cours',
        detail: 'Latence simulée, rejeu éventuel en cours.',
        spinning: true,
      );
    }

    final LucidApiClientResponse<dynamic>? response = _response;
    if (response == null) {
      return const _CenteredState(
        icon: Icons.terminal,
        title: 'Aucun appel pour le moment',
        detail:
            'Choisis un scénario à gauche pour voir la réponse et le journal réseau.',
      );
    }

    return SingleChildScrollView(
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
      padding: const EdgeInsets.all(DemoTokens.gapMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _ResponseSummary(
            response: response,
            elapsed: _elapsed,
            unauthorizedFired: _unauthorizedFired,
          ),
          const SizedBox(height: DemoTokens.gapMd),
          _Panel(
            title: 'Journal réseau',
            trailing: Text(
              _calls.isEmpty ? 'aucun passage' : '${_calls.length} passage(s)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            child: _calls.isEmpty
                ? const Text(
                    'Aucune requête n\'a atteint le réseau : la réponse vient du cache.',
                    style: TextStyle(color: DemoTokens.info, fontSize: 13),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      for (final MockCall call in _calls) _CallRow(call: call),
                    ],
                  ),
          ),
          const SizedBox(height: DemoTokens.gapMd),
          _Panel(
            title: 'Charge utile',
            child: SelectableText(
              _pretty(response.data),
              style: const TextStyle(
                fontFamily: DemoTokens.mono,
                fontSize: 12.5,
                height: 1.5,
                color: DemoTokens.textMid,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _pretty(dynamic data) {
    if (data == null) return '— aucune donnée —';
    try {
      return const JsonEncoder.withIndent('  ').convert(data);
    } on JsonUnsupportedObjectError {
      return data.toString();
    }
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DemoTokens.gapMd,
        DemoTokens.gapMd,
        DemoTokens.gapMd,
        DemoTokens.gapMd,
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: DemoTokens.accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(DemoTokens.gapSm),
              border: Border.all(
                color: DemoTokens.accent.withValues(alpha: 0.4),
              ),
            ),
            child: const Icon(
              Icons.hub_outlined,
              size: 18,
              color: DemoTokens.accent,
            ),
          ),
          const SizedBox(width: DemoTokens.gapSm + DemoTokens.gapXs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'LucidApiClient',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  'lucid_core_flutter · API simulée, aucun appel réseau réel',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScenarioCard extends StatelessWidget {
  const _ScenarioCard({
    required this.scenario,
    required this.busy,
    required this.disabled,
    required this.selected,
    required this.onRun,
  });

  final _Scenario scenario;
  final bool busy;
  final bool disabled;
  final bool selected;
  final VoidCallback onRun;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? DemoTokens.raised : DemoTokens.surface,
      borderRadius: BorderRadius.circular(DemoTokens.radius),
      child: InkWell(
        onTap: disabled ? null : onRun,
        borderRadius: BorderRadius.circular(DemoTokens.radius),
        child: Container(
          padding: const EdgeInsets.all(DemoTokens.gapMd),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DemoTokens.radius),
            border: Border.all(
              color: selected ? DemoTokens.accent : DemoTokens.line,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 24,
                height: 24,
                child: busy
                    ? const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: DemoTokens.accent,
                      )
                    : Icon(
                        scenario.icon,
                        size: 20,
                        color: disabled
                            ? DemoTokens.textLow
                            : DemoTokens.accent,
                      ),
              ),
              const SizedBox(width: DemoTokens.gapSm + DemoTokens.gapXs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      scenario.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: DemoTokens.gapXs),
                    Text(
                      scenario.summary,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: DemoTokens.gapSm),
                    Row(
                      children: <Widget>[
                        _Tag(
                          label: 'GET ${scenario.route}',
                          color: DemoTokens.textLow,
                        ),
                        const SizedBox(width: DemoTokens.gapXs + 2),
                        _Tag(
                          label: scenario.useCache
                              ? 'cache actif'
                              : 'cache ignoré',
                          color: scenario.useCache
                              ? DemoTokens.info
                              : DemoTokens.textLow,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResponseSummary extends StatelessWidget {
  const _ResponseSummary({
    required this.response,
    required this.elapsed,
    required this.unauthorizedFired,
  });

  final LucidApiClientResponse<dynamic> response;
  final Duration elapsed;
  final bool unauthorizedFired;

  @override
  Widget build(BuildContext context) {
    final bool success = response.success;
    final Color tone = success ? DemoTokens.ok : DemoTokens.danger;

    return Container(
      padding: const EdgeInsets.all(DemoTokens.gapMd),
      decoration: BoxDecoration(
        color: DemoTokens.surface,
        borderRadius: BorderRadius.circular(DemoTokens.radius),
        border: Border.all(color: tone.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                success ? Icons.check_circle_outline : Icons.error_outline,
                color: tone,
                size: 20,
              ),
              const SizedBox(width: DemoTokens.gapSm),
              Text(
                success ? 'Réponse reçue' : 'Requête en échec',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: tone),
              ),
            ],
          ),
          if (response.message != null) ...<Widget>[
            const SizedBox(height: DemoTokens.gapSm),
            Text(
              response.message!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: DemoTokens.gapMd),
          Wrap(
            spacing: DemoTokens.gapSm,
            runSpacing: DemoTokens.gapSm,
            children: <Widget>[
              _Tag(
                label: 'statut ${response.statusCode ?? '—'}',
                color: success ? DemoTokens.ok : DemoTokens.danger,
              ),
              _Tag(
                label: response.fromCache
                    ? 'servi par le cache'
                    : 'servi par le réseau',
                color: response.fromCache
                    ? DemoTokens.info
                    : DemoTokens.textLow,
              ),
              _Tag(
                label: '${elapsed.inMilliseconds} ms',
                color: DemoTokens.textLow,
              ),
              if (unauthorizedFired)
                const _Tag(
                  label: 'onUnauthorized déclenché',
                  color: DemoTokens.warn,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CallRow extends StatelessWidget {
  const _CallRow({required this.call});

  final MockCall call;

  @override
  Widget build(BuildContext context) {
    final int? status = call.statusCode;
    final Color tone = status == null
        ? DemoTokens.warn
        : status < 300
        ? DemoTokens.ok
        : status < 500
        ? DemoTokens.danger
        : DemoTokens.warn;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DemoTokens.gapXs + 1),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 30,
            child: Text(
              '#${call.attempt}',
              style: const TextStyle(
                fontFamily: DemoTokens.mono,
                fontSize: 12,
                color: DemoTokens.textLow,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${call.method} ${call.path}',
              style: const TextStyle(
                fontFamily: DemoTokens.mono,
                fontSize: 12.5,
                color: DemoTokens.textMid,
              ),
            ),
          ),
          _Tag(label: status?.toString() ?? 'transport', color: tone),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DemoTokens.gapMd),
      decoration: BoxDecoration(
        color: DemoTokens.surface,
        borderRadius: BorderRadius.circular(DemoTokens.radius),
        border: Border.all(color: DemoTokens.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              ?trailing,
            ],
          ),
          const SizedBox(height: DemoTokens.gapSm + DemoTokens.gapXs),
          child,
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DemoTokens.gapSm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(DemoTokens.gapXs + 2),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: DemoTokens.mono,
          fontSize: 11.5,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _CenteredState extends StatelessWidget {
  const _CenteredState({
    required this.icon,
    required this.title,
    required this.detail,
    this.spinning = false,
  });

  final IconData icon;
  final String title;
  final String detail;
  final bool spinning;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DemoTokens.gapXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (spinning)
              const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: DemoTokens.accent,
                ),
              )
            else
              Icon(icon, size: 30, color: DemoTokens.textLow),
            const SizedBox(height: DemoTokens.gapMd),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: DemoTokens.gapXs),
            SizedBox(
              width: 340,
              child: Text(
                detail,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
