# Website Shower Report

Fixture report generated from read-only scanner output. No audited files were changed.

Report mode: read-only. Edits need a separate approval or follow-up request.

## Summary

- Total tasks: 23
- Safe first cleanup: `WS-023`
- Needs human decision: `WS-001`, `WS-002`, `WS-003`, `WS-004`, `WS-011`, `WS-012`, `WS-013`, `WS-016`, `WS-020`, `WS-022`
- Commands used:

```bash
MAX_SECTION_LINES=300 scripts/scan-website-shower.sh examples/fixture
```

## Inspected Scope

- App roots/routes: `examples/fixture/src/app`, `examples/fixture/src/app/api`
- Feature/domain roots: `examples/fixture/src/feature`, `examples/fixture/src/features`, `examples/fixture/src/components`, `examples/fixture/src/ui`, `examples/fixture/src/state`
- API/data boundaries: route handlers, item feature API client, mock data, worker message contracts
- State/store boundaries: `examples/fixture/src/state`, `examples/fixture/src/state/feature`
- Tests/generated: no test folders in fixture; generated output not present
- Skipped: build output, dependency folders, and repo-ignored files

## Cleanup Checklist

### File Tree Hygiene

- [ ] WS-001 Choose one feature folder convention
  Evidence: medium
  Change risk: medium
  Files:
  - `examples/fixture/src/feature/consumeEvent.ts:1`
  - `examples/fixture/src/features/items/navigation.ts:1`
  Why:
  The repo has both `src/feature` and `src/features`. That can be a migration leftover, but it makes ownership harder to read before later audits judge API, type, and route placement.
  Safe action:
  Pick the repo convention before moving files. If `src/features` is the target, migrate only one owned slice at a time and update imports.
  Validation:
  Run typecheck and a route smoke check after any import move.

- [ ] WS-002 Decide the shared UI folder boundary
  Evidence: medium
  Change risk: medium
  Files:
  - `examples/fixture/src/components/MetricCard.tsx:1`
  - `examples/fixture/src/components/Panel.tsx:1`
  - `examples/fixture/src/ui/control.ts:1`
  Why:
  The repo has both `src/components` and `src/ui`. That can be fine when one holds app components and the other holds primitives, but the boundary should be named clearly before Tailwind or component cleanup starts.
  Safe action:
  Document or enforce the split. Move files only if both folders currently hold the same kind of shared UI primitive.
  Validation:
  Run typecheck and visually check affected components if files move.

### Monorepo Ownership

- [ ] WS-003 Stop importing package internals from the app
  Evidence: high
  Change risk: high
  Boundaries: package-boundary
  Files:
  - `examples/fixture/apps/web/src/useShared.ts:2`
  - `examples/fixture/packages/shared/src/internal.ts:1`
  Why:
  The app imports `@fixture/shared/internal`, which reaches past the shared package public entrypoint. That makes package ownership unclear and can break if the package later tightens its exports.
  Safe action:
  Either export the needed label map from `@fixture/shared` as a public API, or keep the label ownership inside the app if it is app-specific.
  Validation:
  Run typecheck for the app and shared package after changing imports.

- [ ] WS-004 Use the shared package contract instead of repeating it in the app
  Evidence: high
  Change risk: medium
  Files:
  - `examples/fixture/apps/web/src/useShared.ts:4`
  - `examples/fixture/packages/shared/src/index.ts:1`
  Why:
  `SharedStatus` is declared in both the app and shared package. Since the app already depends on the package, this is a cross-package drift lead.
  Safe action:
  Import `SharedStatus` from `@fixture/shared` in the app, or move the type back to the app if the package does not truly own it.
  Validation:
  Run typecheck and confirm package exports allow the type import.

### TypeScript Hygiene

- [ ] WS-005 Replace unsafe input escape hatch
  Evidence: medium
  Change risk: high
  Boundaries: external-api
  Files:
  - `examples/fixture/src/feature/unsafeInput.ts:6`
  - `examples/fixture/src/feature/unsafeInput.ts:7`
  Why:
  `normalizeInput` accepts `any` and then double-casts through `unknown`, so the boundary looks typed before it is checked.
  Safe action:
  Replace the double cast with a small parser or guard that validates `itemId` and `amount`.
  Validation:
  Run typecheck and add the smallest unit test if this boundary handles external input.

