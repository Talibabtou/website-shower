# Website Shower

Read-only website cleanup audits for agents that need evidence before edits.

![Version](https://img.shields.io/badge/version-0.1.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Works with agents](https://img.shields.io/badge/agents-Codex%20%7C%20OpenCode%20%7C%20OpenClaw%20%7C%20Copilot%20%7C%20Cursor%20%7C%20Windsurf%20%7C%20Cline-lightgrey)

**Website Shower** is a read-only website maintenance audit skill. The first stable module audits where types, literal unions, enum-like values, constants, and magic values live in a web repo. The next modules add unused-code leads and TypeScript hygiene signals.

The type and constants module helps an agent answer one practical question:

> Should this contract be inline, feature-local, app-global, shared, or deleted?

The skill ships with a small Bash scanner so agents can quickly map candidate files and repeated patterns, then use the references to decide what is actually worth reporting.

The workflow is:

```text
Multi Audit -> TODO Report -> Human Permission -> Cleanup Work
```

## What It Catches

- duplicated `Status`, `Role`, `Kind`, `Variant`, `Mode`, and event contracts
- repeated literal unions that drift across hooks, stores, services, and UI
- raw strings used even though an owning constant or union already exists
- stale exports and misleading barrels
- junk-drawer `types.ts` or `constants.ts` files
- feature-owned values promoted too high
- fake reuse where an inline literal is clearer

## What It Does Not Do

- It does not edit audited repos by default.
- It does not centralize every repeated string.
- It does not treat scanner output as findings.
- It does not modify example repos during validation.

## Example Report

Full example: [`examples/website-shower-report.md`](examples/website-shower-report.md)

```md
- [ ] WS-001 Deduplicate `WorkItem`
  Module: types-constants
  Confidence: high
  Files:
  - `examples/fixture/src/state/contracts.ts:11`
  - `examples/fixture/src/state/feature/workSlice.ts:3`
  Safe action:
  Keep `WorkItem` in `src/state/contracts.ts`, import it in `workSlice.ts`, and remove the local interface.
  Permission: required
```

## Quick Start

From this repo:

```bash
scripts/scan-types-constants.sh /path/to/repo
```

To gather candidates from all currently available modules:

```bash
scripts/scan-website-shower.sh /path/to/repo
```

The unused-code module first looks for `fallow` in the audited repo's `node_modules/.bin`, then for a globally available `fallow`. If unavailable, it falls back to a simpler `rg` scan for exported symbols to usage-check. To allow `npx` resolution, run:

```bash
FALLOW_USE_NPX=1 scripts/scan-unused-code.sh /path/to/repo
```

To inspect TypeScript migration and escape-hatch leads only:

```bash
scripts/scan-typescript-hygiene.sh /path/to/repo
```

To inspect React and Next.js habit leads only:

```bash
scripts/scan-react-next-habits.sh /path/to/repo
```

For monorepos, scan the root only for orientation, then narrow the target:

```bash
scripts/scan-types-constants.sh /path/to/repo/apps/web
scripts/scan-types-constants.sh /path/to/repo/packages/domain
```

The scanner depends only on `rg` (`ripgrep`) and respects repo ignore files. If no ignore files exist, it falls back to common generated-folder exclusions.

## Install For Codex

Clone this repo into your Codex skills directory:

```bash
git clone https://github.com/Talibabtou/types-constants-audit.git ~/.codex/skills/types-constants-audit
```

Or, from a checkout of this repo:

```bash
scripts/install-agent.sh codex
```

Then ask:

```text
Audit this repo for duplicated types, scattered constants, magic literals, stale exports, and bad global/local placement. Produce findings only; do not edit files.
```

## Install For Other Agents

From a checkout of this repo:

```bash
# Project-local adapters
scripts/install-agent.sh cursor /path/to/project
scripts/install-agent.sh windsurf /path/to/project
scripts/install-agent.sh cline /path/to/project
scripts/install-agent.sh kiro /path/to/project
scripts/install-agent.sh copilot /path/to/project
scripts/install-agent.sh agents /path/to/project
scripts/install-agent.sh opencode /path/to/project

# Skill-directory adapter
scripts/install-agent.sh openclaw

# Copy all project-local instruction adapters
scripts/install-agent.sh all-local /path/to/project
```

Until this repo has marketplace/plugin distribution, the installer copies or links the instruction files each host already understands. See `docs/agent-portability.md` for the file map.

## Other Agents

This repo is instruction-first, so it also works in agents that can read Markdown rules.

- **Claude**: paste or attach `SKILL.md`; include `references/` when the audit needs stronger placement judgment.
- **OpenCode**: use `opencode.json`, which loads `.opencode/instructions/types-constants-audit.md`.
- **OpenClaw**: install `.openclaw/skills/types-constants-audit` as the skill package; see `.openclaw/README.md`.
- **GitHub Copilot**: use `.github/copilot-instructions.md` as the portable instruction entry.
- **Cursor**: use `.cursor/rules/types-constants-audit.mdc`.
- **Windsurf**: use `.windsurf/rules/types-constants-audit.md`.
- **Cline**: use `.clinerules/types-constants-audit.md`.
- **Kiro**: use `.kiro/steering/types-constants-audit.md`.
- **Agents that read `AGENTS.md`**: run from this repo root or copy `AGENTS.md` into the project that should load the audit behavior.
- **Agents that read `.agents/rules/`**: use `.agents/rules/types-constants-audit.md`.
- **Any shell-capable agent**: run `scripts/scan-types-constants.sh` and then inspect usage manually before reporting.

See `docs/agent-portability.md` for the adapter map.

## Repo Layout

```text
SKILL.md                         # Codex skill entry point
agents/openai.yaml               # Codex UI metadata
AGENTS.md                        # portable root instructions
opencode.json                    # OpenCode project config
.opencode/                       # OpenCode instructions and future commands
.openclaw/skills/                # OpenClaw skill package
.github/copilot-instructions.md  # GitHub Copilot instructions
.cursor/rules/                   # Cursor project rule
.windsurf/rules/                 # Windsurf project rule
.clinerules/                     # Cline project rule
.kiro/steering/                  # Kiro steering rule
.agents/rules/                   # generic agent rule
references/audit-heuristics.md   # signal vs noise rules
references/audit-orchestrator.md # multi-module report coordination
references/placement-rules.md    # inline/local/global/shared decision rules
references/report-format.md      # finding and checklist format guidance
references/react-next-habits.md  # React and Next.js habit guidance
references/typescript-hygiene.md # TypeScript migration and escape-hatch guidance
references/unused-code.md        # fallow-backed unused-code audit guidance
scripts/scan-types-constants.sh  # read-only scanner
scripts/scan-react-next-habits.sh # React and Next.js candidate scanner
scripts/scan-unused-code.sh      # fallow-backed unused-code candidate scanner
scripts/scan-typescript-hygiene.sh # TypeScript hygiene candidate scanner
scripts/scan-website-shower.sh   # read-only multi-module scanner
scripts/install-agent.sh         # copies/links agent adapters
tests/smoke-test.sh              # fixture regression check
examples/fixture/                # anonymous scanner fixture
examples/website-shower-report.md # example checklist report
docs/agent-portability.md        # compatibility notes
docs/real-repo-validation-checklist.md # release feedback checklist
```

## Development

Run the smoke test after changing the scanner or fixture:

```bash
npm test
```

The next quality bar is validating the multi-module checklist report on real repos without changing audited files.

Custom command folders are intentionally not shipped yet. The current skill has one primary action, so `SKILL.md` plus the scanner is clearer. Commands become useful in phase two when there are distinct workflows like `/audit-types`, `/audit-tailwind`, `/audit-unused`, or `/audit-next-habits`.

## Release

This repo uses semantic versions in `package.json`.

- Patch: documentation, adapter, and scanner bug fixes.
- Minor: new audit capability.
- Major: behavior or report format changes that break existing workflows.

Release by updating `package.json`, tagging `vX.Y.Z`, and publishing GitHub release notes with the tested agent adapters.
