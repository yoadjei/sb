import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/match_record.dart';

class MatchHistoryRepository {
  MatchHistoryRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _storageKey = 'match_history';

  List<MatchRecord> load() {
    try {
      final raw = _prefs.getString(_storageKey);
      if (raw == null || raw.isEmpty) {
        return [];
      }

      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        _overwriteWithEmpty();
        return [];
      }

      return decoded
          .map((entry) => MatchRecord.fromJson(entry as Map<String, dynamic>))
          .toList();
    } catch (_) {
      _overwriteWithEmpty();
      return [];
    }
  }

  Future<void> add(MatchRecord record) async {
    final matches = load()..add(record);
    await _save(matches);
  }

  Future<void> delete(String id) async {
    final matches = load()..removeWhere((match) => match.id == id);
    await _save(matches);
  }

  Future<void> clear() async {
    await _prefs.remove(_storageKey);
  }

  List<MatchRecord> search(List<MatchRecord> matches, String query) {
    if (query.isEmpty) {
      return matches;
    }

    final normalizedQuery = query.toLowerCase();
    return matches
        .where(
          (match) =>
              match.teamAName.toLowerCase().contains(normalizedQuery) ||
              match.teamBName.toLowerCase().contains(normalizedQuery),
        )
        .toList();
  }

  Future<void> _save(List<MatchRecord> matches) async {
    final encoded =
        jsonEncode(matches.map((match) => match.toJson()).toList());
    await _prefs.setString(_storageKey, encoded);
  }

  void _overwriteWithEmpty() {
    _prefs.setString(_storageKey, '[]');
  }
}
