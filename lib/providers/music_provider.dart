import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/music_track.dart';
import '../models/scoreboard_telemetry.dart';
import '../repositories/music_library_repository.dart';
import '../utils/commands.dart';
import 'connection_provider.dart';

class MusicState {
  final bool playing;
  final bool muted;
  final int volume;
  final bool repeat;
  final bool shuffle;
  final String? currentTitle;
  final List<MusicTrack> tracks;
  final String? lastError;

  const MusicState({
    this.playing = false,
    this.muted = false,
    this.volume = 20,
    this.repeat = false,
    this.shuffle = false,
    this.currentTitle,
    this.tracks = const [],
    this.lastError,
  });

  MusicState copyWith({
    bool? playing,
    bool? muted,
    int? volume,
    bool? repeat,
    bool? shuffle,
    String? currentTitle,
    List<MusicTrack>? tracks,
    String? lastError,
    bool clearError = false,
  }) {
    return MusicState(
      playing: playing ?? this.playing,
      muted: muted ?? this.muted,
      volume: volume ?? this.volume,
      repeat: repeat ?? this.repeat,
      shuffle: shuffle ?? this.shuffle,
      currentTitle: currentTitle ?? this.currentTitle,
      tracks: tracks ?? this.tracks,
      lastError: clearError ? null : (lastError ?? this.lastError),
    );
  }
}

final musicLibraryRepositoryProvider = Provider<MusicLibraryRepository>((ref) {
  return MusicLibraryRepository();
});

final musicProvider = NotifierProvider<MusicNotifier, MusicState>(
  MusicNotifier.new,
);

class MusicNotifier extends Notifier<MusicState> {
  StreamSubscription<ScoreboardTelemetry>? _telemetrySub;

  @override
  MusicState build() {
    final tracks = ref.watch(musicLibraryRepositoryProvider).load();
    ref.listen(connectionProvider, (previous, next) {
      if (next.isLive) {
        _listenTelemetry();
      } else {
        unawaited(_telemetrySub?.cancel());
        _telemetrySub = null;
      }
    });
    ref.onDispose(() => unawaited(_telemetrySub?.cancel()));
    return MusicState(tracks: tracks);
  }

  void _listenTelemetry() {
    unawaited(_telemetrySub?.cancel());
    _telemetrySub = ref.read(scoreboardConnectionProvider).telemetry.listen(
      (telemetry) {
        if (telemetry is TrackTelemetry) {
          state = state.copyWith(currentTitle: telemetry.title);
        }
      },
    );
  }

  Future<void> play() async {
    state = state.copyWith(playing: true, clearError: true);
    await _send(ScoreboardCommands.play);
  }

  Future<void> pause() async {
    state = state.copyWith(playing: false, clearError: true);
    await _send(ScoreboardCommands.pause);
  }

  Future<void> next() async {
    state = state.copyWith(clearError: true);
    await _send(ScoreboardCommands.next);
  }

  Future<void> previous() async {
    state = state.copyWith(clearError: true);
    await _send(ScoreboardCommands.prev);
  }

  Future<void> volumeUp() async {
    state = state.copyWith(
      volume: (state.volume + 1).clamp(0, 30),
      clearError: true,
    );
    await _send(ScoreboardCommands.volUp);
  }

  Future<void> volumeDown() async {
    state = state.copyWith(
      volume: (state.volume - 1).clamp(0, 30),
      clearError: true,
    );
    await _send(ScoreboardCommands.volDown);
  }

  Future<void> mute() async {
    state = state.copyWith(muted: true, clearError: true);
    await _send(ScoreboardCommands.mute);
  }

  Future<void> unmute() async {
    state = state.copyWith(muted: false, clearError: true);
    await _send(ScoreboardCommands.unmute);
  }

  Future<void> toggleRepeat() async {
    state = state.copyWith(repeat: !state.repeat, clearError: true);
    await _send(ScoreboardCommands.repeat);
  }

  Future<void> toggleShuffle() async {
    state = state.copyWith(shuffle: !state.shuffle, clearError: true);
    await _send(ScoreboardCommands.shuffle);
  }

  Future<void> playTrack(int number) async {
    MusicTrack? track;
    for (final t in state.tracks) {
      if (t.number == number) {
        track = t;
        break;
      }
    }
    state = state.copyWith(
      playing: true,
      currentTitle: track?.title,
      clearError: true,
    );
    await _send(ScoreboardCommands.playTrack(number));
  }

  Future<void> _send(String command) async {
    try {
      await ref.read(scoreboardConnectionProvider).send(command);
    } catch (error) {
      state = state.copyWith(lastError: error.toString());
    }
  }
}