- [ ] WS-006 Add repeatable checker guardrails
  Evidence: medium
  Change risk: medium
  Files:
  - `examples/fixture/package.json:1`
  Why:
  The fixture has TypeScript source but no `tsconfig`, Biome, ESLint, lint script, or typecheck script. Real repos need repeatable checks before cleanup work can stay consistent.
  Safe action:
  Add the repo's chosen checker setup. For a TypeScript website this usually means strict `tsconfig`, one formatter path such as Biome or Prettier, one lint path such as Biome or ESLint, `typecheck`, `lint`, and optional dead-code checking.
  Validation:
  Run the new scripts once and record any rule that must stay disabled during migration.

### React And Next.js Habits

- [ ] WS-007 Split client behavior out of the route page
  Evidence: high
  Change risk: high
  Boundaries: client-server, framework-entrypoint
  Files:
  - `examples/fixture/src/app/items/page.tsx:1`
  - `examples/fixture/src/app/items/page.tsx:3`
  - `examples/fixture/src/app/items/page.tsx:14`
  Why:
  The route page exports metadata but also imports client hooks. In App Router, this mixes server-owned route metadata with client-only behavior.
  Safe action:
  Keep metadata in the page, move the interactive state/effect code into a small child client component, and pass only serializable props.
  Validation:
  Run typecheck and the smallest Next build or route smoke check.

- [ ] WS-008 Name repeated item route literals
  Evidence: medium
  Change risk: medium
  Files:
  - `examples/fixture/src/app/items/page.tsx:20`
  - `examples/fixture/src/features/items/navigation.ts:2`
  - `examples/fixture/src/features/items/navigation.ts:3`
  Why:
  Item route strings appear in both route UI and navigation data. This is a lead for drift once links, redirects, and fetch calls grow.
  Safe action:
  If these routes are shared outside their folder owner, add a small route helper near the items feature and import it from consumers.
  Validation:
  Check generated links and route tests, if the repo has them.

### Tailwind Cleanup

- [ ] WS-009 Replace dynamic Tailwind class construction
  Evidence: high
  Change risk: medium
  Boundaries: design-system
  Files:
  - `examples/fixture/src/components/MetricCard.tsx:8`
  Why:
  The component builds `bg-${tone}-600`, but Tailwind detects class names as plain text. This can drop required styles from generated CSS.
  Safe action:
  Replace interpolation with a static variant map, for example `{ blue: 'bg-blue-600', green: 'bg-green-600' }`.
  Validation:
  Run the app build or Tailwind build and inspect the component state that uses each variant.

- [ ] WS-010 Promote repeated arbitrary values to Tailwind tokens
  Evidence: medium
  Change risk: low
  Files:
  - `examples/fixture/src/components/MetricCard.tsx:8`
  - `examples/fixture/src/components/Panel.tsx:3`
  - `examples/fixture/src/components/Panel.tsx:5`
  - `examples/fixture/src/components/Panel.tsx:6`
  Why:
  `rounded-[18px]`, `border-[#d7dde8]`, and the shadow value repeat across UI components. These look like design tokens rather than local one-offs.
  Safe action:
  Add named Tailwind theme variables or config tokens, then replace repeated arbitrary values with named utilities.
  Validation:
  Run the formatter and visual smoke check for the affected components.

### Component Hygiene

- [ ] WS-011 Split `DashboardPanel` responsibilities
  Evidence: medium
  Change risk: medium
  Files:
  - `examples/fixture/src/components/DashboardPanel.tsx:1`
  - `examples/fixture/src/components/DashboardPanel.tsx:15`
  - `examples/fixture/src/components/DashboardPanel.tsx:20`
  - `examples/fixture/src/components/DashboardPanel.tsx:32`
  Why:
  One client component owns fetching, loading/error/empty states, variant props, dynamic import, image rendering, and list rendering.
  Safe action:
  Confirm the desired owner first. A likely cleanup is to move data loading to a feature/API owner, keep UI variants local, and reuse a small status-state component if the pattern repeats.
  Validation:
  Run typecheck and a visual smoke check for loading, error, empty, and populated states.

### API Contracts

