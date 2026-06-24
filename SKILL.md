---
name: website-shower
description: Read-only website maintenance audit. Creates a cleanup checklist for repo shape, TypeScript, React/Next, Tailwind/CSS, API/data, state/domain, dependencies, performance, duplicated types/constants, and unused-code leads.
---

# Website Shower

Audit website maintenance issues from repo evidence. Default mode is read-only for source files: produce a report artifact, but do not edit audited source/config files unless the user explicitly asks for fixes.

Website Shower coordinates multiple read-only website maintenance audits into a Markdown checklist report. Current modules cover file-tree hygiene, monorepo ownership, TypeScript hygiene, React/Next.js habits, Tailwind and CSS cleanup, component hygiene, API contracts, data-fetching hygiene, state/domain contracts, naming drift, dependency hygiene, performance hygiene, types/constants ownership, and unused-code leads.

Default artifact: write the final report to `website-shower-report.md` at the target repo root when file writes are available. If the user asks for chat-only output or the session is read-only, return the same report in chat and say no file was written.

Optional artifact: if the user asks for machine-readable output, also write `website-shower-report.json`. Keep Markdown as the source humans read.

## Workflow

1. Build a website map first: framework, package manager, app/package layout, feature/domain folders, route roots, API/data boundaries, state roots, tests, generated folders, and existing checker setup.
2. Run the global scanner when available:

```bash
scripts/scan-website-shower.sh .
```

For monorepos, treat a root scan as orientation only, then rerun against one owned app or package:

```bash
scripts/scan-website-shower.sh apps/example-app
scripts/scan-website-shower.sh packages/example-domain
```

3. Read scanner output in this order:
   - Website map: app roots, route roots, feature/domain roots, API/data boundaries, tests/stories, generated folders, package and checker signals.
   - File-tree hygiene: app layout, packages, feature folders, generated folders, junk drawers, route shape.
   - Monorepo ownership: workspace packages, public exports, deep imports, shared package boundaries.
   - TypeScript hygiene: checker setup, `any`, unsafe casts, JS migration leftovers, formatting and lint guardrails.
   - React/Next.js habits: app shape, server/client boundaries, metadata, route literals, fetch policy.
   - Tailwind cleanup: Tailwind presence, source coverage, dynamic classes, arbitrary values, duplicate utilities, CSS transition leads.
   - Component hygiene: large components, variant props, repeated loading/error/empty states, client/server work mix.
   - API contracts: routes, clients, schemas, mocks, request parsing, response shapes.
   - Data-fetching hygiene: query keys, cache policy, fetch wrappers, JSON validation, client/server fetching mix.
   - State/domain contracts: store state, selectors, event payloads, status machines, action names.
   - Naming drift: same concept named with different words such as `status`, `state`, `phase`, `mode`, `kind`, or `type`.
   - Dependency hygiene: package managers, dependency blocks, duplicate dependency families, workspace links.
   - Performance hygiene: client boundaries, dynamic imports, raw images, large components, unbounded lists.
   - Types/constants ownership: repeated contracts, literal unions, raw domain values, barrels, junk drawers.
   - Unused code: stale exports and deletion leads after framework and public API context is known.
4. If the global scanner is unavailable, run focused scanners manually:

```bash
scripts/scan-file-tree-hygiene.sh .
scripts/scan-monorepo-ownership.sh .
scripts/scan-typescript-hygiene.sh .
scripts/scan-react-next-habits.sh .
scripts/scan-tailwind-cleanup.sh .
scripts/scan-component-hygiene.sh .
scripts/scan-api-contracts.sh .
scripts/scan-data-fetching-hygiene.sh .
scripts/scan-state-domain-contracts.sh .
scripts/scan-naming-drift.sh .
scripts/scan-dependency-hygiene.sh .
scripts/scan-performance-hygiene.sh .
scripts/scan-types-constants.sh .
scripts/scan-unused-code.sh .
```

If scripts are unavailable, use `rg` manually and let repo ignore files apply first. If the repo has no ignore files, add fallback exclusions:

```bash
--glob '!node_modules/**' --glob '!.git/**' --glob '!.next/**' --glob '!.turbo/**' --glob '!.vercel/**' --glob '!dist/**' --glob '!build/**' --glob '!coverage/**'
```

