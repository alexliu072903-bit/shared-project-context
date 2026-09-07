# Goal Decision Protocol

## Read

Before work that may depend on history, read active files under `goals/`, `state.md`, and only the relevant valid decisions.

## Record

Record a decision only when an authorized participant clearly confirms execution, rejects a direction, replaces or revokes an existing decision, or directly asks to record one.

Do not record tentative preferences, open questions, ordinary work, temporary experiments, or an Agent's recommendation. If a high-impact statement is ambiguous, ask once whether it is a confirmed decision. Without confirmation, do not write it as a decision.

## Format

Write each decision to `decisions/<decision-id>.md` with `workspace`, `decision`, `status`, `decided_by`, `decided_at`, affected `goals`, and optional `supersedes` frontmatter. Include the decision, rationale, scope, explicit exclusions, and overturn signal. Use `To be validated` rather than inventing missing information.

## Change and correction

Never overwrite decision history. Mark the old decision `superseded` or `revoked`, create the replacement when applicable, and connect it with `supersedes`.

When a participant corrects a published fact or decision, repair the canonical state first and append a correction update that preserves the original event and the corrected behavior.
