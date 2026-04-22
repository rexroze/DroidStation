# Changelog

All notable changes to DroidStation are documented here.
Maintained by [@rexroze](https://github.com/rexroze).

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
Versioning follows [Semantic Versioning](https://semver.org/).

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
