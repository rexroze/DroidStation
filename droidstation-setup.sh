#!/data/data/com.termux/files/usr/bin/bash
# ══════════════════════════════════════════════════════════════════════
#  DroidStation v1.0
#  Full Linux Desktop for Android — Samsung DeX Optimized
#
#  Made by: rexroze (https://github.com/rexroze)
#
#  Best features combined from:
#    · techjarves/Linux-on-Samsung  (GPU accel, Wine, spinner UI)
#    · orailnoor/DroidDesk          (Proot Bridge, VNC, dark theme)
#
#  Author : rexroze
#  GitHub : https://github.com/rexroze/DroidStation
#
#  What you get:
#    ├─ Desktop: XFCE4 / KDE Plasma / LXQt / GNOME
#    ├─ Distro:  Ubuntu / Debian / Kali (via Proot — optional)
#    ├─ GPU:     Turnip/Zink (Adreno) · LLVMpipe fallback
#    ├─ Audio:   PulseAudio
#    ├─ Dev:     Python 3, Node.js/TypeScript (user choice)
#    ├─ Extras:  VS Code, Firefox, Chromium, File Manager (user choice)
#    ├─ Container Apps: LibreOffice, GIMP, Inkscape, VLC (optional)
#    ├─ Proot App Bridge — proot apps appear in desktop menu
#    ├─ VNC remote display (optional)
#    ├─ Wine/Hangover — run Windows x86_64 apps (optional)
#    ├─ Dark theme: Adwaita-dark + Dracula terminal
#    ├─ Global commands: startdesk / stopdesk
#    └─ Quick-start help card on completion · uninstall.sh for clean removal
#
#  Installer modes (auto-detected):
#    · Flags:    bash setup.sh --de=xfce --distro=ubuntu --dev=python,node
#    · TUI:      Auto if 'dialog' or 'whiptail' is installed
#    · Prompts:  Numbered menus (default fallback)
#
#  Usage: bash droidstation-setup.sh [OPTIONS]
#  Help:  bash droidstation-setup.sh --help
# ══════════════════════════════════════════════════════════════════════

# ── GLOBAL CONFIG ────────────────────────────────────────────────────
SCRIPT_VERSION="1.0"
TOTAL_STEPS=10   # recalculated after selections
CURRENT_STEP=0
LOG_FILE="$HOME/droidstation-install.log"

# Default selections
DE_CHOICE="1"
DE_NAME="XFCE4"
PROOT_DISTRO="ubuntu"
PROOT_LABEL="Ubuntu 22.04"
PROOT_USER="droiduser"
GPU_DRIVER="freedreno"
DEX_MODE="false"
INSTALLER_MODE="prompt"
TUI_CMD="whiptail"

# Feature flags
INSTALL_PYTHON="false"
INSTALL_NODE="false"
INSTALL_VSCODE="false"
INSTALL_FIREFOX="false"
INSTALL_CHROMIUM="false"
INSTALL_FILEMANAGER="false"
INSTALL_VNC="false"
INSTALL_WINE="false"
INSTALL_PROOT="true"
INSTALL_LIBREOFFICE="false"
INSTALL_GIMP="false"
INSTALL_INKSCAPE="false"
INSTALL_VLC="false"
VNC_PASS="123456"
VNC_GEOMETRY="1280x720"

# Estimated install sizes (MB) — approximate
SIZE_CORE=300
SIZE_XFCE4=400; SIZE_KDE=900; SIZE_LXQT=200; SIZE_GNOME=700
SIZE_PYTHON=100; SIZE_NODE=150
SIZE_VSCODE=220; SIZE_FIREFOX=260; SIZE_CHROMIUM=310; SIZE_FILES=50
SIZE_VNC=30; SIZE_WINE=600
SIZE_PROOT_BASE=800
SIZE_LIBREOFFICE=700; SIZE_GIMP=350; SIZE_INKSCAPE=250; SIZE_VLC=120

# ── COLORS ───────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m'

# ── HELP ─────────────────────────────────────────────────────────────
show_help() {
  echo ""
  echo "DroidStation v${SCRIPT_VERSION} — Full Linux Desktop for Android"
  echo ""
  echo "Usage: bash droidstation-setup.sh [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  --de=<xfce|kde|lxqt|gnome>                          Desktop environment"
  echo "  --distro=<ubuntu|debian|kali>                        Proot Linux distro"
  echo "  --dev=<python,node>                                  Dev stacks (comma-separated)"
  echo "  --extras=<vscode,firefox,chromium,files,             Apps (comma-separated)"
  echo "           libreoffice,gimp,inkscape,vlc>"
  echo "  --vnc                                                Install VNC server"
  echo "  --wine                                               Install Wine/Hangover"
  echo "  --no-proot                                           Skip Proot container"
  echo "  --user=<username>                                    Container username (default: droiduser)"
  echo "  --help                                               Show this help"
  echo ""
  echo "Examples:"
  echo "  # Full setup with flags:"
  echo "  bash droidstation-setup.sh --de=xfce --distro=ubuntu --dev=python,node --extras=vscode,firefox,libreoffice"
  echo ""
  echo "  # Skip the Linux container (saves ~800 MB):"
  echo "  bash droidstation-setup.sh --no-proot"
  echo ""
  echo "  # Interactive (default):"
  echo "  bash droidstation-setup.sh"
  echo ""
  echo "Uninstall:"
  echo "  bash uninstall.sh"
  echo ""
}

# ── FLAG PARSER ──────────────────────────────────────────────────────
parse_flags() {
  FLAG_USED="false"
  for arg in "$@"; do
    case "$arg" in
      --help|-h)
        show_help; exit 0;;
      --de=*)
        FLAG_USED="true"
        val="${arg#*=}"
        case "$val" in
          xfce|xfce4) DE_CHOICE="1"; DE_NAME="XFCE4";;
          kde|plasma)  DE_CHOICE="2"; DE_NAME="KDE Plasma";;
          lxqt|lxde)  DE_CHOICE="3"; DE_NAME="LXQt";;
          gnome)       DE_CHOICE="4"; DE_NAME="GNOME";;
          *) echo "Unknown DE '$val'. Use: xfce, kde, lxqt, gnome"; exit 1;;
        esac;;
      --distro=*)
        FLAG_USED="true"
        val="${arg#*=}"
        case "$val" in
          ubuntu) PROOT_DISTRO="ubuntu";        PROOT_LABEL="Ubuntu 22.04";;
          debian) PROOT_DISTRO="debian";        PROOT_LABEL="Debian 12";;
          kali)   PROOT_DISTRO="kali-nethunter"; PROOT_LABEL="Kali Linux";;
          *) echo "Unknown distro '$val'. Use: ubuntu, debian, kali"; exit 1;;
        esac;;
      --dev=*)
        FLAG_USED="true"
        IFS=',' read -ra devs <<< "${arg#*=}"
        for d in "${devs[@]}"; do
          [ "$d" = "python" ] && INSTALL_PYTHON="true"
          { [ "$d" = "node" ] || [ "$d" = "nodejs" ]; } && INSTALL_NODE="true"
        done;;
      --extras=*)
        FLAG_USED="true"
        IFS=',' read -ra extras <<< "${arg#*=}"
        for e in "${extras[@]}"; do
          [ "$e" = "vscode" ]                          && INSTALL_VSCODE="true"
          [ "$e" = "firefox" ]                         && INSTALL_FIREFOX="true"
          [ "$e" = "chromium" ]                        && INSTALL_CHROMIUM="true"
          { [ "$e" = "files" ] || [ "$e" = "filemanager" ]; } && INSTALL_FILEMANAGER="true"
          [ "$e" = "libreoffice" ]                     && INSTALL_LIBREOFFICE="true"
          [ "$e" = "gimp" ]                            && INSTALL_GIMP="true"
          [ "$e" = "inkscape" ]                        && INSTALL_INKSCAPE="true"
          [ "$e" = "vlc" ]                             && INSTALL_VLC="true"
        done;;
      --vnc)      FLAG_USED="true"; INSTALL_VNC="true";;
      --wine)     FLAG_USED="true"; INSTALL_WINE="true";;
      --no-proot) FLAG_USED="true"; INSTALL_PROOT="false";;
      --user=*)   FLAG_USED="true"; PROOT_USER="${arg#*=}";;
    esac
  done
  [ "$FLAG_USED" = "true" ] && INSTALLER_MODE="flags"
}

# ── INSTALLER MODE DETECTION ─────────────────────────────────────────
detect_installer_mode() {
  [ "$INSTALLER_MODE" = "flags" ] && return
  if command -v whiptail >/dev/null 2>&1; then
    INSTALLER_MODE="tui"; TUI_CMD="whiptail"
  elif command -v dialog >/dev/null 2>&1; then
    INSTALLER_MODE="tui"; TUI_CMD="dialog"
  else
    INSTALLER_MODE="prompt"
  fi
}

# ── SYSTEM RESOURCE CHECK ─────────────────────────────────────────────
check_system_resources() {
  echo -e "${CYAN}━━ System Resources ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""

  local free_mb ram_mb stor_color ram_color
  free_mb=$(df -BM "$HOME" 2>/dev/null | awk 'NR==2{gsub(/M/,"",$4); print $4}')
  free_mb=${free_mb:-0}
  ram_mb=$(free -m 2>/dev/null | awk '/^Mem:/{print $2}')
  ram_mb=${ram_mb:-0}

  [ "$free_mb" -ge 4000 ] && stor_color="$GREEN" || { [ "$free_mb" -ge 2000 ] && stor_color="$YELLOW" || stor_color="$RED"; }
  [ "$ram_mb"  -ge 4000 ] && ram_color="$GREEN"  || { [ "$ram_mb"  -ge 2500 ] && ram_color="$YELLOW"  || ram_color="$RED";  }

  printf "  ${WHITE}Free storage  :${NC} ${stor_color}%s MB${NC}\n" "$free_mb"
  printf "  ${WHITE}RAM (total)   :${NC} ${ram_color}%s MB${NC}\n"  "$ram_mb"
  echo -e "  ${GRAY}Recommended   : 4,000 MB storage · 4,000 MB RAM${NC}"

  if [ "$free_mb" -lt 2000 ]; then
    echo -e "\n  ${RED}⚠  Very low storage — consider skipping proot or large apps.${NC}"
  elif [ "$free_mb" -lt 4000 ]; then
    echo -e "\n  ${YELLOW}💡 Storage is tight — consider skipping proot or large apps.${NC}"
  fi
  echo ""
}

