import 'dart:async';

import 'package:flutter/foundation.dart';

/// Ce que fait une étape d'une séance : un effort, ou une pause.
enum LucidIntervalKind { work, rest }

/// Une étape d'une séance par intervalles : chronométrée ([duration]) ou
/// comptée ([reps], terminée quand la personne le dit).
///
/// ```dart
/// const LucidIntervalStep.timed('Gainage', Duration(seconds: 40));
/// const LucidIntervalStep.counted('Pompes', 12);
/// const LucidIntervalStep.timed('Repos', Duration(seconds: 20), kind: LucidIntervalKind.rest);
/// ```
@immutable
class LucidIntervalStep {
  const LucidIntervalStep.timed(
    this.label,
    Duration this.duration, {
    this.kind = LucidIntervalKind.work,
  }) : reps = null;

  const LucidIntervalStep.counted(
    this.label,
    int this.reps, {
    this.kind = LucidIntervalKind.work,
  }) : duration = null;

  final String label;
  final LucidIntervalKind kind;

  /// Durée d'une étape chronométrée ; `null` pour une étape comptée.
  final Duration? duration;

  /// Répétitions d'une étape comptée ; `null` pour une étape chronométrée.
  final int? reps;

  bool get isTimed => duration != null;

  @override
  bool operator ==(Object other) =>
      other is LucidIntervalStep &&
      other.label == label &&
      other.kind == kind &&
      other.duration == duration &&
      other.reps == reps;

  @override
  int get hashCode => Object.hash(label, kind, duration, reps);
}

/// État d'un [LucidIntervalController].
enum LucidIntervalStatus { ready, running, paused, finished }

/// Déroule une liste de [LucidIntervalStep] : une étape chronométrée passe à
/// la suivante d'elle-même, une étape comptée attend [complete].
///
/// Le temps se lit sur l'horloge ([clock]) et non en comptant des tops : une
/// application mise en arrière-plan retrouve, au retour, l'étape où elle en
/// serait, quitte à en avoir passé plusieurs. Le temps en pause ne compte pas
/// dans [elapsed].
///
/// ```dart
/// final controller = LucidIntervalController(
///   steps: const [
///     LucidIntervalStep.counted('Squats', 15),
///     LucidIntervalStep.timed('Repos', Duration(seconds: 30), kind: LucidIntervalKind.rest),
///     LucidIntervalStep.timed('Gainage', Duration(seconds: 45)),
///   ],
///   onStep: (index) => HapticFeedback.heavyImpact(),
/// )..start();
/// ```
///
/// Un minuteur interne relit l'horloge toutes les [tickEvery] tant que la
/// séance tourne ; les tests passent `tickEvery: null` et appellent [update].
class LucidIntervalController extends ChangeNotifier {
  LucidIntervalController({
    required List<LucidIntervalStep> steps,
    DateTime Function()? clock,
    this.tickEvery = const Duration(milliseconds: 200),
    this.onStep,
  }) : assert(steps.isNotEmpty, 'une séance a au moins une étape'),
       steps = List.unmodifiable(steps),
       _clock = clock ?? DateTime.now;

  final List<LucidIntervalStep> steps;
  final DateTime Function() _clock;

  /// Fréquence de relecture de l'horloge ; `null` : seulement par [update].
  final Duration? tickEvery;

  /// Appelé à chaque changement d'étape, avec l'index de la nouvelle étape, et
  /// avec `steps.length` à la fin de la séance (vibration, son…).
  final void Function(int index)? onStep;

  LucidIntervalStatus _status = LucidIntervalStatus.ready;
  int _index = 0;

  /// Temps actif accumulé avant le segment en cours.
  Duration _activeBefore = Duration.zero;

  /// Début du segment actif en cours (depuis le départ ou la reprise).
  DateTime? _segmentStart;

  /// Temps actif au début de l'étape en cours.
  Duration _stepStartActive = Duration.zero;

  Timer? _timer;

  LucidIntervalStatus get status => _status;
  int get index => _index;
  LucidIntervalStep get current => steps[_index.clamp(0, steps.length - 1)];
  LucidIntervalStep? get next =>
      _index + 1 < steps.length ? steps[_index + 1] : null;
  bool get isFinished => _status == LucidIntervalStatus.finished;

  /// Temps actif depuis le départ, pauses exclues.
  Duration get elapsed {
    final start = _segmentStart;
    if (_status != LucidIntervalStatus.running || start == null) {
      return _activeBefore;
    }
    return _activeBefore + _clock().difference(start);
  }

  /// Temps passé dans l'étape en cours.
  Duration get stepElapsed => elapsed - _stepStartActive;

  /// Ce qui reste de l'étape chronométrée en cours ; `null` pour une étape comptée.
  Duration? get remaining {
    final duration = current.duration;
    if (duration == null) return null;
    if (isFinished) return Duration.zero;
    final left = duration - stepElapsed;
    return left.isNegative ? Duration.zero : left;
  }

  /// Part écoulée de l'étape chronométrée en cours, de 0 à 1 ; `null` pour une étape comptée.
  double? get stepProgress {
    final duration = current.duration;
    if (duration == null) return null;
    if (isFinished || duration == Duration.zero) return 1;
    return (stepElapsed.inMicroseconds / duration.inMicroseconds)
        .clamp(0, 1)
        .toDouble();
  }

  void start() {
    if (_status != LucidIntervalStatus.ready) return;
    _run();
    notifyListeners();
    onStep?.call(_index);
  }

  void pause() {
    if (_status != LucidIntervalStatus.running) return;
    update();
    if (_status != LucidIntervalStatus.running) return;
    _activeBefore = elapsed;
    _segmentStart = null;
    _status = LucidIntervalStatus.paused;
    _stopTimer();
    notifyListeners();
  }

  void resume() {
    if (_status != LucidIntervalStatus.paused) return;
    _run();
    notifyListeners();
  }

  /// Termine l'étape en cours (comptée ou non) et passe à la suivante.
  void complete() {
    if (_status != LucidIntervalStatus.running &&
        _status != LucidIntervalStatus.paused) {
      return;
    }
    _advance(elapsed);
    notifyListeners();
  }

  /// Relit l'horloge : passe les étapes chronométrées échues.
  void update() {
    if (_status != LucidIntervalStatus.running) return;
    while (_status == LucidIntervalStatus.running) {
      final duration = current.duration;
      if (duration == null) break;
      final end = _stepStartActive + duration;
      if (elapsed < end) break;
      // L'étape suivante commence à la fin exacte de celle-ci, pas au moment de la lecture.
      _advance(end);
    }
    // Même sans changement d'étape, le décompte affiché doit se redessiner.
    notifyListeners();
  }

  void _run() {
    _segmentStart = _clock();
    _status = LucidIntervalStatus.running;
    final every = tickEvery;
    if (every != null) _timer = Timer.periodic(every, (_) => update());
  }

  void _advance(Duration stepEnd) {
    if (_index + 1 >= steps.length) {
      _activeBefore = stepEnd;
      _segmentStart = null;
      _index = steps.length - 1;
      _status = LucidIntervalStatus.finished;
      _stopTimer();
      onStep?.call(steps.length);
      return;
    }
    _index++;
    _stepStartActive = stepEnd;
    onStep?.call(_index);
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
