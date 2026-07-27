# Bluetooth Command Protocol

The mobile app sends **newline-terminated ASCII** commands to the ESP32 over Bluetooth Classic (SPP). Each command is a single line ending with `\n` (LF). The helper `ScoreboardCommands.wire()` in `lib/utils/commands.dart` appends the newline.

Example on the wire:

```
START\n
A+\n
NAMEA:Eagles\n
PLAYTRACK:3\n
```

## Outbound commands (app → ESP32)

| Command | Description |
|---------|-------------|
| `START` | Start match |
| `END` | End match |
| `RESET` | Reset scores and defaults |
| `A+` | Increment Team A score |
| `A-` | Decrement Team A score |
| `B+` | Increment Team B score |
| `B-` | Decrement Team B score |
| `NAMEA:<name>` | Set Team A display name |
| `NAMEB:<name>` | Set Team B display name |
| `PLAY` | Start or resume music playback |
| `PAUSE` | Pause music playback |
| `NEXT` | Skip to next track |
| `PREV` | Go to previous track |
| `VOLUP` | Increase volume |
| `VOLDOWN` | Decrease volume |
| `MUTE` | Mute audio output |
| `UNMUTE` | Unmute audio output |
| `REPEAT` | Toggle repeat mode |
| `SHUFFLE` | Toggle shuffle mode |
| `PLAYTRACK:<n>` | Play track number *n* from SD library (e.g. `PLAYTRACK:3`) |
| `AUDIO` | Play test / announcement sample on DFPlayer |

Parameterized commands use a colon separator with no spaces around the delimiter:

- `NAMEA:Home Team`
- `NAMEB:Visitors`
- `PLAYTRACK:12`

## Inbound status (ESP32 → app, optional)

The app parses optional telemetry lines when the firmware sends them. Unknown lines are ignored; missing telemetry never blocks the UI.

| Line | Meaning | Example |
|------|---------|---------|
| `BAT:<percent>` | Battery level 0–100 | `BAT:85` |
| `TRACK:<title>` | Now playing track title | `TRACK:Match Anthem` |
| `OK` | Command acknowledged | `OK` |

## Wire format summary

- **Encoding:** ASCII
- **Line terminator:** `\n` (LF)
- **Direction:** App primarily sends; ESP32 may reply with status lines
- **Source of truth in code:** `lib/utils/commands.dart`, `lib/utils/status_parser.dart`
