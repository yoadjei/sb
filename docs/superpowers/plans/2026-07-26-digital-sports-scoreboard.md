# Digital Sports Scoreboard Flutter App Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship a complete Flutter Android APK that controls an ESP32 sports scoreboard over Bluetooth Classic, with Simulation Mode, Stadium Night UI, music remote, history, stats, timer, and settings.

**Architecture:** Feature-first Flutter app. UI talks to Riverpod notifiers; notifiers use repositories and a `ScoreboardConnection` interface implemented by real SPP Bluetooth and an in-memory Simulation connection. Commands are centralized; inbound `BAT:`/`TRACK:`/`OK` lines are optional.

**Tech Stack:** Flutter (stable), Dart, Material 3, flutter_riverpod, shared_preferences, flutter_bluetooth_serial, permission_handler, google_fonts, flutter_colorpicker, share_plus, intl, flutter_test

**Spec:** `docs/superpowers/specs/2026-07-26-digital-sports-scoreboard-design.md`

---

## File Structure

```
digital_sports_scoreboard/          # Flutter project root (create in repo root or as package folder)
  pubspec.yaml
  README.md
  docs/
    BLUETOOTH_COMMANDS.md
    TESTING.md
  assets/
    images/
    fonts/                          # optional local fonts if not using google_fonts only
  lib/
    main.dart
    app.dart
    themes/
      colors.dart
      app_theme.dart
    utils/
      commands.dart
      status_parser.dart
      csv_export.dart
      formatters.dart
    models/
      team.dart
      match_record.dart
      bt_device.dart
      connection_status.dart
      app_settings.dart
      music_track.dart
      scoreboard_telemetry.dart
    services/
      scoreboard_connection.dart          # abstract interface
      simulation_scoreboard_connection.dart
      bluetooth_service.dart
      bluetooth_scoreboard_connection.dart
    repositories/
      settings_repository.dart
      match_history_repository.dart
      music_library_repository.dart
    providers/
      settings_provider.dart
      connection_provider.dart
      score_provider.dart
      music_provider.dart
      history_provider.dart
      timer_provider.dart
    animations/
      fade_page_route.dart
      score_pop.dart
    widgets/
      live_scoreboard_card.dart
      score_control_panel.dart
      device_card.dart
      now_playing_card.dart
      quick_music_bar.dart
      connection_banner.dart
      match_timer_bar.dart
      hub_tile.dart
      stadium_scaffold.dart
      connection_lost_dialog.dart
    screens/
      splash_screen.dart
      permissions_screen.dart
      bluetooth_scan_screen.dart
      dashboard_screen.dart
      score_control_screen.dart
      teams_screen.dart
      music_player_screen.dart
      music_library_screen.dart
      timer_screen.dart
      history_screen.dart
      statistics_screen.dart
      settings_screen.dart
      about_screen.dart
  test/
    utils/
      commands_test.dart
      status_parser_test.dart
      csv_export_test.dart
    models/
      match_record_test.dart
    services/
      simulation_scoreboard_connection_test.dart
    providers/
      score_provider_test.dart
      history_provider_test.dart
    widgets/
      live_scoreboard_card_test.dart
      connection_lost_dialog_test.dart
```

**Note:** Create the Flutter project so `lib/` lives at `./lib` in the repo root (preferred). If `flutter create .` fails due to existing docs, create into a temp name and move files up, keeping `docs/` and root design files.

---

## Task 1: Scaffold Flutter project and dependencies

**Files:**
- Create: `pubspec.yaml`, `lib/main.dart`, `lib/app.dart`, `analysis_options.yaml`, Android permission manifest entries
- Modify: Android `AndroidManifest.xml` for Bluetooth / location

- [ ] **Step 1: Verify Flutter SDK**

Run: `flutter --version`  
Expected: Flutter stable channel reported. If missing, install Flutter before continuing.

- [ ] **Step 2: Create project in repo root**

Run from `c:\Users\adjei\Downloads\score board mobile app`:

```bash
flutter create --org com.university.dss --project-name digital_sports_scoreboard .
```

If Flutter refuses non-empty directory, run:

```bash
flutter create --org com.university.dss digital_sports_scoreboard
```

Then move `lib/`, `android/`, `pubspec.yaml`, `test/`, etc. to repo root and delete the empty wrapper folder. Keep existing `docs/`, `pt.txt`, design markdown.

- [ ] **Step 3: Add dependencies to `pubspec.yaml`**

```yaml
name: digital_sports_scoreboard
description: Bluetooth-controlled Digital Sports Scoreboard operator app.
publish_to: "none"
version: 1.0.0+1

environment:
  sdk: ">=3.5.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  flutter_riverpod: ^2.6.1
  shared_preferences: ^2.3.3
  flutter_bluetooth_serial: ^0.4.0
  permission_handler: ^11.3.1
  google_fonts: ^6.2.1
  flutter_colorpicker: ^1.1.0
  share_plus: ^10.1.2
  intl: ^0.19.0
  uuid: ^4.5.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/images/
```

