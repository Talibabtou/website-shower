# Types Constants Audit Roadmap

Goal: help an agent find TypeScript type and constant organization issues, then decide where each symbol should live using repo-grounded evidence.

## Done

- [x] Create `SKILL.md` with trigger wording, manual workflow, read-only posture, and reporting rules.
- [x] Add placement guidance in `references/placement-rules.md`.
- [x] Add signal/noise guidance in `references/audit-heuristics.md`.
- [x] Add report shape and severity labels in `references/report-format.md`.
- [x] Add `agents/openai.yaml` metadata.
- [x] Add public `README.md` with setup, usage, and agent compatibility notes.
- [x] Add `scripts/scan-types-constants.sh`.
- [x] Make the scanner dependency-free except for `rg`.
- [x] Make the scanner report candidates only, without placement decisions.
- [x] Detect candidate type/constant files, large TS files, type aliases, interfaces, enums, `as const`, uppercase constants, barrel imports, likely literal unions, repeated type/interface names, repeated watched literals, and repeated primitive constant values.
- [x] Let `rg` honor the target repo's `.gitignore`; use fallback generated-folder exclusions only when no `.gitignore` is available.
- [x] Filter noisy Next.js route handler exports like `export const GET`.
- [x] Filter checked-in generated TypeScript declaration and IDL-style files from scanner output.
- [x] Cap noisy scanner sections with `MAX_SECTION_LINES`.
- [x] Add a tiny anonymized fixture repo under `examples/fixture/`.
- [x] Add `tests/smoke-test.sh` that asserts key scanner sections appear.
- [x] Smoke test the scanner on this repo.
- [x] Test on clean repo `portfolio`; use it to calibrate false positives.
- [x] Test on feature-oriented repo `demos-cratos`; use it to calibrate feature-local ownership.
- [x] Test on massive monorepo `demos-cratos/monorepo`; use it to add monorepo scoping guidance.
- [x] Add lightweight cross-agent compatibility entry points.
- [x] Add MIT `LICENSE`.
- [x] Add `package.json` version metadata and `npm test`.
- [x] Add agent portability docs and instruction adapters for Cursor, Windsurf, Cline, Kiro, Copilot, `.agents`, and `AGENTS.md`.
- [x] Add OpenCode compatibility through `opencode.json` and `.opencode/`.
- [x] Add OpenClaw compatibility through `.openclaw/skills/types-constants-audit/`.
- [x] Add `scripts/install-agent.sh` for local agent adapter installation.
- [x] Move smoke testing into `tests/`.
- [x] Add example markdown under `examples/`.
- [x] Add a reusable report template in `examples/report-template.md`.
- [x] Add a first anonymized example report in `examples/audit-report.md`.
- [x] Require concrete file-path evidence for release-quality findings.

## Release Gate: v0.1.0

These tasks decide whether the current skill is genuinely releasable. Do them before adding any phase-two capability.

- [x] Upgrade `examples/audit-report.md` into a richer before/after-style report:
  - show scanner signals before judgment
  - show final findings after judgment
  - include ignored leads and why they were ignored
  - keep all names anonymous
  - keep the report read-only; no audited files are modified
- [x] Run one full manual validation audit from scanner output.
- [x] Confirm the skill can produce 5-15 useful findings or leads without editing files.
- [x] Record validation outcome in `examples/validation-notes.md`:
  - target shape
  - command used
  - number of findings
  - false positives ignored
  - misses or rule changes discovered
- [x] Add `docs/release-notes-v0.1.0.md` only after validation is recorded.
- [x] Install the skill in Codex and run real-repo validation from the installed skill.
- [x] Run `npm test`.
- [x] Review the public repo surface for release:
  - `README.md`
  - `SKILL.md`
  - `AGENTS.md`
  - agent adapters
  - examples
  - tests
  - license
- [x] Tag `v0.1.0` after the release gate is complete.

## Real Repo Validation

- [x] Test on a small/clean Next.js app.
- [x] Test on a feature-heavy React app.
- [x] Test on a monorepo package.
- [x] Optional before `v0.1.0`: test on a messy older repo with global `types.ts`.
- [x] Record only behavior-changing misses or false positives.
- [x] Stop changing placement rules after two different repos produce no new rule changes.

## Scope Guardrails

- [ ] Do not add commands until there are at least two real workflows.
- [ ] Do not add AST tooling until `rg` fails on a real validation task.
- [ ] Do not add Tailwind, React/Next, unused-code, or TypeScript-migration audits before `v0.1.0`.
- [ ] Do not turn the current skill into a generic cleanup skill until the type/constant audit is release-quality.

## Phase Two: Website Maintenance And Code Hygiene

Keep v0.1 focused on type and constant drift. After v0.1 is released, expand into a broader website maintenance skill in separate, testable modules. Each module should ship with its own scanner or workflow, example report, validation notes, and optional command.

Working name: **Website Shower**. This should be an all-in-one read-only website maintenance audit that produces a Markdown checklist report for humans and agents. The workflow should be: multi-audit -> TODO report -> ask human permission -> clean without changing functionality.

- [x] Add first coordination references for Website Shower: `references/audit-orchestrator.md`.
- [x] Add read-only multi-module candidate scanner: `scripts/scan-website-shower.sh`.
- [x] Add separate unused-code scanner: `scripts/scan-unused-code.sh`.
- [x] Add unused-code guidance using `fallow`: `references/unused-code.md`.
- [ ] Validate the `fallow` unused-code module on a real repo and record false positives.
- [ ] Convert multi-module scanner output into a first `examples/website-shower-report.md` checklist.
- [ ] TypeScript migration hygiene: `any`, unsafe casts, duplicate hand-written API types, weak `unknown` bridges, old JS migration leftovers.
- [ ] React and Next.js habit audit: server/client boundary drift, route constants, metadata duplication, cache/fetch option drift, prop type placement.
- [ ] Tailwind cleanup audit: config drift, repeated arbitrary values, unused theme tokens, one-off utility patterns that should become design tokens, and class soup in shared components.
- [ ] API contract hygiene: duplicated request/response shapes between routes, clients, hooks, schemas, and mocks.
- [ ] State and domain contract hygiene: duplicated store state, event payloads, selector return types, status machines, and action names.
- [ ] Monorepo ownership hygiene: feature-private imports, premature shared packages, app-global junk drawers, and cross-package contract drift.
- [ ] Generated-code boundary audit: generated files mixed with hand-written code, stale generated contracts, and missing ignore guidance.
- [ ] Naming drift audit: same concept named `status`, `state`, `phase`, `mode`, `kind`, or `type` across different owners.
- [ ] Add command workflows only when there are distinct modes, for example `.opencode/command/audit-types.md`, `.opencode/command/audit-tailwind.md`, and `.opencode/command/audit-unused.md`.

## Later

- [ ] Add AST tooling only if real repos show `rg` cannot handle export usage, duplicate type shapes, literal unions, or enum-like objects cleanly.
- [ ] Generate adapters from one canonical source if manual adapter sync becomes error-prone.
- [ ] Run the Codex skill validator when available.
