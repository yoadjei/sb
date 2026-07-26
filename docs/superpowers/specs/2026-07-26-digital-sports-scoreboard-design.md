# Digital Sports Scoreboard — Mobile App Design

**Date:** 2026-07-26  
**Status:** Approved for implementation planning  
**Platform:** Flutter (Android APK)  
**Visual direction:** Stadium Night

## 1. Summary

Build a production-quality Flutter mobile app that controls a portable ESP32 sports scoreboard over Bluetooth Classic (SPP / HC-05-compatible). The app is the operator console: it sends commands for scores, team names, match lifecycle, and DFPlayer Mini music control. Optional inbound status lines (battery, now playing) are parsed when present. A Simulation Mode keeps the full UI demoable without hardware.

## 2. Goals & Constraints

### Goals

- Commercial-quality Material 3 UI suitable for a university final-year demonstration
- Full feature set from the project brief (no placeholder screens)
- Reliable Bluetooth Classic control with clear recovery paths
- Local match history, statistics, CSV export, and on-device match timer
- Music player remote for the DFPlayer Mini

### Constraints

- Mobile app primarily **sends** commands; ESP32 owns hardware actions (display, audio, brightness, charging)
- Bluetooth Classic favors **Android** for the demo APK
- About screen developer/university fields left blank for the student to fill
- Real Bluetooth is prioritized; Simulation Mode is a first-class backup, not a toy stub

### Out of scope (hardware / firmware)

- ESP32 firmware implementation (app defines and documents the command contract)
- Wi-Fi / internet control, voice control, OTA updates

## 3. Decisions Locked

| Topic | Decision |
|-------|----------|
| Stack | Flutter + Dart + Material 3 |
| Deliverable | Android APK (`flutter build apk`) |
| Scope | Full build of all brief screens/features |
| State management | Riverpod |
| Architecture | Feature-first + Repository pattern |
| Connection | `ScoreboardConnection` interface: real SPP + Simulation |
| Status telemetry | Hybrid parser (`BAT:`, `TRACK:`, `OK`) — UI never blocks if absent |
| Navigation | Dashboard hub → push full screens (not bottom tabs) |
| Visual style | Stadium Night (deep navy + neon green + rival coral) |
| Theme modes | Light / Dark / Auto |
| Persistence | SharedPreferences + local JSON history |

## 4. Architecture

```
UI (screens / widgets / theme)
        ↓
Riverpod notifiers (Bluetooth, Score, Music, History, Settings, Timer)
        ↓
Repositories (MatchHistory, Settings, MusicLibrary)
        ↓
ScoreboardConnection (interface)
   ├── BluetoothScoreboardConnection  (prefer `flutter_bluetooth_serial`; swap behind interface if unmaintained)
   └── SimulationScoreboardConnection (in-memory demo + fake delays)
```

### App flow

1. Splash (animated)
2. Bluetooth permission + enable guidance
3. Device scan → connect (or enter Simulation Mode)
4. Dashboard Hub
5. Pushed screens: Score Control, Teams, Music Player, Music Library, History, Statistics, Settings, About, Match Timer (timer also visible on dashboard)

### Folder structure

```
lib/
  main.dart
  app.dart
  screens/
  widgets/
  models/
  providers/
  services/
  repositories/
  utils/
  themes/
  animations/
assets/
docs/
```

## 5. Screens & UI

### Visual system — Stadium Night

- Background: deep navy `#0B1F33` / `#132F4C` gradients (dark), clean elevated surfaces (light)
- Primary accent: neon green `#3DDC97` (Team A / connected / primary CTAs)
- Rival accent: coral `#FF6B4A` (Team B / destructive / end match)
- Digital score typography (tabular / display font)
- Rounded cards, Material 3 motion, haptics on primary controls
- Responsive: phones, tablets, portrait & landscape

### Dashboard Hub

- App bar: logo/title, BT status, battery (or em dash when unknown), settings
- Live scoreboard preview card (names, scores, VS, timer)
- Now Playing card + compact music controls (play / pause / next / volume)
- Quick actions: Start Match, End Match, Reset, Play Test Audio
- Hub grid navigating to Score, Teams, Music, History, Stats, Settings (About via Settings)

### Other screens (complete implementations)

- **Permissions / Scan:** permission requests, search animation, device cards (name, MAC, RSSI if available), connect, green connected state → auto-navigate
- **Score Control:** dual panels, large +/− with animation, live sync to preview, commands `A+` `A-` `B+` `B-`
- **Teams:** editable name, color picker, logo placeholder, save → `NAMEA:` / `NAMEB:`
- **Music Player:** premium player UI, volume, repeat/shuffle, connection status
- **Music Library:** local configurable track list (name + track number) for v1 → `PLAYTRACK:<n>` (ESP32 SD directory listing is not required)
- **Match Timer:** start/pause/resume/reset, count up & countdown; default `00:00`; no ESP32 required
- **History:** search, delete, share, CSV export
- **Statistics:** total matches, highest score, average score, wins per team
- **Settings:** theme, Bluetooth, sounds/animations, music automation toggles/volumes, reset app data, About
- **About:** project name, blank developer/university, version `1.0`

