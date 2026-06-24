# Website Shower For OpenCode

Use this repository as a read-only website maintenance audit workflow for source/config files.

Load these files as needed:

- `SKILL.md` for the canonical workflow.
- `references/audit-orchestrator.md` for multi-module coordination.
- `references/website-map.md` before writing inspected scope.
- the module reference for the section being judged.
- `references/audit-heuristics.md` when deciding signal vs noise.
- `references/placement-rules.md` when judging ownership or placement.
- `references/report-format.md` for output shape.

When shell access is available, run:

```bash
scripts/scan-website-shower.sh <target>
```

For monorepos, scan the root only for orientation, then scan one app/package/domain.

Write `website-shower-report.md` when file writes are available; otherwise return the same report in chat. Do not edit audited source/config files unless the user explicitly asks for fixes. Scanner output is candidate evidence only; confirm ownership, shape, usage, framework rules, boundaries, and validation before reporting a checklist task. Include inspected scope. Use module headings, `Evidence`, `Change risk`, boundary markers when useful, commands used, and ignored leads when output is noisy.
