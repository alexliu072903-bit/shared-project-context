# Shared Project Context

[中文说明](README.zh-CN.md)

A public, installable Agent Skill that automatically turns project-relevant changes from each person's goals and work context into one shared, evidence-backed project state.

## What it solves

People on the same team have different goals and work in different tools. Designers change flows, engineers implement systems, and product managers adjust direction. Teams usually learn what changed only through meetings, status requests, or reports.

Project Publisher lets each person's Agent automatically decide:

- whether a change affects a shared project;
- whether another participant needs to know;
- whether it is progress, a risk, a blocker, a dependency, or a confirmed decision;
- what minimum information and evidence should be shared.

No explicit “publish this” command is required. Work unrelated to a shared project remains private.

## Public mechanism, private data

This public repository contains only the reusable Skill, protocol, templates, and installer.

Personal goals, work records, evidence, credentials, and real project state live in a separate local or private repository. They are never committed to this public repository by the installer.

## Install for Codex

```bash
git clone https://github.com/alexliu072903-bit/shared-project-context.git
cd shared-project-context
bash install.sh \
  --identity "Your Name" \
  --project "your-project" \
  --repository "$HOME/project-context"
```

The installer creates a private-by-default local instance, writes `~/.project-context/config.json`, and installs the Skill to `~/.codex/skills/project-publisher`.

To install against an existing instance that already contains `project-context.json`, add `--use-existing`.

Open a new Codex task after installation so the Skill can be discovered reliably.

## How it works

Continue working normally. At the end of a relevant Agent turn, Project Publisher checks whether the result changes a configured shared project's state.

- If it is unrelated or private, nothing is published.
- If it is project-relevant, the Agent writes a minimal update.
- If it changes shared understanding, the Agent refreshes the canonical `state.md`.
- If it implies a high-impact direction change, it waits for an authorized person's confirmation.

Explicit `$project-publisher` invocation is available for testing and correction, but it is not the normal workflow.

## Team usage

A designer and an engineer install the same public Skill while keeping different personal goals and private contexts.

If the designer completes an Onboarding flow, their Agent may automatically publish:

> The main Onboarding flow has been updated and is awaiting product confirmation before engineering implementation.

If the engineer discovers an API limitation, their Agent may publish:

> Engineering is blocked because the current API does not support the new Onboarding state; the data approach needs confirmation.

Their personal goals do not need to match. Only changes relevant to the same project enter its shared state.

### Current version

The installer currently supports local single-person trials. Separate installations do not yet connect automatically to the same shared project repository. A private shared-project remote and a member-joining flow are still required before a real multi-person trial.

## First-version boundary

This is not task assignment, employee monitoring, performance evaluation, or a complete OKR product. It tests whether different personal goals can produce one trustworthy, traceable, and correctable shared project state.

## License

MIT
