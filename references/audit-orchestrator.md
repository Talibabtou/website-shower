# Audit Orchestrator

Website Shower is a read-only multi-audit workflow for website repositories.

The intended flow:

```text
multi-audit -> TODO report -> human permission -> cleanup work
```

## Current Modules

1. Orchestrated candidate scan
   - Script: `scripts/scan-website-shower.sh`
   - Purpose: run module scanners and collect read-only candidate evidence.

2. File-tree hygiene
   - Script: `scripts/scan-file-tree-hygiene.sh`
   - Reference: `references/file-tree-hygiene.md`
   - Purpose: find repo shape, app/package boundaries, feature folders, generated folders, junk drawers, route layout, and naming consistency leads.

3. Monorepo ownership hygiene
   - Script: `scripts/scan-monorepo-ownership.sh`
   - Reference: `references/monorepo-ownership.md`
   - Purpose: find feature-private imports, premature shared packages, app-global junk drawers, and cross-package contract drift.

4. TypeScript hygiene
   - Script: `scripts/scan-typescript-hygiene.sh`
   - Reference: `references/typescript-hygiene.md`
   - Purpose: find typed-code escape hatches, migration leftovers, and duplicated API-style contracts.

5. React and Next.js habits
   - Script: `scripts/scan-react-next-habits.sh`
   - Reference: `references/react-next-habits.md`
   - Purpose: find server/client boundary drift, route config drift, fetch policy repetition, route literal repetition, and prop type placement leads.

6. Tailwind cleanup
   - Script: `scripts/scan-tailwind-cleanup.sh`
   - Reference: `references/tailwind-cleanup.md`
   - Purpose: find Tailwind source/config drift, dynamic class construction, repeated arbitrary values, long class lists, duplicate utilities, and token leads.

7. Component hygiene
   - Script: `scripts/scan-component-hygiene.sh`
   - Reference: `references/component-hygiene.md`
   - Purpose: find oversized components, variant prop drift, repeated loading/error/empty states, repeated UI patterns, and client components doing server-like work.

8. API contract hygiene
   - Script: `scripts/scan-api-contracts.sh`
   - Reference: `references/api-contracts.md`
   - Purpose: find duplicated request/response contracts between routes, clients, schemas, mocks, tests, and generated boundaries.

9. Data-fetching hygiene
   - Script: `scripts/scan-data-fetching-hygiene.sh`
   - Reference: `references/data-fetching-hygiene.md`
   - Purpose: find query key drift, cache policy repetition, duplicated fetch wrappers, client/server fetching mix, and missing validation around fetched data.

10. State and domain contract hygiene
   - Script: `scripts/scan-state-domain-contracts.sh`
   - Reference: `references/state-domain-contracts.md`
   - Purpose: find duplicated store state, event payloads, selector return types, status machines, action names, and cross-boundary domain contracts.

11. Naming drift hygiene
   - Script: `scripts/scan-naming-drift.sh`
   - Reference: `references/naming-drift.md`
   - Purpose: find one domain concept named with different words, such as `status`, `state`, `phase`, `mode`, `kind`, or `type`.

12. Dependency hygiene
   - Script: `scripts/scan-dependency-hygiene.sh`
   - Reference: `references/dependency-hygiene.md`
   - Purpose: find mixed package managers, dependency block mistakes, duplicate dependency families, workspace dependency leads, and unused-dependency candidates.

13. Performance hygiene
   - Script: `scripts/scan-performance-hygiene.sh`
   - Reference: `references/performance-hygiene.md`
   - Purpose: find client-boundary leads, large TSX files, dynamic imports, raw images, unbounded list renders, and heavy dependency imports.

14. Types and constants ownership
   - Script: `scripts/scan-types-constants.sh`
   - Reference: `references/placement-rules.md`, `references/audit-heuristics.md`
   - Purpose: find repeated contracts, literal unions, enum-like values, magic values, barrels, and placement drift after repo owners are clearer.

15. Unused code and stale exports
   - Script: `scripts/scan-unused-code.sh`
   - Reference: `references/unused-code.md`
   - Tool: repo-local/global `fallow` when available, optional `npx`, basic `rg` fallback otherwise
   - Purpose: find deletion leads after framework entrypoints, generated files, API contracts, and public exports have context.

## Reading Order

Read scanner output in the same order. Use early sections to reduce false positives later:

- File-tree shape tells you which folders are app roots, packages, generated output, framework routes, feature owners, or junk drawers.
- Monorepo ownership tells you which package boundaries are public, private, premature, or drifting.
- TypeScript and checker setup tells you whether strictness, `any`, JS migration leftovers, and formatter policy explain later drift.
- React and Next.js shape tells you which files are framework entrypoints, server components, client components, routes, or metadata owners.
- Tailwind, component, API, data, state/domain, naming, dependency, and performance sections identify styling, UI, request/response, data-flow, store/event, vocabulary, package, and runtime owners before type placement work.
- Types/constants and unused-code sections turn that context into concrete cleanup tasks.

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