# ── PROGRESS BAR ─────────────────────────────────────────────────────
update_progress() {
  CURRENT_STEP=$((CURRENT_STEP + 1))
  PERCENT=$((CURRENT_STEP * 100 / TOTAL_STEPS))
  FILLED=$((PERCENT / 5))
  EMPTY=$((20 - FILLED))
  BAR="${GREEN}"
  for ((i=0; i<FILLED; i++)); do BAR+="█"; done
  BAR+="${GRAY}"
  for ((i=0; i<EMPTY; i++)); do BAR+="░"; done
  BAR+="${NC}"
  echo ""
  echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${CYAN}  📊 Step ${CURRENT_STEP}/${TOTAL_STEPS}${NC}  ${BAR}  ${WHITE}${PERCENT}%${NC}"
  echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
}

# ── SPINNER ──────────────────────────────────────────────────────────
spinner() {
  local pid=$1
  local msg=$2
  local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
  local i=0
  printf "  ${YELLOW}⏳${NC} %-52s\n" "$msg"
  while kill -0 "$pid" 2>/dev/null; do
    i=$(( (i+1) % 10 ))
    printf "\033[1A\033[2K  ${CYAN}${spin:$i:1}${NC} %-52s\n" "$msg"
    sleep 0.1
  done
  wait "$pid"
  local ec=$?
  printf "\033[1A\033[2K"
  if [ $ec -eq 0 ]; then
    printf "  ${GREEN}✓${NC} %-52s\n" "$msg"
  else
    printf "  ${RED}✗${NC} %-52s ${RED}(see $LOG_FILE)${NC}\n" "$msg"
  fi
  return $ec
}

pkg_install() {
  local pkg=$1
  local name=${2:-$pkg}
  (yes | pkg install "$pkg" -y >> "$LOG_FILE" 2>&1) &
  spinner $! "Installing $name"
}

# ── BANNER ───────────────────────────────────────────────────────────
show_banner() {
  clear
  echo -e "${CYAN}"
  cat << 'BANNER'
  ╔════════════════════════════════════════════════════╗
  ║                                                    ║
  ║   ██████╗ ██████╗  ██████╗ ██╗██████╗             ║
  ║   ██╔══██╗██╔══██╗██╔═══██╗██║██╔══██╗            ║
  ║   ██║  ██║██████╔╝██║   ██║██║██║  ██║            ║
  ║   ██║  ██║██╔══██╗██║   ██║██║██║  ██║            ║
  ║   ██████╔╝██║  ██║╚██████╔╝██║██████╔╝            ║
  ║   ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝╚═════╝             ║
  ║            S T A T I O N   v1.0                    ║
  ║                                                    ║
  ║    Full Linux Desktop for Android & Samsung DeX    ║
  ║                                                    ║
  ║              Made by @rexroze                      ║
  ╚════════════════════════════════════════════════════╝
BANNER
  echo -e "${NC}"
  echo -e "${GRAY}   Estimated time: 25–45 min   Log: $LOG_FILE${NC}"
  echo ""
}

# ── DEVICE DETECTION ─────────────────────────────────────────────────
detect_device() {
  echo -e "${PURPLE}[*] Detecting your device...${NC}"
  echo ""

  DEVICE_MODEL=$(getprop ro.product.model    2>/dev/null || echo "Unknown")
  DEVICE_BRAND=$(getprop ro.product.brand    2>/dev/null || echo "Unknown")
  ANDROID_VER=$(getprop ro.build.version.release 2>/dev/null || echo "Unknown")
  CPU_ABI=$(getprop ro.product.cpu.abi       2>/dev/null || echo "arm64-v8a")
  CHIPSET=$(getprop ro.hardware.chipname     2>/dev/null || echo "")
  GPU_VENDOR=$(getprop ro.hardware.egl       2>/dev/null || echo "")
  ONE_UI=$(getprop ro.build.version.oneui    2>/dev/null || echo "")

  echo -e "  ${GREEN}📱${NC} Device  : ${WHITE}$DEVICE_BRAND $DEVICE_MODEL${NC}"
  echo -e "  ${GREEN}🤖${NC} Android : ${WHITE}$ANDROID_VER${NC}"
  [ -n "$ONE_UI" ] && echo -e "  ${GREEN}🪟${NC} One UI  : ${WHITE}$ONE_UI${NC}"
  echo -e "  ${GREEN}⚙️${NC}  CPU     : ${WHITE}$CPU_ABI${NC}"

  # Samsung DeX detection
  if echo "$DEVICE_BRAND" | grep -qi "samsung"; then
    DEX_MODE="true"
    echo -e "  ${CYAN}🖥️${NC}  DeX     : ${WHITE}Supported ✓ — DeX optimizations enabled${NC}"
  fi

  # GPU detection: chipset name (most accurate) → EGL vendor → brand heuristic
  if echo "$CHIPSET" | grep -qiE "sm[0-9]|kalama|taro|lahaina|waipio|crow|anorak"; then
    GPU_DRIVER="freedreno"
    echo -e "  ${GREEN}🎮${NC} GPU     : ${WHITE}Adreno (Snapdragon) — Turnip HW accel ✓${NC}"
  elif echo "$CHIPSET" | grep -qiE "exynos|s5e"; then
    GPU_DRIVER="swrast"
    echo -e "  ${YELLOW}🎮${NC} GPU     : ${WHITE}Mali (Exynos) — Software rendering${NC}"
    echo -e "  ${YELLOW}      ⚠  XFCE or LXQt recommended for Exynos${NC}"
  elif echo "$GPU_VENDOR" | grep -qi "adreno"; then
    GPU_DRIVER="freedreno"
    echo -e "  ${GREEN}🎮${NC} GPU     : ${WHITE}Adreno — Turnip HW accel ✓${NC}"
  elif echo "$GPU_VENDOR" | grep -qi "mali"; then
    GPU_DRIVER="swrast"
    echo -e "  ${YELLOW}🎮${NC} GPU     : ${WHITE}Mali — Software rendering${NC}"
  elif echo "$DEVICE_BRAND" | grep -qiE "samsung|oneplus|xiaomi|redmi|poco|motorola|realme|oppo|vivo"; then
    # Common Snapdragon brands
    GPU_DRIVER="freedreno"
    echo -e "  ${GREEN}🎮${NC} GPU     : ${WHITE}Likely Adreno — Turnip HW accel enabled${NC}"
  else
    GPU_DRIVER="swrast"
    echo -e "  ${GRAY}🎮${NC} GPU     : ${WHITE}Unknown — Software rendering fallback${NC}"
  fi

  echo ""
  sleep 1
}

