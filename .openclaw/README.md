# OpenClaw Adapter

OpenClaw-style skill systems expect skills under `.openclaw/skills/<skill-name>/` or a user-level skills directory.

This repo provides a Website Shower adapter at the current compatibility path:

```text
.openclaw/skills/types-constants-audit/SKILL.md
```

That file is a thin OpenClaw-facing adapter for the broader Website Shower workflow. The canonical skill remains the root `SKILL.md`.

Safety note: this is a read-only audit skill. Do not grant write permissions unless you explicitly want an agent to apply follow-up fixes after reviewing the audit.
