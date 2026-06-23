# Website Shower

Use this repo as a read-only website maintenance audit skill.

When auditing a target repo:

1. Read `SKILL.md` first.
2. Run `scripts/scan-website-shower.sh <target>` when shell access is available.
3. For monorepos, scan the root only for orientation, then scan one app/package/domain.
4. Load only the needed module references:
   - `references/placement-rules.md`
   - `references/audit-heuristics.md`
   - `references/unused-code.md`
   - `references/typescript-hygiene.md`
   - `references/react-next-habits.md`
   - `references/report-format.md`
5. Do not edit the audited repo unless the user explicitly asks for fixes.

Scanner output is candidate evidence only. Convert it into a checklist report with concrete paths, confidence, validation, and permission status before calling anything a cleanup task.
