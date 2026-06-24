# Report Format

Lead with findings. Omit empty sections.

Website Shower reports should end as a Markdown checklist. Classic numbered findings are still useful for type-only audits, but the multi-module report should produce tasks a human or agent can approve one by one.

Default artifact: write the final checklist to `website-shower-report.md` at the target repo root when file writes are available. If the user asks for chat-only output or the session is read-only, return the same report in chat and say no file was written.

Optional artifact: write `website-shower-report.json` only when requested. Do not make JSON the default report.

## Structure

```md
Findings

1. `SymbolName` duplicated across unrelated features
   Severity: medium
   Evidence: high
   Current:
   - `path/file.ts:12`
   - `path/other.ts:8`

   Recommendation:
   Move to `src/types/symbol-name.ts` and import from both sites.

   Reason:
   Same business concept and same literal set used by unrelated features.

   Next action:
   Create shared type, update imports, delete duplicate local aliases.
```

## Severity

Use `high` for:
- drift-prone duplicated unions used in unrelated runtime flows
- stale exports that mislead imports or public package API
- constants with conflicting values for same concept

Use `medium` for:
- junk-drawer files
- duplicated type shapes
- feature-owned values leaked into global files
- magic values repeated across feature boundaries

Use `low` for:
- cleanup that improves readability only
- naming drift with no behavior risk
- constants that could return inline

## Finding Types

Use one of these labels in the finding title:
- duplicated type
- duplicated literal union
- repeated magic value
- stale export
- junk-drawer file
- bad global placement
- bad local placement
- inline candidate

## Evidence Standard

Every finding must cite at least one exact file path. Prefer line numbers. A finding without concrete paths is not release-quality; either add the missing evidence or downgrade it to a lead with an `Evidence missing:` note.

Good:

```md
Current:
- `src/workers/floor-preview.worker.ts:12`
- `src/features/floor/hooks/useFloorPreview.ts:8`
```

Acceptable lead:

```md
Evidence missing:
- Need exact worker and hook file paths before this can be high evidence.
```

## Good Recommendation

Name exact move:

```md
Move `ResearchStatus` from `src/types.ts` to `src/features/research/types.ts`.
```

Or exact deletion:

```md
Delete `LEGACY_STATUS_LABELS`; no imports remain.
```

Or exact non-move:

```md
Keep `"button"` inline. Constant name adds noise and value is HTML syntax.
```

## Bad Recommendation

Avoid vague advice:

```md
Consider centralizing constants.
```

Avoid giant cleanup asks:

```md
Refactor all types into a better structure.
```

## Summary

After findings, add at most:
- total findings by severity
- safest first edit
- checks to run

If there are no findings, say no material issues found and mention search limits.

## Checklist Report

Use this shape for Website Shower reports:

```md
Report mode: read-only. Edits need a separate approval or follow-up request.

Commands used:
- `MAX_SECTION_LINES=300 scripts/scan-website-shower.sh .`
- focused `rg` checks for reported tasks
- unused-code checker used, or fallback used

Inspected scope:
- App roots/routes: `src/app`, `src/pages`, or selected app/package root
- Feature/domain roots: `src/features`, `src/components`, `src/lib`, `src/state`, or repo equivalents
- API/data boundaries: route handlers, API clients, data hooks, schemas, generated contracts
- Tests/generated: test folders checked; generated output skipped or treated as source-of-truth output

### Types And Constants

- [ ] WS-001 Short action title
  Evidence: high
  Change risk: medium
  Boundaries: external-api, client-server
  Files:
  - `src/example.ts:12`
  Why:
  Explain the drift or deletion risk.
  Safe action:
  Name the smallest edit that would fix it.
  Validation:
  Name the smallest check to run after edits.
```

Unchecked boxes mean `open`. Avoid repeating `Status: open` on every new task. Add lifecycle notes only when a task is revisited:

- `[ ]`: open
- `[x]`: fixed or otherwise closed, with a note
- `Lifecycle: accepted`
- `Lifecycle: ignored`
- `Lifecycle: false-positive`

Change risk means implementation risk, not evidence:

- `low`: docs, naming cleanup, deletion after a clear usage check, or local type-only cleanup.
- `medium`: import moves, ownership changes, component splits, checker setup, or formatter setup.
- `high`: API/data parsing, package boundary changes, server/client boundary changes, performance changes, or anything likely to affect runtime behavior.

Evidence means how strong the audit signal is: exact owner and usage proof is `high`, a repeated pattern that still needs context is `medium`, and a weak scanner lead is `low`.

Boundaries are optional tags that explain why validation matters. Use comma-separated values such as `external-api`, `client-server`, `package-boundary`, `state-store`, `generated-code`, `env-config`, `auth-session`, `database`, `local-storage`, `framework-entrypoint`, or `design-system`.

Group tasks by module using headings such as `### Component Hygiene` or `### API Contracts`. Do not repeat `Module:` inside every task.

Add `## Leads Ignored` when scanner output was noisy, a dirty repo produced many candidates, or any module had plausible false positives. Name the reason briefly, for example framework entrypoint, generated output, already-clean setup, public export, or weak fallback-only evidence.

Keep "already clean" observations out of the checklist unless they need an action. Put them in summary notes instead.

## Optional JSON Shape

Use this compact schema when a user or host asks for machine-readable output:

```json
{
  "schemaVersion": "website-shower-report/v1",
  "mode": "read-only",
  "target": ".",
  "commandsUsed": ["MAX_SECTION_LINES=300 scripts/scan-website-shower.sh ."],
  "inspectedScope": {
    "appRoots": ["src/app"],
    "featureRoots": ["src/features", "src/components"],
    "apiBoundaries": ["src/app/api", "src/lib/api"],
    "stateRoots": ["src/state"],
    "tests": ["tests"],
    "generatedSkipped": ["src/generated"]
  },
  "tasks": [
    {
      "id": "WS-001",
      "module": "types-constants",
      "title": "Short action title",
      "status": "open",
      "evidence": "high",
      "changeRisk": "medium",
      "boundaries": ["api", "client-server"],
      "files": ["src/example.ts:12"],
      "why": "Explain the drift or deletion risk.",
      "safeAction": "Name the smallest edit that would fix it.",
      "validation": ["pnpm run typecheck"]
    }
  ],
  "ignoredLeads": [
    {
      "module": "unused-code",
      "reason": "framework entrypoint",
      "files": ["src/app/page.tsx"]
    }
  ]
}
```

Keep JSON values short. Do not include full scanner output.
