# Dependency Hygiene Audit

Use this module when a website repo has `package.json`, workspace packages, lock files, or package imports.

## Tool

```bash
scripts/scan-dependency-hygiene.sh <target>
```

For a full Website Shower pass:

```bash
scripts/scan-website-shower.sh <target>
```

The scanner reports leads for:

- package manager and lockfile signals
- package manifests
- dependency declarations
- imported package names
- tooling packages declared in `dependencies`
- runtime packages declared in `devDependencies`
- duplicate dependency families
- workspace dependency links

## Judgment

Strong signals:

- more than one lock file exists without a clear package-manager policy
- `typescript`, formatter, linter, test runner, or `@types/*` packages live in runtime `dependencies`
- runtime packages such as `react`, `next`, schema validators, or HTTP clients live in `devDependencies` for an app
- two libraries do the same job, such as `clsx` and `classnames`, or several HTTP/date/utility libraries
- a workspace package dependency exists but app code imports package internals

Weak signals:

- libraries that intentionally expose peer dependencies
- package templates with placeholder dependencies
- test-only packages in a test package
- generated SDK dependencies owned by generated code
- monorepos where dependency placement is controlled by a package manager rule

## Follow-Up

Before reporting a task:

```bash
rg --files <target> | rg '(^|/)package.json$|lock'
rg "from ['\\\"]|import\\(" <target>
rg '"dependencies"|"devDependencies"|"peerDependencies"' <target> --glob package.json
```

Good tasks name one cleanup: remove an unused dependency after usage checks, move a package to the right dependency block, pick one duplicate library family, or document the package manager policy.
