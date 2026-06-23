# Agent Portability

Website Shower is an instruction-first skill distribution. The canonical behavior lives in `SKILL.md`; host-specific files are thin adapters that make the same read-only audit workflow easy to load in different agents.

## Supported Adapters

| Host | Files | Notes |
| --- | --- | --- |
| Codex skill | `SKILL.md`, `agents/openai.yaml`, `references/`, `scripts/` | Run `scripts/install-agent.sh codex` or clone into `~/.codex/skills/types-constants-audit` until the compatibility path is renamed. |
| Codex / CodeWhale style agents | `AGENTS.md` | Run `scripts/install-agent.sh agents <project>`. |
| OpenCode | `opencode.json`, `.opencode/instructions/types-constants-audit.md` | Run `scripts/install-agent.sh opencode <project>`. The file path is still the compatibility name. |
| OpenClaw | `.openclaw/skills/types-constants-audit/SKILL.md` | Run `scripts/install-agent.sh openclaw`. The root `SKILL.md` remains canonical for this repo. |
| GitHub Copilot | `.github/copilot-instructions.md` | Run `scripts/install-agent.sh copilot <project>`. |
| Cursor | `.cursor/rules/types-constants-audit.mdc` | Run `scripts/install-agent.sh cursor <project>`. |
| Windsurf | `.windsurf/rules/types-constants-audit.md` | Run `scripts/install-agent.sh windsurf <project>`. |
| Cline | `.clinerules/types-constants-audit.md` | Run `scripts/install-agent.sh cline <project>`. |
| Kiro | `.kiro/steering/types-constants-audit.md` | Run `scripts/install-agent.sh kiro <project>`. |
| Generic agents | `SKILL.md` or `AGENTS.md` | Copy the compact rule file or load the full skill. |

## Installer

From a checkout of this repo:

```bash
scripts/install-agent.sh --help
```

The installer copies project-local instruction adapters into a target project. For Codex it links this repo into the local skill directory. For OpenClaw it copies the OpenClaw skill package into `~/.openclaw/skills/`.

## Adapter Rule

Keep adapters thin. If a host supports skills, point it at `SKILL.md`, `references/`, and `scripts/`. If a host only supports project instructions, keep its copied rule text aligned with `AGENTS.md`.

Do not duplicate detailed module rules in every adapter. Detailed guidance belongs in:

- `references/audit-heuristics.md`
- `references/placement-rules.md`
- `references/report-format.md`
- `references/unused-code.md`
- `references/typescript-hygiene.md`
- `references/react-next-habits.md`

## Release Rule

Update `package.json` version and tag the repo when behavior changes are ready to publish. Patch versions are for documentation, compatibility adapters, and scanner bug fixes. Minor versions are for new audit capabilities.

## Commands

OpenCode supports project commands under `.opencode/command/`. This repo does not ship commands yet because Website Shower still has one primary workflow. Add commands when separate audit modes need direct entry points.
