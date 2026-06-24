# Website Shower

Read-only website cleanup audits for agents that need evidence before edits.

![Version](https://img.shields.io/badge/version-1.1.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Works with agents](https://img.shields.io/badge/agents-Codex%20%7C%20OpenCode%20%7C%20OpenClaw%20%7C%20Copilot%20%7C%20Cursor%20%7C%20Windsurf%20%7C%20Cline-lightgrey)

**Website Shower** is a read-only website maintenance audit skill. It starts with a website map and inspected scope, then checks repo shape, package ownership, tooling, framework habits, styling, components, API contracts, data fetching, state/domain contracts, naming drift, dependencies, performance, type and constant ownership, and unused-code leads.

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
- risky boundaries such as client/server, external API, package, state-store, generated-code, env, auth, database, and design-system ownership

## What It Does Not Do

- It does not edit audited repos by default.
- It does not centralize every repeated string.
- It does not treat scanner output as findings.
- It does not modify example repos during validation.

## Example Report

Full example: [`examples/website-shower-report.md`](examples/website-shower-report.md)

```md
Inspected scope:
- App roots/routes: `examples/fixture/src/app`
- API/data boundaries: `examples/fixture/src/app/api`, `examples/fixture/src/features/items`

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

## Install

The target install path is the Codex plugin marketplace. Until the public repo is pushed with the marketplace manifest, use the manual fallback.

### Codex

```bash
codex plugin marketplace add Talibabtou/website-shower
codex
```

Then open `/plugins`, select the Website Shower marketplace, and install Website Shower.

This same install should cover the Codex desktop app after restart.

Manual fallback:

```bash
git clone https://github.com/Talibabtou/website-shower.git ~/.codex/skills/website-shower
```

From an existing checkout:

```bash
scripts/install-agent.sh codex
```

Then ask:

```text
Audit this website repo with Website Shower. Write `website-shower-report.md` with cleanup tasks, file evidence, change risk, and validation steps. Do not edit source files.
```

### OpenCode

Current supported path:

```bash
scripts/install-agent.sh opencode /path/to/project
```

This copies `opencode.json` and `.opencode/` instructions into the target project.

### OpenClaw

After ClawHub publication:

```bash
clawhub install website-shower
```

Manual fallback:

```bash
scripts/install-agent.sh openclaw
```

This copies `.openclaw/skills/website-shower` into `~/.openclaw/skills/`.

### Cursor, Windsurf, Cline, Kiro, Copilot, And Generic Agents

From a checkout of this repo:

```bash
scripts/install-agent.sh cursor /path/to/project
scripts/install-agent.sh windsurf /path/to/project
scripts/install-agent.sh cline /path/to/project
scripts/install-agent.sh kiro /path/to/project
scripts/install-agent.sh copilot /path/to/project
scripts/install-agent.sh agents /path/to/project
scripts/install-agent.sh all-local /path/to/project
```

The installer copies or links the instruction files each host already understands. See `docs/agent-portability.md` for the file map.

### Other Agents

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

## Uninstall

| Host | Command |
| --- | --- |
| Codex plugin | `codex plugin remove website-shower` |
| Codex manual skill | `scripts/uninstall-agent.sh codex` |
| OpenClaw manual skill | `scripts/uninstall-agent.sh openclaw` |
| OpenCode local adapter | `scripts/uninstall-agent.sh opencode /path/to/project` |
| Cursor / Windsurf / Cline / Kiro / Copilot | Delete the copied rule file, or run the matching `scripts/uninstall-agent.sh <agent> /path/to/project` command. |
| All local adapters | `scripts/uninstall-agent.sh all-local /path/to/project` |

Website Shower does not write mode flags, hooks, config files, or background state. Removing the installed plugin, skill link, or copied rule file is enough.

## Repo Layout

```text
.
├── SKILL.md                    # Codex skill entry point
├── README.md                   # install and usage guide
├── AGENTS.md                   # portable root instructions
├── agents/openai.yaml          # Codex UI metadata
├── .codex-plugin/              # Codex plugin marketplace metadata
├── skills/website-shower/      # plugin skill entry point
├── references/                 # audit judgment rules, one file per module
│   ├── audit-orchestrator.md
│   ├── website-map.md
│   ├── report-format.md
│   └── placement-rules.md
├── scripts/                    # read-only scanners and installers
│   ├── scan-website-shower.sh  # global multi-module scan
│   ├── scan-*.sh               # focused module scans
│   ├── install-agent.sh
│   └── README.md               # scan order and module notes
├── examples/
│   ├── fixture/                # anonymous regression fixture
│   └── website-shower-report.md
├── tests/smoke-test.sh         # fixture regression check
├── adapters/                   # canonical generated adapter source
├── docs/                       # portability and release notes
├── .opencode/                  # OpenCode adapter
├── .openclaw/skills/           # OpenClaw skill package
└── .cursor/, .windsurf/, .clinerules/, .kiro/, .agents/, .github/
```

## Development

Run the smoke test after changing the scanner or fixture:

```bash
npm test
```

The v1.1.0 quality bar is a mapped, grouped report artifact, generated without source edits, that a human or agent can use for approved cleanup work.

Custom command folders are intentionally not shipped yet. The current skill has one primary action, so `SKILL.md` plus the scanner is clearer. Commands become useful when there are distinct workflows like `/audit-types`, `/audit-tailwind`, `/audit-unused`, or `/audit-next-habits`.

## Release

This repo uses semantic versions in `package.json`.

- Patch: documentation, adapter, and scanner bug fixes.
- Minor: new audit capability.
- Major: behavior or report format changes that break existing workflows.

Release by updating `package.json`, tagging `vX.Y.Z`, and publishing GitHub release notes with the tested agent adapters.
