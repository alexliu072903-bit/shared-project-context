# Shared Project Context

A public, installable Agent Skill that turns project-relevant changes from a person's goals and work context into one shared, evidence-backed project state.

## Public mechanism, private data

This repository contains only the reusable Skill, protocol, templates, and installer. Your goals, work updates, evidence, credentials, and real project state live in a separate local or private repository created during installation.

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

Restart Codex after installation so the new Skill is discovered.

## Try it

Tell your Agent about a real work change and ask:

> Use Project Publisher to decide whether this should update one of my shared projects.

The Agent will either keep the change private or publish a minimal update and refresh the project's canonical `state.md`.

## First-version boundary

This is not task assignment, employee monitoring, a performance system, or a complete OKR product. It tests whether different personal goals can produce one trustworthy shared project state.

## License

MIT
