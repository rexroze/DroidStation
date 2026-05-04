#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

scripts=(
  droidstation-setup.sh
  install.sh
  uninstall.sh
)

for script in "${scripts[@]}"; do
  bash -n "$script"
done

help_output="$(bash droidstation-setup.sh --help)"
grep -q "Usage: bash droidstation-setup.sh" <<<"$help_output"
grep -q -- "--no-proot" <<<"$help_output"

dry_run_output="$(bash droidstation-setup.sh dry-run --de=xfce --no-proot --extras=firefox)"
grep -q "Dry run: no packages will be installed" <<<"$dry_run_output"
grep -q "Container .*skipped" <<<"$dry_run_output"
grep -q "Firefox" <<<"$dry_run_output"

vnc_output="$(bash droidstation-setup.sh dry-run --de=xfce --no-proot --vnc)"
grep -q "VNC server" <<<"$vnc_output"

if bash droidstation-setup.sh dry-run --de=xfce --no-proot --vnc --vnc-pass=123 >/tmp/droidstation-invalid-vnc.log 2>&1; then
  echo "Expected short VNC password validation to fail" >&2
  exit 1
fi
grep -q "Invalid VNC password" /tmp/droidstation-invalid-vnc.log

if bash droidstation-setup.sh dry-run --no-proot --extras=vlc >/tmp/droidstation-invalid.log 2>&1; then
  echo "Expected container app validation to fail with --no-proot" >&2
  exit 1
fi
grep -q "Container apps require Proot" /tmp/droidstation-invalid.log

if bash droidstation-setup.sh --does-not-exist >/tmp/droidstation-invalid-flag.log 2>&1; then
  echo "Expected unknown flag validation to fail" >&2
  exit 1
fi
grep -q "Unknown option '--does-not-exist'" /tmp/droidstation-invalid-flag.log

echo "Smoke tests passed."
