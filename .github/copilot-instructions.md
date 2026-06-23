# Website Shower

This repository defines a read-only website maintenance audit skill.

Default behavior is read-only. Produce a checklist report; do not edit audited repos unless explicitly asked.

Use this order:

1. Read `SKILL.md`.
2. Run `scripts/scan-website-shower.sh <target>` if shell access is available.
3. Narrow monorepo audits to one app/package/domain after the root orientation scan.
4. Load only the needed module references.
5. Format cleanup tasks using `references/report-format.md`.

Scanner output is candidate evidence only. Confirm ownership, usage, framework rules, and validation before reporting a task.
