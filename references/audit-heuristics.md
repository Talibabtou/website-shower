# Audit Heuristics

Use these rules to turn scanner output into findings. Scanner output is evidence, not a verdict.

## Strong Signals

- Same literal union repeated across unrelated runtime paths.
- Same type shape duplicated between store, hooks, services, or API clients.
- Existing owner constant or union exists, but related code still compares raw strings.
- Exported symbol is unused outside its declaration file.
- Global `types.ts` or `constants.ts` mixes unrelated domain ownership.
- Same primitive value appears under matching semantic names, such as two `CACHE_CONTROL` constants.

## Weak Signals

- Repeated names like `Props`, `State`, `Config`, `Account`, `Item`, or `Result`.
- Repeated UI variants such as `default`, `primary`, `secondary`, `success`, `error`, or `warning`.
- Repeated primitive numbers with different names or owners.
- External protocol strings, API literals, route segments, HTTP method names, and ARIA labels.
- Large generated API, IDL, protobuf, GraphQL, or program contract files.

## Monorepos

A monorepo root scan is for map-making only. It can show apps, packages, shared libraries, and noisy generated areas.

Before reporting a monorepo finding, narrow to one app/package/domain and prove at least one of:

- the same concept crosses package boundaries
- a shared package already owns the contract
- two apps duplicate the same contract with matching shape
- imports show a feature reaching into another feature's private owner

Do not report a root-wide repeated name or literal from spelling alone.

## Read-Only Audit Posture

Report findings and next actions. Do not edit the audited repo unless the user explicitly asks for fixes.

When testing the skill on example repos, do not modify the example repos.
