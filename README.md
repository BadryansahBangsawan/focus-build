<div align="center">

# Focus Build

**Run test and build presets without leaving the menu bar.**  
macOS menu extra — lives in the menu bar, no Dock icon.

<br/>

[![Latest Release](https://img.shields.io/github/v/release/BadryansahBangsawan/focus-build?style=flat-square&color=76B900&label=latest)](https://github.com/BadryansahBangsawan/focus-build/releases/latest)
[![macOS](https://img.shields.io/badge/macOS-14%2B-black?style=flat-square&logo=apple)](https://github.com/BadryansahBangsawan/focus-build/releases/latest)
[![Swift](https://img.shields.io/badge/Swift-5.9%2B-F05138?style=flat-square&logo=swift&logoColor=white)](https://swift.org)

<br/>

</div>

---

## Download

| Platform | File |
|---|---|
| **macOS** (Apple Silicon & Intel, macOS 14+) | `FocusBuild-*-macos.zip` |

[Go to Releases](https://github.com/BadryansahBangsawan/focus-build/releases/latest)

---

## Installation

### Homebrew (recommended)

```bash
brew tap BadryansahBangsawan/mac-menu-apps
brew install --cask focus-build
```

A **Focus Build** icon appears in the menu bar. If Gatekeeper blocks it on first launch:

```bash
xattr -cr /Applications/FocusBuild.app && open /Applications/FocusBuild.app
```

Or: right-click the app, Open, then Open again. Still blocked? **System Settings → Privacy & Security → Open Anyway**.

### GitHub Releases

1. Download `FocusBuild-*-macos.zip` from [Releases](https://github.com/BadryansahBangsawan/focus-build/releases/latest)
2. Unzip and drag **FocusBuild** into Applications
3. On first launch, run the xattr command above if Gatekeeper blocks it

### Build from source

```bash
git clone https://github.com/BadryansahBangsawan/focus-build.git
cd focus-build
bash package-app.sh
open dist/FocusBuild.app
```

Requires Xcode Command Line Tools and Swift 5.9+.

---

## Notes

– Each preset is a shell command run in a new Terminal window; the working directory is your home folder unless the command `cd`s first.
– Preset results show pass/fail in the menu bar icon.
– No Dock icon; lives entirely in the menu bar.
– If a preset never opens Terminal, allow Focus Build under **System Settings → Privacy & Security → Automation** (and grant Terminal access when prompted).

---

## Troubleshooting

**Preset runs but the command fails immediately**  
Presets run in a non-login shell — tools installed via Homebrew or `nvm` may not be on `$PATH`. Prefix your preset command with a shell path fix:
```bash
export PATH="/opt/homebrew/bin:$HOME/.nvm/versions/node/$(node -v)/bin:$PATH" && npm test
```

**Menu bar icon stays grey after a run**  
The icon updates only when a preset exits. If a command hangs (e.g. a watcher with no `--run-once`), kill the Terminal tab and add an explicit exit or timeout to the preset.

**Build output is empty**  
Some tools buffer output. Add `--no-silent` / `2>&1` or force unbuffered output (`PYTHONUNBUFFERED=1`, `--reporter spec`) so results reach the menu bar.

**Gatekeeper blocks after an update**  
Re-run `xattr -cr /Applications/FocusBuild.app && open /Applications/FocusBuild.app` after each manual update from Releases; Homebrew Cask handles this automatically.

---

<div align="center">

Made with ♥ for developers who prefer staying in the flow.

</div>

