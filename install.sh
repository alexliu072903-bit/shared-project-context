#!/bin/bash

set -euo pipefail

SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)"
IDENTITY=""
PROJECT=""
REPOSITORY=""
USE_EXISTING=false

usage() {
  echo 'Usage: install.sh --identity "Your Name" --project project-id --repository /path/to/private-instance [--use-existing]'
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --identity) IDENTITY="${2:-}"; shift 2 ;;
    --project) PROJECT="${2:-}"; shift 2 ;;
    --repository) REPOSITORY="${2:-}"; shift 2 ;;
    --use-existing) USE_EXISTING=true; shift ;;
    *) usage; exit 1 ;;
  esac
done

if [ -z "$IDENTITY" ] || [ -z "$PROJECT" ] || [ -z "$REPOSITORY" ]; then
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
SKILLS_ROOT="${PROJECT_CONTEXT_SKILLS_ROOT:-$HOME/.codex/skills}"
CONFIG_ROOT="${PROJECT_CONTEXT_CONFIG_ROOT:-$HOME/.project-context}"
SKILL_TARGET="$SKILLS_ROOT/project-publisher"
CONFIG_TARGET="$CONFIG_ROOT/config.json"

if [ "$USE_EXISTING" = false ] && [ -e "$REPOSITORY" ] && [ -n "$(find "$REPOSITORY" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)" ]; then
  echo "Refusing to overwrite non-empty repository: $REPOSITORY" >&2
  exit 1
fi

if [ -e "$SKILL_TARGET" ]; then
  echo "Refusing to overwrite existing Skill: $SKILL_TARGET" >&2
  exit 1
fi

mkdir -p "$SKILLS_ROOT" "$CONFIG_ROOT"

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

mkdir -p "$SKILL_TARGET/agents" "$SKILL_TARGET/references"
cp "$SOURCE_DIR/SKILL.md" "$SKILL_TARGET/SKILL.md"
cp "$SOURCE_DIR/agents/openai.yaml" "$SKILL_TARGET/agents/openai.yaml"
cp "$SOURCE_DIR/references/update-schema.md" "$SKILL_TARGET/references/update-schema.md"

python3 - "$CONFIG_TARGET" "$REPOSITORY" <<'PY'
import json
import sys

target, repository = sys.argv[1:]
with open(target, "w", encoding="utf-8") as handle:
    json.dump({"repository": repository}, handle, indent=2)
    handle.write("\n")
PY

if [ "$USE_EXISTING" = true ]; then
  echo "Using existing private local instance: $REPOSITORY"
else
  echo "Created private local instance: $REPOSITORY"
fi
echo "Installed Skill: $SKILL_TARGET"
echo "Configured: $CONFIG_TARGET"
