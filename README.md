# Shared Project Context

[中文说明](README.zh-CN.md)

An open Agent Skill for keeping real work aligned with human-set goals.

It uses one model at every scale:

```text
N human or Agent actors
→ M goals set by authorized humans
→ one evidence-backed goal state
```

One person using the repository is `N=1`. A small organization is `N>1`. There are no separate personal and team product modes.

## What it does

Actors continue working in Codex, Claude Code, and later AirJelly. Project Publisher automatically detects meaningful progress, drift, risks, blockers, dependencies, and confirmed decisions, then relates them to active Goals.

It maintains:

- human-set Goals and acceptance conditions;
- append-only Actor updates;
- one canonical Goal State;
- decision history and corrections;
- quiet alignment reminders at turn end or next entry;
- evidence references instead of raw activity dumps.

It does not rebuild task assignment, messaging, calendars, organization management, or performance evaluation.

## Public engine, configurable workspace

This public repository distributes the Skill, schemas, protocol, installer, and optional sync scripts. Actual Goals, Actor updates, evidence, and state live in a workspace created from the template.

The workspace may stay local, use a private repository, or use another visibility boundary chosen by its owner. The same data model applies regardless of Actor count.

## Install

```bash
git clone https://github.com/alexliu072903-bit/shared-project-context.git
cd shared-project-context
bash install.sh \
  --identity "Your Name" \
  --workspace "my-goals" \
  --repository "$HOME/goal-context" \
  --codex \
  --claude-code
```

Supported Runtime targets:

- `--codex`
- `--claude-code`
- `--airjelly-production`
- `--airjelly-development PATH`

The installer creates the first Actor, a draft Goal, `state.md`, and the Actor's empty attention state. It writes `~/.project-context/config.json` and installs one canonical Skill into the selected Runtimes.

`--project` remains accepted as an alias for `--workspace` during the early prototype.

## Join an existing workspace

After cloning or receiving access to an existing workspace:

```bash
bash install.sh \
  --identity "Designer A" \
  --workspace "airjelly" \
  --repository "$HOME/airjelly-goal-context" \
  --use-existing \
  --codex \
  --claude-code
```

This adds the Actor when absent and creates only that Actor's profile, update directory, and attention state. Repository access and membership remain the responsibility of the existing collaboration platform.

## Reminder behavior

Project Publisher currently supports two Agent-native reminders:

1. `turn_end`: one concise alignment note after the normal work result when it is useful immediately;
2. `next_entry`: a persisted Focus Brief shown when the Actor next enters a relevant Agent turn.

An isolated unrelated action is not automatically drift. The Skill requires a coherent Work Episode plus plausible opportunity cost, Goal stagnation, dependency risk, or deadline risk.

## AirJelly Context Source

AirJelly is optional for Agent-turn behavior. Later it can provide incremental, deduplicated, evidence-backed Work Episodes for activity outside Codex and Claude Code. Project Publisher—not AirJelly—owns Goal attribution, reminders, confirmation, and canonical state changes. See [the Context Source contract](references/context-source-contract.md).

## Optional Git sync

The generated workspace includes macOS scripts for 30-minute commit, rebase, and push. Connect an appropriate remote, then explicitly run:

```bash
bash "$HOME/goal-context/scripts/setup-autosync.sh"
```

The setup refuses a GitHub remote reported as public because work Context may be sensitive. Workspace owners may choose a different sharing mechanism or adapt the script deliberately.

## License

MIT
