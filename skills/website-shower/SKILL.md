---
name: website-shower
description: Read-only website maintenance audit. Creates a cleanup checklist for repo shape, TypeScript, React/Next, Tailwind/CSS, API/data, state/domain, dependencies, performance, duplicated types/constants, and unused-code leads.
---

# Website Shower

This is the plugin skill entry point. The canonical skill lives at the repository root in `../../SKILL.md`.

When this skill is loaded from a plugin install:

1. Read `../../SKILL.md`.
2. Use `../../references/` for audit judgment.
3. Use `../../scripts/scan-website-shower.sh` when shell access is available.
4. Write `website-shower-report.md` by default.
5. Keep audited source/config files read-only unless the user explicitly asks for fixes.

If relative paths are unavailable in the host agent, use this compact fallback:

Audit website repo hygiene read-only. Build an inspected scope first, run or mimic the Website Shower scanner order, confirm scanner leads against real files, then write `website-shower-report.md` with grouped checklist tasks, file evidence, boundary markers when useful, change risk, safe action, and validation steps.
