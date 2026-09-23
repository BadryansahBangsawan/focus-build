<div align="center">

# Focus Build

**Run a named preset (`pnpm test`, `npm test`, `cargo test`, `swift test`) from the extra. Stop it, or watch pids `ps` already started.**

Menu extra for macOS 14+. Lives on the **right** of the menu bar. No Dock icon.

<br/>

[![Build](https://github.com/BadryansahBangsawan/focus-build/actions/workflows/ci.yml/badge.svg)](https://github.com/BadryansahBangsawan/focus-build/actions/workflows/ci.yml)
[![Latest Release](https://img.shields.io/github/v/release/BadryansahBangsawan/focus-build?style=flat-square)](https://github.com/BadryansahBangsawan/focus-build/releases/latest)
[![macOS](https://img.shields.io/badge/macOS-14%2B-black?style=flat-square&logo=apple)](https://github.com/BadryansahBangsawan/focus-build/releases/latest)

<br/>

| | |
|---|---|
| Product | `FocusBuild` |
| Bundle ID | `engineer.badry.focusbuild` |
| Cask | `focus-build` |
| Status item | SF Symbol `hammer` |
| Panel | opaque ~360×420 pt |

</div>

---

## What you get

| Piece | Behavior |
|---|---|
| **Presets** | name, command, arguments, cwd. Empty cwd → **Choose folder** on run. Defaults: `pnpm test`, `npm test`, `cargo test`, `swift test` via `/usr/bin/env`. |
| **Run** | **Run** / **Stop**. Stop sends SIGTERM, then SIGKILL after 3 seconds if the pid is still alive. |
| **Detected** | `/bin/ps -axo pid=,comm=,args=` every 2s. Needles: `pnpm test`, `npm test`, `cargo test`, `swift test`, `xcodebuild`. |
| **Log** | Last 200 lines. **Copy last log**. Exit: `<name> succeeded` or `<name> failed (code N)`. |
| **Empty** | **Nothing running**. Action: **Run** plus the first preset name, or **Open Settings**. |
| **Notify** | `UNUserNotificationCenter` request on launch (alert / sound / badge). Title `Focus Build`. |
| **Login** | Open at Login from Settings (`SMAppService`). |

---

## Download

| File | Use |
|---|---|
| **`FocusBuild.app.zip`** | Homebrew cask / unzip, drag **FocusBuild** onto **Applications** |

**[Releases](https://github.com/BadryansahBangsawan/focus-build/releases/latest)**

---

## Install

### Homebrew

```bash
brew tap BadryansahBangsawan/mac-menu-apps
brew trust BadryansahBangsawan/mac-menu-apps
brew install --cask focus-build
```

`brew trust` is required on Homebrew 6 or `brew install --cask` refuses the tap.

First open (ad-hoc signed):

```bash
xattr -cr /Applications/FocusBuild.app
open /Applications/FocusBuild.app
```

Still blocked: System Settings → Privacy & Security → Open Anyway.

Do not run `dist/FocusBuild.app` while `/Applications/FocusBuild.app` is running (same bundle ID).

---

## How to open

This is an `LSUIElement` extra. Proof it is running is the **hammer** status item on the **right** of the menu bar, not a window from Finder or Launchpad.

1. Click that extra. The panel is opaque ~360×420 pt, not a 10px strip.
2. If the bar is full, look behind the Control Center overflow chevron **«**.
3. Double-clicking in Finder/Launchpad only changes the left-side app name. That is expected. There is no Dock icon.

---

## Usage

1. Click **Run** next to a preset. If cwd is empty, pick a folder (**Choose folder**). Missing path: **Working directory does not exist:** plus the path.
2. Empty: **Nothing running** — run the first preset, or **Open Settings**.
3. **Stop** terminates the spawned process.
4. **Detected** lists pids whose args contain a test needle. `ps` failures are a red label, not a crash.
5. **Settings** at the bottom: presets (**No presets** / **Add** / **Delete**), Open at Login, Quit.

---

## Permissions

No `NS*UsageDescription` keys. On launch, `UNUserNotificationCenter` requests alert / sound / badge. Deny is allowed; the extra still runs.

---

## Data

| What | Where |
|---|---|
| Presets | `~/Library/Application Support/Focus Build/presets.json` |
| Open at Login | `SMAppService.mainApp` (Settings toggle) |

Decode failure → empty list plus a red banner. The extra does not crash. Missing file seeds the four default presets.

---

## Privacy

No network of its own. Commands you configure run locally. Notifications stay on this Mac.

---

## Uninstall

```bash
brew uninstall --cask focus-build
```

Or delete `/Applications/FocusBuild.app`. Then:

```bash
rm -rf "$HOME/Library/Application Support/Focus Build"
```

Turn off **Focus Build** in System Settings → General → Login Items if it remains.

---

## Troubleshooting

| What you see | What to do |
|---|---|
| Finder “opens” nothing / no Dock icon | Click the **hammer** extra on the right of the menu bar. |
| Extra missing | Overflow **«**, or `pgrep -x FocusBuild` then `open /Applications/FocusBuild.app`. |
| “Damaged” / cannot verify | `xattr -cr /Applications/FocusBuild.app`. `spctl --assess` is `rejected` even when it runs. |
| `brew install --cask` refuses the tap | `brew trust BadryansahBangsawan/mac-menu-apps` |
| **Nothing running** | Run a preset, or wait for a detected test pid. |
| **Working directory does not exist:** | Pick a folder, or fix the preset cwd in Settings. |
| `ps failed` | `/bin/ps` stderr as a red label. |
| ~10px empty strip under the bar | Reinstall from this repo. |

---

## Build from source

```bash
git clone https://github.com/BadryansahBangsawan/focus-build.git
cd focus-build
swift build -c release --product FocusBuild
bash package-app.sh
open dist/FocusBuild.app
```

Tag `v*` runs CI: `FocusBuild.app.zip`. Never commit `dist/`.

Layout: `Sources/` (SwiftPM executable), `Info.plist`, `Assets/AppIcon.icns`, `package-app.sh`. `FunTheme.swift` is copied verbatim (no shared package).

---

## FAQ

**Why is there no Dock icon?**  
It is a menu extra. Click the hammer item on the **right** of the menu bar.

**Do I have to allow notifications?**  
No. Deny is allowed. End-of-run banners in the panel still show `<name> succeeded` / `failed (code N)`.

**Where are presets stored?**  
`~/Library/Application Support/Focus Build/presets.json`.

**How do I stop it opening at login?**  
Settings in the panel, or System Settings → General → Login Items → **Focus Build**.

---

<div align="center">

[MIT](LICENSE)

</div>