### Reusable widgets

`LiveScoreboardCard`, `ScoreControlPanel`, `DeviceCard`, `NowPlayingCard`, `QuickMusicBar`, `ConnectionBanner`, `MatchTimerBar`, themed primary/secondary buttons

## 6. Data Flow & Command Protocol

### Optimistic updates

User actions update local Riverpod state immediately (scores, names, playback UI). Commands are then sent through `ScoreboardConnection`. Failures surface via SnackBar; connection loss uses a dedicated dialog.

### Outbound commands

| Command | Meaning |
|---------|---------|
| `START` | Start match |
| `END` | End match |
| `RESET` | Reset scores / defaults |
| `A+` `A-` | Team A score adjust |
| `B+` `B-` | Team B score adjust |
| `NAMEA:<name>` | Set Team A name |
| `NAMEB:<name>` | Set Team B name |
| `PLAY` `PAUSE` `NEXT` `PREV` | Music transport |
| `VOLUP` `VOLDOWN` `MUTE` `UNMUTE` | Volume |
| `REPEAT` `SHUFFLE` | Playback modes |
| `PLAYTRACK:<n>` | Play library track number |
| `AUDIO` | Play test / announcement sample on DFPlayer |

Commands are newline-terminated ASCII. Command string constants live in one module (`lib/utils/commands.dart` or equivalent) for easy firmware alignment.

### Match automation (settings-gated)

- Start Match → `START` then `PLAY` (if auto-play enabled)
- End Match → `END` then `PAUSE` (if stop-on-end enabled)
- Scoring sounds are primarily on ESP32; app may play optional local click if enabled

### Inbound (hybrid)

Parser accepts optional lines such as:

- `BAT:85`
- `TRACK:Match Anthem`
- `OK`

Unknown or missing telemetry never blocks UI. Battery and now-playing show placeholders (`—` / last known / simulation values) until data arrives.

### Persistence

- **Settings / theme / music prefs:** SharedPreferences
- **Match history:** local JSON list (date, time, team names, final scores, winner, duration)
- **CSV export:** generated on demand from history
- **Ending a match:** writes a history record when appropriate

## 7. Bluetooth Service

`BluetoothService` (used by `BluetoothScoreboardConnection`):

- `scan()`, `connect()`, `disconnect()`, `sendCommand()`, `receiveData()` stream
- Auto-reconnect attempts with user-visible status
- Connection-lost dialog: Reconnect / Use Simulation Mode
- Android permissions: Bluetooth + location as required by Classic discovery APIs

Simulation connection mirrors the same API, updates local faux device state, and supports the full demo path without ESP32.

## 8. Error Handling

- Permission denied → explanatory UI + retry
- Adapter off → prompt to enable
- Empty scan → tips + rescan
- Connect failure → SnackBar + retry
- Mid-match disconnect → modal with Reconnect / Simulation
- Command send failure → SnackBar; keep optimistic state unless user confirms revert
- Empty team names blocked before send
- Destructive actions (reset match, reset app data, delete history) require confirmation
- Corrupt history JSON → isolate and reset that store safely
- Loading indicators limited to scan/connect; dashboard remains interactive

## 9. Testing Strategy

### Automated

- Unit: command builders, status parser, score rules, history/CSV helpers
- Notifier tests against `SimulationScoreboardConnection`
- Widget tests: live scoreboard, score buttons, connection-lost dialog

### Manual (demo day)

- Permissions → scan → connect → start → score → end → reset
- Music controls + `PLAYTRACK`
- Disconnect mid-match → reconnect
- Full Simulation Mode walkthrough
- Light/dark + phone/tablet/landscape smoke check

### Documentation deliverables

- `README.md` — install, run, build APK
- Bluetooth command documentation
- Testing checklist
- Future improvements section

## 10. Implementation Principles

- No placeholder screens; no pseudocode stubs in deliverables
- Prefer focused files and clear interfaces over god-services
- Keep Bluetooth package choice behind `ScoreboardConnection` so maintenance swaps are localized
- YAGNI still applies to firmware features not needed by the mobile contract; app-side brief features remain in scope

## 11. Success Criteria

- Installable release APK controls a real ESP32 scoreboard over Classic Bluetooth using the documented commands
- Entire UI works in Simulation Mode for offline marking/demo
- Stadium Night design reads as a polished commercial operator app
- History, stats, music, timer, settings, and themes are fully usable end-to-end