# ── SELECTION: NUMBERED PROMPTS ──────────────────────────────────────
select_options_prompt() {

  # Reset flags on re-entry (go-back support)
  INSTALL_PYTHON="false"; INSTALL_NODE="false"
  INSTALL_VSCODE="false"; INSTALL_FIREFOX="false"; INSTALL_CHROMIUM="false"
  INSTALL_FILEMANAGER="false"; INSTALL_VNC="false"; INSTALL_WINE="false"
  INSTALL_PROOT="true"; INSTALL_LIBREOFFICE="false"; INSTALL_GIMP="false"
  INSTALL_INKSCAPE="false"; INSTALL_VLC="false"

  # Desktop Environment
  echo -e "${CYAN}━━ Desktop Environment ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  echo -e "  ${WHITE}1) XFCE4${NC}       ${GREEN}(Recommended)${NC} — Fast, DeX-friendly, macOS dock  ${GRAY}~${SIZE_XFCE4} MB${NC}"
  echo -e "  ${WHITE}2) KDE Plasma${NC}  — Full Windows-style, needs strong GPU/RAM         ${GRAY}~${SIZE_KDE} MB${NC}"
  echo -e "  ${WHITE}3) LXQt${NC}        — Ultra-lightweight, best for Exynos/older devices  ${GRAY}~${SIZE_LXQT} MB${NC}"
  echo -e "  ${WHITE}4) GNOME${NC}       — Modern, touch-friendly ${YELLOW}(heavy)${NC}                  ${GRAY}~${SIZE_GNOME} MB${NC}"
  echo ""
  [ "$GPU_DRIVER" = "swrast" ] && echo -e "  ${YELLOW}💡 Mali GPU — XFCE or LXQt strongly recommended${NC}\n"
  while true; do
    printf "  Enter number (1-4) [default: 1]: "
    read -r DE_INPUT </dev/tty
    DE_INPUT=${DE_INPUT:-1}
    echo "$DE_INPUT" | grep -qE '^[1-4]$' && break
    echo "  Please enter 1, 2, 3, or 4."
  done
  DE_CHOICE="$DE_INPUT"
  case $DE_CHOICE in
    1) DE_NAME="XFCE4";;
    2) DE_NAME="KDE Plasma";;
    3) DE_NAME="LXQt";;
    4) DE_NAME="GNOME";;
  esac
  echo -e "  ${GREEN}✓ Selected: $DE_NAME${NC}\n"

  # Linux Container (Proot)
  echo -e "${CYAN}━━ Linux Container (Proot — Optional) ━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  echo -e "  A Linux container lets you run Ubuntu/Debian apps on Android"
  echo -e "  with full GPU acceleration (Turnip/Zink). Required for"
  echo -e "  LibreOffice, GIMP, Inkscape, VLC, and other desktop apps."
  echo -e "  ${GRAY}Base download: ~${SIZE_PROOT_BASE} MB${NC}"
  echo ""
  printf "  Install Linux Container? (Y/n) [default: Y]: "
  read -r PROOT_ANS </dev/tty
  PROOT_ANS=${PROOT_ANS:-Y}
  if echo "$PROOT_ANS" | grep -qi '^y'; then
    INSTALL_PROOT="true"
    echo ""
    echo -e "  ${WHITE}1) Ubuntu 22.04${NC}  ${GREEN}(Recommended)${NC} — Best app compatibility  ${GRAY}~600 MB rootfs${NC}"
    echo -e "  ${WHITE}2) Debian 12${NC}     — Minimal, rock-stable                    ${GRAY}~450 MB rootfs${NC}"
    echo -e "  ${WHITE}3) Kali Linux${NC}    — Security & pentesting tools              ${GRAY}~1.2 GB rootfs${NC}"
    echo ""
    while true; do
      printf "  Enter number (1-3) [default: 1]: "
      read -r DISTRO_INPUT </dev/tty
      DISTRO_INPUT=${DISTRO_INPUT:-1}
      echo "$DISTRO_INPUT" | grep -qE '^[1-3]$' && break
    done
    case $DISTRO_INPUT in
      1) PROOT_DISTRO="ubuntu";         PROOT_LABEL="Ubuntu 22.04";;
      2) PROOT_DISTRO="debian";         PROOT_LABEL="Debian 12";;
      3) PROOT_DISTRO="kali-nethunter"; PROOT_LABEL="Kali Linux";;
    esac
    echo -e "  ${GREEN}✓ Distro: $PROOT_LABEL${NC}\n"

    # Apps inside the container
    echo -e "${CYAN}━━ Apps inside Linux Container ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "  ${GRAY}These install inside $PROOT_LABEL (via apt) and appear in your desktop menu.${NC}"
    echo ""
    printf "  Install LibreOffice (office suite)?    (y/N)  ~${SIZE_LIBREOFFICE} MB: "
    read -r LO_ANS </dev/tty; LO_ANS=${LO_ANS:-N}
    echo "$LO_ANS" | grep -qi '^y' && INSTALL_LIBREOFFICE="true"

    printf "  Install GIMP (image editor)?           (y/N)  ~${SIZE_GIMP} MB: "
    read -r GIMP_ANS </dev/tty; GIMP_ANS=${GIMP_ANS:-N}
    echo "$GIMP_ANS" | grep -qi '^y' && INSTALL_GIMP="true"

    printf "  Install Inkscape (vector graphics)?    (y/N)  ~${SIZE_INKSCAPE} MB: "
    read -r INK_ANS </dev/tty; INK_ANS=${INK_ANS:-N}
    echo "$INK_ANS" | grep -qi '^y' && INSTALL_INKSCAPE="true"

    printf "  Install VLC media player?              (y/N)  ~${SIZE_VLC} MB: "
    read -r VLC_ANS </dev/tty; VLC_ANS=${VLC_ANS:-N}
    echo "$VLC_ANS" | grep -qi '^y' && INSTALL_VLC="true"
    echo ""
  else
    INSTALL_PROOT="false"
    echo -e "  ${GRAY}⟳ Skipping Linux Container${NC}\n"
  fi

  # Dev stacks
  echo -e "${CYAN}━━ Developer Stacks ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  printf "  Install Python 3 + pip + virtualenv + uv?   ~${SIZE_PYTHON} MB (Y/n): "
  read -r PY_ANS </dev/tty
  PY_ANS=${PY_ANS:-Y}
  echo "$PY_ANS" | grep -qi '^y' && INSTALL_PYTHON="true"

  printf "  Install Node.js LTS + TypeScript + ts-node? ~${SIZE_NODE} MB (Y/n): "
  read -r NODE_ANS </dev/tty
  NODE_ANS=${NODE_ANS:-Y}
  echo "$NODE_ANS" | grep -qi '^y' && INSTALL_NODE="true"
  echo ""

  # Optional apps
  echo -e "${CYAN}━━ Optional Apps ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  printf "  Install VS Code (code-oss)?                  ~${SIZE_VSCODE} MB (Y/n): "
  read -r VS_ANS </dev/tty
  VS_ANS=${VS_ANS:-Y}
  echo "$VS_ANS" | grep -qi '^y' && INSTALL_VSCODE="true"

  printf "  Install Firefox?                             ~${SIZE_FIREFOX} MB (Y/n): "
  read -r FF_ANS </dev/tty
  FF_ANS=${FF_ANS:-Y}
  echo "$FF_ANS" | grep -qi '^y' && INSTALL_FIREFOX="true"

  printf "  Install Chromium?                            ~${SIZE_CHROMIUM} MB (y/N): "
  read -r CR_ANS </dev/tty
  CR_ANS=${CR_ANS:-N}
  echo "$CR_ANS" | grep -qi '^y' && INSTALL_CHROMIUM="true"

  printf "  Install File Manager (Thunar/Dolphin/PCManFM)? ~${SIZE_FILES} MB (Y/n): "
  read -r FM_ANS </dev/tty
  FM_ANS=${FM_ANS:-Y}
  echo "$FM_ANS" | grep -qi '^y' && INSTALL_FILEMANAGER="true"
  echo ""

  # VNC
  echo -e "${CYAN}━━ Remote Display (VNC) ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  echo -e "  VNC lets you view your desktop on a monitor or other device via WiFi/USB."
  printf "  Install VNC server?  ~${SIZE_VNC} MB (y/N): "
  read -r VNC_ANS </dev/tty
  VNC_ANS=${VNC_ANS:-N}
  if echo "$VNC_ANS" | grep -qi '^y'; then
    INSTALL_VNC="true"
    printf "  VNC password [default: 123456]: "
    read -r VNC_PASS_IN </dev/tty
    VNC_PASS="${VNC_PASS_IN:-123456}"
    printf "  VNC resolution [default: 1280x720]: "
    read -r VNC_GEO_IN </dev/tty
    VNC_GEOMETRY="${VNC_GEO_IN:-1280x720}"
  fi
  echo ""

  # Wine
  echo -e "${CYAN}━━ Windows App Support ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  printf "  Install Wine/Hangover (run Windows x86_64 apps)?  ~${SIZE_WINE} MB (y/N): "
  read -r WINE_ANS </dev/tty
  WINE_ANS=${WINE_ANS:-N}
  echo "$WINE_ANS" | grep -qi '^y' && INSTALL_WINE="true"
  echo ""
}

# ── SELECTION: TUI (whiptail/dialog) ─────────────────────────────────
select_options_tui() {
  # Reset flags on re-entry (go-back support)
  INSTALL_PYTHON="false"; INSTALL_NODE="false"
  INSTALL_VSCODE="false"; INSTALL_FIREFOX="false"; INSTALL_CHROMIUM="false"
  INSTALL_FILEMANAGER="false"; INSTALL_VNC="false"; INSTALL_WINE="false"
  INSTALL_PROOT="true"; INSTALL_LIBREOFFICE="false"; INSTALL_GIMP="false"
  INSTALL_INKSCAPE="false"; INSTALL_VLC="false"

  # Desktop Environment
  DE_INPUT=$($TUI_CMD --title "DroidStation — Desktop" \
    --menu "Choose your Desktop Environment:" 16 72 4 \
    "1" "XFCE4      — Fast, DeX-optimized (Recommended) ~${SIZE_XFCE4} MB" \
    "2" "KDE Plasma — Full-featured, Windows-style       ~${SIZE_KDE} MB" \
    "3" "LXQt       — Ultra-lightweight                  ~${SIZE_LXQT} MB" \
    "4" "GNOME      — Modern, touch-friendly (heavy)     ~${SIZE_GNOME} MB" \
    3>&1 1>&2 2>&3) || DE_INPUT="1"
  DE_CHOICE="$DE_INPUT"
  case $DE_CHOICE in
    1) DE_NAME="XFCE4";;
    2) DE_NAME="KDE Plasma";;
    3) DE_NAME="LXQt";;
    4) DE_NAME="GNOME";;
  esac

  # Linux Container (Proot)
  if $TUI_CMD --title "DroidStation — Linux Container" \
      --yesno "Install a Linux Container (Proot)?\n\nRuns Ubuntu/Debian apps on Android with full GPU\nacceleration. Required for LibreOffice, GIMP, VLC etc.\n\nBase download: ~${SIZE_PROOT_BASE} MB" 14 60; then
    INSTALL_PROOT="true"

    DISTRO_INPUT=$($TUI_CMD --title "DroidStation — Container Distro" \
      --menu "Choose Linux distro for the container:" 12 65 3 \
      "1" "Ubuntu 22.04  — Best compatibility (Recommended)  ~600 MB" \
      "2" "Debian 12     — Minimal, rock-stable              ~450 MB" \
      "3" "Kali Linux    — Security & pentesting tools       ~1.2 GB" \
      3>&1 1>&2 2>&3) || DISTRO_INPUT="1"
    case $DISTRO_INPUT in
      1) PROOT_DISTRO="ubuntu";         PROOT_LABEL="Ubuntu 22.04";;
      2) PROOT_DISTRO="debian";         PROOT_LABEL="Debian 12";;
      3) PROOT_DISTRO="kali-nethunter"; PROOT_LABEL="Kali Linux";;
    esac

    # Proot apps
    PROOT_APP_CHOICES=$($TUI_CMD --title "DroidStation — Container Apps" \
      --checklist "Select apps to install inside $PROOT_LABEL:" 14 72 4 \
      "libreoffice" "LibreOffice — Office suite          ~${SIZE_LIBREOFFICE} MB" OFF \
      "gimp"        "GIMP        — Image editor          ~${SIZE_GIMP} MB" OFF \
      "inkscape"    "Inkscape    — Vector graphics       ~${SIZE_INKSCAPE} MB" OFF \
      "vlc"         "VLC         — Media player          ~${SIZE_VLC} MB" OFF \
      3>&1 1>&2 2>&3) || PROOT_APP_CHOICES=""
    echo "$PROOT_APP_CHOICES" | grep -q "libreoffice" && INSTALL_LIBREOFFICE="true"
    echo "$PROOT_APP_CHOICES" | grep -q "gimp"        && INSTALL_GIMP="true"
    echo "$PROOT_APP_CHOICES" | grep -q "inkscape"    && INSTALL_INKSCAPE="true"
    echo "$PROOT_APP_CHOICES" | grep -q "vlc"         && INSTALL_VLC="true"
  else
    INSTALL_PROOT="false"
  fi

  # Dev stacks
  DEV_CHOICES=$($TUI_CMD --title "DroidStation — Dev Stacks" \
    --checklist "Select developer tools to install:" 12 72 2 \
    "python" "Python 3 + pip + virtualenv + uv   ~${SIZE_PYTHON} MB" ON \
    "node"   "Node.js LTS + TypeScript + ts-node ~${SIZE_NODE} MB"  ON \
    3>&1 1>&2 2>&3) || DEV_CHOICES="python node"
  echo "$DEV_CHOICES" | grep -q "python" && INSTALL_PYTHON="true"
  echo "$DEV_CHOICES" | grep -q "node"   && INSTALL_NODE="true"

  # Optional apps + Wine
  EXTRA_CHOICES=$($TUI_CMD --title "DroidStation — Optional Apps" \
    --checklist "Select apps to install:" 18 72 5 \
    "vscode"  "VS Code (code-oss)                ~${SIZE_VSCODE} MB" ON \
    "firefox" "Firefox Browser                   ~${SIZE_FIREFOX} MB" ON \
    "chromium" "Chromium Browser                 ~${SIZE_CHROMIUM} MB" OFF \
    "files"   "File Manager (Thunar/Dolphin/PCManFM) ~${SIZE_FILES} MB" ON \
    "wine"    "Wine/Hangover (Windows apps)      ~${SIZE_WINE} MB"  OFF \
    3>&1 1>&2 2>&3) || EXTRA_CHOICES="vscode firefox files"
  echo "$EXTRA_CHOICES" | grep -q "vscode"   && INSTALL_VSCODE="true"
  echo "$EXTRA_CHOICES" | grep -q "firefox"  && INSTALL_FIREFOX="true"
  echo "$EXTRA_CHOICES" | grep -q "chromium" && INSTALL_CHROMIUM="true"
  echo "$EXTRA_CHOICES" | grep -q "files"    && INSTALL_FILEMANAGER="true"
  echo "$EXTRA_CHOICES" | grep -q "wine"     && INSTALL_WINE="true"

  # VNC
  if $TUI_CMD --title "DroidStation — VNC" \
      --yesno "Install VNC server?  ~${SIZE_VNC} MB\n(Remote/monitor display via WiFi or USB)" 9 55; then
    INSTALL_VNC="true"
    VNC_PASS_IN=$($TUI_CMD --title "VNC Password" \
      --inputbox "Set a VNC password:" 8 45 "123456" 3>&1 1>&2 2>&3) && VNC_PASS="${VNC_PASS_IN:-123456}"
    VNC_GEO_IN=$($TUI_CMD --title "VNC Resolution" \
      --inputbox "Set VNC resolution:" 8 45 "1280x720" 3>&1 1>&2 2>&3) && VNC_GEOMETRY="${VNC_GEO_IN:-1280x720}"
  fi
}

