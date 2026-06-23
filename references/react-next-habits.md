# React And Next.js Habit Audit

Use this module to find React and Next.js cleanup tasks that keep behavior unchanged.

## Tool

```bash
scripts/scan-react-next-habits.sh <target>
```

For a full Website Shower pass:

```bash
scripts/scan-website-shower.sh <target>
```

The scanner reports leads for:

- App Router files that use client hooks without a top-level `"use client"`
- metadata and route config exports
- repeated fetch cache options
- hard-coded route-like strings
- component prop types that may belong near or away from the component

## Judgment

Strong signals:

- server component file imports or calls client hooks
- one page mixes metadata ownership with client-only behavior
- repeated fetch cache options hide a route-level convention
- the same route literal appears in navigation, redirects, fetch calls, and tests
- prop types are exported from a page only because another module imports them

Weak signals:

- client hook appears in a file that already starts with `"use client"`
- metadata export is local and unique to one route
- fetch options differ because data freshness differs
- route strings are framework folder names, not app-owned constants
- local `Props` names used only in one component

## Follow-Up

Before reporting a task:

```bash
rg '"use client"|useState|useEffect|useMemo|useCallback' <target>
rg 'export const metadata|export const revalidate|export const dynamic|fetchCache' <target>
rg 'cache:|next: \{ revalidate' <target>
rg "'/items|\"/items|'/api|\"/api" <target>
```

Report the smallest safe action. Good tasks split a client component from a server page, move a shared route literal to the route owner, or name a repeated fetch policy. Do not recommend moving metadata or route config unless ownership is clearly repeated or mixed with unrelated client code.
