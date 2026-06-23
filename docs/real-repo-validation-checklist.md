# Real Repo Validation Checklist

Use this file while testing Website Shower before a release. The goal is feedback on the skill, not cleanup of the target repo.

## Rules

- [ ] Run audits read-only. Do not edit the target repo.
- [ ] Record the exact command and target path.
- [ ] Keep private names out of public notes.
- [ ] Count useful tasks, false positives, and missed issues.
- [ ] Record whether the report gives a human or agent enough context to act later.

## Repo Mix

- [ ] Small clean website, such as a portfolio or simple Next.js app.
- [ ] Feature-heavy React or Next.js app.
- [ ] Monorepo package or app.
- [ ] Older or messier repo with global `types.ts`, `constants.ts`, or weak checker setup.
- [ ] Repo with Tailwind, when Tailwind cleanup is added.
- [ ] Repo with API routes, generated contracts, or database schema files.

## Baseline Commands

- [ ] Run the full candidate scan:

```bash
MAX_SECTION_LINES=300 scripts/scan-website-shower.sh /path/to/repo
```

- [ ] If `fallow` is installed in the repo or globally, run:

```bash
scripts/scan-unused-code.sh /path/to/repo
```

- [ ] If the repo can use `npx` and you accept network/tool resolution:

```bash
FALLOW_USE_NPX=1 scripts/scan-unused-code.sh /path/to/repo
```

- [ ] Run focused scanners when the full output is too large:

```bash
scripts/scan-types-constants.sh /path/to/repo
scripts/scan-typescript-hygiene.sh /path/to/repo
```

## Module Checks

### Types And Constants

- [ ] Does the scanner find duplicated type/interface names worth inspecting?
- [ ] Does it separate real domain literals from local UI strings?
- [ ] Does it catch raw literals that bypass existing owners?
- [ ] Does it avoid generated files, route handlers, and framework noise?
- [ ] Does the final report cite exact file paths and line numbers?

### Unused Code

- [ ] Does `fallow` produce better leads than the fallback on this repo?
- [ ] Does the fallback label its output as leads, not deletion proof?
- [ ] Are framework entrypoints, config files, public exports, and dynamic imports handled as weak signals?
- [ ] Did any stale helper, dependency, or export become a useful task?

### TypeScript Hygiene

- [ ] Does it detect the repo's checker setup: Biome, ESLint, Prettier, oxlint, knip, or none?
- [ ] Does it recommend missing `tsconfig` strictness only when it fits the repo?
- [ ] If Biome exists, does it spot missing formatter, linter, `noExplicitAny`, `noDebugger`, `useConst`, unused-variable, and Tailwind class rules?
- [ ] If Prettier exists, does it spot missing formatter policy, ignore file, and format script?
- [ ] If ESLint exists, does it spot missing `no-console`, `no-debugger`, `prefer-const`, `eqeqeq`, `@typescript-eslint/no-explicit-any`, TypeScript unused-vars, and React hooks rules?
- [ ] Does it flag `any`, double casts, suppressions, and old JS files without turning safe `unknown` narrowing into a finding?

### React And Next.js Habits

- [ ] Does it detect App Router, Pages Router, or non-Next React shape correctly?
- [ ] Does it flag client hooks in App Router files without treating valid client components as findings?
- [ ] Does it separate metadata and route config repetition from local route-owned values?
- [ ] Does it find repeated fetch cache policies that should become a named convention?
- [ ] Does it find route literals that cross navigation, redirects, fetch calls, and tests?

### Future Modules

- [ ] Tailwind cleanup: config drift, repeated arbitrary values, unused tokens, class duplication, shared component class soup.
- [ ] API contracts: duplicated request/response shapes between routes, clients, hooks, schemas, and mocks.
- [ ] State and domain contracts: duplicated store state, event payloads, selector return types, status machines, and action names.
- [ ] Monorepo ownership: feature-private imports, premature shared packages, app-global junk drawers, and cross-package drift.
- [ ] Generated-code boundary: generated files mixed with hand-written code, stale generated contracts, and missing ignore guidance.
- [ ] Naming drift: same concept named `status`, `state`, `phase`, `mode`, `kind`, or `type` across owners.

## Report Quality

- [ ] The final report has 5-15 useful tasks or leads for a non-trivial repo.
- [ ] Each task has a stable ID, module, confidence, files, reason, safe action, validation, and permission status.
- [ ] Ignored leads explain why they were ignored.
- [ ] Setup leads are grouped; missing Biome, Prettier, and ESLint should not become separate tasks if the repo only needs one formatter path and one lint path.
- [ ] The report is useful without scanner output open beside it.

## Feedback Template

```md
Target:
Repo shape:
Command:
Modules tested:
Useful tasks:
False positives:
Missed issues:
Rule or scanner change needed:
Would I trust an agent to act from the report after permission? yes/no
Notes:
```