# ── SELECTION ROUTER ─────────────────────────────────────────────────
select_options() {
  case $INSTALLER_MODE in
    flags)
      echo -e "${CYAN}🚩 Flag mode — skipping interactive prompts${NC}"
      echo -e "   DE: ${WHITE}$DE_NAME${NC}  |  Distro: ${WHITE}$PROOT_LABEL${NC}"
      [ "$INSTALL_PYTHON" = "true" ] && echo -e "   Dev: ${WHITE}Python 3${NC}"
      [ "$INSTALL_NODE"   = "true" ] && echo -e "   Dev: ${WHITE}Node.js + TypeScript${NC}"
      echo "";;
    tui)
      select_options_tui;;
    *)
      select_options_prompt;;
  esac
}

# ── INSTALL SUMMARY + GO-BACK ────────────────────────────────────────
show_install_summary() {
  local total=$SIZE_CORE
  local de_size items=""

  case $DE_CHOICE in
    2) de_size=$SIZE_KDE;;
    3) de_size=$SIZE_LXQT;;
    4) de_size=$SIZE_GNOME;;
    *) de_size=$SIZE_XFCE4;;
  esac
  total=$((total + de_size))

  if [ "$INSTALL_PROOT" = "true" ]; then
    total=$((total + SIZE_PROOT_BASE))
    [ "$INSTALL_LIBREOFFICE" = "true" ] && total=$((total + SIZE_LIBREOFFICE))
    [ "$INSTALL_GIMP"        = "true" ] && total=$((total + SIZE_GIMP))
    [ "$INSTALL_INKSCAPE"    = "true" ] && total=$((total + SIZE_INKSCAPE))
    [ "$INSTALL_VLC"         = "true" ] && total=$((total + SIZE_VLC))
  fi
  [ "$INSTALL_PYTHON"  = "true" ] && total=$((total + SIZE_PYTHON))
  [ "$INSTALL_NODE"    = "true" ] && total=$((total + SIZE_NODE))
  [ "$INSTALL_VSCODE"  = "true" ] && total=$((total + SIZE_VSCODE))
  [ "$INSTALL_FIREFOX" = "true" ] && total=$((total + SIZE_FIREFOX))
  [ "$INSTALL_CHROMIUM"= "true" ] && total=$((total + SIZE_CHROMIUM))
  [ "$INSTALL_FILEMANAGER" = "true" ] && total=$((total + SIZE_FILES))
  [ "$INSTALL_VNC"     = "true" ] && total=$((total + SIZE_VNC))
  [ "$INSTALL_WINE"    = "true" ] && total=$((total + SIZE_WINE))

  echo ""
  echo -e "${WHITE}╔══════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${WHITE}║           📦  Estimated Installation Size                   ║${NC}"
  echo -e "${WHITE}╠══════════════════════════════════════════════════════════════╣${NC}"
  printf "${WHITE}║${NC}  %-42s %8s MB  ${WHITE}║${NC}\n" "Core (X11, audio, GPU drivers)"   "$SIZE_CORE"
  printf "${WHITE}║${NC}  %-42s %8s MB  ${WHITE}║${NC}\n" "Desktop: $DE_NAME"                "$de_size"
  if [ "$INSTALL_PROOT" = "true" ]; then
    printf "${WHITE}║${NC}  %-42s %8s MB  ${WHITE}║${NC}\n" "Linux Container: $PROOT_LABEL"  "$SIZE_PROOT_BASE"
    [ "$INSTALL_LIBREOFFICE" = "true" ] && printf "${WHITE}║${NC}  %-42s %8s MB  ${WHITE}║${NC}\n" "  + LibreOffice" "$SIZE_LIBREOFFICE"
    [ "$INSTALL_GIMP"        = "true" ] && printf "${WHITE}║${NC}  %-42s %8s MB  ${WHITE}║${NC}\n" "  + GIMP"        "$SIZE_GIMP"
    [ "$INSTALL_INKSCAPE"    = "true" ] && printf "${WHITE}║${NC}  %-42s %8s MB  ${WHITE}║${NC}\n" "  + Inkscape"    "$SIZE_INKSCAPE"
    [ "$INSTALL_VLC"         = "true" ] && printf "${WHITE}║${NC}  %-42s %8s MB  ${WHITE}║${NC}\n" "  + VLC"         "$SIZE_VLC"
  else
    printf "${WHITE}║${NC}  %-42s %11s  ${WHITE}║${NC}\n" "Linux Container" "skipped"
  fi
  [ "$INSTALL_PYTHON"  = "true" ] && printf "${WHITE}║${NC}  %-42s %8s MB  ${WHITE}║${NC}\n" "Dev: Python 3 + pip"   "$SIZE_PYTHON"
  [ "$INSTALL_NODE"    = "true" ] && printf "${WHITE}║${NC}  %-42s %8s MB  ${WHITE}║${NC}\n" "Dev: Node.js LTS"      "$SIZE_NODE"
  [ "$INSTALL_VSCODE"  = "true" ] && printf "${WHITE}║${NC}  %-42s %8s MB  ${WHITE}║${NC}\n" "App: VS Code"          "$SIZE_VSCODE"
  [ "$INSTALL_FIREFOX" = "true" ] && printf "${WHITE}║${NC}  %-42s %8s MB  ${WHITE}║${NC}\n" "App: Firefox"          "$SIZE_FIREFOX"
  [ "$INSTALL_CHROMIUM"= "true" ] && printf "${WHITE}║${NC}  %-42s %8s MB  ${WHITE}║${NC}\n" "App: Chromium"         "$SIZE_CHROMIUM"
  [ "$INSTALL_FILEMANAGER" = "true" ] && printf "${WHITE}║${NC}  %-42s %8s MB  ${WHITE}║${NC}\n" "App: File Manager" "$SIZE_FILES"
  [ "$INSTALL_VNC"     = "true" ] && printf "${WHITE}║${NC}  %-42s %8s MB  ${WHITE}║${NC}\n" "VNC Server"            "$SIZE_VNC"
  [ "$INSTALL_WINE"    = "true" ] && printf "${WHITE}║${NC}  %-42s %8s MB  ${WHITE}║${NC}\n" "Wine/Hangover"         "$SIZE_WINE"
  echo -e "${WHITE}╠══════════════════════════════════════════════════════════════╣${NC}"
  printf "${WHITE}║${NC}  ${CYAN}%-42s %8s MB${NC}  ${WHITE}║${NC}\n" "Total estimate:" "$total"
  echo -e "${WHITE}╚══════════════════════════════════════════════════════════════╝${NC}"
  echo ""
  echo -e "  ${WHITE}[1]${NC} Start installation"
  echo -e "  ${WHITE}[2]${NC} Go back and change selections"
  echo ""
  printf "  Enter choice [default: 1]: "
  read -r CONFIRM_CHOICE </dev/tty
  CONFIRM_CHOICE=${CONFIRM_CHOICE:-1}
  [ "$CONFIRM_CHOICE" = "2" ] && return 1
  return 0
}

# ── USERNAME PROMPT (before install) ─────────────────────────────────
prompt_proot_username() {
  [ "$INSTALL_PROOT" != "true" ] && return
  [ "$INSTALLER_MODE" = "flags" ] && return
  echo -e "${CYAN}━━ Linux Container Username ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  printf "  Username for Linux container [default: droiduser]: "
  read -r USER_INPUT </dev/tty
  PROOT_USER="${USER_INPUT:-droiduser}"
  echo -e "  ${GREEN}✓ Username: $PROOT_USER${NC}\n"
}

# ── DYNAMIC STEP COUNT ───────────────────────────────────────────────
calculate_total_steps() {
  # Always: update, repos, x11, desktop, gpu, audio, dev, extras, theme, launchers
  TOTAL_STEPS=10
  [ "$INSTALL_WINE"  = "true" ] && TOTAL_STEPS=$((TOTAL_STEPS + 1))
  if [ "$INSTALL_PROOT" = "true" ]; then
    TOTAL_STEPS=$((TOTAL_STEPS + 2))
    { [ "$INSTALL_LIBREOFFICE" = "true" ] || [ "$INSTALL_GIMP"     = "true" ] || \
      [ "$INSTALL_INKSCAPE"    = "true" ] || [ "$INSTALL_VLC"      = "true" ]; } && \
      TOTAL_STEPS=$((TOTAL_STEPS + 1))
  fi
  [ "$INSTALL_VNC" = "true" ] && TOTAL_STEPS=$((TOTAL_STEPS + 1))
}

# ══════════════════════════════════════════════════════════════════════
# INSTALLATION STEPS
# ══════════════════════════════════════════════════════════════════════

