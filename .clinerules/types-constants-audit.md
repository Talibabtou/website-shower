# Website Shower

Use this rule when auditing website repo hygiene: type and constant ownership, unused-code leads, TypeScript escape hatches, React/Next.js habit drift, stale exports, and cleanup tasks.

Default behavior is read-only. Produce a checklist report; do not edit audited repos unless explicitly asked.

Workflow:

1. Read `SKILL.md` if available.
2. Run `scripts/scan-website-shower.sh <target>` if shell access is available.
3. For monorepos, scan the root only for orientation, then scan one app/package/domain.
4. Load only the needed references for the module being judged.
5. Format cleanup tasks using `references/report-format.md`.

Scanner output is candidate evidence only. Confirm ownership, usage, framework rules, and validation before reporting a task.
