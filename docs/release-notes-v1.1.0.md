# v1.1.0 Release Notes

Website Shower v1.1.0 sharpens the audit workflow without changing the read-only default.

## Added

- Website map-first audit step.
- `scripts/scan-website-map.sh` for app roots, routes, feature roots, API/data boundaries, tests, generated output, packages, and checker signals.
- Required inspected-scope section in reports.
- Optional `website-shower-report.json` shape for host tools and later reruns.
- Lightweight lifecycle guidance for `open`, `accepted`, `fixed`, `ignored`, and `false-positive` tasks.
- Boundary markers such as `client-server`, `external-api`, `package-boundary`, `state-store`, `generated-code`, `env-config`, `auth-session`, `database`, `framework-entrypoint`, and `design-system`.
- Codex plugin marketplace metadata under `.codex-plugin/`.
- Codex marketplace manifest under `.agents/plugins/marketplace.json`.
- Plugin skill entry point under `skills/website-shower/`.
- `scripts/uninstall-agent.sh` for local adapter cleanup.

## Kept

- Markdown checklist remains the default report.
- Source/config files remain read-only unless the user explicitly asks for fixes.
- Scanner output remains candidate evidence, not automatic findings.
