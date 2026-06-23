---
name: types-constants-audit
description: Read-only Website Shower audit for website repo hygiene, including type and constant drift, unused-code leads, TypeScript hygiene, React/Next.js habits, stale exports, and cleanup checklist tasks.
---

# Website Shower

Use this skill to audit website maintenance issues without modifying the target repository.

If the repository checkout includes the root skill files, read:

- `SKILL.md`
- `references/audit-orchestrator.md`
- `references/audit-heuristics.md`
- `references/placement-rules.md`
- `references/report-format.md`
- `references/unused-code.md`
- `references/typescript-hygiene.md`
- `references/react-next-habits.md`

When shell access is available, run:

```bash
scripts/scan-website-shower.sh <target>
```

For monorepos, scan the root only for orientation, then scan one app/package/domain.

Report checklist tasks only after confirming shape, ownership, usage, framework rules, and validation. Do not edit audited files unless the user explicitly asks for fixes.
