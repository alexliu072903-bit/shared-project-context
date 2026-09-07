---
name: project-publisher
description: Automatically relate meaningful work from one or more human or Agent actors to human-set goals, maintain a repository-backed goal state, and surface concise alignment reminders. Use when work produces progress, drift, risks, blockers, dependencies, or confirmed decisions that may change a configured goal. The same model applies from one actor to a small organization. No explicit invocation is required. Do not use for task assignment, performance evaluation, or bulk activity reporting.
---

# Project Publisher

Use one scale-independent model:

`N Actors → M human-set Goals → one Goal State`

A single user is `N=1`; a team is `N>1`. Do not create separate personal and team modes. Repository visibility and actor permissions are configuration, not different product architectures.

## Resolve the workspace

1. Read `${PROJECT_CONTEXT_CONFIG:-$HOME/.project-context/config.json}`.
2. Require `repository` and `actor_id`; expand `~` against the current user's home directory.
3. Read `<repository>/workspace.json`.
4. Require `workspace`, `actors`, `goals_path`, `state_path`, and `attention_path`.
5. Confirm `actor_id` exists in the workspace actor list.

Resolve relative paths against `<repository>`. If configuration or required files are missing, stop and ask the user to run the installer rather than guessing.

## Start of a relevant turn

Read active Goals, the canonical Goal State, and `<attention_path>/<actor_id>.md`.

If there is a pending next-entry reminder, surface one short Focus Brief before starting new work. State the affected Goal, the last verified position, and the most natural re-entry point. Then mark the reminder delivered. Do not repeat a delivered, dismissed, superseded, or expired reminder.

## End of a relevant turn

Before finishing a turn containing meaningful work, a discovered problem, a changed dependency, or a confirmed decision, silently determine:

1. Which active Goal or Goals the work affects.
2. Whether it changes progress, risk, blocker, dependency, decision, or alignment.
3. What evidence supports the change.
4. Whether another Actor's next action or the overall Goal State changes.

Do not require the user to invoke Project Publisher. If nothing crosses the update threshold, remain silent and continue normally.

Read [references/update-schema.md](references/update-schema.md) before writing an update.

## Maintain Goal State

Write qualifying events append-only to `actors/<actor_id>/updates/`. Update the canonical `state.md` only when shared understanding changes.

Preserve these invariants:

- Goals are set or changed by an authorized human; Agents may suggest but not silently create them.
- Every Actor, including a Founder or Goal Setter, uses the same Actor layer.
- The same facts apply to every Actor; views may reorder but may not rewrite them.
- Do not estimate percentage complete without an explicit measurable denominator.
- Label inference with confidence and link the minimum necessary evidence.
- High-impact changes stay `awaiting_confirmation` until an authorized Actor confirms them.
- Absence of visible activity is not evidence of absence of work.

When recording or correcting a decision, read `<repository>/protocol/README.md` first.

## Alignment reminders

An unrelated action is not automatically drift. Create a reminder only when a coherent Work Episode is weakly aligned with active Goals and continuing it creates plausible opportunity cost, Goal stagnation, dependency risk, or deadline risk.

Choose one delivery mode:

- `turn_end`: add one concise alignment note after the normal work result when the observation is high-confidence and useful now.
- `next_entry`: write a pending reminder to `<attention_path>/<actor_id>.md` when interruption is not justified but the next re-entry point would benefit.

The user can connect the work to a Goal, mark it as intentional exploration, dismiss or defer the reminder, or change the Goal. Treat that response as evidence for later judgments.

Read [references/attention-schema.md](references/attention-schema.md) before writing or updating a reminder.

## External Context Sources

Codex and Claude Code can classify changes visible in their own Agent turns. AirJelly or another always-on source may provide external Work Episodes, but it does not own Goal attribution or final Goal State.

Read [references/context-source-contract.md](references/context-source-contract.md) before consuming external Context. Project Publisher owns Goal mapping, update thresholds, reminders, confirmation, and canonical state changes.

## Corrections and boundaries

- Never silently overwrite an incorrect update; append a correction and repair state.
- Do not dump raw conversations, screenshots, credentials, or activity streams into the workspace.
- Do not turn Work Context into performance evaluation.
- Do not rebuild task assignment, organization management, calendars, or messaging already handled by existing tools.
- Do not change membership, permissions, remotes, or visibility without explicit authorization.

Explicit invocation remains available for testing, correction, and review, but is not the normal workflow.
