# v0.1.0 Release Notes

Initial release of `types-constants-audit`.

## Included

- Codex skill for read-only TypeScript type and constant audits.
- Bash scanner for candidate type/constant files, repeated literals, literal unions, repeated type/interface names, large files, and exported constants to usage-check.
- Placement rules for inline, feature-local, app-global, and shared contracts.
- Signal/noise heuristics for monorepos, generated files, repeated primitives, and local prop/state names.
- Report format guidance.
- Anonymous fixture and smoke test.
- Example before/after audit report.
- Agent compatibility files for Codex, OpenCode, OpenClaw, Copilot, Cursor, Windsurf, Cline, Kiro, `.agents`, and `AGENTS.md` consumers.

## Validation

- Fixture validation produced 5 findings/leads without editing files.
- Installed Codex skill validation on a feature-oriented TypeScript website produced 4 useful read-only findings.
- Tested previously on a clean Next.js app, a feature-heavy React app, and a large monorepo during development.
- `npm test` passes.

## Boundaries

- The scanner prints candidates only; agents must inspect usage before reporting findings.
- The default workflow is read-only.
- Same literal values can still need separate owner constants when database enums, tables, or lifecycle ownership differ.
- Phase-two website maintenance audits are intentionally out of scope for this release.

## Install

```bash
git clone https://github.com/Talibabtou/types-constants-audit.git ~/.codex/skills/types-constants-audit
```
