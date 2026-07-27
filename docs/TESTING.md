# Testing Guide

## Automated tests

From the project root:

```bash
flutter test
```

Static analysis:

```bash
flutter analyze
```

### What is covered

| Area | Tests |
|------|-------|
| Commands | `test/utils/commands_test.dart` — wire format and builders |
| Status parser | `test/utils/status_parser_test.dart` — `BAT:`, `TRACK:`, `OK` |
| Score rules | `test/providers/score_provider_test.dart` |
| Simulation connection | `test/services/simulation_scoreboard_connection_test.dart` |
| CSV export | `test/utils/csv_export_test.dart` |
| Match records | `test/models/match_record_test.dart` |
| Widgets | `test/widgets/live_scoreboard_card_test.dart`, `connection_lost_dialog_test.dart` |

## Manual demo checklist

Use this list before a demonstration or hardware handoff. Run in **Simulation Mode** if no ESP32 is available.

### Connection flow

- [ ] Splash screen appears and navigates forward
- [ ] Bluetooth permissions screen explains requirements and allows retry
- [ ] Device scan lists devices (or shows empty-state tips)
- [ ] Connect to a device **or** enter Simulation Mode
- [ ] Dashboard shows connection status (BT / Simulation / Offline)

### Match lifecycle

- [ ] **Start Match** activates live state and sends `START`
- [ ] Score **+ / −** on Score Control updates preview and sends `A+` / `A-` / `B+` / `B-`
- [ ] **Teams** screen saves names and sends `NAMEA:` / `NAMEB:`
- [ ] **End Match** records history and sends `END`
- [ ] **Reset** confirms, clears scores, and sends `RESET`

### Music

- [ ] Dashboard quick music bar: play, pause, next, volume
- [ ] Music Player screen: transport, volume, repeat, shuffle
- [ ] Music Library plays a track via `PLAYTRACK:<n>`
- [ ] **Test Audio** on dashboard sends `AUDIO`

### Timer, history, stats

- [ ] Match timer start / pause / resume / reset on Timer screen and dashboard bar
- [ ] History lists completed matches; search, delete, share, CSV export work
- [ ] Statistics reflect recorded matches

### Resilience

- [ ] Disconnect mid-match (or toggle airplane mode) shows connection-lost dialog
- [ ] **Reconnect** and **Use Simulation Mode** both recover gracefully
- [ ] Command failure shows SnackBar; UI remains usable

### Settings and themes

- [ ] Light, Dark, and Auto theme modes apply correctly
- [ ] Settings toggles persist after app restart
- [ ] About screen shows version 1.0

### Layout smoke check

- [ ] Phone portrait — no overflow on dashboard or score control
- [ ] Phone landscape — content readable, no clipped controls
- [ ] Tablet or large emulator — dashboard and score control use centered max-width layout
