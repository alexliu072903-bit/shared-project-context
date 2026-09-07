#!/bin/bash

set -euo pipefail

SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)"
IDENTITY=""
WORKSPACE=""
REPOSITORY=""
USE_EXISTING=false
INSTALL_CODEX=false
INSTALL_CLAUDE_CODE=false
INSTALL_AIRJELLY_PROD=false
AIRJELLY_DEV_REPO=""

usage() {
  echo 'Usage: install.sh --identity "Your Name" --workspace workspace-id --repository PATH [--use-existing] [--codex] [--claude-code] [--airjelly-production] [--airjelly-development PATH]'
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --identity) IDENTITY="${2:-}"; shift 2 ;;
    --workspace) WORKSPACE="${2:-}"; shift 2 ;;
    --project) WORKSPACE="${2:-}"; shift 2 ;;
    --repository) REPOSITORY="${2:-}"; shift 2 ;;
    --use-existing) USE_EXISTING=true; shift ;;
    --codex) INSTALL_CODEX=true; shift ;;
    --claude-code) INSTALL_CLAUDE_CODE=true; shift ;;
    --airjelly-production) INSTALL_AIRJELLY_PROD=true; shift ;;
    --airjelly-development) AIRJELLY_DEV_REPO="${2:-}"; shift 2 ;;
    *) usage; exit 1 ;;
  esac
done

if [ -z "$IDENTITY" ] || [ -z "$WORKSPACE" ] || [ -z "$REPOSITORY" ]; then
  usage
  exit 1
fi

if [ "$INSTALL_CODEX" = false ] && [ "$INSTALL_CLAUDE_CODE" = false ] && [ "$INSTALL_AIRJELLY_PROD" = false ] && [ -z "$AIRJELLY_DEV_REPO" ]; then
  echo 'Select at least one Runtime target.' >&2
  usage
  exit 1
fi

case "$WORKSPACE" in
  *[!a-z0-9-]*|'') echo 'Workspace id must use lowercase letters, digits, and hyphens.' >&2; exit 1 ;;
esac

ACTOR_ID="$(printf '%s' "$IDENTITY" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '-' | sed 's/^-//;s/-$//')"
if [ -z "$ACTOR_ID" ]; then
  ACTOR_ID="actor-$(printf '%s' "$IDENTITY" | cksum | awk '{print $1}')"
fi

REPOSITORY="${REPOSITORY/#\~/$HOME}"
CONFIG_ROOT="${PROJECT_CONTEXT_CONFIG_ROOT:-$HOME/.project-context}"
CONFIG_TARGET="$CONFIG_ROOT/config.json"

if [ "$USE_EXISTING" = false ] && [ -e "$REPOSITORY" ] && [ -n "$(find "$REPOSITORY" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)" ]; then
  echo "Refusing to overwrite non-empty workspace: $REPOSITORY" >&2
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
  cp "$SOURCE_DIR"/references/*.md "$target/references/"
  echo "Installed Skill: $target"
}

check_skill_target() {
  target="$1/project-publisher"
  if [ -e "$target" ]; then
    echo "Refusing to overwrite existing Skill: $target" >&2
    exit 1
  fi
}

if [ "$INSTALL_CODEX" = true ]; then
  check_skill_target "${PROJECT_CONTEXT_CODEX_SKILLS_ROOT:-$HOME/.codex/skills}"
fi
if [ "$INSTALL_CLAUDE_CODE" = true ]; then
  check_skill_target "${PROJECT_CONTEXT_CLAUDE_SKILLS_ROOT:-$HOME/.claude/skills}"
fi
if [ "$INSTALL_AIRJELLY_PROD" = true ]; then
  check_skill_target "$HOME/Library/Application Support/AirJelly/skills"
fi
if [ -n "$AIRJELLY_DEV_REPO" ]; then
  check_skill_target "$AIRJELLY_DEV_REPO/.data/skills"
fi

mkdir -p "$CONFIG_ROOT"

if [ "$USE_EXISTING" = false ]; then
  mkdir -p "$REPOSITORY"
  cp -R "$SOURCE_DIR/template/." "$REPOSITORY/"
  mv "$REPOSITORY/actors/__ACTOR_ID__" "$REPOSITORY/actors/$ACTOR_ID"
  mv "$REPOSITORY/attention/__ACTOR_ID__.md" "$REPOSITORY/attention/$ACTOR_ID.md"

  python3 - "$REPOSITORY" "$IDENTITY" "$ACTOR_ID" "$WORKSPACE" <<'PY'
from datetime import date
from pathlib import Path
import sys

root, identity, actor_id, workspace = sys.argv[1:]
replacements = {
    "__IDENTITY__": identity,
    "__ACTOR_ID__": actor_id,
    "__WORKSPACE__": workspace,
    "__DATE__": date.today().isoformat(),
}
for path in Path(root).rglob("*"):
    if path.is_file():
        text = path.read_text(encoding="utf-8")
        for old, new in replacements.items():
            text = text.replace(old, new)
        path.write_text(text, encoding="utf-8")
PY
else
  if [ ! -f "$REPOSITORY/workspace.json" ]; then
    echo "Existing workspace is missing workspace.json: $REPOSITORY" >&2
    exit 1
  fi

  python3 - "$REPOSITORY" "$IDENTITY" "$ACTOR_ID" "$WORKSPACE" <<'PY'
import json
from pathlib import Path
import sys

root = Path(sys.argv[1])
identity, actor_id, expected_workspace = sys.argv[2:]
workspace_path = root / "workspace.json"
workspace = json.loads(workspace_path.read_text(encoding="utf-8"))
if workspace.get("workspace") != expected_workspace:
    raise SystemExit(
        f"Workspace id mismatch: expected {expected_workspace}, found {workspace.get('workspace')}"
    )
actors = workspace.setdefault("actors", [])
if not any(actor.get("id") == actor_id for actor in actors):
    actors.append({"id": actor_id, "name": identity, "can_manage_goals": False})
    workspace_path.write_text(json.dumps(workspace, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

actor_root = root / "actors" / actor_id
(actor_root / "updates").mkdir(parents=True, exist_ok=True)
profile = actor_root / "profile.md"
if not profile.exists():
    profile.write_text(
        f"---\nactor: {actor_id}\nname: {identity}\ncan_manage_goals: false\n---\n\n# {identity}\n",
        encoding="utf-8",
    )
attention_root = root / workspace.get("attention_path", "attention")
attention_root.mkdir(parents=True, exist_ok=True)
attention = attention_root / f"{actor_id}.md"
if not attention.exists():
    attention.write_text(
        f"---\nactor: {actor_id}\nstatus: none\ndelivery: next_entry\ngoal: null\ncreated_at: null\nconfidence: null\nsource_updates: []\n---\n\n# No pending reminder\n",
        encoding="utf-8",
    )
PY
fi

python3 - "$CONFIG_TARGET" "$REPOSITORY" "$ACTOR_ID" <<'PY'
import json
import sys

target, repository, actor_id = sys.argv[1:]
with open(target, "w", encoding="utf-8") as handle:
    json.dump({"repository": repository, "actor_id": actor_id}, handle, ensure_ascii=False, indent=2)
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
  echo "Joined existing workspace: $REPOSITORY as $ACTOR_ID"
else
  echo "Created workspace: $REPOSITORY"
fi
echo "Configured: $CONFIG_TARGET"
