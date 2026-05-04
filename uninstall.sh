#!/data/data/com.termux/files/usr/bin/bash
# DroidStation cleanup helper. Removes files created by the installer; it does
# not uninstall Termux packages because other Termux setups may share them.

set -u

PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"

echo "DroidStation uninstall"
echo ""
echo "This removes DroidStation launchers, config, desktop shortcuts, VNC files,"
echo "and optional Proot container files created by DroidStation."
echo ""
printf "Continue? (y/N): "
read -r CONFIRM
case "$CONFIRM" in
  y|Y|yes|YES) ;;
  *) echo "Cancelled."; exit 0;;
esac

echo ""
echo "Stopping running sessions..."
if [ -x "$HOME/stopdesk.sh" ]; then
  "$HOME/stopdesk.sh" >/dev/null 2>&1 || true
fi
pkill -9 -f "termux.x11" 2>/dev/null || true
pkill -9 -f "pulseaudio" 2>/dev/null || true
vncserver -kill :1 2>/dev/null || true

echo "Removing launchers and commands..."
rm -f "$HOME/startdesk.sh" "$HOME/stopdesk.sh" "$HOME/start-vnc.sh"
rm -f "$HOME/start-proot.sh" "$HOME/proot-menu-sync.sh"
rm -f "$PREFIX/bin/startdesk" "$PREFIX/bin/stopdesk"

echo "Removing config and desktop entries..."
rm -rf "$HOME/.config/droidstation"
rm -f "$HOME/.config/droidstation-gpu.sh"
rm -f "$HOME/.config/droidstation-wallpaper.jpg"
rm -f "$HOME/.config/droidstation-first-run.sh"
rm -f "$HOME/.config/autostart/droidstation-first-run.desktop"
rm -f "$HOME/Desktop/Firefox.desktop" "$HOME/Desktop/Chromium.desktop"
rm -f "$HOME/Desktop/VSCode.desktop" "$HOME/Desktop/Terminal.desktop"
rm -f "$HOME/Desktop/WineConfig.desktop" "$HOME/Desktop/WineExplorer.desktop"

echo "Removing Proot menu bridge files..."
rm -rf "$HOME/.local/share/applications/proot-bridge"
rm -rf "$HOME/.local/share/proot-wrappers"

echo "Removing VNC config..."
rm -rf "$HOME/.vnc"

echo ""
echo "Optional: Proot rootfs can be large."
printf "Remove installed Proot distros used by DroidStation? (y/N): "
read -r REMOVE_PROOT
if echo "$REMOVE_PROOT" | grep -qi '^y'; then
  if command -v proot-distro >/dev/null 2>&1; then
    for distro in ubuntu debian kali-nethunter; do
      proot-distro remove "$distro" >/dev/null 2>&1 || true
    done
    echo "Removed matching Proot distros."
  else
    echo "proot-distro is not installed; skipped rootfs removal."
  fi
fi

echo ""
echo "DroidStation files removed."
