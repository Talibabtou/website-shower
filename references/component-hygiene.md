# Component Hygiene Audit

Use this module when a website repo has React or JSX components. It looks for component shape issues that can make later cleanup harder.

## Tool

```bash
scripts/scan-component-hygiene.sh <target>
```

For a full Website Shower pass:

```bash
scripts/scan-website-shower.sh <target>
```

The scanner reports leads for:

- large component files
- prop unions that may want named variants
- repeated loading, error, and empty states
- client components doing fetch or server-like work
- repeated UI patterns, raw images, class blocks, and list renders

## Judgment

Strong signals:

- one component owns data loading, error states, empty states, rendering, and variant decisions
- the same loading, error, or empty state appears in several components
- prop unions such as `mode`, `variant`, `tone`, or `size` repeat without a local variant owner
- a client component fetches server-owned data when the framework has a server route or loader path
- raw image or list-render patterns repeat across shared UI

Weak signals:

- small local components with one clear job
- one-off loading text in a route file
- UI library wrappers where the prop API comes from the library
- generated component examples or docs snippets
- client components that truly need browser APIs

## Follow-Up

Before reporting a task:

```bash
rg "use client|isLoading|error|empty|variant|mode|tone|size" <target>
rg "fetch\\(|<img|\\.map\\(" <target>
```

Good tasks name one small cleanup: extract a client child, name a variant map, reuse a loading/error/empty state component, or split a large component along an existing feature boundary.