- [ ] WS-014 Consolidate create-item API contracts
  Evidence: high
  Change risk: high
  Boundaries: external-api, framework-entrypoint
  Files:
  - `examples/fixture/src/app/api/items/route.ts:3`
  - `examples/fixture/src/app/api/items/route.ts:8`
  - `examples/fixture/src/features/items/api.ts:1`
  - `examples/fixture/src/features/items/api.ts:6`
  - `examples/fixture/src/features/items/mock.ts:1`
  Why:
  The route handler, client, and mock repeat the same request/response shape. These contracts can drift without TypeScript comparing them.
  Safe action:
  Move the request and response contract to an items API model or schema owner, then import it from the route, client, and mock.
  Validation:
  Run typecheck and one route/client test, or add a small contract test if none exists.

- [ ] WS-015 Validate create-item request body before use
  Evidence: medium
  Change risk: high
  Boundaries: external-api
  Files:
  - `examples/fixture/src/app/api/items/route.ts:16`
  Why:
  The route casts `request.json()` to `CreateItemRequest`. TypeScript does not validate external JSON at runtime.
  Safe action:
  Add a route-owned parser or schema validation step, then derive the request type from that schema if the repo uses a schema tool.
  Validation:
  Test a valid request and one invalid body.

### Data Fetching Hygiene

- [ ] WS-012 Name item data-fetching policy
  Evidence: medium
  Change risk: high
  Boundaries: external-api, client-server
  Files:
  - `examples/fixture/src/components/DashboardPanel.tsx:20`
  - `examples/fixture/src/features/items/api.ts:15`
  - `examples/fixture/src/features/items/queries.ts:4`
  - `examples/fixture/src/features/items/queries.ts:5`
  Why:
  `/api/items` is fetched from multiple places, and `cache: 'no-store'` appears as a raw policy. JSON parsing also relies on casts instead of validation.
  Safe action:
  Pick one feature-owned API client or query owner, name the cache policy if it is shared, and validate external JSON at the boundary.
  Validation:
  Run typecheck and one route/client test, or add a small invalid-response check if none exists.

### Naming Drift

- [ ] WS-016 Pick one workflow lifecycle name
  Evidence: medium
  Change risk: medium
  Files:
  - `examples/fixture/src/features/items/workflow.ts:1`
  - `examples/fixture/src/feature/workflowPhase.ts:1`
  - `examples/fixture/src/state/contracts.ts:5`
  Why:
  The same values, `'draft' | 'active' | 'archived'`, appear as `ItemStatus`, `ItemPhase`, and `ProcessStep`. This may be one lifecycle with three names.
  Safe action:
  Confirm ownership first. If these values describe the same item workflow, pick one term and expose it from the owner. If they describe separate lifecycles, leave them separate and document the distinction.
  Validation:
  Run typecheck and search for all three names before any rename.

### Dependency Hygiene

- [ ] WS-017 Clean package metadata drift
  Evidence: medium
  Change risk: low
  Boundaries: package-boundary
  Files:
  - `examples/fixture/package.json:6`
  - `examples/fixture/package.json:7`
  - `examples/fixture/package.json:8`
  - `examples/fixture/package.json:11`
  - `examples/fixture/package-lock.json:1`
  - `examples/fixture/pnpm-workspace.yaml:1`
  Why:
  The fixture has a workspace file and an npm lock file, both `clsx` and `classnames`, `typescript` in runtime dependencies, and `react` in dev dependencies. These are cleanup leads, not deletion proof.
  Safe action:
  Pick one package manager policy, keep one class-name helper, move tooling to `devDependencies`, and keep runtime app packages in `dependencies`.
  Validation:
  Run install, typecheck, and a usage search before deleting or moving any package.

### Performance Hygiene

- [ ] WS-013 Check client-side performance pressure in `DashboardPanel`
  Evidence: medium
  Change risk: high
  Files:
  - `examples/fixture/src/components/DashboardPanel.tsx:1`
  - `examples/fixture/src/components/DashboardPanel.tsx:12`
  - `examples/fixture/src/components/DashboardPanel.tsx:47`
  - `examples/fixture/src/components/DashboardPanel.tsx:49`
  Why:
  The component is client-only, dynamically imports a child, renders raw images, and maps an unbounded list. These are performance leads until route behavior and list size are checked.
  Safe action:
  Confirm whether the component needs to be client-only. If not, split a small client child, use the framework image path where appropriate, and add pagination or a limit when list size is unbounded.
  Validation:
  Run the app build or bundle check, then smoke test the populated list state.

### State And Domain Contracts

