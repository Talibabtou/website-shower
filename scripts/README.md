# Scripts

All scripts are read-only. They print candidate evidence for an agent or human to judge later. They do not edit the audited repo.

Default output cap is `MAX_SECTION_LINES=300` per section. Raise it for manual validation or narrow the target path when output is noisy.

```bash
MAX_SECTION_LINES=300 scripts/scan-website-shower.sh /path/to/repo
```

## Global Scan Order

`scan-website-shower.sh` runs modules in this order:

1. `scan-file-tree-hygiene.sh`
2. `scan-monorepo-ownership.sh`
3. `scan-typescript-hygiene.sh`
4. `scan-react-next-habits.sh`
5. `scan-tailwind-cleanup.sh`
6. `scan-component-hygiene.sh`
7. `scan-api-contracts.sh`
8. `scan-data-fetching-hygiene.sh`
9. `scan-state-domain-contracts.sh`
10. `scan-naming-drift.sh`
11. `scan-dependency-hygiene.sh`
12. `scan-performance-hygiene.sh`
13. `scan-types-constants.sh`
14. `scan-unused-code.sh`

The order is deliberate. File-tree shape gives the first map of apps, packages, feature folders, generated output, and junk drawers. Monorepo ownership clarifies public package boundaries before later modules judge imports and shared contracts. Checker setup and framework shape change how later leads should be judged. UI, API, data, state, naming, dependency, and performance sections identify the main owners before type placement work. Unused-code leads come last because framework entrypoints, generated boundaries, public exports, and route conventions can make raw usage counts noisy.

The global scanner only gathers candidates. Convert the output into a checklist report with file paths, confidence, safe action, validation, and permission status before editing anything.

## Module Scripts

### `scan-file-tree-hygiene.sh`

Finds repo-shape and ownership-boundary leads:

- root config and workspace signals
- top-level directories
- app, package, service, worker, and function folders
- feature and UI boundary folders
- mixed `feature`/`features` or `components`/`ui` conventions
- junk-drawer files and folders
- generated/build folders that later audits should treat carefully
- route layout and unusually deep source files

Use `references/file-tree-hygiene.md` before reporting a task. File-tree output should guide later modules; it is not proof that a file should move.

### `scan-monorepo-ownership.sh`

Finds monorepo ownership leads:

- workspace config and package manifests
- workspace package names
- cross-package imports
- deep imports into package internals
- broad shared packages
- app-level junk drawers
- repeated contract names across apps and packages

Use `references/monorepo-ownership.md` before reporting a task. Deep imports and broad shared folders are leads until package exports and workspace policy are checked.

### `scan-types-constants.sh`

Finds type and constant ownership leads:

- candidate `types`, `constants`, `contracts`, enum, role, status, and config files
- repeated type/interface names
- repeated literal unions and watched domain literals
- enum-like objects and uppercase constants
- barrels and imports from type/constant owners
- large candidate files and stale exported constants to usage-check

Use `references/placement-rules.md` and `references/audit-heuristics.md` before reporting a task.

### `scan-unused-code.sh`

Finds stale export and dead-code leads.

Resolution order:

1. repo-local `node_modules/.bin/fallow`
2. globally available `fallow`
3. `npx --yes fallow`, only when `FALLOW_USE_NPX=1`
4. basic `rg` fallback for exported symbols whose names appear once

The fallback is weaker than `fallow`. Treat every fallback line as a lead.

### `scan-typescript-hygiene.sh`

Finds TypeScript and checker setup leads:

- `tsconfig` strictness guardrails
- Biome, Prettier, ESLint, oxlint, knip, and package scripts
- optional JS-to-TS migration leads when JS exists without TS
- `any`, `unknown`, double casts, and suppressions
- JS files in typed source
- API-style contract type names

Migration suggestions are optional. Recommend TypeScript only when the repo has real contract pressure: APIs, forms, workers, shared domain logic, or long-lived state.

### `scan-react-next-habits.sh`

