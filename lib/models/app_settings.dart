enum ThemePreference { light, dark, system }

class AppSettings {
  final ThemePreference theme;
  final bool scoreIncrementSound;
  final bool animationsEnabled;
  final bool enableBackgroundMusic;
  final bool autoPlayOnGameStart;
  final bool stopMusicOnGameEnd;
  final int defaultVolume; // 0-30 DFPlayer style
  final bool soundEffectsEnabled;

  const AppSettings({
    this.theme = ThemePreference.system,
    this.scoreIncrementSound = true,
    this.animationsEnabled = true,
    this.enableBackgroundMusic = true,
    this.autoPlayOnGameStart = true,
    this.stopMusicOnGameEnd = true,
    this.defaultVolume = 20,
    this.soundEffectsEnabled = true,
  });

  AppSettings copyWith({
    ThemePreference? theme,
    bool? scoreIncrementSound,
    bool? animationsEnabled,
    bool? enableBackgroundMusic,
    bool? autoPlayOnGameStart,
    bool? stopMusicOnGameEnd,
    int? defaultVolume,
    bool? soundEffectsEnabled,
  }) {
    return AppSettings(
      theme: theme ?? this.theme,
      scoreIncrementSound: scoreIncrementSound ?? this.scoreIncrementSound,
      animationsEnabled: animationsEnabled ?? this.animationsEnabled,
      enableBackgroundMusic:
          enableBackgroundMusic ?? this.enableBackgroundMusic,
      autoPlayOnGameStart: autoPlayOnGameStart ?? this.autoPlayOnGameStart,
      stopMusicOnGameEnd: stopMusicOnGameEnd ?? this.stopMusicOnGameEnd,
      defaultVolume: defaultVolume ?? this.defaultVolume,
      soundEffectsEnabled: soundEffectsEnabled ?? this.soundEffectsEnabled,
    );
  }
}
