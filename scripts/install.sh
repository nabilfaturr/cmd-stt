#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "Installing cmd-stt..."

# Dependencies check
for cmd in ffmpeg wl-copy ydotool curl jq notify-send; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Missing dependency: $cmd" >&2
  fi
done

# Install binary
mkdir -p "$HOME/.local/bin"
cp "$ROOT/bin/cmd-stt" "$HOME/.local/bin/cmd-stt"
chmod +x "$HOME/.local/bin/cmd-stt"

# Install config (don't overwrite existing)
mkdir -p "$HOME/.config/cmd-stt"
if [[ ! -f "$HOME/.config/cmd-stt/config" ]]; then
  cp "$ROOT/config/config.example" "$HOME/.config/cmd-stt/config"
  echo "Created config at ~/.config/cmd-stt/config"
fi

# Install desktop entries
mkdir -p "$HOME/.local/share/applications"
cp "$ROOT/desktop/"*.desktop "$HOME/.local/share/applications/"

# Install systemd service
mkdir -p "$HOME/.config/systemd/user"
cp "$ROOT/systemd/ydotoold.service" "$HOME/.config/systemd/user/"
systemctl --user daemon-reload 2>/dev/null || true
systemctl --user enable ydotoold 2>/dev/null || true

# Update KDE global shortcuts (best-effort)
KG="$HOME/.config/kglobalshortcutsrc"
if [[ -f "$KG" ]]; then
  if lsattr "$KG" 2>/dev/null | grep -q 'i'; then
    chattr -i "$KG" 2>/dev/null || true
  fi
  python3 - "$KG" <<'PY'
import sys
p=sys.argv[1]
s=open(p).read()
s=s.replace("_launch=Meta+Ctrl+S","_launch=Meta+Ctrl+Alt+S")
s=s.replace("_launch=Meta+Ctrl+D","_launch=Meta+Ctrl+Alt+D")
s=s.replace("_launch=Meta+Ctrl+X","_launch=Meta+Ctrl+Alt+X")
open(p,"w").write(s)
PY
  chattr +i "$KG" 2>/dev/null || true
fi

kbuildsycoca6 --noincremental 2>/dev/null || true

echo "Done. Start ydotool daemon: systemctl --user start ydotoold"
echo "Hotkeys: Meta+Ctrl+Alt+S (start), D (stop), X (toggle)"