Finds React and Next.js habit leads:

- App Router files with client hooks but no top-level `"use client"`
- metadata and route config exports
- fetch cache option repetition
- route-like strings
- component prop type placement

Confirm router mode and framework version before reporting. Route-owned metadata or local props are often fine.

### `scan-tailwind-cleanup.sh`

Finds Tailwind cleanup leads when Tailwind is present:

- config/source detection
- theme token definitions
- arbitrary values
- dynamic class construction
- long `className` strings
- duplicate utility tokens
- class composition helpers
- `@apply` and custom CSS boundaries

If Tailwind is absent but CSS exists, the script prints an optional CSS-to-Tailwind transition lead. Recommend that only when CSS shows repeated design tokens, utility-like classes, or component style drift.

### `scan-component-hygiene.sh`

Finds component hygiene leads:

- large TSX/JSX component files
- prop unions that may want named variants
- repeated loading, error, and empty states
- client components doing fetch or server-like work
- repeated UI patterns such as raw images, repeated class blocks, and list renders

Use `references/component-hygiene.md` before reporting a task. Component output needs ownership and UX judgment before recommending a split.

### `scan-api-contracts.sh`

Finds API contract hygiene leads:

- route handler files
- request body parsing
- JSON response boundaries
- API fetch clients
- schema validation calls
- request, response, payload, DTO, params, and result type names
- mock and fixture API shapes

API contract findings need judgment. Strong tasks usually have the same contract copied between route, client, schema, mock, or test. Body parsing such as `request.json()` is a lead until you confirm whether runtime validation exists.

Good outcomes name one owner: route-local schema, feature API model, generated SDK, or shared domain schema. Do not create a global API types file unless unrelated features truly share the contract.

### `scan-data-fetching-hygiene.sh`

Finds data-fetching hygiene leads:

- fetch, query, SWR, axios, and ky calls
- query key declarations
- repeated cache policies
- fetch wrapper functions
- `response.json()` and cast-based parsing
- client/server fetching mix

Use `references/data-fetching-hygiene.md` before reporting a task. Cache and validation findings need framework context and runtime boundary checks.

### `scan-state-domain-contracts.sh`

Finds state and domain contract leads:

- state, store, reducer, selector, event, action, and machine files
- `State`, `Store`, `Slice`, `Action`, `Event`, `Payload`, `Status`, `Phase`, `Mode`, and `Machine` type names
- state creators, action creators, selectors, hooks, and status-machine literals
- repeated state/domain contract names
- event and action string literals that may need an owner

Use `references/state-domain-contracts.md` before reporting a task. State output is strongest when a contract crosses store, feature, route, worker, or API boundaries.

### `scan-naming-drift.sh`

Finds naming drift leads:

- `status`, `state`, `phase`, `mode`, `kind`, `type`, `variant`, and `step` words
- type, field, and function names using those words
- literal unions tied to naming words
- same literal sets with different type names
- same type prefix with different convention words

Use `references/naming-drift.md` before reporting a task. Different names can be correct when they describe different lifecycles.

### `scan-dependency-hygiene.sh`

Finds dependency hygiene leads:

- package manager and lockfile signals
- package manifests and dependency blocks
- imported package names
- tooling packages in runtime `dependencies`
- runtime packages in `devDependencies`
- duplicate dependency families
- workspace dependency links

Use `references/dependency-hygiene.md` before reporting a task. Deletion always needs a usage check; package-block moves need repo policy and build context.

### `scan-performance-hygiene.sh`

Finds performance hygiene leads:

- client component boundaries
- large TSX/JSX files
- dynamic imports
- raw image tags
- unbounded list renders
- heavy dependency imports

Use `references/performance-hygiene.md` before reporting a task. Performance output is a lead until route behavior, bundle tooling, and data size are checked.

## Installer

`install-agent.sh` installs thin adapters for other agents. Some paths still use the old `types-constants-audit` compatibility name until the repo/package rename is finished.
