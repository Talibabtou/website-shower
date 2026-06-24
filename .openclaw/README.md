# OpenClaw Adapter

OpenClaw-style skill systems expect skills under `.openclaw/skills/<skill-name>/` or a user-level skills directory.

This repo provides a Website Shower adapter at:

```text
.openclaw/skills/website-shower/SKILL.md
```

That file is a thin OpenClaw-facing adapter for the broader Website Shower workflow. The canonical skill remains the root `SKILL.md`.

Safety note: this is read-only for audited source/config files. It may write `website-shower-report.md` as the audit artifact. Do not grant broader write permissions unless you want an agent to apply follow-up fixes after reviewing the audit.