5. Inspect usage before recommending movement or deletion:

```bash
rg "\\bSymbolName\\b" .
rg "from ['\"].*(types|constants|enums)" .
```

Quote paths with shell-special characters when inspecting files directly, especially Next.js routes such as `'src/app/[locale]/profile/page.tsx'`.

6. Classify each task:
   - unclear file-tree boundary
   - unclear package ownership boundary
   - missing checker guardrail
   - unsafe TypeScript escape hatch
   - framework boundary drift
   - styling token or utility drift
   - component shape drift
   - duplicated API contract
   - data-fetching ownership drift
   - duplicated state or domain contract
   - naming drift for the same domain concept
   - dependency drift or duplicate package family
   - performance risk lead
   - duplicated type shape
   - duplicated literal union
   - repeated magic string or number
   - junk-drawer file
   - stale export
   - fake reuse that should stay inline
   - constant that hurts readability
   - drifted local contract that should use an existing owner
7. Add boundary markers where relevant:
   - `client-server`
   - `external-api`
   - `local-storage`
   - `env-config`
   - `auth-session`
   - `database`
   - `generated-code`
   - `package-boundary`
   - `framework-entrypoint`
   - `state-store`
   - `design-system`
8. Apply the relevant reference before reporting:
   - `references/audit-orchestrator.md`
   - `references/website-map.md`
   - `references/file-tree-hygiene.md`
   - `references/monorepo-ownership.md`
   - `references/typescript-hygiene.md`
   - `references/react-next-habits.md`
   - `references/tailwind-cleanup.md`
   - `references/component-hygiene.md`
   - `references/api-contracts.md`
   - `references/data-fetching-hygiene.md`
   - `references/state-domain-contracts.md`
   - `references/naming-drift.md`
   - `references/dependency-hygiene.md`
   - `references/performance-hygiene.md`
   - `references/placement-rules.md`
   - `references/audit-heuristics.md`
   - `references/unused-code.md`
9. Format the final checklist with `references/report-format.md`.
10. Include an inspected-scope section before findings. Name what was inspected and what was absent or intentionally skipped.
11. Mark new tasks as open by using unchecked checklist boxes. Do not mark tasks accepted, fixed, ignored, or false-positive unless the user or repo evidence already says so.
12. If requested, write `website-shower-report.json` using the compact task schema from `references/report-format.md`.
13. Write `website-shower-report.md` in the target repo root by default. This report file is the audit output, not a source fix. Do not edit existing source/config files unless the user separately approves cleanup work.

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
- `any`, double casts, or suppression comments near repo-owned boundaries
- JavaScript migration leftovers in typed source folders
- React/Next server-client boundary drift, route literal drift, and repeated fetch policy
- Tailwind source/config drift, dynamic class construction, repeated arbitrary values, and duplicate utilities
- Oversized components, repeated UI states, variant prop drift, or client components doing server-like work
- API request/response contracts duplicated across routes, clients, schemas, mocks, and tests
- Query key drift, cache policy repetition, duplicated fetch wrappers, or unvalidated fetched JSON
- Store state, event payloads, selector return types, status machines, or action names duplicated across owners
- Feature-private imports, premature shared packages, and cross-package contract drift
- One concept named differently across owners, for example `status` in one file and `phase` in another
- Mixed package managers, duplicate dependency families, or packages in the wrong dependency block
- Performance leads such as needless client boundaries, raw images, unbounded lists, or heavy imports

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
- evidence
- change risk for checklist tasks

For Website Shower checklist reports, group tasks under module headings such as `### Component Hygiene` and do not repeat `Module:` inside each task.

Every report should include:
- commands or tools used
- the report mode
- inspected scope
- grouped checklist tasks
- boundary markers when they explain risk or validation
- ignored leads when scanner output was noisy or the repo was dirty

Only create JSON when asked. Do not replace the Markdown checklist with JSON.

Lifecycle labels for later cleanup passes:
- `open`: reported task, not yet approved or fixed
- `accepted`: human agreed this should be fixed
- `fixed`: follow-up cleanup completed and validated
- `ignored`: intentionally left as-is
- `false-positive`: audit lead was wrong after deeper inspection

Do not turn "already clean" observations into tasks. Put them in the summary unless there is a concrete action.

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
