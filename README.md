# DroidStation 🚀

**Full Linux Desktop for Android — Samsung DeX Optimized**

Turn any Android phone or tablet into a real Linux workstation. Not a terminal emulator, not a sandbox — a complete desktop environment with GPU acceleration, a full Linux package manager via Proot, and native dev tooling running directly on your hardware.

Connect to a monitor via Samsung DeX or USB-C and it becomes a Linux PC. Unplug it and your entire setup comes with you.

---

## What You Get

| Category | Details |
|---|---|
| **Desktops** | XFCE4, KDE Plasma, LXQt, GNOME |
| **Linux Container** | Ubuntu 22.04, Debian 12, Kali Linux (via Proot — optional) |
| **GPU** | Turnip/Zink (Adreno) · LLVMpipe fallback (Mali/other) |
| **Audio** | PulseAudio |
| **Dev — Python** | Python 3 + pip + virtualenv + uv + flask + ruff (optional) |
| **Dev — Node.js** | Node.js LTS + TypeScript + ts-node + nodemon (optional) |
| **Extras** | VS Code, Firefox, Chromium, File Manager (all optional) |
| **Container Apps** | LibreOffice, GIMP, Inkscape, VLC — installed inside Ubuntu (optional) |
| **Proot Bridge** | Apps installed inside Proot appear in your desktop menu |
| **VNC** | TigerVNC remote display over WiFi or USB (optional) |
| **Wine** | Hangover + Box64 — run Windows x86\_64 apps (optional) |
| **Theme** | Adwaita-dark + Dracula terminal (pre-configured) |
| **Commands** | `startdesk` / `stopdesk` work from anywhere in Termux |

---

## Requirements

