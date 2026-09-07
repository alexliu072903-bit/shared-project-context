# Goal update schema

Write each qualifying change to `actors/<actor_id>/updates/<update-id>.md`.

```markdown
---
update: <YYYY-MM-DD-HHMM-actor-short-name>
workspace: <workspace-id>
actor: <actor-id>
observed_at: <ISO-8601 timestamp or date>
goals: [<goal-id>]
type: progress | risk | blocker | dependency | decision | alignment
status: published | awaiting_confirmation | corrected
confidence: high | medium | low
corrects: <optional update-id>
---

# Short factual title

## Change
## Goal impact
## Evidence
## Next dependency
```

Write only when a verifiable result changes a Goal, a known acceptance condition changes, a blocker or dependency affects another Actor, an authorized human confirms a decision, a shared fact is corrected, or a meaningful alignment observation meets the reminder threshold.

Do not publish ordinary effort, time spent, browsing, tentative thoughts, or activity with no Goal impact.
