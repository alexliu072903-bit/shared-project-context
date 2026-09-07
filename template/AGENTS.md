# Goal Context Workspace

This workspace uses one model at every scale: `N Actors → M human-set Goals → one Goal State`.

## At the start of relevant work

1. Read `workspace.json` and resolve the current Actor.
2. Read active files under `goals/`, `state.md`, and `attention/<actor-id>.md`.
3. If a valid next-entry reminder is pending, surface a short Focus Brief and mark it delivered.

## At the end of relevant work

1. Use the installed `project-publisher` Skill.
2. Append only qualifying events under `actors/<actor-id>/updates/`.
3. Update `state.md` only when Goal understanding changes.
4. Follow `protocol/README.md` for decisions and corrections.

Do not invent Actors, Goals, progress, blockers, dependencies, or evidence. Do not use Work Context for performance evaluation. Do not change repository visibility or membership without explicit authorization.
