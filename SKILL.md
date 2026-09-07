---
name: project-publisher
description: Automatically detect and publish project-relevant changes from a person's goals and work context into a shared repository-backed project state. Use when a user or Agent completes meaningful work, discovers a risk, blocker, or dependency, or confirms a decision that may affect a shared project. No explicit invocation is required. Keep unrelated or private work in personal context; do not use this Skill for task assignment, performance evaluation, or bulk activity reporting.
---

# Project Publisher

Personal context and shared project context are different sources of truth. Publish only the minimum change another participant needs to coordinate their work.

## Resolve context

1. Read `${PROJECT_CONTEXT_CONFIG:-$HOME/.project-context/config.json}`.
2. Require `repository` and expand `~` against the current user's home directory.
3. Read `<repository>/project-context.json`.
4. Require `identity`, `personal_goals`, and at least one project with `id` and `path`.

Resolve relative paths against `<repository>`. If anything is missing, stop and ask the user to run the installer rather than guessing.

## Trigger automatically

Do not require the user to say “use Project Publisher” or ask for an update. Before finishing any turn that contains meaningful work, a discovered problem, a changed dependency, or a confirmed decision, silently check whether it crosses a configured project's publication boundary.

- If it qualifies, publish the update as part of the same turn and briefly tell the user what changed.
- If it does not qualify, remain silent and continue the user's task normally.
- If a high-impact direction change is ambiguous, ask once whether it is confirmed before publishing it as a decision.

Explicit invocation remains available for testing, correction, or review, but is not the normal workflow.

## Classify a work change

Determine which personal goal the change supports, whether it changes a shared project's progress, risk, blocker, dependency, or confirmed decision, which project is affected, and what evidence supports the classification.

Do not publish changes that are unrelated, private, speculative, duplicated, or too vague to alter another participant's understanding.

Use these update types:

- `progress`: a verifiable result moved the project forward.
- `risk`: evidence suggests the shared outcome may be affected.
- `blocker`: progress is stopped by a named unmet condition.
- `dependency`: one participant or workstream now depends on another.
- `decision`: an authorized person explicitly confirmed a direction change.

Read [references/update-schema.md](references/update-schema.md) before writing.

## Publish

Write one append-only update to `<project>/updates/<identity>/`. Do not copy raw conversations, screenshots, credentials, or private activity. Link or describe the minimum evidence needed to verify the claim.

Update `<project>/state.md` only if the new event changes shared understanding. Maintain one canonical set of facts. Personal views may reorder facts but may not rewrite them. Do not generate percentage-complete estimates without an explicit denominator. Label inference with confidence. High-impact changes remain `awaiting_confirmation` until an authorized person confirms them.

## Corrections

Never silently overwrite an incorrect update. Add a correction referencing the original and repair `state.md`, preserving why the state changed.

## Boundaries

- Keep personal goals unrelated to the shared project private.
- Do not interpret absence of visible activity as absence of work.
- Do not turn work evidence into performance evaluation.
- Do not change membership, permissions, remotes, or visibility without explicit authorization.
- Do not publish a direction change merely because an Agent inferred it.
