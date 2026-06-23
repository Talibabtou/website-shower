# Report Format

Lead with findings. Omit empty sections.

## Structure

```md
Findings

1. `SymbolName` duplicated across unrelated features
   Severity: medium
   Confidence: high
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
- Need exact worker and hook file paths before this can be high confidence.
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
