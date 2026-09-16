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

– Each preset is a shell command run in a new Terminal window.
– Preset results show pass/fail in the menu bar icon.
– No Dock icon; lives entirely in the menu bar.

---

<div align="center">

Made with ♥ for developers who prefer staying in the flow.

</div>

