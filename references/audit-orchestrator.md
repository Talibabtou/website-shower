# Audit Orchestrator

Website Shower is a read-only multi-audit workflow for website repositories.

The intended flow:

```text
multi-audit -> TODO report -> human permission -> cleanup work
```

## Current Modules

1. Types and constants ownership
   - Script: `scripts/scan-types-constants.sh`
   - Reference: `references/placement-rules.md`, `references/audit-heuristics.md`

2. Unused code and stale exports
   - Script: `scripts/scan-unused-code.sh`
   - Reference: `references/unused-code.md`
   - Tool: repo-local/global `fallow` when available, optional `npx`, basic `rg` fallback otherwise

3. Orchestrated candidate scan
   - Script: `scripts/scan-website-shower.sh`
   - Purpose: run module scanners and collect read-only candidate evidence.

## Report Contract

The final report must be a Markdown checklist that can be read by a human or another agent.

Each task must include:

- stable ID, such as `WS-001`
- module, such as `types-constants` or `unused-code`
- task title
- confidence
- exact file paths, preferably line numbers
- reason
- safe action
- required validation
- permission status

Example:

```md
- [ ] WS-001 `WorkItem` duplicated between worker and hook
  Module: types-constants
  Confidence: high
  Files:
  - `src/workers/example.worker.ts:12`
  - `src/features/example/useExample.ts:8`
  Safe action:
  Move the message contract to `src/workers/example-model.ts` and import it from both sides.
  Permission: required
```

## Rules

- Scanner output is candidate evidence, not a cleanup plan.
- No cleanup task is release-quality without concrete file paths.
- Prefer small, reversible tasks.
- Do not edit audited repos unless the user explicitly approves the task or asks for fixes.
- Do not mix unrelated modules in one task.
