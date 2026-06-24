# v1.0.0 Release Notes

First full Website Shower release.

## Included

- Read-only website maintenance skill for agents.
- Multi-module scanner that gathers candidate evidence before judgment.
- Modules for file tree hygiene, monorepo ownership, TypeScript hygiene, React/Next habits, Tailwind/CSS cleanup, component hygiene, API contracts, data fetching, state/domain contracts, naming drift, dependency hygiene, performance, types/constants, and unused-code leads.
- Checklist report format for human or agent follow-up.
- Anonymous fixture and smoke test.
- Canonical compact adapter rule with generated agent adapters.
- Agent support for Codex, OpenCode, OpenClaw, Copilot, Cursor, Windsurf, Cline, Kiro, `.agents`, and `AGENTS.md` consumers.

## Validation

- Fixture scan produces a full Website Shower checklist report without editing files.
- `npm test` checks scanner syntax, adapter sync, and fixture smoke output.
- Real-repo validation has been tested during development on clean, complex, and monorepo website repos.

## Boundaries

- Scanner output is candidate evidence only.
- The default workflow is read-only.
- Reports must include file evidence, change risk, and validation steps before edits.
- Same literal values can still need separate owner constants when database enums, tables, or lifecycle ownership differs.

## Install

```bash
git clone https://github.com/Talibabtou/website-shower.git ~/.codex/skills/website-shower
```

From a checkout:

```bash
scripts/install-agent.sh codex
scripts/install-agent.sh all-local /path/to/project
```
