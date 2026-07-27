import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TimerMode { countUp, countdown }

class TimerState {
  final TimerMode mode;
  final Duration duration;
  final bool running;

  const TimerState({
    this.mode = TimerMode.countUp,
    this.duration = Duration.zero,
    this.running = false,
  });

  TimerState copyWith({
    TimerMode? mode,
    Duration? duration,
    bool? running,
  }) {
    return TimerState(
      mode: mode ?? this.mode,
      duration: duration ?? this.duration,
      running: running ?? this.running,
    );
  }
}

final timerProvider = NotifierProvider<TimerNotifier, TimerState>(
  TimerNotifier.new,
);

class TimerNotifier extends Notifier<TimerState> {
  Timer? _ticker;
  DateTime? _startedAt;
  Duration _accumulated = Duration.zero;
  Duration _countdownTarget = Duration.zero;

  @override
  TimerState build() {
    ref.onDispose(_stopTicker);
    return const TimerState();
  }

  void setMode(TimerMode mode) {
    _stopTicker();
    _accumulated = Duration.zero;
    _startedAt = null;
    _countdownTarget = Duration.zero;
    state = TimerState(mode: mode);
  }

  void setCountdown(Duration target) {
    _stopTicker();
    _accumulated = Duration.zero;
    _startedAt = null;
    _countdownTarget = target;
    state = TimerState(
      mode: TimerMode.countdown,
      duration: target,
    );
  }

  void start() {
    if (state.running) {
      return;
    }
    _startedAt = DateTime.now();
    state = state.copyWith(running: true);
    _startTicker();
  }

  void pause() {
    if (!state.running) {
      return;
    }
    final startedAt = _startedAt;
    if (startedAt != null) {
      _accumulated += DateTime.now().difference(startedAt);
    }
    if (state.mode == TimerMode.countdown) {
      final remaining = _countdownTarget - _accumulated;
      state = state.copyWith(duration: remaining, running: false);
    } else {
      state = state.copyWith(duration: _accumulated, running: false);
    }
    _startedAt = null;
    _stopTicker();
  }

  void resume() {
    if (state.running) {
      return;
    }
    _startedAt = DateTime.now();
    state = state.copyWith(running: true);
    _startTicker();
  }

  void reset() {
    _stopTicker();
    _accumulated = Duration.zero;
    _startedAt = null;
    if (state.mode == TimerMode.countdown) {
      state = TimerState(
        mode: TimerMode.countdown,
        duration: _countdownTarget,
      );
    } else {
      state = const TimerState();
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final startedAt = _startedAt;
    if (startedAt == null) {
      return;
    }

    final elapsed = _accumulated + DateTime.now().difference(startedAt);

    if (state.mode == TimerMode.countUp) {
      state = state.copyWith(duration: elapsed);
      return;
    }

    final remaining = _countdownTarget - elapsed;
    if (remaining <= Duration.zero) {
      _accumulated = Duration.zero;
      _startedAt = null;
      _stopTicker();
      state = state.copyWith(duration: Duration.zero, running: false);
      return;
    }
    state = state.copyWith(duration: remaining);
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }
}
