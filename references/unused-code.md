# Unused Code Audit

Use this module to identify unused files, exports, dependencies, and stale helpers in TypeScript/JavaScript website repos.

## Tool

Prefer `fallow` for this module.

```bash
scripts/scan-unused-code.sh <target>
```

The script resolves tools in this order:

1. repo-local `node_modules/.bin/fallow`
2. globally available `fallow`
3. `npx --yes fallow` only when `FALLOW_USE_NPX=1`
4. basic `rg` fallback for exported symbols whose names appear only once

To allow `npx` resolution:

```bash
FALLOW_USE_NPX=1 scripts/scan-unused-code.sh <target>
```

If `fallow` is unavailable, the basic fallback is useful for orientation but weaker than `fallow`. Treat fallback output as leads only.

For a full candidate pass with other modules:

```bash
scripts/scan-website-shower.sh <target>
```

## Judgment

Unused-code findings are dangerous if applied blindly. Treat output as candidates until usage is traced.

Strong signals:

- export has no imports and is not an entrypoint API
- helper name is misleading and has no external usage
- dependency is unused in production and not required by tooling
- duplicated fallback config exists next to an env-owned source of truth

Weak signals:

- framework entrypoints
- route files
- config files loaded by convention
- public package exports
- dynamic imports
- generated files
- test helpers and story fixtures
- symbols found only by the basic fallback without `fallow` trace evidence

## Follow-Up

Before deleting:

```bash
fallow dead-code --trace <file>:<export>
fallow dead-code --trace-dependency <name>
rg "\\bSymbolName\\b" <target>
```

If the evidence remains clear, report the task as a checklist item and ask for permission before editing.