- [ ] WS-018 Deduplicate `WorkItem`
  Evidence: high
  Change risk: medium
  Boundaries: state-store
  Files:
  - `examples/fixture/src/state/contracts.ts:11`
  - `examples/fixture/src/state/feature/workSlice.ts:3`
  Why:
  The state owner and state slice both declare the same item shape. The `side` and `status` fields can drift.
  Safe action:
  Keep `WorkItem` in `src/state/contracts.ts`, import it in `workSlice.ts`, and remove the local interface.
  Validation:
  Run the repo typecheck after import updates.

- [ ] WS-019 Name and reuse `WorkStatus`
  Evidence: high
  Change risk: medium
  Files:
  - `examples/fixture/src/state/contracts.ts:14`
  - `examples/fixture/src/state/feature/workSlice.ts:6`
  Why:
  `'queued' | 'done' | 'error'` appears in two item contracts and also drives filtering.
  Safe action:
  Add `export type WorkStatus = 'queued' | 'done' | 'error';` next to `WorkItem`, then use it from the owned contract.
  Validation:
  Run typecheck and confirm selectors still compare the same values.

- [ ] WS-021 Import `DomainEvent` from the owner
  Evidence: high
  Change risk: medium
  Files:
  - `examples/fixture/src/state/contracts.ts:17`
  - `examples/fixture/src/feature/consumeEvent.ts:1`
  Why:
  The consumer repeats the event payload owned by the state contract.
  Safe action:
  Delete the local `DomainEvent` interface in `consumeEvent.ts` and import the owned type.
  Validation:
  Run typecheck.

### Types And Constants

- [ ] WS-020 Consolidate preview worker messages
  Evidence: high
  Change risk: high
  Boundaries: client-server
  Files:
  - `examples/fixture/src/workers/previewWorker.ts:1`
  - `examples/fixture/src/workers/previewWorker.ts:9`
  - `examples/fixture/src/feature/usePreviewWorker.ts:1`
  - `examples/fixture/src/feature/usePreviewWorker.ts:9`
  Why:
  Both sides of a worker-style message protocol declare request and response shapes independently.
  Safe action:
  Move `PreviewWorkerRequest` and `PreviewWorkerResponse` to a small worker contract file and import them from both sides.
  Validation:
  Run typecheck and manually confirm message strings are unchanged.

- [ ] WS-022 Decide whether `ResourceMap` is shared production shape
  Evidence: medium
  Change risk: medium
  Files:
  - `examples/fixture/src/feature/sourceData.ts:1`
  - `examples/fixture/src/feature/preloadData.ts:1`
  Why:
  The shape repeats in nearby data helpers, but the owner depends on whether these files are generated, fixture-only, or production-owned.
  Safe action:
  If production-owned, move `ResourceMap` to the nearest feature model file. Otherwise leave it local.
  Validation:
  Check file ownership before editing.

### Unused Code

- [ ] WS-023 Remove stale env helpers
  Evidence: medium
  Change risk: low
  Files:
  - `examples/fixture/src/config/env.ts:5`
  - `examples/fixture/src/config/env.ts:7`
  - `examples/fixture/src/config/env.ts:9`
  Why:
  The fallback unused-code scan found exported helpers that only appear at declaration. They are candidates, not proof.
  Safe action:
  If `rg` and the app entrypoints confirm no usage, delete `getLegacyApiUrl`, `getUnusedCallbackUrl`, and `buildPreviewUrl`.
  Validation:
  Run typecheck and the smallest app build command.

## Leads Ignored

- `default` in `src/ui/control.ts` is a local UI variant, not a domain constant.
- `AppState` appears twice, but one version is store-derived. Store-derived state often wins over hand-written aliases.
- Basic unused-code fallback output is weaker than `fallow`; every unused-code item needs a follow-up search before deletion.
- `readOptionalAmount` uses `unknown` safely because it narrows before returning a value.
- Missing Biome, Prettier, and ESLint are one setup lead, not separate tasks. A repo should pick one formatter path and one lint path unless it has a reason to run more.
- `metadata` in a single route file is normal. It becomes a task only when it is mixed with client behavior or repeated across routes without ownership.
- One arbitrary value can stay inline. The report only promotes values that repeat or encode a shared visual decision.
- Framework `Request`, `Response`, and `NextResponse` names are not contract duplicates by themselves.
