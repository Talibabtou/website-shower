---
name: website-shower
description: Read-only Website Shower audit for website repo hygiene, cleanup leads, and approval-ready checklist tasks.
---

# Website Shower

Use this skill to audit website maintenance issues without modifying audited source/config files.

If the repository checkout includes the root skill files, read:

- `SKILL.md`
- `references/audit-orchestrator.md`
- `references/audit-heuristics.md`
- `references/placement-rules.md`
- `references/report-format.md`
- the module reference for the section being judged

When shell access is available, run:

```bash
scripts/scan-website-shower.sh <target>
```

For monorepos, scan the root only for orientation, then scan one app/package/domain.

Write `website-shower-report.md` when file writes are available; otherwise return the same report in chat. Report checklist tasks only after confirming shape, ownership, usage, framework rules, and validation. Use module headings, `Evidence`, and `Change risk`. Do not edit audited source/config files unless the user explicitly asks for fixes.
