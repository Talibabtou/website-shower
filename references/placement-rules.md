# Placement Rules

Use these rules after checking actual usage.

## Inline

Keep a value inline when:
- used once
- literal is clearer than a name
- name would only repeat the value
- value belongs to JSX, HTML, test text, or framework syntax

Examples:

```tsx
<button type="button" aria-label="Close" />
expect(screen.getByText("Publish")).toBeVisible()
```

Bad extraction:

```ts
const BUTTON_TYPE_BUTTON = "button"
```

## Feature-Local

Use feature-local `types.ts` or `constants.ts` when one product area owns the concept.

Good owners:
- `src/features/billing/types.ts`
- `src/features/editor/constants.ts`
- `src/domains/account/status.ts`

Signals:
- all usages sit under one feature/domain
- exported value names mention feature vocabulary
- external API belongs only to that feature
- other code should not depend on it

## Shared Inside Feature Group

Use a nearby shared folder when sibling subfeatures share ownership.

Example:

```text
src/features/editor/
  shared/types.ts
  toolbar/
  canvas/
```

This is not app-global. It is still editor-owned.

## App-Global

Use app-global `src/types.ts`, `src/constants.ts`, or clearer named files only when unrelated features need the same concept.

Required evidence:
- two or more unrelated product areas use it
- concept has same meaning in each area
- shared name would reduce drift
- owner can be named without lying

Prefer named files over giant drawers:

```text
src/types/auth.ts
src/constants/routes.ts
src/constants/permissions.ts
```

Avoid dumping mixed exports into `src/types.ts` unless repo already uses that pattern and file stays small.

## Shared Package

Use a package only when more than one app/package consumes the symbol.

Signals:
- monorepo has multiple apps
- API contracts cross package boundary
- duplication already exists across packages

Do not create a package for one app.

## Enum-Like Values

Prefer literal unions and `as const` maps when repo already uses them.

Keep native `enum` only when repo already uses enums or runtime enum semantics matter.

Good pattern:

```ts
export const NOTE_STATUSES = ["draft", "published"] as const
export type NoteStatus = (typeof NOTE_STATUSES)[number]
```

Do not reuse an enum-like constant just because the string values match. If two database enums, tables, API resources, or lifecycle owners use the same literal, keep separate owner constants and derive separate types.

## Stale Exports

If exported symbol has no usage outside its own declaration file:
- delete it if unused
- unexport it if only local
- move it only after proving real usage

Barrel files can hide stale exports. Search both symbol name and import paths.

## Junk-Drawer Files

Flag a file when it mixes unrelated ownership:
- auth roles beside CMS statuses
- UI variants beside API payloads
- route constants beside table columns
- feature-specific types in app-global file

Recommend small splits by owner, not a full taxonomy.

## Evidence

Use `high` when usages clearly prove owner and action.

Use `medium` when usage is clear but naming or architecture leaves room.

Use `low` when dynamic imports, generated code, barrels, or unclear domain ownership hide evidence.
