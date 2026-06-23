# Types Constants Audit

This repository defines an audit skill for TypeScript type and constant organization.

Default behavior is read-only. Produce findings and recommendations; do not edit audited repos unless explicitly asked.

Use this order:

1. Read `SKILL.md`.
2. Run `scripts/scan-types-constants.sh <target>` if shell access is available.
3. Narrow monorepo audits to one app/package/domain after the root orientation scan.
4. Apply `references/placement-rules.md` for placement decisions.
5. Apply `references/audit-heuristics.md` to separate signal from noise.
6. Format findings using `references/report-format.md`.

Treat repeated names, literals, and primitive values as leads, not findings. Confirm shape, ownership, and usage before recommending movement.
