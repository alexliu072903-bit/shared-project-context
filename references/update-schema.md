# Shared project update schema

```markdown
---
update: <YYYY-MM-DD-HHMM-identity-short-name>
project: <project-id>
author: <identity>
observed_at: <ISO-8601 timestamp or date>
type: progress | risk | blocker | dependency | decision
status: published | awaiting_confirmation | corrected
personal_goal: <personal goal id, optional>
confidence: high | medium | low
corrects: <update id, optional>
---

# Short factual title

## Change
## Project impact
## Evidence
## Next dependency
```

Publish only when an explicit result was produced, an acceptance condition changed, a blocker or dependency affects another participant, an authorized person confirmed a direction change, or a shared fact was corrected.

Do not publish ordinary effort, browsing, time spent, tentative thoughts, or activity with no project impact.