| Requirement | Notes |
|---|---|
| **Android 10+** | ARM64 device |
| **Termux** | Install from [F-Droid](https://f-droid.org/en/packages/com.termux/) — **not** the Play Store version |
| **Termux-X11** | Download the latest APK from [GitHub Releases](https://github.com/termux/termux-x11/releases) |
| **Storage** | ~2 GB minimum (desktop only) · ~4–6 GB with Linux container + extras |
| **RAM** | 4 GB minimum · 6 GB+ recommended for KDE/GNOME |

> **Samsung DeX users:** No extra setup needed. DroidStation auto-detects DeX and applies a 1920×1080 resolution on launch.

---

## Installation

### One-liner (recommended)

```bash
apt update && apt upgrade -y && apt install curl -y
curl -fsSL https://raw.githubusercontent.com/rexroze/DroidStation/main/droidstation-setup.sh -o setup.sh
bash setup.sh
```

### Manual clone

```bash
apt update && apt install git -y
git clone https://github.com/rexroze/DroidStation.git
cd DroidStation
chmod +x droidstation-setup.sh
bash droidstation-setup.sh
```

---

## Installer

### How it works

When you run the installer, it:

1. Shows your available **storage and RAM** with a color-coded warning if space is tight
2. Walks you through every option with **estimated download sizes** next to each choice
3. Displays a **full size breakdown** before anything downloads — you can go back and change selections if the total is too large
4. Installs only what you chose, with a **live progress bar** showing the current step, percentage, and task

### Installer modes

DroidStation auto-detects the best mode for your environment.

#### Interactive prompts (default)
Just run the script with no arguments. You'll be walked through every choice with numbered menus and size estimates.

```bash
bash droidstation-setup.sh
```

#### TUI menus
If `dialog` or `whiptail` is installed, a graphical checklist menu is shown automatically.

```bash
pkg install dialog
bash droidstation-setup.sh
```

#### One-liner flags
Skip all prompts by passing everything as flags. Ideal for re-installs or automation.

```bash
bash droidstation-setup.sh --de=xfce --distro=ubuntu --dev=python,node \
  --extras=vscode,firefox,libreoffice,gimp --wine
```

#### Dry run
Preview the install plan, estimated size, and generated files without changing anything.

```bash
bash droidstation-setup.sh dry-run --de=xfce --no-proot --extras=firefox
```

#### Doctor
Check your current Termux environment before or after installing.

```bash
bash droidstation-setup.sh doctor
```

### Available flags

| Flag | Values | Description |
|---|---|---|
| `--de=` | `xfce` `kde` `lxqt` `gnome` | Desktop environment |
| `--distro=` | `ubuntu` `debian` `kali` | Proot Linux distro |
| `--dev=` | `python` `node` (comma-separated) | Dev stacks |
| `--extras=` | `vscode` `firefox` `chromium` `files` `libreoffice` `gimp` `inkscape` `vlc` | Optional apps |
| `--vnc` | — | Install TigerVNC server |
| `--vnc-pass=` | any 6-8 character password | VNC password; generated if omitted |
| `--wine` | — | Install Wine/Hangover |
| `--no-proot` | — | Skip Linux container entirely (saves ~800 MB) |
| `--user=` | any username | Container username (default: `droiduser`) |
| `--dry-run` | — | Show the install plan without making changes |
| `--help` | — | Show help |

---

## Estimated Install Sizes

These are approximate. Actual sizes depend on your device and cached packages.

| Component | Est. Size |
|---|---|
| Core (X11, audio, GPU drivers) | ~300 MB |
| XFCE4 | ~400 MB |
| KDE Plasma | ~900 MB |
| LXQt | ~200 MB |
| GNOME | ~700 MB |
| Linux Container base (Ubuntu/Debian) | ~800 MB |
| Kali Linux container | ~1.2 GB |
| Python 3 + pip + libs | ~100 MB |
| Node.js LTS | ~150 MB |
| VS Code | ~220 MB |
| Firefox | ~260 MB |
| Chromium | ~310 MB |
| Wine/Hangover | ~600 MB |
| LibreOffice (in container) | ~700 MB |
| GIMP (in container) | ~350 MB |
| Inkscape (in container) | ~250 MB |
| VLC (in container) | ~120 MB |

The installer shows a total estimate and lets you go back to adjust selections before anything downloads.

---

## Starting the Desktop

1. Open the **Termux-X11** app on your phone (leave it running in the background)
2. In Termux, run:

```bash
startdesk
```

3. Switch to the Termux-X11 app — your desktop is ready.

To stop:

```bash
stopdesk
```

---

## Commands Reference

| Command | What It Does |
|---|---|
| `startdesk` | Start your Linux desktop (X11) |
| `stopdesk` | Stop all desktop sessions |
| `bash ~/start-proot.sh` | Open the Linux container shell |
| `bash ~/proot-menu-sync.sh` | Sync container apps into desktop menu |
| `bash ~/start-vnc.sh` | Start VNC remote desktop (if installed) |
| `bash droidstation-setup.sh doctor` | Check Termux, display, audio, storage, RAM, and Proot readiness |

---

## Linux Container

The Proot container gives you a full standard Linux environment (Ubuntu/Debian/Kali) where `apt` works normally. It's **optional** — you can skip it during setup to save ~800 MB.

```bash
# Enter the container
bash ~/start-proot.sh

# Inside the container — install anything
sudo apt install blender wireshark

# Exit the container
exit

# Sync newly installed apps to your desktop menu
bash ~/proot-menu-sync.sh
```

Apps installed inside the container appear in your XFCE/KDE application menu with a `[P]` prefix. They launch with full GPU passthrough and X11 display sharing — no extra configuration needed.

### Optional container apps

During setup you can choose to install these directly into the container:

| App | What It Is | Est. Size |
|---|---|---|
| **LibreOffice** | Full office suite (Writer, Calc, Impress) | ~700 MB |
| **GIMP** | Image editor — Photoshop alternative | ~350 MB |
| **Inkscape** | Vector graphics editor — Illustrator alternative | ~250 MB |
| **VLC** | Universal media player | ~120 MB |

You can also install them manually anytime:

```bash
bash ~/start-proot.sh
sudo apt install libreoffice gimp inkscape vlc
exit
bash ~/proot-menu-sync.sh
```

---

## Desktop Environments

### XFCE4 ⭐ Recommended
Fast, lightweight, and DeX-friendly. Includes a macOS-style Plank dock and the Whisker Menu launcher. Best choice for daily use and most hardware.

### KDE Plasma
Full Windows-style desktop with modern effects. Requires a Snapdragon device with Adreno GPU for smooth performance. Heavy on RAM.

### LXQt
Ultra-lightweight Qt desktop. Best for Exynos devices (Mali GPU) or phones with 4 GB RAM or less. Snappy and efficient.

### GNOME
Modern, touch-friendly interface. Heavy and best suited to high-end hardware with Adreno acceleration.

---

## GPU Acceleration

| Chipset | GPU | Driver | Notes |
|---|---|---|---|
| Snapdragon (Qualcomm) | Adreno | Turnip + Zink | Full hardware acceleration |
| Exynos (Samsung) | Mali | LLVMpipe | Software rendering — use XFCE or LXQt |
| Other (MediaTek, etc.) | Varies | LLVMpipe fallback | Software rendering |

> DroidStation auto-detects your GPU from `ro.hardware.chipname` and `ro.hardware.egl` at install time. No manual configuration needed.

---

## Developer Tooling

### Python stack
```
Python 3 · pip · virtualenv · uv · flask · requests · httpx · black · ruff
```

### Node.js stack
```
Node.js LTS · npm · Yarn · TypeScript · ts-node · nodemon
```

Both stacks are optional — you're asked during setup (or use `--dev=python,node`).

---

## Samsung DeX Tips

- DroidStation detects Samsung hardware automatically and enables DeX optimizations
- For the best experience, connect a keyboard and mouse before running `startdesk`
- XFCE4 with Plank dock is the most DeX-like layout
- **Important:** Go to **Settings → Developer Options** and disable **"Child Process"** restrictions for Termux. Without this, your desktop session may be killed by Android when the screen locks or the app goes to background

---

## VNC Remote Display

VNC lets you view your desktop on a monitor, TV, or another device over WiFi or USB.

```bash
# Start VNC desktop
bash ~/start-vnc.sh

# Connect with any VNC Viewer app:
# Local:   127.0.0.1:5901
# Network: <your-phone-ip>:5901
```

If you enable VNC without setting `--vnc-pass`, DroidStation generates an 8-character password during setup and prints it on the completion screen.

For a **Raspberry Pi monitor bridge** (for phones without USB-C display output):
1. Connect phone to Pi via USB tethering
2. Run `bash ~/start-vnc.sh` on your phone
3. Use a VNC Viewer on the Pi to connect to the phone's IP

---

## Wine / Windows App Support

Wine via Hangover + Box64 lets you run x86\_64 Windows applications on ARM64 Android.

```bash
# Configure Wine
winecfg

# Run a Windows app
wine yourapp.exe
```

> Performance varies by app. Simple utilities run well. Heavier apps may be slow.

---

## Theming

DroidStation ships with a pre-configured dark theme:

- **GTK Theme:** Adwaita-dark
- **Terminal:** Dracula color scheme (background `#282a36`, accent `#bd93f9`)
- **Compositor:** Shadows + 95% frame opacity
- **Panels:** Dark semi-transparent background
- **Wallpaper:** Auto-generated dark purple gradient (no internet required)

Panel layout and wallpaper are applied automatically on first desktop launch via a one-shot autostart script.

---

## Keyboard Shortcuts (XFCE)

| Shortcut | Action |
|---|---|
| `Super + T` | Open Terminal |
| `Super + E` | Open File Manager |
| `Super + R` | App Finder / Run |
| `Super + D` | Show Desktop |
| `Super + ←` | Tile Window Left |
| `Super + →` | Tile Window Right |
| `Super + ↑` | Maximize Window |
| `Alt + F4` | Close Window |
| `Print` | Screenshot |

---

## Troubleshooting

**Desktop doesn't appear after running `startdesk`**
Make sure the Termux-X11 app is open before running `startdesk`. Switch to it after the script prints the startup message.

**Screen goes black / session drops**
Disable Child Process restrictions in Developer Options (see Samsung DeX Tips above).

**GPU acceleration not working**
Run `glxinfo | grep renderer` inside a terminal on the desktop. If it shows `llvmpipe`, your GPU isn't supported by Turnip. This is expected on Exynos/Mali devices.

**Container apps not showing in menu**
Run `bash ~/proot-menu-sync.sh` after installing apps inside the container.

**Audio not working**
Inside the desktop terminal, run:
```bash
pulseaudio --start --exit-idle-time=-1
pactl load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1
export PULSE_SERVER=127.0.0.1
```

**Check the install log**
```bash
cat ~/droidstation-install.log
```

**Preview before installing**
```bash
bash droidstation-setup.sh dry-run --de=xfce --no-proot --extras=firefox
```

**Run environment checks**
```bash
bash droidstation-setup.sh doctor
```

**Uninstall DroidStation-created files**
```bash
bash uninstall.sh
```

---

## Project Structure

```
DroidStation/
├── droidstation-setup.sh   # Main installer
├── uninstall.sh            # Cleanup helper
└── README.md               # This file
```

After installation, the following are created in your home directory:

```
~/
├── startdesk.sh            # Start desktop (also symlinked as global 'startdesk')
├── stopdesk.sh             # Stop desktop  (also symlinked as global 'stopdesk')
├── start-proot.sh          # Open Linux container shell (if installed)
├── proot-menu-sync.sh      # Sync container apps to desktop menu (if installed)
├── start-vnc.sh            # Start VNC (if installed)
├── Desktop/                # Desktop shortcuts
│   ├── Terminal.desktop
│   ├── Firefox.desktop     # (if installed)
│   ├── Chromium.desktop    # (if installed)
│   ├── VSCode.desktop      # (if installed)
│   ├── WineConfig.desktop  # (if Wine installed)
│   └── WineExplorer.desktop
├── droidstation-install.log
└── .config/
    ├── droidstation/config.env      # Saved installer choices
    ├── droidstation-gpu.sh          # GPU environment vars (auto-sourced)
    ├── droidstation-wallpaper.jpg   # Generated wallpaper
    ├── droidstation-first-run.sh    # One-shot panel/theme setup
    └── xfce4/                       # XFCE theme + keyboard config
```

---

## Made By

**DroidStation** is designed, built, and maintained by **[@rexroze](https://github.com/rexroze)**.

If this project helped you, consider dropping a ⭐ on the repo — it helps more people find it.

---

## Credits & Upstream Projects

DroidStation stands on the shoulders of two great projects:

| Project | Author | Contribution to DroidStation |
|---|---|---|
| [Linux-on-Samsung](https://github.com/techjarves/Linux-on-Samsung) | techjarves | GPU detection, Turnip/Zink drivers, Wine/Hangover, spinner UI, progress bar |
| [DroidDesk](https://github.com/orailnoor/DroidDesk) | orailnoor | Proot container, App Bridge menu sync, VNC, dark theme, GPU proot passthrough |

Both are released under the MIT License.

---

## License

MIT — see [LICENSE](./LICENSE) for full text.
