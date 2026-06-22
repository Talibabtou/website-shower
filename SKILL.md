---
name: types-constants-audit
description: Audit and organize TypeScript type files, constant files, literal unions, enum-like objects, magic strings/numbers, and stale exports in web repos. Use when asked to audit types and constants, clean magic values, organize types.ts or constants.ts, decide whether a type or constant should be global, find duplicated enums/statuses/roles/kinds/variants, split junk-drawer files, or review shared vs feature-local placement.
---

# Types Constants Audit

Use this skill to produce a repo-grounded audit report. Default to read-only inspection: do not edit files unless the user explicitly asks for fixes.

## Workflow

1. Read repo shape first:
   - package manager and framework
   - `src/`, `app/`, `pages/`, `features/`, `domains/`, `packages/`
   - existing naming style for types, constants, enums, and barrels
2. Find candidates with `scripts/scan-types-constants.sh` when it exists, or with `rg` manually.

```bash
scripts/scan-types-constants.sh .
```

When running manual searches, let `rg` honor the repo's `.gitignore` first. If the repo has no `.gitignore`, add fallback exclusions for common generated and dependency folders:

```bash
--glob '!node_modules/**' --glob '!.git/**' --glob '!.next/**' --glob '!.turbo/**' --glob '!.vercel/**' --glob '!dist/**' --glob '!build/**' --glob '!coverage/**'
```

Manual candidate searches:

```bash
rg --files | rg '(^|/)(types|constants|contracts|enums|status|statuses|roles|variants|config)\.(ts|tsx)$'
rg "type [A-Za-z0-9_]+\\s*=" .
rg "interface [A-Za-z0-9_]+" .
rg "as const" .
rg "const [A-Z0-9_]+\\s*=" .
rg "'(draft|published|pending|queued|done|approved|rejected|active|inactive|failed|admin|moderator|user|owner|viewer|editor|success|error|warning|info)'" .
```

3. For each candidate, inspect usage before recommending movement:

```bash
rg "\\bSymbolName\\b" .
rg "from ['\"].*(types|constants|enums)" .
```

4. Classify each issue:
   - duplicated type shape
   - duplicated literal union
   - repeated magic string or number
   - junk-drawer file
   - stale export
   - fake reuse that should stay inline
   - constant that hurts readability
   - drifted local contract that should use an existing owner
5. Apply placement rules from `references/placement-rules.md` when the location is not obvious.
6. Format findings with `references/report-format.md`.

## Core Judgment

Global only after two unrelated features need it.

Feature-local when one product area owns it.

Inline when used once, fake-reused, or clearer as a literal.

Delete stale exports before moving code.

Do not turn readable literals into named constants just to remove all strings. `aria-label="Close"`, `type="button"`, route segment names, HTTP method strings, and test names often read better inline.

Repeated names are leads, not findings. `Props`, CVA `default` variants, JSX labels, and local UI option strings can be legitimate. Confirm drift by checking shape, ownership, and usage.

## What To Report

Prioritize findings that reduce confusion:
- same concept named differently in unrelated files
- same literal union repeated across features
- shared `types.ts` or `constants.ts` exporting unrelated things
- constants imported far from their owner
- exported symbols with no runtime or type usage
- values promoted to global before real shared ownership exists
- store-derived types duplicated by hand-written aliases or interfaces
- event payload contracts duplicated between hooks, slices, and services
- repeated status/team/result unions that cross Redux, hooks, and UI

Skip low-value noise:
- one-off JSX labels
- test fixture strings
- values dictated by external APIs, unless duplicated wrappers drift
- CSS class names in components using utility CSS
- tiny local aliases that improve a gnarly signature

## Report Style

Lead with findings. Keep summary short.

Each finding must include:
- symbol or literal
- current file(s)
- recommended action
- reason
- confidence

Use exact file paths and line numbers when available.

When unsure, say what evidence is missing instead of guessing.

## Edit Mode

If the user asks for edits:
- make the smallest safe move
- update imports
- delete stale exports
- run the repo's typecheck or smallest relevant check
- avoid broad folder rewrites

Do not introduce a new shared file if an existing local owner is clearer.

## Skill Test Fixture

Use `examples/fixture` for scanner smoke testing only. It intentionally uses anonymous names and includes duplicated state types, repeated status/side unions, duplicated event contracts, duplicated local data, and one benign UI `default` literal.

```bash
scripts/smoke-test.sh
```
