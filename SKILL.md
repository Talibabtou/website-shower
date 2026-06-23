---
name: types-constants-audit
description: Audit and organize TypeScript type files, constant files, literal unions, enum-like objects, magic strings/numbers, and stale exports in web repos. Use when asked to audit types and constants, clean magic values, organize types.ts or constants.ts, decide whether a type or constant should be global, find duplicated enums/statuses/roles/kinds/variants, split junk-drawer files, or review shared vs feature-local placement.
---

# Types Constants Audit

Audit TypeScript type and constant organization from repo evidence. Default mode is read-only: produce findings and recommendations, but do not edit files unless the user explicitly asks for fixes.

This skill is the first module of the broader Website Shower workflow. Website Shower coordinates multiple read-only website maintenance audits into a Markdown TODO report. The current stable module is types/constants ownership; unused-code scanning through `fallow` is being introduced as the next module.

## Workflow

1. Read repo shape first: framework, package manager, app/package layout, feature/domain folders, and existing naming style for `types`, `constants`, `enums`, contracts, and barrels.
2. Run the scanner when available:

```bash
scripts/scan-types-constants.sh .
```

For monorepos, treat a root scan as orientation only, then rerun against one owned target:

```bash
scripts/scan-types-constants.sh apps/example-app
scripts/scan-types-constants.sh packages/example-domain
```

3. If the scanner is unavailable, use `rg` manually and let repo ignore files apply first:

```bash
rg --files | rg '(^|/)(types|constants|contracts|enums|status|statuses|roles|variants|config)\.(ts|tsx)$'
rg "type [A-Za-z0-9_]+\\s*=" .
rg "interface [A-Za-z0-9_]+" .
rg "as const" .
rg "const [A-Z0-9_]+\\s*=" .
rg "'(draft|published|pending|queued|done|approved|rejected|active|inactive|failed|admin|moderator|user|owner|viewer|editor|success|error|warning|info)'" .
```

If the repo has no ignore files, add fallback exclusions:

```bash
--glob '!node_modules/**' --glob '!.git/**' --glob '!.next/**' --glob '!.turbo/**' --glob '!.vercel/**' --glob '!dist/**' --glob '!build/**' --glob '!coverage/**'
```

4. Inspect usage before recommending movement:

```bash
rg "\\bSymbolName\\b" .
rg "from ['\"].*(types|constants|enums)" .
```

Quote paths with shell-special characters when inspecting files directly, especially Next.js routes such as `'src/app/[locale]/profile/page.tsx'`.

5. Classify each issue:
   - duplicated type shape
   - duplicated literal union
   - repeated magic string or number
   - junk-drawer file
   - stale export
   - fake reuse that should stay inline
   - constant that hurts readability
   - drifted local contract that should use an existing owner
6. Apply `references/placement-rules.md` for placement decisions.
7. Apply `references/audit-heuristics.md` to separate signal from noise.
8. Format findings with `references/report-format.md`.

For multi-module candidate gathering, use:

```bash
scripts/scan-website-shower.sh .
```

Then use `references/audit-orchestrator.md` to convert scanner output into a checklist report.

## Core Judgment

- Global only after two unrelated features need it.
- Feature-local when one product area owns it.
- Inline when used once, fake-reused, or clearer as a literal.
- Delete stale exports before moving code.
- Repeated names, literals, and primitive values are leads, not findings. Confirm shape, ownership, and usage.
- Raw literals are strongest when the repo already has an owning constant or union and nearby code drifts from it.
- Same literal value can still need separate constants when ownership differs, for example two database enums that both include `"approved"` but belong to different tables or lifecycles.

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
- one-off JSX labels, route segments, HTTP method strings, and framework syntax
- test fixture strings and generated API/IDL/protobuf/GraphQL contract outputs
- CSS utility classes and local UI variant strings
- repeated `Props`/`State` names that are file-local
- repeated primitive values with different semantic owners

## Report Style

Lead with findings. Keep summary short.

Each finding must include:
- symbol or literal
- current file(s)
- recommended action
- reason
- confidence

A finding without concrete file paths is not release-quality. Use exact file paths and line numbers when available. If evidence is missing, mark it as a lead and say what path or usage check is still needed.

When unsure, say what evidence is missing instead of guessing. If there are no material findings, say so and mention search limits.

## Edit Mode

If the user asks for edits:
- make the smallest safe move
- update imports
- delete stale exports
- run the repo's typecheck or smallest relevant check
- avoid broad folder rewrites

Do not introduce a new shared file if an existing local owner is clearer.

## Skill Test Fixture

Use `examples/fixture` for scanner smoke testing only. It intentionally uses anonymous names so agents are not biased by product vocabulary.

```bash
tests/smoke-test.sh
```
