# Monorepo Ownership Audit

Use this module when a repo has `apps`, `packages`, workspace config, or package-scoped imports.

## Tool

```bash
scripts/scan-monorepo-ownership.sh <target>
```

For a full Website Shower pass:

```bash
scripts/scan-website-shower.sh <target>
```

The scanner reports leads for:

- workspace config and package manifests
- workspace package names
- cross-package imports
- deep package imports
- private or internal boundary imports
- broad shared packages
- app-global junk drawers
- repeated contract names across apps and packages

## Judgment

Strong signals:

- an app imports from another package's `src`, `internal`, `private`, feature folder, or non-exported path
- a shared package owns unrelated app-specific contracts
- the same request, response, event, state, or status contract repeats in an app and a package
- app code reaches around a package export instead of using the public entrypoint
- a package exists only because code was promoted too early from one app
- packages import back into apps

Weak signals:

- small single-app repos with `packages` reserved for later
- generated SDKs or build output inside packages
- temporary deep imports during a documented migration
- package-private tests that intentionally import internals
- shared UI or config packages with a clear narrow purpose

## Follow-Up

Before reporting a task:

```bash
rg "from ['\\\"]@" <target>
rg "from ['\\\"].*(/internal|/private|/src/)" <target>
rg --files <target> | rg '(^|/)(apps|packages)/.*/package.json$'
```

Good tasks name one boundary: export a public contract, move app-private code back into the app, split a broad shared package, or delete a premature shared package. Do not recommend a workspace rewrite from import strings alone.
