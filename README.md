# Focus Build

Run test/build presets from the menu bar, or attach to a test process the app detects.

Menu extra for macOS 14+. It lives in the menu bar and does not show a Dock icon.

## Features

- Presets: name, command, arguments, working directory (empty = choose on run).
- Shipped defaults: `pnpm test`, `npm test`, `cargo test`, `swift test`.
- Stop a running job.
- Detects likely test processes via `ps` and can notify when they end.
- Last exit line (`succeeded` / `failed (code N)`).

## Requirements

- macOS 14 Sonoma or later
- Swift 5.9 or later
- Notification permission if you want end-of-run alerts (deny is allowed)

## Install

```bash
git clone https://github.com/BadryansahBangsawan/focus-build.git
cd focus-build
bash package-app.sh
open dist/FocusBuild.app
```

`package-app.sh` builds a release binary, wraps `dist/FocusBuild.app`, and ad-hoc codesigns it (`codesign -s -`). Unsigned is fine for local use.

Enable **Open at Login** from Settings if you want it after reboot.

## Usage

- Click **Run** next to a preset. If cwd is empty, pick a folder first.
- **Stop** terminates the spawned process.
- Add or delete presets in Settings. `ps` failures show as a red label, not a crash.

## Permissions

- Notifications are optional. No Accessibility.

Denied permissions must not crash the app. You should see a banner and a button to open System Settings.

## Privacy

No network unless your preset command talks to the network. Presets: `~/Library/Application Support/Focus Build/presets.json`.

Bundle ID: `engineer.badry.focusbuild`.

## Development

```bash
swift build
swift build -c release --product FocusBuild
```

Layout: `Sources/` (SwiftPM executable), `Info.plist`, `Assets/AppIcon.icns`, `package-app.sh`.

## License

[MIT](LICENSE)