# STEP 1 — Update system
step_update() {
  update_progress
  echo -e "${PURPLE}[Step $CURRENT_STEP/$TOTAL_STEPS] Updating system packages...${NC}\n"
  (yes | pkg update -y  >> "$LOG_FILE" 2>&1) & spinner $! "Updating package lists"
  (yes | pkg upgrade -y >> "$LOG_FILE" 2>&1) & spinner $! "Upgrading installed packages"
}

# STEP 2 — Add repos
step_repos() {
  update_progress
  echo -e "${PURPLE}[Step $CURRENT_STEP/$TOTAL_STEPS] Adding repositories...${NC}\n"
  pkg_install "x11-repo" "X11 Repository"
  pkg_install "tur-repo" "TUR Repository (Firefox, VS Code, Node.js)"
}

# STEP 3 — Termux-X11
step_x11() {
  update_progress
  echo -e "${PURPLE}[Step $CURRENT_STEP/$TOTAL_STEPS] Installing Termux-X11...${NC}\n"
  pkg_install "termux-x11-nightly" "Termux-X11 Display Server"
  pkg_install "xorg-xrandr"        "XRandR (display settings)"
}

# STEP 4 — Desktop Environment
step_desktop() {
  update_progress
  echo -e "${PURPLE}[Step $CURRENT_STEP/$TOTAL_STEPS] Installing $DE_NAME...${NC}\n"
  case $DE_CHOICE in
    1) # XFCE4
      pkg_install "xfce4"                    "XFCE4 Desktop"
      pkg_install "xfce4-terminal"           "XFCE4 Terminal"
      pkg_install "xfce4-whiskermenu-plugin" "Whisker Menu"
      pkg_install "xfce4-notifyd"            "XFCE Notifications"
      pkg_install "plank-reloaded"           "Plank Dock (macOS-style)"
      pkg_install "mousepad"                 "Mousepad Text Editor";;
    2) # KDE Plasma
      pkg_install "plasma-desktop" "KDE Plasma Desktop"
      pkg_install "konsole"        "Konsole Terminal";;
    3) # LXQt
      pkg_install "lxqt"       "LXQt Desktop"
      pkg_install "qterminal"  "QTerminal"
      pkg_install "featherpad" "FeatherPad Editor";;
    4) # GNOME
      pkg_install "gnome"          "GNOME Desktop"
      pkg_install "gnome-terminal" "GNOME Terminal";;
  esac
}

# STEP 5 — GPU drivers
step_gpu() {
  update_progress
  echo -e "${PURPLE}[Step $CURRENT_STEP/$TOTAL_STEPS] Installing GPU drivers...${NC}\n"
  pkg_install "mesa-zink"            "Mesa Zink (OpenGL over Vulkan)"
  if [ "$GPU_DRIVER" = "freedreno" ]; then
    pkg_install "mesa-vulkan-icd-freedreno" "Turnip Adreno Driver"
  else
    pkg_install "mesa-vulkan-icd-swrast"    "Software Vulkan Renderer"
  fi
  pkg_install "vulkan-loader-android" "Vulkan Loader"

  # KDE needs extra env injection for XDG paths
  if [ "$DE_CHOICE" = "2" ]; then
    mkdir -p ~/.config/plasma-workspace/env
    cat > ~/.config/plasma-workspace/env/xdg_fix.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
export XDG_DATA_DIRS=/data/data/com.termux/files/usr/share:${XDG_DATA_DIRS}
export XDG_CONFIG_DIRS=/data/data/com.termux/files/usr/etc/xdg:${XDG_CONFIG_DIRS}
EOF
    chmod +x ~/.config/plasma-workspace/env/xdg_fix.sh
  fi
  echo -e "  ${GREEN}✓ GPU acceleration configured${NC}"
}

# STEP 6 — Audio
step_audio() {
  update_progress
  echo -e "${PURPLE}[Step $CURRENT_STEP/$TOTAL_STEPS] Installing audio support...${NC}\n"
  pkg_install "pulseaudio" "PulseAudio Sound Server"
}

# STEP 7 — Dev stacks
step_dev() {
  update_progress
  echo -e "${PURPLE}[Step $CURRENT_STEP/$TOTAL_STEPS] Installing developer tools...${NC}\n"

  # Core tools always installed
  pkg_install "git"  "Git"
  pkg_install "curl" "cURL"
  pkg_install "wget" "wget"

  if [ "$INSTALL_PYTHON" = "true" ]; then
    pkg_install "python"     "Python 3"
    pkg_install "python-pip" "pip"
    (pip install virtualenv uv black ruff flask requests httpx \
      --quiet >> "$LOG_FILE" 2>&1) &
    spinner $! "Installing Python dev libraries (virtualenv, uv, flask, ruff...)"
  fi

  if [ "$INSTALL_NODE" = "true" ]; then
    pkg_install "nodejs-lts" "Node.js LTS"
    pkg_install "yarn"       "Yarn"
    (npm install -g typescript ts-node nodemon \
      >> "$LOG_FILE" 2>&1) &
    spinner $! "Installing TypeScript + ts-node + nodemon (global)"
  fi
}

# STEP 8 — Optional extras
step_extras() {
  update_progress
  echo -e "${PURPLE}[Step $CURRENT_STEP/$TOTAL_STEPS] Installing optional apps...${NC}\n"

  [ "$INSTALL_VSCODE"  = "true" ] && pkg_install "code-oss"  "VS Code (code-oss)"
  [ "$INSTALL_FIREFOX" = "true" ] && pkg_install "firefox"   "Firefox"
  [ "$INSTALL_CHROMIUM"= "true" ] && pkg_install "chromium"  "Chromium"

  if [ "$INSTALL_FILEMANAGER" = "true" ]; then
    case $DE_CHOICE in
      1) pkg_install "thunar"      "Thunar File Manager";;
      2) pkg_install "dolphin"     "Dolphin File Manager";;
      3) pkg_install "pcmanfm-qt"  "PCManFM-Qt File Manager";;
      4) pkg_install "nautilus"    "Nautilus File Manager";;
    esac
  fi

  # ImageMagick for wallpaper generation
  pkg_install "imagemagick" "ImageMagick (wallpaper)"
}

# STEP — Wine/Hangover (optional, called only when selected)
step_wine() {
  update_progress
  echo -e "${PURPLE}[Step $CURRENT_STEP/$TOTAL_STEPS] Installing Wine/Hangover...${NC}\n"
  (yes | pkg remove wine-stable -y >> "$LOG_FILE" 2>&1) &
  spinner $! "Removing old Wine versions"
  pkg_install "hangover-wine"    "Wine (Hangover)"
  pkg_install "hangover-wowbox64" "Box64 x86_64 wrapper"
  # Symlink binaries
  ln -sf "$PREFIX/opt/hangover-wine/bin/wine"    "$PREFIX/bin/wine"    2>/dev/null || true
  ln -sf "$PREFIX/opt/hangover-wine/bin/winecfg" "$PREFIX/bin/winecfg" 2>/dev/null || true
  echo -e "  ${GREEN}✓ Wine/Hangover configured${NC}"
}

