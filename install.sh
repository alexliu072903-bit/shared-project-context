#!/bin/bash

set -euo pipefail

SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)"
IDENTITY=""
PROJECT=""
REPOSITORY=""
USE_EXISTING=false
INSTALL_CODEX=false
INSTALL_CLAUDE_CODE=false
INSTALL_AIRJELLY_PROD=false
AIRJELLY_DEV_REPO=""

usage() {
  echo 'Usage: install.sh --identity "Your Name" --project project-id --repository PATH [--use-existing] [--codex] [--claude-code] [--airjelly-production] [--airjelly-development PATH]'
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --identity) IDENTITY="${2:-}"; shift 2 ;;
    --project) PROJECT="${2:-}"; shift 2 ;;
    --repository) REPOSITORY="${2:-}"; shift 2 ;;
    --use-existing) USE_EXISTING=true; shift ;;
    --codex) INSTALL_CODEX=true; shift ;;
    --claude-code) INSTALL_CLAUDE_CODE=true; shift ;;
    --airjelly-production) INSTALL_AIRJELLY_PROD=true; shift ;;
    --airjelly-development) AIRJELLY_DEV_REPO="${2:-}"; shift 2 ;;
    *) usage; exit 1 ;;
  esac
done

if [ -z "$IDENTITY" ] || [ -z "$PROJECT" ] || [ -z "$REPOSITORY" ]; then
  usage
  exit 1
fi

if [ "$INSTALL_CODEX" = false ] && [ "$INSTALL_CLAUDE_CODE" = false ] && [ "$INSTALL_AIRJELLY_PROD" = false ] && [ -z "$AIRJELLY_DEV_REPO" ]; then
  echo 'Select at least one runtime target.' >&2
  usage
  exit 1
fi

case "$PROJECT" in
  *[!a-z0-9-]*|'') echo 'Project id must use lowercase letters, digits, and hyphens.' >&2; exit 1 ;;
esac

IDENTITY_SLUG="$(printf '%s' "$IDENTITY" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '-' | sed 's/^-//;s/-$//')"
if [ -z "$IDENTITY_SLUG" ]; then
  IDENTITY_SLUG="user-$(printf '%s' "$IDENTITY" | cksum | awk '{print $1}')"
fi

REPOSITORY="${REPOSITORY/#\~/$HOME}"
CONFIG_ROOT="${PROJECT_CONTEXT_CONFIG_ROOT:-$HOME/.project-context}"
CONFIG_TARGET="$CONFIG_ROOT/config.json"

if [ "$USE_EXISTING" = false ] && [ -e "$REPOSITORY" ] && [ -n "$(find "$REPOSITORY" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)" ]; then
  echo "Refusing to overwrite non-empty repository: $REPOSITORY" >&2
  exit 1
fi

install_skill() {
  target_root="$1"
  target="$target_root/project-publisher"
  if [ -e "$target" ]; then
    echo "Refusing to overwrite existing Skill: $target" >&2
    exit 1
  fi
  mkdir -p "$target/agents" "$target/references"
  cp "$SOURCE_DIR/SKILL.md" "$target/SKILL.md"
  cp "$SOURCE_DIR/agents/openai.yaml" "$target/agents/openai.yaml"
  cp "$SOURCE_DIR/references/update-schema.md" "$target/references/update-schema.md"
  cp "$SOURCE_DIR/references/context-source-contract.md" "$target/references/context-source-contract.md"
  echo "Installed Skill: $target"
}

mkdir -p "$CONFIG_ROOT"

if [ "$USE_EXISTING" = true ]; then
  if [ ! -f "$REPOSITORY/project-context.json" ]; then
    echo "Existing instance is missing project-context.json: $REPOSITORY" >&2
    exit 1
  fi
else
  mkdir -p "$REPOSITORY"
  cp -R "$SOURCE_DIR/template/." "$REPOSITORY/"
  mv "$REPOSITORY/personal/__IDENTITY_SLUG__" "$REPOSITORY/personal/$IDENTITY_SLUG"
  mv "$REPOSITORY/projects/__PROJECT__" "$REPOSITORY/projects/$PROJECT"
  mv "$REPOSITORY/projects/$PROJECT/updates/__IDENTITY_SLUG__" "$REPOSITORY/projects/$PROJECT/updates/$IDENTITY_SLUG"

  python3 - "$REPOSITORY" "$IDENTITY" "$IDENTITY_SLUG" "$PROJECT" <<'PY'
from datetime import date
from pathlib import Path
import sys

root, identity, identity_slug, project = sys.argv[1:]
replacements = {
    "__IDENTITY__": identity,
    "__IDENTITY_SLUG__": identity_slug,
    "__PROJECT__": project,
    "__DATE__": date.today().isoformat(),
}
for path in Path(root).rglob("*"):
    if path.is_file():
        text = path.read_text(encoding="utf-8")
        for old, new in replacements.items():
            text = text.replace(old, new)
        path.write_text(text, encoding="utf-8")
PY
fi

python3 - "$CONFIG_TARGET" "$REPOSITORY" <<'PY'
import json
import sys

target, repository = sys.argv[1:]
with open(target, "w", encoding="utf-8") as handle:
    json.dump({"repository": repository}, handle, indent=2)
    handle.write("\n")
PY

if [ "$INSTALL_CODEX" = true ]; then
  install_skill "${PROJECT_CONTEXT_CODEX_SKILLS_ROOT:-$HOME/.codex/skills}"
fi

if [ "$INSTALL_CLAUDE_CODE" = true ]; then
  install_skill "${PROJECT_CONTEXT_CLAUDE_SKILLS_ROOT:-$HOME/.claude/skills}"
fi

if [ "$INSTALL_AIRJELLY_PROD" = true ]; then
  install_skill "$HOME/Library/Application Support/AirJelly/skills"
fi

if [ -n "$AIRJELLY_DEV_REPO" ]; then
  install_skill "$AIRJELLY_DEV_REPO/.data/skills"
fi

if [ "$USE_EXISTING" = true ]; then
  echo "Using existing private local instance: $REPOSITORY"
else
  echo "Created private local instance: $REPOSITORY"
fi
echo "Configured: $CONFIG_TARGET"
