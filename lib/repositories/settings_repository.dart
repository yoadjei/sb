import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';

class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _keyTheme = 'settings.theme';
  static const _keyScoreIncrementSound = 'settings.scoreIncrementSound';
  static const _keyAnimationsEnabled = 'settings.animationsEnabled';
  static const _keyEnableBackgroundMusic = 'settings.enableBackgroundMusic';
  static const _keyAutoPlayOnGameStart = 'settings.autoPlayOnGameStart';
  static const _keyStopMusicOnGameEnd = 'settings.stopMusicOnGameEnd';
  static const _keyDefaultVolume = 'settings.defaultVolume';
  static const _keySoundEffectsEnabled = 'settings.soundEffectsEnabled';

  AppSettings load() {
    try {
      final themeIndex = _prefs.getInt(_keyTheme);
      final theme = themeIndex != null &&
              themeIndex >= 0 &&
              themeIndex < ThemePreference.values.length
          ? ThemePreference.values[themeIndex]
          : ThemePreference.system;

      return AppSettings(
        theme: theme,
        scoreIncrementSound:
            _prefs.getBool(_keyScoreIncrementSound) ?? true,
        animationsEnabled: _prefs.getBool(_keyAnimationsEnabled) ?? true,
        enableBackgroundMusic:
            _prefs.getBool(_keyEnableBackgroundMusic) ?? true,
        autoPlayOnGameStart:
            _prefs.getBool(_keyAutoPlayOnGameStart) ?? true,
        stopMusicOnGameEnd: _prefs.getBool(_keyStopMusicOnGameEnd) ?? true,
        defaultVolume: _prefs.getInt(_keyDefaultVolume) ?? 20,
        soundEffectsEnabled:
            _prefs.getBool(_keySoundEffectsEnabled) ?? true,
      );
    } catch (_) {
      return const AppSettings();
    }
  }

  Future<void> save(AppSettings settings) async {
    try {
      await _prefs.setInt(_keyTheme, settings.theme.index);
      await _prefs.setBool(
          _keyScoreIncrementSound, settings.scoreIncrementSound);
      await _prefs.setBool(_keyAnimationsEnabled, settings.animationsEnabled);
      await _prefs.setBool(
          _keyEnableBackgroundMusic, settings.enableBackgroundMusic);
      await _prefs.setBool(
          _keyAutoPlayOnGameStart, settings.autoPlayOnGameStart);
      await _prefs.setBool(
          _keyStopMusicOnGameEnd, settings.stopMusicOnGameEnd);
      await _prefs.setInt(_keyDefaultVolume, settings.defaultVolume);
      await _prefs.setBool(
          _keySoundEffectsEnabled, settings.soundEffectsEnabled);
    } catch (_) {
      // Persist failures should not crash callers.
    }
  }
}
