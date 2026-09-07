# Attention state schema

Each Actor has one attention file at `attention/<actor_id>.md`.

```markdown
---
actor: <actor-id>
status: none | pending | delivered | deferred | dismissed | corrected | superseded
delivery: turn_end | next_entry
goal: <goal-id>
created_at: <ISO-8601 timestamp>
deliver_after: <optional ISO-8601 timestamp>
expires_at: <optional ISO-8601 timestamp>
confidence: high | medium | low
source_updates: [<update-id>]
---

# Short reminder

## Observation
## Why it matters now
## Suggested re-entry
```

Do not create a reminder from an isolated unrelated action. Require a coherent Work Episode plus plausible opportunity cost, Goal stagnation, dependency risk, or deadline risk.

When the Actor corrects the reminder, preserve the correction in the file or an append-only update so the same interpretation is less likely to recur.