- [ ] **Step 4: Create asset dirs and fetch packages**

```bash
mkdir assets\images
flutter pub get
```

Expected: exit 0, packages resolved. If `flutter_bluetooth_serial` fails on latest SDK, pin a compatible version or note adapter wrapper still compiles against the interface in Task 5.

- [ ] **Step 5: Minimal `lib/main.dart` and `lib/app.dart`**

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: DigitalSportsScoreboardApp()));
}
```

```dart
// lib/app.dart
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

class DigitalSportsScoreboardApp extends StatelessWidget {
  const DigitalSportsScoreboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Sports Scoreboard',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
```

Create a temporary `lib/screens/splash_screen.dart` with a centered `Text('DSS')` so the app builds; replace in Task 8.

- [ ] **Step 6: Android permissions**

In `android/app/src/main/AndroidManifest.xml` inside `<manifest>`, add:

```xml
<uses-permission android:name="android.permission.BLUETOOTH" android:maxSdkVersion="30" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" android:maxSdkVersion="30" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" android:usesPermissionFlags="neverForLocation" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

- [ ] **Step 7: Commit**

```bash
git add pubspec.yaml lib android analysis_options.yaml assets .metadata
git commit -m "chore: scaffold Flutter Digital Sports Scoreboard project"
```

---

## Task 2: Command constants and status parser (TDD)

**Files:**
- Create: `lib/utils/commands.dart`, `lib/utils/status_parser.dart`, `lib/models/scoreboard_telemetry.dart`
- Test: `test/utils/commands_test.dart`, `test/utils/status_parser_test.dart`

- [ ] **Step 1: Write failing tests**

```dart
// test/utils/commands_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:digital_sports_scoreboard/utils/commands.dart';

void main() {
  test('score and match commands are exact protocol strings', () {
    expect(ScoreboardCommands.start, 'START');
    expect(ScoreboardCommands.end, 'END');
    expect(ScoreboardCommands.reset, 'RESET');
    expect(ScoreboardCommands.aPlus, 'A+');
    expect(ScoreboardCommands.aMinus, 'A-');
    expect(ScoreboardCommands.bPlus, 'B+');
    expect(ScoreboardCommands.bMinus, 'B-');
    expect(ScoreboardCommands.audio, 'AUDIO');
  });

  test('name and track builders format payloads', () {
    expect(ScoreboardCommands.nameA('Man Utd'), 'NAMEA:Man Utd');
    expect(ScoreboardCommands.nameB('Chelsea'), 'NAMEB:Chelsea');
    expect(ScoreboardCommands.playTrack(5), 'PLAYTRACK:5');
  });

  test('wire format appends newline', () {
    expect(ScoreboardCommands.wire('START'), 'START\n');
  });
}
```

```dart
// test/utils/status_parser_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:digital_sports_scoreboard/utils/status_parser.dart';
import 'package:digital_sports_scoreboard/models/scoreboard_telemetry.dart';

void main() {
  test('parses battery and track lines', () {
    final bat = StatusParser.parseLine('BAT:85');
    expect(bat, isA<BatteryTelemetry>());
    expect((bat as BatteryTelemetry).percent, 85);

    final track = StatusParser.parseLine('TRACK:Match Anthem');
    expect(track, isA<TrackTelemetry>());
    expect((track as TrackTelemetry).title, 'Match Anthem');
  });

  test('parses OK and ignores unknown', () {
    expect(StatusParser.parseLine('OK'), isA<OkTelemetry>());
    expect(StatusParser.parseLine('NOISE'), isNull);
    expect(StatusParser.parseLine(''), isNull);
  });
}
```

- [ ] **Step 2: Run tests — expect FAIL**

Run: `flutter test test/utils/commands_test.dart test/utils/status_parser_test.dart`  
Expected: FAIL (library/file not found)

- [ ] **Step 3: Implement**

```dart
// lib/utils/commands.dart
class ScoreboardCommands {
  static const start = 'START';
  static const end = 'END';
  static const reset = 'RESET';
  static const aPlus = 'A+';
  static const aMinus = 'A-';
  static const bPlus = 'B+';
  static const bMinus = 'B-';
  static const play = 'PLAY';
  static const pause = 'PAUSE';
  static const next = 'NEXT';
  static const prev = 'PREV';
  static const volUp = 'VOLUP';
  static const volDown = 'VOLDOWN';
  static const mute = 'MUTE';
  static const unmute = 'UNMUTE';
  static const repeat = 'REPEAT';
  static const shuffle = 'SHUFFLE';
  static const audio = 'AUDIO';

  static String nameA(String name) => 'NAMEA:$name';
  static String nameB(String name) => 'NAMEB:$name';
  static String playTrack(int n) => 'PLAYTRACK:$n';
  static String wire(String command) => '$command\n';
}
```

```dart
// lib/models/scoreboard_telemetry.dart
sealed class ScoreboardTelemetry {
  const ScoreboardTelemetry();
}

class BatteryTelemetry extends ScoreboardTelemetry {
  final int percent;
  const BatteryTelemetry(this.percent);
}

class TrackTelemetry extends ScoreboardTelemetry {
  final String title;
  const TrackTelemetry(this.title);
}

class OkTelemetry extends ScoreboardTelemetry {
  const OkTelemetry();
}
```

```dart
// lib/utils/status_parser.dart
import '../models/scoreboard_telemetry.dart';

class StatusParser {
  static ScoreboardTelemetry? parseLine(String raw) {
    final line = raw.trim();
    if (line.isEmpty) return null;
    if (line == 'OK') return const OkTelemetry();
    if (line.startsWith('BAT:')) {
      final value = int.tryParse(line.substring(4).trim());
      if (value == null) return null;
      return BatteryTelemetry(value.clamp(0, 100));
    }
    if (line.startsWith('TRACK:')) {
      final title = line.substring(6).trim();
      if (title.isEmpty) return null;
      return TrackTelemetry(title);
    }
    return null;
  }
}
```

- [ ] **Step 4: Run tests — expect PASS**

Run: `flutter test test/utils/commands_test.dart test/utils/status_parser_test.dart`  
Expected: All tests passed

- [ ] **Step 5: Commit**

```bash
git add lib/utils lib/models/scoreboard_telemetry.dart test/utils
git commit -m "feat: add scoreboard command constants and status parser"
```

---

## Task 3: Domain models

**Files:**
- Create: `lib/models/team.dart`, `lib/models/match_record.dart`, `lib/models/bt_device.dart`, `lib/models/connection_status.dart`, `lib/models/app_settings.dart`, `lib/models/music_track.dart`
- Test: `test/models/match_record_test.dart`

- [ ] **Step 1: Write failing match record JSON test**

```dart
// test/models/match_record_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:digital_sports_scoreboard/models/match_record.dart';

void main() {
  test('MatchRecord round-trips through JSON', () {
    final record = MatchRecord(
      id: 'abc',
      playedAt: DateTime.utc(2026, 7, 26, 18, 0),
      teamAName: 'Man Utd',
      teamBName: 'Chelsea',
      scoreA: 12,
      scoreB: 8,
      winner: 'Man Utd',
      durationSeconds: 5400,
    );
    final copy = MatchRecord.fromJson(record.toJson());
    expect(copy.id, record.id);
    expect(copy.scoreA, 12);
    expect(copy.winner, 'Man Utd');
    expect(copy.durationSeconds, 5400);
  });
}
```

- [ ] **Step 2: Run test — expect FAIL**

Run: `flutter test test/models/match_record_test.dart`

- [ ] **Step 3: Implement models**

```dart
// lib/models/team.dart
import 'package:flutter/material.dart';

class Team {
  final String name;
  final Color color;
  final int score;

  const Team({
    required this.name,
    required this.color,
    this.score = 0,
  });

  Team copyWith({String? name, Color? color, int? score}) {
    return Team(
      name: name ?? this.name,
      color: color ?? this.color,
      score: score ?? this.score,
    );
  }
}
```

```dart
// lib/models/match_record.dart
class MatchRecord {
  final String id;
  final DateTime playedAt;
  final String teamAName;
  final String teamBName;
  final int scoreA;
  final int scoreB;
  final String winner;
  final int durationSeconds;

  const MatchRecord({
    required this.id,
    required this.playedAt,
    required this.teamAName,
    required this.teamBName,
    required this.scoreA,
    required this.scoreB,
    required this.winner,
    required this.durationSeconds,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'playedAt': playedAt.toIso8601String(),
        'teamAName': teamAName,
        'teamBName': teamBName,
        'scoreA': scoreA,
        'scoreB': scoreB,
        'winner': winner,
        'durationSeconds': durationSeconds,
      };

  factory MatchRecord.fromJson(Map<String, dynamic> json) {
    return MatchRecord(
      id: json['id'] as String,
      playedAt: DateTime.parse(json['playedAt'] as String),
      teamAName: json['teamAName'] as String,
      teamBName: json['teamBName'] as String,
      scoreA: json['scoreA'] as int,
      scoreB: json['scoreB'] as int,
      winner: json['winner'] as String,
      durationSeconds: json['durationSeconds'] as int,
    );
  }
}
```

```dart
// lib/models/bt_device.dart
class BtDevice {
  final String name;
  final String address;
  final int? rssi;

  const BtDevice({
    required this.name,
    required this.address,
    this.rssi,
  });
}
```

```dart
// lib/models/connection_status.dart
enum ConnectionMode { disconnected, scanning, connecting, connected, simulation }

class ConnectionStatus {
  final ConnectionMode mode;
  final String? deviceName;
  final String? deviceAddress;
  final int? batteryPercent;
  final String? lastError;

  const ConnectionStatus({
    required this.mode,
    this.deviceName,
    this.deviceAddress,
    this.batteryPercent,
    this.lastError,
  });

  bool get isLive =>
      mode == ConnectionMode.connected || mode == ConnectionMode.simulation;

  ConnectionStatus copyWith({
    ConnectionMode? mode,
    String? deviceName,
    String? deviceAddress,
    int? batteryPercent,
    String? lastError,
    bool clearError = false,
  }) {
    return ConnectionStatus(
      mode: mode ?? this.mode,
      deviceName: deviceName ?? this.deviceName,
      deviceAddress: deviceAddress ?? this.deviceAddress,
      batteryPercent: batteryPercent ?? this.batteryPercent,
      lastError: clearError ? null : (lastError ?? this.lastError),
    );
  }
}
```

```dart
// lib/models/app_settings.dart
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
```

```dart
// lib/models/music_track.dart
class MusicTrack {
  final int number;
  final String title;
  final Duration? duration;

  const MusicTrack({
    required this.number,
    required this.title,
    this.duration,
  });
}
```

- [ ] **Step 4: Run test — expect PASS**

Run: `flutter test test/models/match_record_test.dart`

- [ ] **Step 5: Commit**

```bash
git add lib/models test/models
git commit -m "feat: add domain models for teams, matches, connection, settings"
```

---

## Task 4: ScoreboardConnection interface + Simulation (TDD)

**Files:**
- Create: `lib/services/scoreboard_connection.dart`, `lib/services/simulation_scoreboard_connection.dart`
- Test: `test/services/simulation_scoreboard_connection_test.dart`

- [ ] **Step 1: Write failing simulation test**

```dart
// test/services/simulation_scoreboard_connection_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:digital_sports_scoreboard/services/simulation_scoreboard_connection.dart';
import 'package:digital_sports_scoreboard/utils/commands.dart';

void main() {
  test('simulation accepts commands and emits faux battery', () async {
    final conn = SimulationScoreboardConnection();
    await conn.connect();
    final batteries = <int>[];
    final sub = conn.telemetry.listen((t) {
      // collected via side channel in impl test below
    });
    await conn.send(ScoreboardCommands.start);
    expect(conn.isConnected, isTrue);
    expect(conn.lastCommand, 'START');
    await conn.disconnect();
    expect(conn.isConnected, isFalse);
    await sub.cancel();
  });
}
```

- [ ] **Step 2: Run — expect FAIL**

- [ ] **Step 3: Implement interface + simulation**

```dart
// lib/services/scoreboard_connection.dart
import '../models/bt_device.dart';
import '../models/scoreboard_telemetry.dart';

abstract class ScoreboardConnection {
  Stream<ScoreboardTelemetry> get telemetry;
  Stream<bool> get connectionChanges;
  bool get isConnected;

  Future<void> connect({BtDevice? device});
  Future<void> disconnect();
  Future<void> send(String command);
  Future<List<BtDevice>> scan({Duration timeout = const Duration(seconds: 5)});
}
```

```dart
// lib/services/simulation_scoreboard_connection.dart
import 'dart:async';
import '../models/bt_device.dart';
import '../models/scoreboard_telemetry.dart';
import '../utils/commands.dart';
import 'scoreboard_connection.dart';

class SimulationScoreboardConnection implements ScoreboardConnection {
  final _telemetry = StreamController<ScoreboardTelemetry>.broadcast();
  final _connection = StreamController<bool>.broadcast();
  bool _connected = false;
  String? lastCommand;

  @override
  Stream<ScoreboardTelemetry> get telemetry => _telemetry.stream;

  @override
  Stream<bool> get connectionChanges => _connection.stream;

  @override
  bool get isConnected => _connected;

  @override
  Future<List<BtDevice>> scan({Duration timeout = const Duration(seconds: 5)}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return const [
      BtDevice(name: 'DSS-ESP32-SIM', address: '00:11:22:33:44:55', rssi: -50),
    ];
  }

  @override
  Future<void> connect({BtDevice? device}) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _connected = true;
    _connection.add(true);
    _telemetry.add(const BatteryTelemetry(88));
    _telemetry.add(const TrackTelemetry('Match Anthem'));
  }

  @override
  Future<void> disconnect() async {
    _connected = false;
    _connection.add(false);
  }

  @override
  Future<void> send(String command) async {
    if (!_connected) {
      throw StateError('Not connected');
    }
    lastCommand = command.trim();
    await Future<void>.delayed(const Duration(milliseconds: 40));
    _telemetry.add(const OkTelemetry());
    if (command.trim() == ScoreboardCommands.play ||
        command.trim().startsWith('PLAYTRACK:')) {
      _telemetry.add(TrackTelemetry(
        command.trim().startsWith('PLAYTRACK:')
            ? 'Track ${command.trim().split(':').last}'
            : 'Match Anthem',
      ));
    }
  }

  Future<void> dispose() async {
    await _telemetry.close();
    await _connection.close();
  }
}
```

- [ ] **Step 4: Run — expect PASS**

Run: `flutter test test/services/simulation_scoreboard_connection_test.dart`

- [ ] **Step 5: Commit**

```bash
git add lib/services/scoreboard_connection.dart lib/services/simulation_scoreboard_connection.dart test/services
git commit -m "feat: add ScoreboardConnection interface and simulation impl"
```

---

## Task 5: Real Bluetooth service + adapter

**Files:**
- Create: `lib/services/bluetooth_service.dart`, `lib/services/bluetooth_scoreboard_connection.dart`

- [ ] **Step 1: Implement `BluetoothService` wrapping `flutter_bluetooth_serial`**

Responsibilities:
- `isEnabled`, `requestEnable`
- `startDiscovery` → map to `List<BtDevice>`
- `connect(address)` → `BluetoothConnection`
- `sendCommand` write `utf8.encode(ScoreboardCommands.wire(cmd))`
- `input` stream → split on newlines → yield strings
- `disconnect` / dispose

Keep package-specific types inside this file only.

- [ ] **Step 2: Implement `BluetoothScoreboardConnection`**

```dart
// lib/services/bluetooth_scoreboard_connection.dart
// Implements ScoreboardConnection by delegating to BluetoothService.
// On connect, subscribe to lines, parse with StatusParser, forward telemetry.
// On link drop, emit connectionChanges(false).
```

Full implementation must include:
- `scan` → service discovery
- `connect` → service connect + listen
- `send` → service write
- `disconnect` → cancel subscription + close socket
- Map parse results to `telemetry` stream

- [ ] **Step 3: Manual smoke note**

Document in commit message that hardware test is deferred to Task 10 scan UI; unit tests continue using Simulation.

- [ ] **Step 4: Commit**

```bash
git add lib/services/bluetooth_service.dart lib/services/bluetooth_scoreboard_connection.dart
git commit -m "feat: add Bluetooth Classic SPP service behind ScoreboardConnection"
```

---

## Task 6: Repositories (settings, history, music library)

**Files:**
- Create: `lib/repositories/settings_repository.dart`, `lib/repositories/match_history_repository.dart`, `lib/repositories/music_library_repository.dart`, `lib/utils/csv_export.dart`
- Test: `test/utils/csv_export_test.dart`, extend history tests in `test/providers/history_provider_test.dart` later

- [ ] **Step 1: Write CSV export failing test**

```dart
// test/utils/csv_export_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:digital_sports_scoreboard/models/match_record.dart';
import 'package:digital_sports_scoreboard/utils/csv_export.dart';

void main() {
  test('exports header and row', () {
    final csv = CsvExport.fromMatches([
      MatchRecord(
        id: '1',
        playedAt: DateTime.utc(2026, 7, 26, 18, 0),
        teamAName: 'A',
        teamBName: 'B',
        scoreA: 2,
        scoreB: 1,
        winner: 'A',
        durationSeconds: 60,
      ),
    ]);
    expect(csv.split('\n').first, contains('id,playedAt,teamAName'));
    expect(csv, contains('A,B,2,1,A,60'));
  });
}
```

- [ ] **Step 2: Implement repositories + CSV**

`SettingsRepository`: load/save `AppSettings` via SharedPreferences keys.  
`MatchHistoryRepository`: load JSON list; on corrupt JSON return `[]` and overwrite clean store; add/delete/clear; search filter helper.  
`MusicLibraryRepository`: return default const list:

```dart
const defaultTracks = [
  MusicTrack(number: 1, title: 'Match Anthem'),
  MusicTrack(number: 2, title: 'Crowd Cheer'),
  MusicTrack(number: 3, title: 'Halftime Groove'),
  MusicTrack(number: 4, title: 'Victory Fanfare'),
  MusicTrack(number: 5, title: 'Warmup Beats'),
];
```

```dart
// lib/utils/csv_export.dart
import '../models/match_record.dart';

class CsvExport {
  static String fromMatches(List<MatchRecord> matches) {
    final buffer = StringBuffer(
      'id,playedAt,teamAName,teamBName,scoreA,scoreB,winner,durationSeconds\n',
    );
    for (final m in matches) {
      buffer.writeln(
        '${m.id},${m.playedAt.toIso8601String()},${_esc(m.teamAName)},${_esc(m.teamBName)},${m.scoreA},${m.scoreB},${_esc(m.winner)},${m.durationSeconds}',
      );
    }
    return buffer.toString();
  }

  static String _esc(String value) {
    if (value.contains(',') || value.contains('"')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
```

- [ ] **Step 3: Run CSV test — PASS**

- [ ] **Step 4: Commit**

```bash
git add lib/repositories lib/utils/csv_export.dart test/utils/csv_export_test.dart
git commit -m "feat: add settings, history, music library repositories and CSV export"
```

---

## Task 7: Stadium Night theme + app wiring

**Files:**
- Create: `lib/themes/colors.dart`, `lib/themes/app_theme.dart`
- Modify: `lib/app.dart`, `lib/providers/settings_provider.dart`

- [ ] **Step 1: Define color tokens**

```dart
// lib/themes/colors.dart
import 'package:flutter/material.dart';

class StadiumColors {
  static const navy = Color(0xFF0B1F33);
  static const navyMid = Color(0xFF132F4C);
  static const accent = Color(0xFF3DDC97);
  static const rival = Color(0xFFFF6B4A);
  static const surfaceLight = Color(0xFFF7F8FA);
  static const textDark = Color(0xFF14213D);
}
```

- [ ] **Step 2: Build Material 3 light/dark `ThemeData` in `app_theme.dart` using `StadiumColors` + `GoogleFonts.spaceGroteskTextTheme` for UI and a tabular display style for scores**

- [ ] **Step 3: `settingsProvider` as `AsyncNotifier`/`Notifier` loading `SettingsRepository`; expose `themeMode` mapping**

- [ ] **Step 4: Wire `DigitalSportsScoreboardApp` as `ConsumerWidget` applying themeMode**

- [ ] **Step 5: Commit**

```bash
git add lib/themes lib/app.dart lib/providers/settings_provider.dart
git commit -m "feat: add Stadium Night theme and settings-driven themeMode"
```

---

## Task 8: Connection + score + timer + music providers

**Files:**
- Create: `lib/providers/connection_provider.dart`, `lib/providers/score_provider.dart`, `lib/providers/timer_provider.dart`, `lib/providers/music_provider.dart`, `lib/providers/history_provider.dart`
- Test: `test/providers/score_provider_test.dart`

- [ ] **Step 1: Write score provider test with simulation**

```dart
// test/providers/score_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:digital_sports_scoreboard/providers/score_provider.dart';
import 'package:digital_sports_scoreboard/providers/connection_provider.dart';
import 'package:digital_sports_scoreboard/services/simulation_scoreboard_connection.dart';
import 'package:digital_sports_scoreboard/utils/commands.dart';

void main() {
  test('incrementA updates score and sends A+', () async {
    final sim = SimulationScoreboardConnection();
    await sim.connect();
    final container = ProviderContainer(overrides: [
      scoreboardConnectionProvider.overrideWithValue(sim),
    ]);
    addTearDown(container.dispose);

    await container.read(scoreProvider.notifier).incrementA();
    final state = container.read(scoreProvider);
    expect(state.teamA.score, 1);
    expect(sim.lastCommand, ScoreboardCommands.aPlus);
  });
}
```

- [ ] **Step 2: Implement providers**

`connectionProvider`:
- Holds `ConnectionStatus`
- Methods: `startScan`, `connectDevice`, `enterSimulation`, `disconnect`, `reconnect`
- Owns which `ScoreboardConnection` is active (provider overrideable)
- Listens telemetry for battery
- Exposes `connectionLost` flag for dialog

`scoreProvider`:
- State: teamA, teamB, matchActive, startedAt
- `incrementA/B`, `decrementA/B` (floor 0), `setNameA/B`, `startMatch`, `endMatch`, `resetMatch`
- Optimistic update then `connection.send`
- On `startMatch`/`endMatch`, call music automation via reading settings + music notifier
- On `endMatch`, append `MatchRecord` through history repository

`timerProvider`:
- count-up / countdown mode, running flag, `Duration elapsed` or remaining
- tick with `Timer.periodic` while running; cancel on dispose
- no Bluetooth

`musicProvider`:
- playing, muted, volume, repeat, shuffle, currentTitle, tracks from library repo
- send PLAY/PAUSE/NEXT/PREV/VOL*/MUTE/UNMUTE/REPEAT/SHUFFLE/PLAYTRACK

`historyProvider`:
- list + search query + delete + clear + exportCsv string

- [ ] **Step 3: Run score provider test — PASS**

- [ ] **Step 4: Commit**

```bash
git add lib/providers test/providers
git commit -m "feat: add Riverpod providers for connection, score, timer, music, history"
```

---

## Task 9: Splash, permissions, scan screens

**Files:**
- Create: `lib/screens/splash_screen.dart`, `lib/screens/permissions_screen.dart`, `lib/screens/bluetooth_scan_screen.dart`, `lib/widgets/device_card.dart`, `lib/animations/fade_page_route.dart`

- [ ] **Step 1: Animated splash**

- Stadium Night gradient background  
- Large scoreboard illustration (CustomPainter or asset)  
- Title “Digital Sports Scoreboard”  
- Loading indicator  
- After ~2s fade navigate to `PermissionsScreen`

- [ ] **Step 2: Permissions screen**

- Request Bluetooth + location via `permission_handler`  
- Explain why  
- Continue / Retry  
- Navigate to `BluetoothScanScreen`

- [ ] **Step 3: Scan screen**

- Auto-start scan when BT on  
- Search animation  
- List of `DeviceCard` (icon, name, MAC, RSSI, Connect)  
- On connect success → green indicator → pushReplacement `DashboardScreen`  
- Prominent **Enter Simulation Mode** button calling `enterSimulation()` then dashboard  
- Empty state tips + Rescan  
- SnackBar on connect failure

- [ ] **Step 4: Manual run**

Run: `flutter run`  
Expected: splash → permissions → scan; Simulation reaches dashboard shell (Task 10 may still be stub — create minimal dashboard scaffold if needed)

- [ ] **Step 5: Commit**

```bash
git add lib/screens/splash_screen.dart lib/screens/permissions_screen.dart lib/screens/bluetooth_scan_screen.dart lib/widgets/device_card.dart lib/animations
git commit -m "feat: add splash, permissions, and Bluetooth scan screens"
```

---

## Task 10: Dashboard hub + core widgets

**Files:**
- Create: `lib/screens/dashboard_screen.dart`, `lib/widgets/live_scoreboard_card.dart`, `lib/widgets/now_playing_card.dart`, `lib/widgets/quick_music_bar.dart`, `lib/widgets/connection_banner.dart`, `lib/widgets/match_timer_bar.dart`, `lib/widgets/hub_tile.dart`, `lib/widgets/stadium_scaffold.dart`, `lib/widgets/connection_lost_dialog.dart`
- Test: `test/widgets/live_scoreboard_card_test.dart`, `test/widgets/connection_lost_dialog_test.dart`

- [ ] **Step 1: Widget tests**

```dart
// test/widgets/live_scoreboard_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:digital_sports_scoreboard/widgets/live_scoreboard_card.dart';
import 'package:digital_sports_scoreboard/models/team.dart';

void main() {
  testWidgets('shows team names and scores', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LiveScoreboardCard(
            teamA: const Team(name: 'Man Utd', color: Colors.green, score: 12),
            teamB: const Team(name: 'Chelsea', color: Colors.orange, score: 8),
            timerLabel: '00:12:44',
          ),
        ),
      ),
    );
    expect(find.text('Man Utd'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('VS'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Implement widgets with Stadium Night styling; animated score text when `animationsEnabled`**

- [ ] **Step 3: Dashboard layout**

App bar: DSS logo text, BT/Simulation chip, battery or `—`, settings icon  
Body: `LiveScoreboardCard`, `NowPlayingCard` + `QuickMusicBar`, quick action row (Start/End/Reset/AUDIO), hub grid (Score, Teams, Music, History, Stats, Settings, Timer)  
Listen for connection lost → show `ConnectionLostDialog` (Reconnect / Simulation)

- [ ] **Step 4: Run widget tests — PASS**

- [ ] **Step 5: Commit**

```bash
git add lib/screens/dashboard_screen.dart lib/widgets test/widgets
git commit -m "feat: add Stadium Night dashboard hub and shared scoreboard widgets"
```

---

## Task 11: Score control + teams screens

**Files:**
- Create: `lib/screens/score_control_screen.dart`, `lib/screens/teams_screen.dart`, `lib/widgets/score_control_panel.dart`

- [ ] **Step 1: Score control UI**

Two `ScoreControlPanel`s with huge +/−, haptic feedback, scale animation on tap → call score provider

- [ ] **Step 2: Teams UI**

Editable name fields, `flutter_colorpicker`, logo placeholder container, Save buttons validating non-empty names → `NAMEA`/`NAMEB`

- [ ] **Step 3: Confirm dialogs for Reset from dashboard already wired; ensure Reset confirms**

- [ ] **Step 4: Manual Simulation path: change names, score up/down, verify live card updates**

- [ ] **Step 5: Commit**

```bash
git add lib/screens/score_control_screen.dart lib/screens/teams_screen.dart lib/widgets/score_control_panel.dart
git commit -m "feat: add score control and team management screens"
```

---

## Task 12: Music player + library

**Files:**
- Create: `lib/screens/music_player_screen.dart`, `lib/screens/music_library_screen.dart`

- [ ] **Step 1: Music player screen**

Artwork placeholder, title, volume indicator, animated transport buttons (Play/Pause/Next/Prev/Repeat/Shuffle/Vol/Mute), BT status chip

- [ ] **Step 2: Library screen**

List default tracks as cards with Play → `PLAYTRACK:n`; update now-playing title optimistically

- [ ] **Step 3: Ensure dashboard quick music bar uses same `musicProvider`**

- [ ] **Step 4: Commit**

```bash
git add lib/screens/music_player_screen.dart lib/screens/music_library_screen.dart
git commit -m "feat: add music player and local track library screens"
```

---

## Task 13: Timer, history, statistics

**Files:**
- Create: `lib/screens/timer_screen.dart`, `lib/screens/history_screen.dart`, `lib/screens/statistics_screen.dart`, `lib/utils/formatters.dart`

- [ ] **Step 1: Timer screen**

Mode toggle count-up/countdown, start/pause/resume/reset, large digital clock; countdown default target e.g. 10:00 configurable field

- [ ] **Step 2: History screen**

Search field, list tiles (date, teams, score, winner, duration), delete with confirm, share text summary via `share_plus`, export CSV share

- [ ] **Step 3: Statistics screen**

Compute from history: total matches, highest score, average score, wins per team name; empty state when no history

- [ ] **Step 4: On End Match from dashboard, verify a history row appears**

- [ ] **Step 5: Commit**

```bash
git add lib/screens/timer_screen.dart lib/screens/history_screen.dart lib/screens/statistics_screen.dart lib/utils/formatters.dart
git commit -m "feat: add match timer, history, and statistics screens"
```

---

## Task 14: Settings + About + reset app data

**Files:**
- Create: `lib/screens/settings_screen.dart`, `lib/screens/about_screen.dart`

- [ ] **Step 1: Settings sections**

Theme (light/dark/auto), Bluetooth (open scan / disconnect), score sound toggle, animation toggle, music toggles (background, auto play on start, stop on end, default volume slider), sound effects, Reset App Data (confirm → clear prefs + history), link to About

- [ ] **Step 2: About screen**

Project name Digital Sports Scoreboard; Developed by blank; University blank; Version 1.0

- [ ] **Step 3: Commit**

```bash
git add lib/screens/settings_screen.dart lib/screens/about_screen.dart
git commit -m "feat: add settings and about screens"
```

---

## Task 15: Polish, responsiveness, docs, release APK

**Files:**
- Create: `README.md`, `docs/BLUETOOTH_COMMANDS.md`, `docs/TESTING.md`
- Modify: layouts for landscape/tablet using `LayoutBuilder` / constrained widths on dashboard and score panels
- Modify: `lib/animations/fade_page_route.dart` used for hub pushes

- [ ] **Step 1: Responsive pass**

Ensure dashboard and score control readable on small phones and tablets; landscape uses two-column where sensible without breaking portrait.

- [ ] **Step 2: Write README**

Contents: project overview, prerequisites, `flutter pub get`, `flutter run`, Simulation Mode, `flutter build apk`, link to command docs and testing checklist.

- [ ] **Step 3: Write `docs/BLUETOOTH_COMMANDS.md`**

Table of all outbound/inbound commands matching the spec.

- [ ] **Step 4: Write `docs/TESTING.md`**

Automated commands + manual demo-day checklist from spec section 9.

- [ ] **Step 5: Run full test suite**

Run: `flutter test`  
Expected: All tests passed

- [ ] **Step 6: Build release APK**

Run: `flutter build apk --release`  
Expected: `build/app/outputs/flutter-apk/app-release.apk` created

- [ ] **Step 7: Commit**

```bash
git add README.md docs/BLUETOOTH_COMMANDS.md docs/TESTING.md lib
git commit -m "docs: add install, Bluetooth protocol, and testing guides; polish responsive UI"
```

---

## Spec Coverage Checklist

| Spec requirement | Task |
|------------------|------|
| Flutter Android APK | 1, 15 |
| Riverpod + repository architecture | 6, 8 |
| ScoreboardConnection real + simulation | 4, 5 |
| Commands module + hybrid parser | 2 |
| Stadium Night theme light/dark/auto | 7, 14 |
| Splash → permissions → scan → dashboard hub | 9, 10 |
| Live scoreboard, quick actions, now playing | 10 |
| Score control + teams | 11 |
| Music player + library | 12 |
| Timer app-only | 13 |
| History search/delete/share/CSV | 6, 13 |
| Statistics | 13 |
| Settings + About blanks + v1.0 | 14 |
| Connection lost dialog / reconnect | 8, 10 |
| Match automation start/end music | 8 |
| Tests + README + command docs | 2–4, 8, 10, 15 |
| Responsive phone/tablet | 15 |

---

## Self-Review Notes

- No TBD placeholders left in tasks; Bluetooth package risk handled with interface isolation (Task 5).
- Types aligned: `ScoreboardConnection`, `ConnectionStatus`, `MatchRecord`, `AppSettings`, `ScoreboardCommands`.
- Full brief scope retained as one plan (single APK); execute tasks in order so Simulation demo works from Task 10 onward.
