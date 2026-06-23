# Performance Hygiene Audit

Use this module after framework, component, data-fetching, dependency, and ownership context is known. It prints performance leads, not proof of slow code.

## Tool

```bash
scripts/scan-performance-hygiene.sh <target>
```

For a full Website Shower pass:

```bash
scripts/scan-website-shower.sh <target>
```

The scanner reports leads for:

- `"use client"` boundaries
- large TSX/JSX files
- dynamic imports
- raw image tags
- unbounded list renders
- heavy dependency imports

## Judgment

Strong signals:

- a route or shared component is client-side only but mostly renders static or server-owned data
- large client components combine data loading, state, and rendering
- dynamic imports hide a component split that should be explicit
- raw `<img>` is used in a Next.js app where image optimization is expected
- `.map()` renders unbounded data without pagination, virtualization, or limits
- heavy libraries are imported into broad client entrypoints

Weak signals:

- small client components that need browser APIs
- dynamic imports used for a measured bundle split
- raw images in markdown, docs, or generated content
- bounded lists with tiny static data
- server components with large files but no client bundle cost

## Follow-Up

Before reporting a task:

```bash
rg "'use client'|dynamic\\(|<img|\\.map\\(" <target>
rg "from ['\\\"](lodash|moment|chart\\.js|three|framer-motion|@mui|antd)" <target>
```

Good tasks name one measurable risk and one validation path: build analyzer, route smoke test, image check, or list-size check. Avoid performance claims without evidence.
