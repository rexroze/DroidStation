# DroidStation 🚀

**Full Linux Desktop for Android — Samsung DeX Optimized**

Turn any Android phone or tablet into a real Linux workstation. Not a terminal emulator, not a sandbox — a complete desktop environment with GPU acceleration, a full Linux package manager via Proot, and native dev tooling running directly on your hardware.

Connect to a monitor via Samsung DeX or USB-C and it becomes a Linux PC. Unplug it and your entire setup comes with you.

---

## What You Get

| Category | Details |
|---|---|
| **Desktops** | XFCE4, KDE Plasma, LXQt, GNOME |
| **Distros** | Ubuntu 22.04, Debian 12, Kali Linux (via Proot) |
| **GPU** | Turnip/Zink (Adreno) · LLVMpipe fallback (Mali/other) |
| **Audio** | PulseAudio |
| **Dev — Python** | Python 3 + pip + virtualenv + uv + flask + ruff |
| **Dev — Node.js** | Node.js LTS + TypeScript + ts-node + nodemon |
| **Extras** | VS Code, Firefox, Chromium, File Manager (all optional) |
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
| **Storage** | ~4–6 GB free (more if you choose Kali or install extras) |
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

## Installer Modes

DroidStation auto-detects the best installer for your environment.

### 1 · Interactive prompts (default)
Just run the script with no arguments. You'll be walked through every choice with numbered menus.

```bash
bash droidstation-setup.sh
```

### 2 · TUI menus
If `dialog` or `whiptail` is installed, a graphical menu is shown automatically.

```bash
pkg install dialog
bash droidstation-setup.sh
```

### 3 · One-liner flags
Skip all prompts by passing everything as flags. Ideal for re-installs or automation.

```bash
bash droidstation-setup.sh --de=xfce --distro=ubuntu --dev=python,node --extras=vscode,firefox --vnc --wine
```

**Available flags:**

| Flag | Values | Description |
|---|---|---|
| `--de=` | `xfce` `kde` `lxqt` `gnome` | Desktop environment |
| `--distro=` | `ubuntu` `debian` `kali` | Proot Linux distro |
| `--dev=` | `python` `node` (comma-separated) | Dev stacks |
| `--extras=` | `vscode` `firefox` `chromium` `files` | Optional apps |
| `--vnc` | — | Install TigerVNC server |
| `--wine` | — | Install Wine/Hangover |
| `--no-proot` | — | Skip Proot container |
| `--help` | — | Show help |

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
| `bash ~/start-proot.sh` | Open the Proot Linux shell |
| `bash ~/proot-menu-sync.sh` | Sync Proot apps into desktop menu |
| `bash ~/start-vnc.sh` | Start VNC remote desktop (if installed) |

---

## Proot Linux Container

The Proot container gives you a full standard Linux environment (Ubuntu/Debian/Kali) where `apt` works normally. Install anything you can't get from Termux's repositories.

```bash
# Enter the container
bash ~/start-proot.sh

# Inside proot — install anything
sudo apt install blender wireshark libreoffice gimp

# Exit proot
exit

# Sync newly installed apps to your desktop menu
bash ~/proot-menu-sync.sh
```

Apps installed this way appear in your XFCE/KDE application menu with a `[P]` prefix. They launch with full GPU passthrough and X11 display sharing — no extra configuration needed.

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

# Open Windows file explorer
wine winefile
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

**Proot apps not showing in menu**
Run `bash ~/proot-menu-sync.sh` after installing apps inside proot.

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

---

## Project Structure

```
DroidStation/
├── droidstation-setup.sh   # Main installer
└── README.md               # This file
```

After installation, the following are created in your home directory:

```
~/
├── startdesk.sh            # Start desktop (also symlinked as global 'startdesk')
├── stopdesk.sh             # Stop desktop  (also symlinked as global 'stopdesk')
├── start-proot.sh          # Open Proot Linux shell
├── proot-menu-sync.sh      # Sync Proot apps to desktop menu
├── start-vnc.sh            # Start VNC (if installed)
├── Desktop/                # Desktop shortcuts
│   ├── Firefox.desktop
│   ├── VSCode.desktop
│   ├── Terminal.desktop
│   ├── LinuxContainer.desktop
│   └── ...
├── droidstation-install.log
└── .config/
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
