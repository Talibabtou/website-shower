# Tailwind Cleanup Audit

Use this module for Tailwind and CSS design-system cleanup. If Tailwind is present, audit Tailwind plus raw CSS. If Tailwind is absent but CSS exists, report Tailwind migration only as an optional setup lead and still audit CSS drift.

## Tool

```bash
scripts/scan-tailwind-cleanup.sh <target>
```

For a full Website Shower pass:

```bash
scripts/scan-website-shower.sh <target>
```

The scanner reports leads for:

- Tailwind config and CSS source detection
- theme token definitions in config or CSS
- repeated arbitrary values
- dynamic class construction that Tailwind may not detect
- very long `className` strings
- duplicate utilities in one class list
- class composition helpers such as `cn`, `clsx`, `cva`, and `tailwind-merge`
- `@apply` and custom component CSS
- CSS token definitions, raw values, selectors, and repeated raw values
- CSS-to-Tailwind migration leads when CSS exists and Tailwind is absent

## Source Basis

Tailwind scans source files as plain text, so dynamically constructed class fragments can be missed. Prefer complete class names or maps from props to complete class strings.

Tailwind ignores common paths such as `.gitignore` entries, `node_modules`, binary files, CSS files, and lock files. If a repo needs classes from ignored sources, source paths must be registered explicitly.

Theme variables drive many utilities. Repeated arbitrary values may indicate missing `@theme` variables or config tokens, but a one-off arbitrary value can be fine.

Utility repetition is normal at first. Report it only when repeated class groups hide a shared component, a design token, or a project convention.

## Judgment

Strong signals:

- CSS-only repo repeats design tokens, utility-like classes, or component style patterns
- Tailwind project has unclear source/content coverage in a monorepo or app/package split
- class names are built with interpolation, for example `bg-${color}-600`
- same arbitrary value appears in several components
- hard-coded hex, pixel, radius, or shadow values repeat across owned UI
- CSS files repeat colors, spacing, radius, shadow, or typography values that should be theme tokens
- one-off CSS classes duplicate component variants already modeled in Tailwind or shared UI code
- class lists are long enough that intent and conflicts are hard to review
- duplicate utilities conflict or add noise, such as two `px-*` values in one class list
- a shared component repeats the same styling pattern instead of owning it

Weak signals:

- small CSS-only app with stable styles and no repeated design system pressure
- one-off arbitrary value for a genuinely unique layout fix
- generated or vendored component markup
- class names inside docs, tests, fixtures, or visual snapshots
- local component `className` strings that are long but still easy to read
- `@apply` used for a tiny stable CSS boundary

## Follow-Up

Before reporting a task:

```bash
rg "tailwindcss|@tailwind|@theme|@source" <target>
rg "className=" <target>
rg "\[[^]]+\]" <target>
rg "bg-\\$\\{|text-\\$\\{|className=.*\\$\\{" <target>
rg --glob "*.css" "#[0-9a-fA-F]{3,8}|[0-9]+px|rgba?\\(" <target>
```

Good tasks name the smallest cleanup: replace dynamic class construction with a static variant map, move repeated arbitrary values into a theme token, add missing source coverage, split a class-heavy repeated pattern into a component, or suggest a Tailwind migration only when CSS drift makes it worth the cost.
