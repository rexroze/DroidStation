# Changelog

All notable changes to DroidStation are documented here.
Maintained by [@rexroze](https://github.com/rexroze).

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
Versioning follows [Semantic Versioning](https://semver.org/).

---

## [1.1.0] — 2026-04-23

### Added
- **Size estimates** — every menu option now shows its approximate download/install size
- **Installation size summary** — full breakdown table shown before anything downloads, with a "Go back and change selections" option so users can adjust before committing
- **Optional Linux container** — proot/Ubuntu is now opt-in during setup; skipping it saves ~800 MB
- **Container apps** — LibreOffice, GIMP, Inkscape, and VLC can be installed directly into the Ubuntu container during setup (appear in desktop menu via Proot Bridge)
- **System resource check** — installer shows free storage and RAM with color-coded warnings before the option menus
- **Dynamic step count** — `TOTAL_STEPS` is calculated after selections so the progress bar percentage is always accurate
- **`--user=<name>` flag** — set a custom username for the Linux container (default: `droiduser`)
- **`--extras=libreoffice,gimp,inkscape,vlc` flag** — install container apps non-interactively
- **`--no-proot` flag** — documented and exposed in all installer modes, not just flags mode

### Changed
- **Spinner fixed** — replaced `\r` carriage-return with ANSI `\033[1A\033[2K` (cursor-up + erase-line); the "Installing X" line now overwrites itself correctly in Termux mobile terminals instead of flooding the screen with repeated lines
- **Wine, VNC, proot steps** are now skipped entirely (not just no-ops) when not selected, keeping the progress bar accurate
- Storage requirement updated: ~2 GB minimum without container, ~4–6 GB with container + extras

### Removed
- **Linux Container desktop shortcut** (`LinuxContainer.desktop`) — it opened a raw shell window with no context; users can still open the container with `bash ~/start-proot.sh` from any terminal

---

## [1.0.0] — 2026-04-22

### Added
- Initial release of DroidStation
- Desktop Environment selection: XFCE4, KDE Plasma, LXQt, GNOME
- Proot Linux container support: Ubuntu 22.04, Debian 12, Kali Linux
- Proot App Bridge — apps installed inside Proot automatically appear in the desktop menu
- Smart GPU detection: Turnip/Zink for Adreno (Snapdragon), LLVMpipe fallback for Mali/other
- Samsung DeX auto-detection with 1920×1080 resolution optimization
- PulseAudio sound server with TCP module for proot passthrough
- Developer stack: Python 3 + pip + virtualenv + uv + flask + ruff (optional)
- Developer stack: Node.js LTS + TypeScript + ts-node + nodemon (optional)
- Optional apps: VS Code (code-oss), Firefox, Chromium, File Manager
- Optional Wine/Hangover + Box64 for Windows x86_64 app compatibility
- Optional TigerVNC server for remote/monitor display
- Three installer modes: flags, TUI (dialog/whiptail), numbered prompts (auto-detected)
- Global `startdesk` / `stopdesk` commands symlinked to `$PREFIX/bin`
- Dark theme pre-configured: Adwaita-dark + Dracula terminal (Xfconf XML)
- Auto-generated dark gradient wallpaper via ImageMagick (no internet required)
- First-run script for panel theming (self-destructs after first launch)
- Keyboard shortcuts pre-configured: Super+T, Super+E, tiling, screenshot
- Full install log written to `~/droidstation-install.log`
- Credits to upstream projects: techjarves/Linux-on-Samsung, orailnoor/DroidDesk

---

## [Unreleased]

### Planned
- ARM Mali GPU driver improvements
- Dotfiles customization flag (`--dotfiles=<url>`)
- Auto-update command: `droidstation update`
- Wayland/XWayland support (experimental)
- GitHub Actions shell linting with ShellCheck
