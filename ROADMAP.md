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
- [x] Add a script smoke test that asserts key scanner sections appear.
- [x] Smoke test the scanner on this repo.
- [x] Test on clean repo `portfolio`; use it to calibrate false positives.
- [x] Test on feature-oriented repo `demos-cratos`; use it to calibrate feature-local ownership.
- [x] Test on massive monorepo `demos-cratos/monorepo`; use it to add monorepo scoping guidance.
- [x] Add lightweight cross-agent compatibility entry points.

## Next

- [ ] Add `LICENSE`.
- [ ] Add one anonymized before/after audit report in `examples/`.
- [ ] Add a short GitHub-ready badge/header section once the repo has a first release.
- [ ] Run one full manual audit report using scanner output.
- [ ] Confirm the skill can produce 5-15 useful findings without editing files.

## Real Repo Validation

- [x] Test on a small/clean Next.js app.
- [x] Test on a feature-heavy React app.
- [x] Test on a monorepo package.
- [ ] Test on a messy older repo with global `types.ts`.
- [ ] Record only behavior-changing misses or false positives.
- [ ] Stop changing placement rules after two different repos produce no new rule changes.

## Later

- [ ] Add `package.json` only if we introduce Node-based validation or generated compatibility files.
- [ ] Add AST tooling only if real repos show `rg` cannot handle export usage, duplicate type shapes, literal unions, or enum-like objects cleanly.
- [ ] Add generated adapters for specific agents only after the canonical `SKILL.md` stabilizes.
- [ ] Run the Codex skill validator when available.
- [ ] Create a versioned release tag.
