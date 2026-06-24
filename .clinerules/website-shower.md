# Website Shower

Use this rule when auditing website repo hygiene with Website Shower: file tree shape, monorepo ownership, TypeScript/checker setup, React/Next habits, Tailwind/CSS cleanup, components, API/data contracts, state/domain contracts, naming drift, dependencies, performance, types/constants, and unused-code leads.

Default behavior is read-only for source files. Write `website-shower-report.md` when file writes are available; otherwise return the same report in chat. Do not edit audited source/config files unless explicitly asked.

Workflow:

1. Read `SKILL.md` if available.
2. Run `scripts/scan-website-shower.sh <target>` if shell access is available.
3. For monorepos, scan the root only for orientation, then scan one app/package/domain.
4. Load `references/audit-orchestrator.md`, then only the needed module references.
5. Format cleanup tasks using `references/report-format.md`: group by module heading, use `Evidence` and `Change risk`, include commands used, and include ignored leads when the scan is noisy.

Scanner output is candidate evidence only. Confirm ownership, usage, framework rules, and validation before reporting a task.
