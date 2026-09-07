#!/bin/bash

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SYNC_SCRIPT="$REPO_DIR/scripts/sync.sh"

if [ "$(uname -s)" != "Darwin" ]; then
  echo "Automatic scheduling currently supports macOS only." >&2
  exit 1
fi

case "$REPO_DIR/" in
  "$HOME/Documents/"*|"$HOME/Desktop/"*|"$HOME/Downloads/"*)
    echo "Move the private instance outside macOS protected directories before enabling autosync." >&2
    exit 1
    ;;
esac

BRANCH="$(git -C "$REPO_DIR" symbolic-ref --quiet --short HEAD 2>/dev/null || true)"
REMOTE_URL="$(git -C "$REPO_DIR" remote get-url origin 2>/dev/null || true)"
if [ -z "$BRANCH" ] || [ -z "$REMOTE_URL" ]; then
  echo "Initialize Git, add a private origin, and push the first branch before enabling autosync." >&2
  exit 1
fi

if command -v gh >/dev/null 2>&1; then
  case "$REMOTE_URL" in
    https://github.com/*|git@github.com:*)
      REPO_SLUG="${REMOTE_URL#https://github.com/}"
      REPO_SLUG="${REPO_SLUG#git@github.com:}"
      REPO_SLUG="${REPO_SLUG%.git}"
      VISIBILITY="$(gh repo view "$REPO_SLUG" --json visibility --jq .visibility 2>/dev/null || true)"
      if [ "$VISIBILITY" = "PUBLIC" ]; then
        echo "Refusing to autosync private context to a public repository: $REPO_SLUG" >&2
        exit 1
      fi
      ;;
  esac
fi

REPO_ID="$(printf '%s' "$REPO_DIR" | cksum | awk '{print $1}')"
LABEL="ai.shared-project-context.autosync.$REPO_ID"
PLIST_PATH="$HOME/Library/LaunchAgents/$LABEL.plist"
DOMAIN="gui/$(id -u)"
TARGET="$DOMAIN/$LABEL"

chmod +x "$SYNC_SCRIPT"
mkdir -p "$HOME/Library/LaunchAgents" "$REPO_DIR/.project-context"

cat > "$PLIST_PATH" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>Label</key><string>$LABEL</string>
<key>ProgramArguments</key><array><string>/bin/bash</string><string>$SYNC_SCRIPT</string></array>
<key>WorkingDirectory</key><string>$REPO_DIR</string>
<key>StartInterval</key><integer>1800</integer>
<key>RunAtLoad</key><true/>
<key>StandardOutPath</key><string>$REPO_DIR/.project-context/sync.log</string>
<key>StandardErrorPath</key><string>$REPO_DIR/.project-context/sync.log</string>
</dict></plist>
EOF

launchctl bootout "$TARGET" 2>/dev/null || true
launchctl bootstrap "$DOMAIN" "$PLIST_PATH"
launchctl kickstart -k "$TARGET"

echo "Autosync enabled every 30 minutes."
echo "Repository: $REPO_DIR"
echo "Log: $REPO_DIR/.project-context/sync.log"
