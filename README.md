# Website Shower

Read-only website cleanup audits for agents that need evidence before edits.

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Works with agents](https://img.shields.io/badge/agents-Codex%20%7C%20OpenCode%20%7C%20OpenClaw%20%7C%20Copilot%20%7C%20Cursor%20%7C%20Windsurf%20%7C%20Cline-lightgrey)

**Website Shower** is a read-only website maintenance audit skill. It starts with repo shape and package ownership, then checks tooling, framework habits, styling, components, API contracts, data fetching, state/domain contracts, naming drift, dependencies, performance, type and constant ownership, and unused-code leads.

The audit helps an agent answer one practical question across the repo:

> What can we clean without changing what the website does?

The skill ships with small Bash scanners so agents can quickly map candidate files and repeated patterns, then use the references to decide what is actually worth reporting.

The workflow is:

```text
Multi Audit -> Checklist Report -> Approval -> Cleanup Work
```

## What It Catches

- unclear app, package, feature, and generated-code boundaries
- duplicated API, state, worker, and event contracts
- repeated literal unions, route literals, cache policies, and query keys
- component, Tailwind, CSS token, data-fetching, and performance cleanup leads
- naming drift for one concept across `status`, `state`, `phase`, `mode`, `kind`, or `type`
- dependency drift, stale exports, misleading barrels, and junk-drawer files

## What It Does Not Do

- It does not edit audited repos by default.
- It does not centralize every repeated string.
- It does not treat scanner output as findings.
- It does not modify example repos during validation.

## Example Report

Full example: [`examples/website-shower-report.md`](examples/website-shower-report.md)

```md
### File Tree Hygiene

- [ ] WS-001 Choose one feature folder convention
  Evidence: medium
  Change risk: medium
  Files:
  - `examples/fixture/src/feature/consumeEvent.ts:1`
  - `examples/fixture/src/features/items/navigation.ts:1`
  Safe action:
  Pick the repo convention before moving files. If `src/features` is the target, migrate one owned slice at a time.
```

## Quick Start

From this repo, gather candidates from all available modules:

```bash
scripts/scan-website-shower.sh /path/to/repo
```

To inspect file-tree hygiene only:

```bash
scripts/scan-file-tree-hygiene.sh /path/to/repo
```

To inspect monorepo ownership only:

```bash
scripts/scan-monorepo-ownership.sh /path/to/repo
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

To inspect Tailwind cleanup leads only:

```bash
scripts/scan-tailwind-cleanup.sh /path/to/repo
```

To inspect component hygiene leads only:

```bash
scripts/scan-component-hygiene.sh /path/to/repo
```

To inspect API contract leads only:

```bash
scripts/scan-api-contracts.sh /path/to/repo
```

To inspect data-fetching hygiene leads only:

```bash
scripts/scan-data-fetching-hygiene.sh /path/to/repo
```

To inspect state and domain contract leads only:

```bash
scripts/scan-state-domain-contracts.sh /path/to/repo
```

To inspect naming drift leads only:

```bash
scripts/scan-naming-drift.sh /path/to/repo
```

To inspect dependency hygiene leads only:

```bash
scripts/scan-dependency-hygiene.sh /path/to/repo
```

To inspect performance hygiene leads only:

```bash
scripts/scan-performance-hygiene.sh /path/to/repo
```

For monorepos, scan the root only for orientation, then narrow the target:

```bash
scripts/scan-website-shower.sh /path/to/repo/apps/web
scripts/scan-website-shower.sh /path/to/repo/packages/domain
```

The scanner depends only on `rg` (`ripgrep`) and respects repo ignore files. If no ignore files exist, it falls back to common generated-folder exclusions.

## Install For Codex

Clone this repo into your Codex skills directory:

```bash
git clone https://github.com/Talibabtou/website-shower.git ~/.codex/skills/website-shower
```

Or, from a checkout of this repo:

```bash
scripts/install-agent.sh codex
```

Then ask:

```text
Audit this website repo with Website Shower. Write `website-shower-report.md` with cleanup tasks, file evidence, change risk, and validation steps. Do not edit source files.
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
- **OpenCode**: use `opencode.json`, which loads `.opencode/instructions/website-shower.md`.
- **OpenClaw**: install `.openclaw/skills/website-shower` as the skill package; see `.openclaw/README.md`.
- **GitHub Copilot**: use `.github/copilot-instructions.md` as the portable instruction entry.
- **Cursor**: use `.cursor/rules/website-shower.mdc`.
- **Windsurf**: use `.windsurf/rules/website-shower.md`.
- **Cline**: use `.clinerules/website-shower.md`.
- **Kiro**: use `.kiro/steering/website-shower.md`.
- **Agents that read `AGENTS.md`**: run from this repo root or copy `AGENTS.md` into the project that should load the audit behavior.
- **Agents that read `.agents/rules/`**: use `.agents/rules/website-shower.md`.
- **Any shell-capable agent**: run `scripts/scan-website-shower.sh` and then inspect usage manually before reporting.

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
references/api-contracts.md      # API contract hygiene guidance
references/audit-orchestrator.md # multi-module report coordination
references/component-hygiene.md  # component hygiene guidance
references/data-fetching-hygiene.md # data-fetching hygiene guidance
references/dependency-hygiene.md # package dependency hygiene guidance
references/file-tree-hygiene.md  # repo shape and ownership-boundary guidance
references/monorepo-ownership.md # workspace and package ownership guidance
references/naming-drift.md       # domain vocabulary drift guidance
references/performance-hygiene.md # performance lead guidance
references/placement-rules.md    # inline/local/global/shared decision rules
references/report-format.md      # finding and checklist format guidance
references/react-next-habits.md  # React and Next.js habit guidance
references/state-domain-contracts.md # state and domain contract guidance
references/tailwind-cleanup.md   # Tailwind cleanup guidance
references/typescript-hygiene.md # TypeScript migration and escape-hatch guidance
references/unused-code.md        # fallow-backed unused-code audit guidance
scripts/scan-file-tree-hygiene.sh # repo shape candidate scanner
scripts/scan-monorepo-ownership.sh # monorepo ownership candidate scanner
scripts/scan-naming-drift.sh     # naming drift candidate scanner
scripts/scan-types-constants.sh # type and constant candidate scanner
scripts/scan-api-contracts.sh    # API contract candidate scanner
scripts/scan-component-hygiene.sh # component candidate scanner
scripts/scan-data-fetching-hygiene.sh # data-fetching candidate scanner
scripts/scan-dependency-hygiene.sh # dependency candidate scanner
scripts/scan-performance-hygiene.sh # performance candidate scanner
scripts/scan-react-next-habits.sh # React and Next.js candidate scanner
scripts/scan-state-domain-contracts.sh # state and domain candidate scanner
scripts/scan-tailwind-cleanup.sh # Tailwind cleanup candidate scanner
scripts/scan-unused-code.sh      # fallow-backed unused-code candidate scanner
scripts/scan-typescript-hygiene.sh # TypeScript hygiene candidate scanner
scripts/scan-website-shower.sh   # read-only multi-module scanner
scripts/install-agent.sh         # copies/links agent adapters
scripts/sync-agent-adapters.sh   # syncs generated project-rule adapters
scripts/README.md                # script order and module notes
tests/smoke-test.sh              # fixture regression check
examples/fixture/                # anonymous scanner fixture
examples/website-shower-report.md # example checklist report
adapters/website-shower-rule.md  # canonical compact adapter rule
docs/agent-portability.md        # compatibility notes
docs/release-notes-v1.0.0.md     # release notes
```

## Development

Run the smoke test after changing the scanner or fixture:

```bash
npm test
```

The v1.0.0 quality bar is a grouped report artifact, generated without source edits, that a human or agent can use for approved cleanup work.

Custom command folders are intentionally not shipped yet. The current skill has one primary action, so `SKILL.md` plus the scanner is clearer. Commands become useful when there are distinct workflows like `/audit-types`, `/audit-tailwind`, `/audit-unused`, or `/audit-next-habits`.

## Release

This repo uses semantic versions in `package.json`.

- Patch: documentation, adapter, and scanner bug fixes.
- Minor: new audit capability.
- Major: behavior or report format changes that break existing workflows.

Release by updating `package.json`, tagging `vX.Y.Z`, and publishing GitHub release notes with the tested agent adapters.
