# External Context Source contract

An external source such as AirJelly should provide bounded, evidence-backed Work Episodes, not raw surveillance streams and not final project conclusions.

## Minimum viable episode

Each candidate episode needs:

- stable `episode_id` for deduplication;
- actor identity and source Runtime;
- start and end time;
- observed goal or intent when supported;
- concise process summary;
- observable outcome or state change;
- artifact and evidence references;
- author and visibility boundary;
- source confidence;
- incremental cursor or timestamp for querying new episodes.

Do not emit a project update from a screenshot, isolated click, application duration, or activity count alone. Incomplete evidence may enrich an episode but may not establish progress, a blocker, or a decision by itself.

## Responsibility boundary

AirJelly or another source owns collection, normalization, identity, evidence references, privacy controls, and incremental retrieval.

Project Publisher owns:

- mapping an episode to personal goals and configured projects;
- deciding whether another participant needs to know;
- choosing progress, risk, blocker, dependency, or decision;
- requiring confirmation for high-impact changes;
- writing append-only updates and canonical project state.

## First useful level

The initial AirJelly integration is sufficient when Project Publisher can request recent, complete Work Episodes for one person, trace each episode to evidence, avoid duplicates, and exclude private or unrelated activity before publication.

Real-time streaming, full raw-screen replay, company-wide ingestion, performance scoring, and a separate dashboard are not required for the first validation.
