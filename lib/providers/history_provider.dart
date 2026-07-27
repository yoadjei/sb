import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/match_record.dart';
import '../repositories/match_history_repository.dart';
import '../utils/csv_export.dart';
import 'score_provider.dart';

class HistoryState {
  final List<MatchRecord> matches;
  final String searchQuery;
  final String? lastError;

  const HistoryState({
    this.matches = const [],
    this.searchQuery = '',
    this.lastError,
  });

  List<MatchRecord> get filteredMatches {
    if (searchQuery.isEmpty) {
      return matches;
    }
    final normalized = searchQuery.toLowerCase();
    return matches
        .where(
          (match) =>
              match.teamAName.toLowerCase().contains(normalized) ||
              match.teamBName.toLowerCase().contains(normalized),
        )
        .toList();
  }

  HistoryState copyWith({
    List<MatchRecord>? matches,
    String? searchQuery,
    String? lastError,
    bool clearError = false,
  }) {
    return HistoryState(
      matches: matches ?? this.matches,
      searchQuery: searchQuery ?? this.searchQuery,
      lastError: clearError ? null : (lastError ?? this.lastError),
    );
  }
}

final historyProvider = NotifierProvider<HistoryNotifier, HistoryState>(
  HistoryNotifier.new,
);

class HistoryNotifier extends Notifier<HistoryState> {
  MatchHistoryRepository get _repo => ref.read(matchHistoryRepositoryProvider);

  @override
  HistoryState build() {
    return HistoryState(matches: _repo.load());
  }

  void refresh() {
    state = state.copyWith(matches: _repo.load(), clearError: true);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query, clearError: true);
  }

  Future<void> delete(String id) async {
    try {
      await _repo.delete(id);
      state = state.copyWith(
        matches: _repo.load(),
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(lastError: error.toString());
    }
  }

  Future<void> clear() async {
    try {
      await _repo.clear();
      state = const HistoryState();
    } catch (error) {
      state = state.copyWith(lastError: error.toString());
    }
  }

  String exportCsv() {
    return CsvExport.fromMatches(state.filteredMatches);
  }
}
