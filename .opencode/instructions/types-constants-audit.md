# Website Shower For OpenCode

Use this repository as a read-only website maintenance audit workflow.

Load these files as needed:

- `SKILL.md` for the canonical workflow.
- `references/audit-orchestrator.md` for multi-module coordination.
- `references/audit-heuristics.md` for signal vs noise.
- `references/placement-rules.md` for inline/local/global/shared placement.
- `references/unused-code.md` for unused-code leads.
- `references/typescript-hygiene.md` for checker and TypeScript hygiene leads.
- `references/react-next-habits.md` for React and Next.js habit leads.
- `references/report-format.md` for output shape.

When shell access is available, run:

```bash
scripts/scan-website-shower.sh <target>
```

For monorepos, scan the root only for orientation, then scan one app/package/domain.

Do not edit the audited repo unless the user explicitly asks for fixes. Scanner output is candidate evidence only; confirm ownership, shape, usage, framework rules, and validation before reporting a checklist task.
