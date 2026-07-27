import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/match_record.dart';
import '../models/team.dart';
import '../repositories/match_history_repository.dart';
import '../themes/colors.dart';
import '../utils/commands.dart';
import 'connection_provider.dart';
import 'settings_provider.dart';

class ScoreState {
  final Team teamA;
  final Team teamB;
  final bool matchActive;
  final DateTime? startedAt;
  final String? lastError;

  const ScoreState({
    required this.teamA,
    required this.teamB,
    this.matchActive = false,
    this.startedAt,
    this.lastError,
  });

  ScoreState copyWith({
    Team? teamA,
    Team? teamB,
    bool? matchActive,
    DateTime? startedAt,
    String? lastError,
    bool clearError = false,
    bool clearStartedAt = false,
  }) {
    return ScoreState(
      teamA: teamA ?? this.teamA,
      teamB: teamB ?? this.teamB,
      matchActive: matchActive ?? this.matchActive,
      startedAt: clearStartedAt ? null : (startedAt ?? this.startedAt),
      lastError: clearError ? null : (lastError ?? this.lastError),
    );
  }
}

final matchHistoryRepositoryProvider = Provider<MatchHistoryRepository>((ref) {
  return MatchHistoryRepository(ref.watch(sharedPreferencesProvider));
});

final scoreProvider = NotifierProvider<ScoreNotifier, ScoreState>(
  ScoreNotifier.new,
);

class ScoreNotifier extends Notifier<ScoreState> {
  static const defaultNameA = 'Team A';
  static const defaultNameB = 'Team B';

  @override
  ScoreState build() {
    return ScoreState(
      teamA: const Team(name: defaultNameA, color: StadiumColors.accent),
      teamB: const Team(name: defaultNameB, color: StadiumColors.rival),
    );
  }

  Future<void> incrementA() async {
    state = state.copyWith(
      teamA: state.teamA.copyWith(score: state.teamA.score + 1),
      clearError: true,
    );
    await _send(ScoreboardCommands.aPlus);
  }

  Future<void> decrementA() async {
    if (state.teamA.score <= 0) {
      return;
    }
    state = state.copyWith(
      teamA: state.teamA.copyWith(score: state.teamA.score - 1),
      clearError: true,
    );
    await _send(ScoreboardCommands.aMinus);
  }

  Future<void> incrementB() async {
    state = state.copyWith(
      teamB: state.teamB.copyWith(score: state.teamB.score + 1),
      clearError: true,
    );
    await _send(ScoreboardCommands.bPlus);
  }

  Future<void> decrementB() async {
    if (state.teamB.score <= 0) {
      return;
    }
    state = state.copyWith(
      teamB: state.teamB.copyWith(score: state.teamB.score - 1),
      clearError: true,
    );
    await _send(ScoreboardCommands.bMinus);
  }

  Future<void> setNameA(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      state = state.copyWith(lastError: 'Team name cannot be empty');
      return;
    }
    state = state.copyWith(
      teamA: state.teamA.copyWith(name: trimmed),
      clearError: true,
    );
    await _send(ScoreboardCommands.nameA(trimmed));
  }

  Future<void> setNameB(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      state = state.copyWith(lastError: 'Team name cannot be empty');
      return;
    }
    state = state.copyWith(
      teamB: state.teamB.copyWith(name: trimmed),
      clearError: true,
    );
    await _send(ScoreboardCommands.nameB(trimmed));
  }

  void setColorA(Color color) {
    state = state.copyWith(
      teamA: state.teamA.copyWith(color: color),
      clearError: true,
    );
  }

  void setColorB(Color color) {
    state = state.copyWith(
      teamB: state.teamB.copyWith(color: color),
      clearError: true,
    );
  }

  Future<void> startMatch() async {
    final now = DateTime.now();
    state = state.copyWith(
      matchActive: true,
      startedAt: now,
      clearError: true,
    );
    await _send(ScoreboardCommands.start);

    final settings = ref.read(settingsProvider);
    if (settings.autoPlayOnGameStart) {
      await _send(ScoreboardCommands.play);
    }
  }

  Future<void> endMatch() async {
    final startedAt = state.startedAt;
    final teamA = state.teamA;
    final teamB = state.teamB;

    state = state.copyWith(
      matchActive: false,
      clearStartedAt: true,
      clearError: true,
    );

    await _send(ScoreboardCommands.end);

    final settings = ref.read(settingsProvider);
    if (settings.stopMusicOnGameEnd) {
      await _send(ScoreboardCommands.pause);
    }

    if (startedAt != null) {
      final durationSeconds =
          DateTime.now().difference(startedAt).inSeconds.clamp(0, 86400);
      final winner = _winner(teamA.score, teamB.score);
      final record = MatchRecord(
        id: const Uuid().v4(),
        playedAt: DateTime.now(),
        teamAName: teamA.name,
        teamBName: teamB.name,
        scoreA: teamA.score,
        scoreB: teamB.score,
        winner: winner,
        durationSeconds: durationSeconds,
      );
      try {
        await ref.read(matchHistoryRepositoryProvider).add(record);
      } catch (error) {
        state = state.copyWith(lastError: error.toString());
      }
    }
  }

  Future<void> resetMatch() async {
    state = ScoreState(
      teamA: const Team(name: defaultNameA, color: StadiumColors.accent),
      teamB: const Team(name: defaultNameB, color: StadiumColors.rival),
    );
    await _send(ScoreboardCommands.reset);
  }

  String _winner(int scoreA, int scoreB) {
    if (scoreA > scoreB) {
      return 'A';
    }
    if (scoreB > scoreA) {
      return 'B';
    }
    return 'Draw';
  }

  Future<void> _send(String command) async {
    try {
      await ref.read(scoreboardConnectionProvider).send(command);
    } catch (error) {
      state = state.copyWith(lastError: error.toString());
    }
  }
}
