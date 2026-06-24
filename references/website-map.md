# Website Map

Start every Website Shower audit by mapping the website before judging cleanup tasks.

## What To Map

- app roots: `src/app`, `src/pages`, `app`, `pages`, `apps/*`
- route systems: App Router, Pages Router, Remix routes, Astro routes, React Router, API routes
- feature/domain roots: `src/features`, `src/domain`, `src/modules`, `src/components`, `src/ui`, `src/lib`
- API/data boundaries: route handlers, API clients, data hooks, schemas, generated SDKs, mocks
- state roots: Redux, Zustand, context, server state, event contracts
- styling roots: Tailwind config, global CSS, design tokens, shared UI variants
- test/story coverage: unit tests, integration tests, e2e tests, Storybook stories
- generated or vendor output: generated contracts, migrations, SDKs, build folders
- package boundaries: workspaces, apps, packages, public exports, deep imports

## How To Use It

Use the map to decide which later scanner leads deserve attention.

A route file can be a framework entrypoint, not dead code. A generated contract can be the source of truth, not a duplicate. A package-internal import can be a real boundary problem even if TypeScript compiles.

## Report Requirement

Every final report should include an `Inspected scope` section. Name what was inspected, what was absent, and what was skipped.
