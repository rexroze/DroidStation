#!/data/data/com.termux/files/usr/bin/bash
# ──────────────────────────────────────────────────────────────────────
#  DroidStation — Quick Installer
#
#  This script downloads and runs the full setup script.
#  It exists so the install one-liner URL never changes,
#  even if the main script is renamed or restructured.
#
#  Usage:
#    bash install.sh [OPTIONS]
#
#  All flags are passed directly to droidstation-setup.sh:
#    bash install.sh --de=xfce --distro=ubuntu --dev=python,node
# ──────────────────────────────────────────────────────────────────────

set -e

REPO="https://raw.githubusercontent.com/rexroze/DroidStation/main"
SETUP_SCRIPT="droidstation-setup.sh"
DEST="$HOME/droidstation-setup.sh"

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

echo ""
echo -e "${CYAN}  DroidStation — Fetching installer...${NC}"
echo ""

# Ensure curl or wget is available
if command -v curl > /dev/null 2>&1; then
  curl -fsSL "$REPO/$SETUP_SCRIPT" -o "$DEST"
elif command -v wget > /dev/null 2>&1; then
  wget -q "$REPO/$SETUP_SCRIPT" -O "$DEST"
else
  echo -e "${RED}  Error: neither curl nor wget found.${NC}"
  echo -e "  Run: ${WHITE}pkg install curl${NC}"
  exit 1
fi

chmod +x "$DEST"

echo -e "${GREEN}  ✓ Downloaded droidstation-setup.sh${NC}"
echo ""

# Pass all arguments through to the main setup script
bash "$DEST" "$@"
