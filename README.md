# Digital Sports Scoreboard

Flutter operator app for a portable ESP32 sports scoreboard over Bluetooth Classic (SPP). Control live scores, team names, match lifecycle, and DFPlayer Mini music from your phone. **Simulation Mode** runs the full UI without hardware for demos and development.

## Prerequisites

- [Flutter stable](https://docs.flutter.dev/get-started/install) (SDK >= 3.5)
- Android SDK (for device deploy and release APK)
- Physical Android device with Bluetooth Classic, or an emulator for Simulation Mode

## Setup

```bash
flutter pub get
```

## Run

```bash
flutter run
```

On first launch, grant Bluetooth permissions. From the scan screen, connect to a paired ESP32 module or tap **Simulation Mode** to demo without hardware.

## Build APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

## Documentation

- [Bluetooth command protocol](docs/BLUETOOTH_COMMANDS.md) — wire format and full command table
- [Testing guide](docs/TESTING.md) — automated tests and manual demo checklist

## Architecture

The app uses **Riverpod** for state and a **`ScoreboardConnection`** interface that abstracts the transport layer:

```
UI (screens / widgets)
        ↓
Riverpod notifiers (connection, score, music, history, settings, timer)
        ↓
Repositories (settings, match history, music library)
        ↓
ScoreboardConnection
   ├── BluetoothScoreboardConnection  (SPP via flutter_bluetooth_serial)
   └── SimulationScoreboardConnection (in-memory demo)
```

Commands are defined in `lib/utils/commands.dart`; inbound telemetry (`BAT:`, `TRACK:`, `OK`) is parsed in `lib/utils/status_parser.dart`.

## Future improvements

- iOS support with a maintained Bluetooth Classic package
- Wi-Fi or BLE fallback when Classic pairing is unavailable
- OTA firmware update flow from the app
- Cloud sync for match history across devices
- Voice shortcuts for score adjustments during live play
