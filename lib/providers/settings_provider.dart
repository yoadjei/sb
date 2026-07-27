import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';
import '../repositories/settings_repository.dart';
import 'score_provider.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main.dart',
  );
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(sharedPreferencesProvider));
});

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    return ref.watch(settingsRepositoryProvider).load();
  }

  ThemeMode get themeMode {
    switch (state.theme) {
      case ThemePreference.light:
        return ThemeMode.light;
      case ThemePreference.dark:
        return ThemeMode.dark;
      case ThemePreference.system:
        return ThemeMode.system;
    }
  }

  Future<void> update(AppSettings settings) async {
    state = settings;
    await ref.read(settingsRepositoryProvider).save(settings);
  }

  Future<void> setTheme(ThemePreference theme) async {
    await update(state.copyWith(theme: theme));
  }

  Future<void> resetAppData() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.clear();
    await ref.read(matchHistoryRepositoryProvider).clear();
    state = const AppSettings();
    await ref.read(settingsRepositoryProvider).save(state);
  }
}

final themeModeProvider = Provider<ThemeMode>((ref) {
  switch (ref.watch(settingsProvider).theme) {
    case ThemePreference.light:
      return ThemeMode.light;
    case ThemePreference.dark:
      return ThemeMode.dark;
    case ThemePreference.system:
      return ThemeMode.system;
  }
});