# STEP 10 — Proot Linux container
step_proot() {
  update_progress
  echo -e "${PURPLE}[Step $CURRENT_STEP/$TOTAL_STEPS] Installing Proot container ($PROOT_LABEL)...${NC}\n"

  pkg_install "proot-distro" "Proot-Distro Manager"
  pkg_install "proot"        "PRoot"

  echo -e "  ${YELLOW}⏳ Downloading $PROOT_LABEL rootfs (large download, be patient)...${NC}"
  (proot-distro install "$PROOT_DISTRO" >> "$LOG_FILE" 2>&1) &
  spinner $! "Installing $PROOT_LABEL"

  # Bootstrap base packages + GPU libs inside proot
  (proot-distro login "$PROOT_DISTRO" -- bash -c "
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -y -q > /dev/null 2>&1
    apt-get install -y -q --no-install-recommends \
      sudo curl wget git htop nano dbus-x11 neofetch \
      mesa-utils libgl1-mesa-glx libvulkan1 \
      build-essential ca-certificates > /dev/null 2>&1
  " >> "$LOG_FILE" 2>&1) &
  spinner $! "Installing base packages in container"

  # Create container user with passwordless sudo
  proot-distro login "$PROOT_DISTRO" -- bash -c "
    id '${PROOT_USER}' > /dev/null 2>&1 || useradd -m -s /bin/bash '${PROOT_USER}'
    usermod -aG sudo '${PROOT_USER}' 2>/dev/null || true
    mkdir -p /etc/sudoers.d
    echo 'Defaults !requiretty' > /etc/sudoers.d/proot-compat
    echo '${PROOT_USER} ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/proot-compat
    chmod 0440 /etc/sudoers.d/proot-compat
    chmod u+s /usr/bin/sudo 2>/dev/null || true
    echo 'export PS1=\"\[\033[01;32m\]${PROOT_USER}@linux\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ \"' >> /home/${PROOT_USER}/.bashrc
    echo 'alias ll=\"ls -la\"' >> /home/${PROOT_USER}/.bashrc
    echo 'alias update=\"sudo apt update && sudo apt upgrade -y\"' >> /home/${PROOT_USER}/.bashrc
  " 2>/dev/null || true

  echo -e "  ${GREEN}✓ $PROOT_LABEL ready — user: $PROOT_USER (passwordless sudo)${NC}"
}

# STEP 11 — Proot App Bridge
step_proot_bridge() {
  update_progress
  echo -e "${PURPLE}[Step $CURRENT_STEP/$TOTAL_STEPS] Setting up Proot App Bridge...${NC}\n"

  TVKICD="$PREFIX/share/vulkan/icd.d"

  # start-proot.sh
  cat > ~/start-proot.sh << PROOTEOF
#!/data/data/com.termux/files/usr/bin/bash
PROOT_DISTRO="${PROOT_DISTRO}"
TERMUX_TMP="\${TMPDIR:-/data/data/com.termux/files/usr/tmp}"
echo ""
echo "  ════════════════════════════════════════"
echo "  🐧 Starting ${PROOT_LABEL}"
echo "  ════════════════════════════════════════"
echo ""
BINDS=""
[ -d "\$TERMUX_TMP/.X11-unix" ] && BINDS="\$BINDS --bind \$TERMUX_TMP/.X11-unix:/tmp/.X11-unix"
[ -d "/dev/dri" ]               && BINDS="\$BINDS --bind /dev/dri:/dev/dri"
[ -e "/dev/kgsl-3d0" ]          && BINDS="\$BINDS --bind /dev/kgsl-3d0:/dev/kgsl-3d0"
[ -d "${TVKICD}" ]              && BINDS="\$BINDS --bind ${TVKICD}:/usr/share/vulkan/icd.d.termux"
proot-distro login "\$PROOT_DISTRO" \$BINDS -- bash -c "
  export DISPLAY=:0
  export MESA_NO_ERROR=1
  export MESA_GL_VERSION_OVERRIDE=4.6
  export GALLIUM_DRIVER=zink
  export MESA_LOADER_DRIVER_OVERRIDE=zink
  export TU_DEBUG=noconform
  export ZINK_DESCRIPTORS=lazy
  export XDG_DATA_DIRS=/usr/share:/usr/local/share
  export PS1='\[\033[01;32m\]${PROOT_USER}@linux\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
  echo '  GPU: GALLIUM=zink  |  Type exit to leave proot'
  echo ''
  exec bash
"
PROOTEOF
  chmod +x ~/start-proot.sh
  echo -e "  ${GREEN}✓ Created ~/start-proot.sh${NC}"

  # proot-menu-sync.sh — syncs installed proot .desktop apps into native desktop menu
  cat > ~/proot-menu-sync.sh << 'SYNCEOF'
#!/data/data/com.termux/files/usr/bin/bash
# Proot App Bridge — Automatically adds proot apps to your desktop menu.
# Run after installing anything inside proot: bash ~/proot-menu-sync.sh
PROOT_DISTRO="${1:-ubuntu}"
PROOT_BIN="/data/data/com.termux/files/usr/bin/proot-distro"
PROOT_ROOTFS="/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/$PROOT_DISTRO"
PROOT_APPS="$PROOT_ROOTFS/usr/share/applications"
BRIDGE_DIR="$HOME/.local/share/applications/proot-bridge"
WRAPPER_DIR="$HOME/.local/share/proot-wrappers"
TERMUX_TMP="${TMPDIR:-/data/data/com.termux/files/usr/tmp}"
mkdir -p "$BRIDGE_DIR" "$WRAPPER_DIR"

[ ! -f "$PROOT_BIN" ]    && echo "[!] proot-distro not installed" && exit 1
[ ! -d "$PROOT_ROOTFS" ] && echo "[!] Proot distro '$PROOT_DISTRO' not found" && exit 1
[ ! -d "$PROOT_APPS" ]   && echo "[!] No proot apps yet — install with: bash ~/start-proot.sh" && exit 0

SYNCED=0; REMOVED=0

# Remove stale bridge entries
for bf in "$BRIDGE_DIR"/proot-*.desktop; do
  [ -f "$bf" ] || continue
  orig=$(basename "$bf" | sed 's/^proot-//')
  if [ ! -f "$PROOT_APPS/$orig" ]; then
    rm -f "$bf" "$WRAPPER_DIR/proot-${orig%.desktop}.sh"
    REMOVED=$((REMOVED + 1))
  fi
done

# Add/update bridge entries
for df in "$PROOT_APPS"/*.desktop; do
  [ -f "$df" ] || continue
  fname=$(basename "$df")
  appname="${fname%.desktop}"
  output="$BRIDGE_DIR/proot-$fname"
  wrapper="$WRAPPER_DIR/proot-${appname}.sh"

  grep -q "^NoDisplay=true" "$df" 2>/dev/null && continue
  grep -q "^Hidden=true"    "$df" 2>/dev/null && continue
  ORIG_EXEC=$(grep "^Exec=" "$df" | head -1 | sed 's/^Exec=//')
  [ -z "$ORIG_EXEC" ] && continue
  CLEAN_EXEC=$(echo "$ORIG_EXEC" | sed 's/ %[a-zA-Z]//g; s/%[a-zA-Z]//g')

  cat > "$wrapper" << WEOF
#!/data/data/com.termux/files/usr/bin/bash
LOG="${TERMUX_TMP}/proot-${appname}.log"
BINDS=""
X11_DIR="\${TMPDIR:-/data/data/com.termux/files/usr/tmp}/.X11-unix"
[ -d "\$X11_DIR" ] && BINDS="\$BINDS --bind \$X11_DIR:/tmp/.X11-unix"
[ -d "/dev/dri" ]  && BINDS="\$BINDS --bind /dev/dri:/dev/dri"
{ /data/data/com.termux/files/usr/bin/proot-distro login "${PROOT_DISTRO}" \$BINDS -- /bin/bash -c "
  export DISPLAY=:0
  export MESA_NO_ERROR=1
  export GALLIUM_DRIVER=zink
  export MESA_GL_VERSION_OVERRIDE=4.6
  dbus-run-session ${CLEAN_EXEC}
"; } > "\$LOG" 2>&1
WEOF
  chmod +x "$wrapper"
  cp "$df" "$output"
  sed -i \
    -e "s|^Exec=.*|Exec=$wrapper|" \
    -e "s|^TryExec=.*|TryExec=$wrapper|" \
    -e '/^NoDisplay=/d' \
    -e '/^Hidden=/d' \
    "$output"
  echo "NoDisplay=false" >> "$output"
  APP_NAME=$(grep "^Name=" "$output" | head -1 | sed 's/^Name=//')
  echo "$APP_NAME" | grep -q "^\[P\]" || sed -i "s|^Name=.*|Name=[P] $APP_NAME|" "$output"
  SYNCED=$((SYNCED + 1))
done

echo "[+] Proot Bridge: $SYNCED synced, $REMOVED removed"
echo "    Logs: $TERMUX_TMP/proot-<app>.log"
echo "    Re-run after new installs: bash ~/proot-menu-sync.sh"
pgrep -x "xfce4-panel" > /dev/null 2>&1 && xfce4-panel --restart > /dev/null 2>&1 &
pgrep -x "xfdesktop"   > /dev/null 2>&1 && { sleep 1; xfdesktop --reload > /dev/null 2>&1 & }
SYNCEOF
  chmod +x ~/proot-menu-sync.sh
  echo -e "  ${GREEN}✓ Created ~/proot-menu-sync.sh${NC}"
  bash ~/proot-menu-sync.sh "$PROOT_DISTRO" 2>/dev/null || true
}

# STEP — Container apps (optional, called only when selected)
step_proot_apps() {
  update_progress
  echo -e "${PURPLE}[Step $CURRENT_STEP/$TOTAL_STEPS] Installing apps in Linux container...${NC}\n"
  local pkgs=""
  [ "$INSTALL_LIBREOFFICE" = "true" ] && pkgs="$pkgs libreoffice"
  [ "$INSTALL_GIMP"        = "true" ] && pkgs="$pkgs gimp"
  [ "$INSTALL_INKSCAPE"    = "true" ] && pkgs="$pkgs inkscape"
  [ "$INSTALL_VLC"         = "true" ] && pkgs="$pkgs vlc"
  pkgs="${pkgs# }"

  (proot-distro login "$PROOT_DISTRO" -- bash -c "
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -y -q > /dev/null 2>&1
    apt-get install -y -q --no-install-recommends $pkgs > /dev/null 2>&1
  " >> "$LOG_FILE" 2>&1) &
  spinner $! "Installing container apps: $pkgs"
  echo -e "  ${GREEN}✓ Container apps installed ($pkgs)${NC}"
}

# STEP 12 — Dark theme + wallpaper
step_theme() {
  update_progress
  echo -e "${PURPLE}[Step $CURRENT_STEP/$TOTAL_STEPS] Applying dark theme (Adwaita-dark + Dracula)...${NC}\n"

  mkdir -p ~/.config/xfce4/xfconf/xfce-perchannel-xml ~/.config/autostart

  # GTK theme + fonts
  cat > ~/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xsettings" version="1.0">
  <property name="Net" type="empty">
    <property name="ThemeName"     type="string" value="Adwaita-dark"/>
    <property name="IconThemeName" type="string" value="Adwaita"/>
  </property>
  <property name="Xft" type="empty">
    <property name="DPI"       type="int"    value="96"/>
    <property name="Antialias" type="int"    value="1"/>
    <property name="HintStyle" type="string" value="hintslight"/>
    <property name="RGBA"      type="string" value="rgb"/>
  </property>
  <property name="Gtk" type="empty">
    <property name="FontName"           type="string" value="Sans 11"/>
    <property name="MonospaceFontName"  type="string" value="Monospace 10"/>
    <property name="DecorationLayout"   type="string" value="menu:minimize,maximize,close"/>
    <property name="MenuImages"         type="bool"   value="true"/>
    <property name="ButtonImages"       type="bool"   value="true"/>
  </property>
</channel>
EOF

  # Window manager — compositing + shadows
  cat > ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfwm4" version="1.0">
  <property name="general" type="empty">
    <property name="theme"              type="string" value="Default-xhdpi"/>
    <property name="title_font"         type="string" value="Sans Bold 10"/>
    <property name="use_compositing"    type="bool"   value="true"/>
    <property name="frame_opacity"      type="int"    value="95"/>
    <property name="inactive_opacity"   type="int"    value="90"/>
    <property name="show_frame_shadow"  type="bool"   value="true"/>
    <property name="show_popup_shadow"  type="bool"   value="true"/>
    <property name="shadow_opacity"     type="int"    value="50"/>
    <property name="button_layout"      type="string" value="O|SHMC"/>
    <property name="tile_on_move"       type="bool"   value="true"/>
    <property name="snap_to_windows"    type="bool"   value="true"/>
    <property name="snap_to_border"     type="bool"   value="true"/>
    <property name="wrap_workspaces"    type="bool"   value="false"/>
  </property>
</channel>
EOF

  # Terminal — Dracula color scheme
  cat > ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-terminal.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-terminal" version="1.0">
  <property name="color-foreground" type="string" value="#f8f8f2"/>
  <property name="color-background" type="string" value="#282a36"/>
  <property name="color-cursor"     type="string" value="#f8f8f2"/>
  <property name="color-selection"  type="string" value="#44475a"/>
  <property name="color-palette"    type="string"
    value="#21222c;#ff5555;#50fa7b;#f1fa8c;#bd93f9;#ff79c6;#8be9fd;#f8f8f2;#6272a4;#ff6e6e;#69ff94;#ffffa5;#d6acff;#ff92df;#a4ffff;#ffffff"/>
  <property name="font-name"          type="string" value="Monospace 11"/>
  <property name="misc-cursor-blinks" type="bool"   value="true"/>
  <property name="misc-cursor-shape"  type="uint"   value="1"/>
  <property name="scrolling-bar"      type="uint"   value="0"/>
  <property name="tab-activity-color" type="string" value="#bd93f9"/>
  <property name="title-mode"         type="uint"   value="0"/>
</channel>
EOF

  # Keyboard shortcuts (Super+T, Super+E, Super+D, tiling)
  cat > ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-keyboard-shortcuts" version="1.0">
  <property name="commands" type="empty">
    <property name="custom" type="empty">
      <property name="&lt;Super&gt;e" type="string" value="thunar"/>
      <property name="&lt;Super&gt;t" type="string" value="xfce4-terminal"/>
      <property name="&lt;Super&gt;r" type="string" value="xfce4-appfinder --collapsed"/>
      <property name="&lt;Alt&gt;F2"  type="string" value="xfce4-appfinder --collapsed"/>
      <property name="Print"          type="string" value="xfce4-screenshooter"/>
    </property>
  </property>
  <property name="xfwm4" type="empty">
    <property name="custom" type="empty">
      <property name="&lt;Alt&gt;F4"      type="string" value="close_window_key"/>
      <property name="&lt;Alt&gt;F10"     type="string" value="maximize_window_key"/>
      <property name="&lt;Super&gt;d"     type="string" value="show_desktop_key"/>
      <property name="&lt;Super&gt;Left"  type="string" value="tile_left_key"/>
      <property name="&lt;Super&gt;Right" type="string" value="tile_right_key"/>
      <property name="&lt;Super&gt;Up"    type="string" value="maximize_window_key"/>
    </property>
  </property>
</channel>
EOF

  # Desktop icon visibility
  cat > ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-desktop" version="1.0">
  <property name="desktop-icons" type="empty">
    <property name="file-icons" type="empty">
      <property name="show-filesystem" type="bool" value="false"/>
      <property name="show-home"       type="bool" value="true"/>
      <property name="show-trash"      type="bool" value="true"/>
      <property name="show-removable"  type="bool" value="true"/>
    </property>
    <property name="icon-size"    type="uint"   value="48"/>
    <property name="tooltip-size" type="double" value="64"/>
  </property>
</channel>
EOF

  # Plank dock autostart (XFCE only)
  if [ "$DE_CHOICE" = "1" ]; then
    cat > ~/.config/autostart/plank.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Plank Dock
Exec=plank
Hidden=false
X-GNOME-Autostart-enabled=true
EOF
  fi

  # First-run panel theming (runs once on first desktop launch)
  cat > ~/.config/droidstation-first-run.sh << 'FREOF'
#!/data/data/com.termux/files/usr/bin/bash
WALLPAPER="$HOME/.config/droidstation-wallpaper.jpg"
sleep 4  # wait for xfconfd + panel to initialise

xfconf-query -c xsettings -p /Net/ThemeName -s "Adwaita-dark"        2>/dev/null || true
xfconf-query -c xfwm4 -p /general/theme -s "Default-xhdpi"           2>/dev/null || true
xfconf-query -c xfwm4 -p /general/use_compositing -s true             2>/dev/null || true

# Bottom panel — dark semi-transparent background
xfconf-query -c xfce4-panel -p /panels/panel-1/position          -s "p=8;x=0;y=0" 2>/dev/null || true
xfconf-query -c xfce4-panel -p /panels/panel-1/size          -t int    -s 44   2>/dev/null || true
xfconf-query -c xfce4-panel -p /panels/panel-1/position-locked   -s true  2>/dev/null || true
xfconf-query -c xfce4-panel -p /panels/panel-1/background-style -t int    -s 1    2>/dev/null || true
xfconf-query -c xfce4-panel -p /panels/panel-1/background-rgba \
  -t double -s 0.12 -t double -s 0.12 -t double -s 0.18 -t double -s 0.90 2>/dev/null || true

# Top panel — smaller, dark
xfconf-query -c xfce4-panel -p /panels/panel-2/size          -t int    -s 28   2>/dev/null || true
xfconf-query -c xfce4-panel -p /panels/panel-2/background-style -t int    -s 1    2>/dev/null || true
xfconf-query -c xfce4-panel -p /panels/panel-2/background-rgba \
  -t double -s 0.10 -t double -s 0.10 -t double -s 0.14 -t double -s 0.95 2>/dev/null || true

# Wallpaper
if [ -f "$WALLPAPER" ]; then
  for prop in $(xfconf-query -c xfce4-desktop -lv 2>/dev/null | grep "last-image"  | awk '{print $1}'); do
    xfconf-query -c xfce4-desktop -p "$prop" -s "$WALLPAPER" 2>/dev/null
  done
  for prop in $(xfconf-query -c xfce4-desktop -lv 2>/dev/null | grep "image-style" | awk '{print $1}'); do
    xfconf-query -c xfce4-desktop -p "$prop" -t int -s 5 2>/dev/null
  done
  xfdesktop --reload 2>/dev/null &
fi

# Self-destruct so it only runs once
rm -f "$HOME/.config/autostart/droidstation-first-run.desktop"
FREOF
  chmod +x ~/.config/droidstation-first-run.sh

  cat > ~/.config/autostart/droidstation-first-run.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=DroidStation First Run
Exec=bash /root/.config/droidstation-first-run.sh
NoDisplay=true
X-GNOME-Autostart-enabled=true
EOF

  # Generate dark gradient wallpaper (fallback if no internet)
  WALLPAPER_FILE="$HOME/.config/droidstation-wallpaper.jpg"
  if command -v convert > /dev/null 2>&1; then
    (convert -size 1920x1080 gradient:"#0f0c29"-"#302b63" "$WALLPAPER_FILE" >> "$LOG_FILE" 2>&1) &
    spinner $! "Generating dark gradient wallpaper"
  fi

  echo -e "  ${GREEN}✓ Dark theme configured: Adwaita-dark + Dracula terminal${NC}"
}

# STEP — VNC (optional, called only when selected)
step_vnc() {
  update_progress
  echo -e "${PURPLE}[Step $CURRENT_STEP/$TOTAL_STEPS] Installing VNC server...${NC}\n"
  pkg_install "tigervnc" "TigerVNC Server"
  mkdir -p ~/.vnc
  echo "$VNC_PASS" | vncpasswd -f > ~/.vnc/passwd 2>/dev/null
  chmod 600 ~/.vnc/passwd

  case $DE_CHOICE in
    1) VNC_EXEC="exec startxfce4";;
    2) VNC_EXEC="(sleep 5 && pkill -9 plasmashell && plasmashell) > /dev/null 2>&1 & exec startplasma-x11";;
    3) VNC_EXEC="exec startlxqt";;
    4) VNC_EXEC="exec gnome-session";;
  esac

  cat > ~/.vnc/xstartup << VNCEOF
#!/data/data/com.termux/files/usr/bin/bash
source ~/.config/droidstation-gpu.sh 2>/dev/null
$VNC_EXEC
VNCEOF
  chmod +x ~/.vnc/xstartup

  cat > ~/start-vnc.sh << SVNCEOF
#!/data/data/com.termux/files/usr/bin/bash
echo ""
echo "  ════════════════════════════════════════"
echo "  📺 DroidStation — VNC Desktop"
echo "  ════════════════════════════════════════"
echo ""
vncserver -kill :1 2>/dev/null
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1 2>/dev/null
pulseaudio --kill 2>/dev/null; sleep 0.5
pulseaudio --start --exit-idle-time=-1; sleep 1
pactl load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1 2>/dev/null
export PULSE_SERVER=127.0.0.1
vncserver -localhost no -geometry ${VNC_GEOMETRY} -depth 24 :1
DEVICE_IP=\$(ip -4 addr show wlan0 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1)
echo ""
echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  VNC is ready! Open any VNC Viewer:"
echo "  Local  : 127.0.0.1:5901"
[ -n "\$DEVICE_IP" ] && echo "  Network: \${DEVICE_IP}:5901"
echo "  Pass   : ${VNC_PASS}"
echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
SVNCEOF
  chmod +x ~/start-vnc.sh
  echo -e "  ${GREEN}✓ VNC configured — use ~/start-vnc.sh${NC}"
}

# STEP 14 — Launch scripts + global commands
step_launchers() {
  update_progress
  echo -e "${PURPLE}[Step $CURRENT_STEP/$TOTAL_STEPS] Creating launch scripts + global commands...${NC}\n"

  # GPU environment config (sourced on every desktop launch)
  cat > ~/.config/droidstation-gpu.sh << GPUEOF
# DroidStation GPU Environment
export MESA_NO_ERROR=1
export MESA_GL_VERSION_OVERRIDE=4.6
export MESA_GLES_VERSION_OVERRIDE=3.2
export GALLIUM_DRIVER=zink
export MESA_LOADER_DRIVER_OVERRIDE=zink
export TU_DEBUG=noconform
export MESA_VK_WSI_PRESENT_MODE=immediate
export ZINK_DESCRIPTORS=lazy
export XDG_DATA_DIRS=/data/data/com.termux/files/usr/share:\${XDG_DATA_DIRS}
export XDG_CONFIG_DIRS=/data/data/com.termux/files/usr/etc/xdg:\${XDG_CONFIG_DIRS}
GPUEOF
  [ "$DE_CHOICE" = "2" ] && echo "export KWIN_COMPOSE=O2ES" >> ~/.config/droidstation-gpu.sh

  # Source GPU config in every Termux session
  grep -q "droidstation-gpu.sh" ~/.bashrc 2>/dev/null || \
    echo 'source ~/.config/droidstation-gpu.sh 2>/dev/null' >> ~/.bashrc

  # Determine DE exec + kill commands
  case $DE_CHOICE in
    1) DS_EXEC="exec startxfce4"
       DS_KILL="pkill -9 xfce4-session 2>/dev/null; pkill -9 plank 2>/dev/null";;
    2) DS_EXEC="(sleep 5 && pkill -9 plasmashell && plasmashell) > /dev/null 2>&1 &
exec startplasma-x11"
       DS_KILL="pkill -9 startplasma-x11 2>/dev/null; pkill -9 kwin_x11 2>/dev/null; pkill -9 plasmashell 2>/dev/null";;
    3) DS_EXEC="exec startlxqt"
       DS_KILL="pkill -9 lxqt-session 2>/dev/null";;
    4) DS_EXEC="exec gnome-session"
       DS_KILL="pkill -9 gnome-session 2>/dev/null";;
  esac

  # Samsung DeX resolution hint
  DEX_HINT=""
  [ "$DEX_MODE" = "true" ] && DEX_HINT="
  # Samsung DeX — apply optimized resolution
  xrandr --output :0 --mode 1920x1080 2>/dev/null || true"

  # ── startdesk.sh ──────────────────────────────────────────────────
  cat > ~/startdesk.sh << LEOF
#!/data/data/com.termux/files/usr/bin/bash
echo ""
echo "  ╔═════════════════════════════════════════════╗"
echo "  ║  🚀 DroidStation — Starting ${DE_NAME}"
echo "  ╚═════════════════════════════════════════════╝"
echo ""

source ~/.config/droidstation-gpu.sh 2>/dev/null

# Override Android's generated username with a friendly display name
export USER="droiduser"
export LOGNAME="droiduser"
export HOSTNAME="droidstation"
export HOST="droidstation"

# Kill old sessions
pkill -9 -f "termux.x11" 2>/dev/null
${DS_KILL}
pkill -9 -f "dbus" 2>/dev/null

# Audio setup
unset PULSE_SERVER
pulseaudio --kill 2>/dev/null
sleep 0.5
echo "  🔊 Starting audio server..."
pulseaudio --start --exit-idle-time=-1
sleep 1
pactl load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1 2>/dev/null
export PULSE_SERVER=127.0.0.1

# Start X11
echo "  📺 Starting X11 display server..."
termux-x11 :0 -ac &
sleep 3
export DISPLAY=:0
${DEX_HINT}

# Sync proot apps to menu in background (non-blocking)
[ -f ~/proot-menu-sync.sh ] && bash ~/proot-menu-sync.sh "${PROOT_DISTRO}" > /dev/null 2>&1 &

echo ""
echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  📱 Switch to the Termux-X11 app to see your desktop"
echo "  🔊 Audio : PulseAudio active"
echo "  🎮 GPU   : Turnip/Zink"
echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
${DS_EXEC}
LEOF
  chmod +x ~/startdesk.sh

  # ── stopdesk.sh ───────────────────────────────────────────────────
  cat > ~/stopdesk.sh << 'SEOF'
#!/data/data/com.termux/files/usr/bin/bash
echo "🛑 Stopping DroidStation..."
pkill -9 -f "termux.x11" 2>/dev/null
pkill -9 -f "pulseaudio"  2>/dev/null
pkill -9 xfce4-session    2>/dev/null
pkill -9 plank            2>/dev/null
pkill -9 lxqt-session     2>/dev/null
pkill -9 gnome-session    2>/dev/null
pkill -9 startplasma-x11  2>/dev/null
pkill -9 kwin_x11         2>/dev/null
pkill -9 plasmashell      2>/dev/null
pkill -9 -f "dbus"        2>/dev/null
vncserver -kill :1 2>/dev/null
echo "✓ Stopped."
SEOF
  chmod +x ~/stopdesk.sh

  # ── Global commands: startdesk / stopdesk (type from anywhere) ────
  ln -sf ~/startdesk.sh "$PREFIX/bin/startdesk" 2>/dev/null && chmod +x "$PREFIX/bin/startdesk" 2>/dev/null || true
  ln -sf ~/stopdesk.sh  "$PREFIX/bin/stopdesk"  2>/dev/null && chmod +x "$PREFIX/bin/stopdesk"  2>/dev/null || true
  echo -e "  ${GREEN}✓ Global commands installed: startdesk / stopdesk${NC}"

  # ── Desktop shortcuts ─────────────────────────────────────────────
  mkdir -p ~/Desktop

  case $DE_CHOICE in
    1) TERM_CMD="xfce4-terminal";;
    2) TERM_CMD="konsole";;
    3) TERM_CMD="qterminal";;
    4) TERM_CMD="gnome-terminal";;
  esac

  [ "$INSTALL_FIREFOX"  = "true" ] && cat > ~/Desktop/Firefox.desktop << 'EOF'
[Desktop Entry]
Name=Firefox
Exec=firefox
Icon=firefox
Type=Application
Categories=Network;WebBrowser;
EOF

  [ "$INSTALL_CHROMIUM" = "true" ] && cat > ~/Desktop/Chromium.desktop << 'EOF'
[Desktop Entry]
Name=Chromium
Exec=chromium --no-sandbox
Icon=chromium
Type=Application
Categories=Network;WebBrowser;
EOF

  [ "$INSTALL_VSCODE"   = "true" ] && cat > ~/Desktop/VSCode.desktop << 'EOF'
[Desktop Entry]
Name=VS Code
Exec=code-oss --no-sandbox
Icon=code-oss
Type=Application
Categories=Development;
EOF

  cat > ~/Desktop/Terminal.desktop << EOF2
[Desktop Entry]
Name=Terminal
Exec=$TERM_CMD
Icon=utilities-terminal
Type=Application
Categories=System;TerminalEmulator;
EOF2

  [ "$INSTALL_WINE" = "true" ] && cat > ~/Desktop/WineConfig.desktop << 'EOF'
[Desktop Entry]
Name=Wine Config
Exec=winecfg
Icon=wine
Type=Application
Categories=System;
EOF

  [ "$INSTALL_WINE" = "true" ] && cat > ~/Desktop/WineExplorer.desktop << 'EOF'
[Desktop Entry]
Name=Windows Explorer
Exec=wine winefile
Icon=folder-wine
Type=Application
Categories=System;
EOF

  chmod +x ~/Desktop/*.desktop 2>/dev/null || true
  echo -e "  ${GREEN}✓ Desktop shortcuts created${NC}"
}

# ── COMPLETION SCREEN ─────────────────────────────────────────────────
show_completion() {
  echo ""
  echo -e "${GREEN}"
  cat << 'DONE'
  ╔══════════════════════════════════════════════════╗
  ║                                                  ║
  ║       ✅   INSTALLATION COMPLETE!   ✅           ║
  ║                                                  ║
  ╚══════════════════════════════════════════════════╝
DONE
  echo -e "${NC}"

  echo -e "${YELLOW}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${WHITE}  Desktop   :${NC} ${CYAN}$DE_NAME${NC}"
  [ "$INSTALL_PROOT" = "true" ] && echo -e "${WHITE}  Container :${NC} ${CYAN}$PROOT_LABEL${NC}"
  echo -e "${WHITE}  GPU Mode  :${NC} ${CYAN}$GPU_DRIVER${NC}"
  [ "$DEX_MODE"       = "true" ]  && echo -e "${WHITE}  Samsung DeX:${NC} ${CYAN}Optimized ✓${NC}"
  [ "$INSTALL_PYTHON" = "true" ]  && echo -e "${WHITE}  Dev        :${NC} ${CYAN}Python 3 + pip + virtualenv + uv${NC}"
  [ "$INSTALL_NODE"   = "true" ]  && echo -e "${WHITE}  Dev        :${NC} ${CYAN}Node.js + TypeScript + ts-node${NC}"
  [ "$INSTALL_VNC"    = "true" ]  && echo -e "${WHITE}  VNC        :${NC} ${CYAN}Enabled — pass: $VNC_PASS${NC}"
  [ "$INSTALL_WINE"   = "true" ]  && echo -e "${WHITE}  Wine       :${NC} ${CYAN}Hangover installed${NC}"
  echo -e "${YELLOW}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  echo -e "${WHITE}  🖥️  START DESKTOP (from anywhere in Termux):${NC}"
  echo -e "       ${GREEN}startdesk${NC}"
  echo ""
  echo -e "${WHITE}  🛑 STOP DESKTOP:${NC}"
  echo -e "       ${GREEN}stopdesk${NC}"
  echo ""
  if [ "$INSTALL_PROOT" = "true" ]; then
    echo -e "${WHITE}  🐧 OPEN LINUX CONTAINER ($PROOT_LABEL):${NC}"
    echo -e "       ${GREEN}bash ~/start-proot.sh${NC}"
    echo ""
    echo -e "${WHITE}  🔄 SYNC PROOT APPS TO DESKTOP MENU:${NC}"
    echo -e "       ${GREEN}bash ~/proot-menu-sync.sh${NC}"
    echo -e "       ${GRAY}(run after 'apt install <app>' inside proot)${NC}"
  fi
  [ "$INSTALL_VNC" = "true" ] && {
    echo ""
    echo -e "${WHITE}  📺 VNC REMOTE DESKTOP:${NC}"
    echo -e "       ${GREEN}bash ~/start-vnc.sh${NC}"
  }
  echo ""
  echo -e "${YELLOW}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${GRAY}  ⚡ TIP: Open the Termux-X11 app first, then run 'startdesk'${NC}"
  echo -e "${GRAY}  ⚠  Samsung: disable 'Child Process' in Developer Options${NC}"
  echo -e "${GRAY}     to prevent Termux from being killed in background.${NC}"
  echo -e "${GRAY}  📄 Install log: $LOG_FILE${NC}"
  echo ""
  echo -e "${CYAN}  Made by @rexroze · https://github.com/rexroze/DroidStation${NC}"
  echo ""
  echo ""
}

# ══════════════════════════════════════════════════════════════════════
# MAIN
# ══════════════════════════════════════════════════════════════════════
main() {
  # Init log
  echo "DroidStation v${SCRIPT_VERSION} install log — $(date)" > "$LOG_FILE"

  parse_flags "$@"
  detect_installer_mode
  show_banner

  if [ "$INSTALLER_MODE" != "flags" ]; then
    echo -e "${WHITE}  This will install a full Linux desktop on your Android device.${NC}"
    echo -e "${GRAY}  Estimated time: 25–45 minutes${NC}"
    echo ""
    printf "  Press Enter to start, Ctrl+C to cancel... "
    read -r </dev/tty
  fi

  detect_device
  check_system_resources

  while true; do
    select_options
    [ "$INSTALLER_MODE" = "flags" ] && break
    show_install_summary && break
  done

  prompt_proot_username
  calculate_total_steps

  step_update
  step_repos
  step_x11
  step_desktop
  step_gpu
  step_audio
  step_dev
  step_extras
  [ "$INSTALL_WINE" = "true" ] && step_wine
  if [ "$INSTALL_PROOT" = "true" ]; then
    step_proot
    step_proot_bridge
    { [ "$INSTALL_LIBREOFFICE" = "true" ] || [ "$INSTALL_GIMP"     = "true" ] || \
      [ "$INSTALL_INKSCAPE"    = "true" ] || [ "$INSTALL_VLC"      = "true" ]; } && step_proot_apps
  fi
  step_theme
  [ "$INSTALL_VNC" = "true" ] && step_vnc
  step_launchers

  show_completion
}

main "$@"
