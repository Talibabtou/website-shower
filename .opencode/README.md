# OpenCode Adapter

OpenCode reads `opencode.json` from the project root. That file points to `.opencode/instructions/website-shower.md`.

Commands are intentionally not shipped yet. Website Shower still has one primary workflow: run the multi-module audit, turn candidates into a checklist artifact, then wait for approval before source edits.

When separate audit modes need direct entry points, add commands under:

```text
.opencode/command/
```

Likely future commands:

- `audit-types.md`
- `audit-next-habits.md`
- `audit-tailwind.md`
- `audit-unused.md`
