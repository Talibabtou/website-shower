# Types Constants Audit Roadmap

Goal: help an agent find TypeScript type and constant organization issues, then decide where each symbol should live using repo-grounded evidence.

## Done

- [x] Create `SKILL.md` with trigger wording, manual workflow, and reporting rules.
- [x] Add placement guidance in `references/placement-rules.md`.
- [x] Add report shape and severity labels in `references/report-format.md`.
- [x] Add `agents/openai.yaml` metadata.
- [x] Add `README.md` with install and usage notes.
- [x] Add `scripts/scan-types-constants.sh`.
- [x] Make the scanner dependency-free except for `rg`.
- [x] Make the scanner report candidates only, without placement decisions.
- [x] Detect candidate type/constant files, large TS files, type aliases, interfaces, enums, `as const`, uppercase constants, barrel imports, likely literal unions, repeated type/interface names, repeated watched literals, and repeated primitive constant values.
- [x] Let `rg` honor the target repo's `.gitignore`; use fallback generated-folder exclusions only when no `.gitignore` is available.
- [x] Filter noisy Next.js route handler exports like `export const GET`.
- [x] Smoke test the scanner on this repo.
- [x] Smoke test the scanner on one local TypeScript repo.
- [x] Add a tiny fixture repo under `examples/fixture/`.
- [x] Add a script smoke test that asserts key scanner sections appear.
- [x] Update the skill to make read-only audit mode explicit.

## Next

- [ ] Run one full manual audit using scanner output.
- [ ] Revise `SKILL.md` and references from that audit report.
- [ ] Confirm the skill can produce 5-15 useful findings without editing files.

## Real Repo Validation

- [ ] Test on a small Next.js app.
- [ ] Test on a feature-heavy React app.
- [ ] Test on a monorepo package.
- [ ] Test on a messy older repo with global `types.ts`.
- [ ] Record only behavior-changing misses or false positives.
- [ ] Stop changing placement rules after two different repos produce no new rule changes.

## Later

- [ ] Add `LICENSE`.
- [ ] Add one anonymized before/after audit report in `examples/`.
- [ ] Add AST tooling only if real repos show `rg` cannot handle export usage, duplicate type shapes, literal unions, or enum-like objects cleanly.
- [ ] Run the Codex skill validator when available.
- [ ] Create a versioned release tag.
