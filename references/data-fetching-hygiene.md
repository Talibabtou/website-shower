# Data Fetching Hygiene Audit

Use this module when a repo has fetch clients, route handlers, query libraries, server components, API clients, or cache policy decisions.

## Tool

```bash
scripts/scan-data-fetching-hygiene.sh <target>
```

For a full Website Shower pass:

```bash
scripts/scan-website-shower.sh <target>
```

The scanner reports leads for:

- `fetch`, query, SWR, axios, and ky usage
- query key declarations
- cache policy repetition
- fetch wrapper functions
- unvalidated `response.json()` usage
- client/server fetching mix

## Judgment

Strong signals:

- the same API path is fetched from server and client code without a named owner
- query keys repeat as raw arrays or strings
- cache policy such as `no-store` repeats across routes and clients
- `response.json()` is cast to a type without runtime validation at an external boundary
- several fetch wrappers build the same base URL or headers

Weak signals:

- tiny route-local fetches that do not cross ownership boundaries
- framework-required cache settings in a route file
- generated SDK clients
- tests with partial mock responses
- server-only fetches that already validate at the route boundary

## Follow-Up

Before reporting a task:

```bash
rg "fetch\\(|useQuery|useSWR|queryKey|cache:|revalidate" <target>
rg "response\\.json\\(\\)|request\\.json\\(\\)|safeParse|parse\\(" <target>
```

Good tasks name one owner: feature API client, route-local schema, query key factory, cache policy helper, or generated SDK. Do not centralize every fetch call.
