# Types Constants Audit

Find TypeScript type and constant drift before it turns into a habit.

`types-constants-audit` is a read-only agent skill for auditing where types, literal unions, enum-like values, constants, and magic values live in a web repo. It helps an agent answer one practical question:

> Should this contract be inline, feature-local, app-global, shared, or deleted?

The skill ships with a small Bash scanner so agents can quickly map candidate files and repeated patterns, then use the references to decide what is actually worth reporting.

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

## Quick Start

From this repo:

```bash
scripts/scan-types-constants.sh /path/to/repo
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

Then ask:

```text
Audit this repo for duplicated types, scattered constants, magic literals, stale exports, and bad global/local placement. Produce findings only; do not edit files.
```

## Other Agents

This repo is instruction-first, so it also works in agents that can read Markdown rules.

- **Claude / Cursor / Windsurf / Cline**: paste or attach `SKILL.md`; include `references/` when the audit needs stronger placement judgment.
- **GitHub Copilot**: use `.github/copilot-instructions.md` as the portable instruction entry.
- **Agents that read `AGENTS.md`**: run from this repo root or copy `AGENTS.md` into the project that should load the audit behavior.
- **Any shell-capable agent**: run `scripts/scan-types-constants.sh` and then inspect usage manually before reporting.

## Repo Layout

```text
SKILL.md                         # Codex skill entry point
agents/openai.yaml               # Codex UI metadata
references/audit-heuristics.md   # signal vs noise rules
references/placement-rules.md    # inline/local/global/shared decision rules
references/report-format.md      # finding format and severity guidance
scripts/scan-types-constants.sh  # read-only scanner
scripts/smoke-test.sh            # fixture regression check
examples/fixture/                # anonymous scanner fixture
```

## Development

Run the smoke test after changing the scanner or fixture:

```bash
bash -n scripts/scan-types-constants.sh
scripts/smoke-test.sh
```

The next quality bar is one anonymized before/after audit report showing how scanner output becomes actual findings.
