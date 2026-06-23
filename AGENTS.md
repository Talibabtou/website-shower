# Types Constants Audit

Use this repo as a read-only audit skill for TypeScript type and constant organization.

When auditing a target repo:

1. Read `SKILL.md` first.
2. Run `scripts/scan-types-constants.sh <target>` when shell access is available.
3. For monorepos, scan the root only for orientation, then scan one app/package/domain.
4. Use `references/placement-rules.md`, `references/audit-heuristics.md`, and `references/report-format.md` before reporting findings.
5. Do not edit the audited repo unless the user explicitly asks for fixes.

Scanner output is candidate evidence only. Confirm ownership, shape, and usage before calling anything a finding.
