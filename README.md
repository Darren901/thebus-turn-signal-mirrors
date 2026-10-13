# TurnSignalMirrors — The Bus

**English** | [繁體中文](README.zh-TW.md)

A UE4SS Lua mod for **The Bus** that shows each HUD side-mirror window (the ones you add in Tab / HUD edit mode) only while the turn signal on that side is active.

## Requirements

- The Bus (tested on 1.2.0.100996, Unreal Engine 5.6)
- [UE4SS](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental-latest) **experimental** build (the stable v3.0.1 release does not support UE 5.6)

## Installation

1. Extract the UE4SS experimental zip into `The Bus\TheBus\Binaries\Win64\` (this adds `dwmapi.dll` and a `ue4ss\` folder).
2. Copy the `TurnSignalMirrors` folder from this repo into `Win64\ue4ss\Mods\`.
3. In `ue4ss\Mods\mods.txt`, add the line `TurnSignalMirrors : 1` above `Keybinds : 1`.
4. Start the game, get in a bus, press Tab and add the left / right HUD mirrors.

**Uninstall:** delete `ue4ss\Mods\TurnSignalMirrors`. To remove UE4SS entirely, also delete `dwmapi.dll` and the `ue4ss\` folder.

## Behavior

| State | Left mirror | Right mirror (incl. wheel mirror) |
|---|---|---|
| Indicator off | Hidden | Hidden |
| Left indicator | Shown | Hidden |
| Right indicator | Hidden | Shown |
| Tab / HUD edit mode | Shown | Shown |

After the indicator turns off, the mirror stays visible for `HoldSeconds` before hiding.

## Hotkeys

- `Ctrl+F11` — toggle the mod on/off (when off, mirrors are always visible)
- `Ctrl+F12` — write the current state to `ue4ss\UE4SS.log`

## Configuration

At the top of `Scripts/main.lua`:

| Option | Default | Description |
|---|---|---|
| `HoldSeconds` | `1.5` | Seconds to keep the mirror visible after the indicator turns off |
| `ShowBothOnHazard` | `false` | Show both mirrors while hazard lights are on |
| `IncludeRightWheel` | `true` | The right wheel mirror follows the right indicator |
| `PollMs` | `100` | Polling interval in milliseconds |

## Known limitations

- Only tested in single-player, Berlin map, Scania Citywide. Other buses should work as long as their mirror components are named `Mirror_Left_*` / `Mirror_Right_*`.
- Multiplayer is untested.
- Mirrors are made transparent, not disabled — the game still renders them, so there is no FPS gain.
- Relies on internal class names (`UMG_MirrorHUD_C`, `BP_IndicatorModule_C`); a game update may break it.
- Steam's "Verify integrity of game files" removes UE4SS; reinstall it afterwards.

## License

[MIT](LICENSE)
