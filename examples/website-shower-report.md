# Website Shower Report

Fixture report generated from read-only scanner output. No audited files were changed.

## Summary

- Total tasks: 6
- Safe first cleanup: `WS-004`
- Needs human decision: `WS-003`, `WS-006`
- Commands used:

```bash
MAX_SECTION_LINES=80 scripts/scan-website-shower.sh examples/fixture
```

## Cleanup Checklist

- [ ] WS-001 Deduplicate `WorkItem`
  Module: types-constants
  Confidence: high
  Files:
  - `examples/fixture/src/state/contracts.ts:11`
  - `examples/fixture/src/state/feature/workSlice.ts:3`
  Why:
  The state owner and state slice both declare the same item shape. The `side` and `status` fields can drift.
  Safe action:
  Keep `WorkItem` in `src/state/contracts.ts`, import it in `workSlice.ts`, and remove the local interface.
  Validation:
  Run the repo typecheck after import updates.
  Permission: required

- [ ] WS-002 Name and reuse `WorkStatus`
  Module: types-constants
  Confidence: high
  Files:
  - `examples/fixture/src/state/contracts.ts:14`
  - `examples/fixture/src/state/feature/workSlice.ts:6`
  Why:
  `'queued' | 'done' | 'error'` appears in two item contracts and also drives filtering.
  Safe action:
  Add `export type WorkStatus = 'queued' | 'done' | 'error';` next to `WorkItem`, then use it from the owned contract.
  Validation:
  Run typecheck and confirm selectors still compare the same values.
  Permission: required

- [ ] WS-003 Consolidate preview worker messages
  Module: types-constants
  Confidence: high
  Files:
  - `examples/fixture/src/workers/previewWorker.ts:1`
  - `examples/fixture/src/workers/previewWorker.ts:9`
  - `examples/fixture/src/feature/usePreviewWorker.ts:1`
  - `examples/fixture/src/feature/usePreviewWorker.ts:9`
  Why:
  Both sides of a worker-style message protocol declare request and response shapes independently.
  Safe action:
  Move `PreviewWorkerRequest` and `PreviewWorkerResponse` to a small worker contract file and import them from both sides.
  Validation:
  Run typecheck and manually confirm message strings are unchanged.
  Permission: required

- [ ] WS-004 Remove stale env helpers
  Module: unused-code
  Confidence: medium
  Files:
  - `examples/fixture/src/config/env.ts:5`
  - `examples/fixture/src/config/env.ts:7`
  - `examples/fixture/src/config/env.ts:9`
  Why:
  The fallback unused-code scan found exported helpers that only appear at declaration. They are candidates, not proof.
  Safe action:
  If `rg` and the app entrypoints confirm no usage, delete `getLegacyApiUrl`, `getUnusedCallbackUrl`, and `buildPreviewUrl`.
  Validation:
  Run typecheck and the smallest app build command.
  Permission: required

- [ ] WS-005 Import `DomainEvent` from the owner
  Module: types-constants
  Confidence: high
  Files:
  - `examples/fixture/src/state/contracts.ts:17`
  - `examples/fixture/src/feature/consumeEvent.ts:1`
  Why:
  The consumer repeats the event payload owned by the state contract.
  Safe action:
  Delete the local `DomainEvent` interface in `consumeEvent.ts` and import the owned type.
  Validation:
  Run typecheck.
  Permission: required

- [ ] WS-006 Decide whether `ResourceMap` is shared production shape
  Module: types-constants
  Confidence: medium
  Files:
  - `examples/fixture/src/feature/sourceData.ts:1`
  - `examples/fixture/src/feature/preloadData.ts:1`
  Why:
  The shape repeats in nearby data helpers, but the owner depends on whether these files are generated, fixture-only, or production-owned.
  Safe action:
  If production-owned, move `ResourceMap` to the nearest feature model file. Otherwise leave it local.
  Validation:
  Check file ownership before editing.
  Permission: required

## Leads Ignored

- `default` in `src/ui/control.ts` is a local UI variant, not a domain constant.
- `AppState` appears twice, but one version is store-derived. Store-derived state often wins over hand-written aliases.
- Basic unused-code fallback output is weaker than `fallow`; every unused-code item needs a follow-up search before deletion.
