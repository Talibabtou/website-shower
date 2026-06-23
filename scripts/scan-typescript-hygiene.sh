#!/usr/bin/env bash

set -uo pipefail

TARGET="${1:-.}"
MAX_SECTION_LINES="${MAX_SECTION_LINES:-300}"

if [ ! -d "$TARGET" ]; then
  echo "error: target is not a directory: $TARGET" >&2
  exit 1
fi

section() {
  printf '\n== %s ==\n' "$1"
}

limit_output() {
  awk -v max="$MAX_SECTION_LINES" '
    NR <= max { print }
    NR == max + 1 {
      printf "... truncated after %d lines; narrow the target path for more detail.\n", max
      exit
    }
  '
}

run_rg() {
  local pattern="$1"
  shift

  rg \
    --color never \
    --line-number \
    --glob '*.ts' \
    --glob '*.tsx' \
    --glob '!*.d.ts' \
    --glob '!**/*.d.ts' \
    --glob '!**/__generated__/**' \
    --glob '!**/generated/**' \
    "$@" \
    "$pattern" \
    "$TARGET" 2>/dev/null | limit_output || true
}

has_file() {
  local path
  for path in "$@"; do
    if [ -f "$TARGET/$path" ]; then
      return 0
    fi
  done
  return 1
}

first_existing_file() {
  local path
  for path in "$@"; do
    if [ -f "$TARGET/$path" ]; then
      printf '%s\n' "$TARGET/$path"
      return 0
    fi
  done
  return 1
}

file_has() {
  local file="$1"
  local pattern="$2"
  rg --quiet "$pattern" "$file" 2>/dev/null
}

print_missing() {
  printf 'missing recommended guardrail: %s\n' "$1"
}

section "Target"
printf '%s\n' "$TARGET"

section "Repo shape"
for path in \
  package.json \
  tsconfig.json \
  jsconfig.json \
  vite.config.ts \
  next.config.js \
  next.config.mjs; do
  if [ -e "$TARGET/$path" ]; then
    printf '%s\n' "$path"
  fi
done

section "Checker config files"
for path in \
  biome.json \
  biome.jsonc \
  eslint.config.js \
  eslint.config.mjs \
  eslint.config.cjs \
  .eslintrc \
  .eslintrc.json \
  .eslintrc.js \
  .prettierrc \
  .prettierrc.json \
  .prettierrc.js \
  .prettierrc.cjs \
  .prettierignore \
  prettier.config.js \
  prettier.config.cjs \
  prettier.config.mjs \
  oxlint.json \
  knip.json \
  knip.ts; do
  if [ -e "$TARGET/$path" ]; then
    printf '%s\n' "$path"
  fi
done

section "Package checker scripts"
if [ -f "$TARGET/package.json" ]; then
  rg --color never --line-number '"(lint|format|check|typecheck|type-check|biome|eslint|prettier|knip|fallow|ts-prune)"[[:space:]]*:' "$TARGET/package.json" 2>/dev/null | limit_output || true
fi

section "TypeScript config guardrails"
tsconfig="$(first_existing_file tsconfig.json tsconfig.base.json 2>/dev/null || true)"
if [ -n "$tsconfig" ]; then
  printf 'config: %s\n' "${tsconfig#"$TARGET/"}"
  file_has "$tsconfig" '"strict"[[:space:]]*:[[:space:]]*true' || print_missing 'tsconfig compilerOptions.strict: true'
  file_has "$tsconfig" '"noImplicitAny"[[:space:]]*:[[:space:]]*true' || print_missing 'tsconfig compilerOptions.noImplicitAny: true, unless strict already owns it'
  file_has "$tsconfig" '"noUncheckedIndexedAccess"[[:space:]]*:[[:space:]]*true' || print_missing 'tsconfig compilerOptions.noUncheckedIndexedAccess: true'
  file_has "$tsconfig" '"exactOptionalPropertyTypes"[[:space:]]*:[[:space:]]*true' || print_missing 'tsconfig compilerOptions.exactOptionalPropertyTypes: true'
  file_has "$tsconfig" '"noImplicitOverride"[[:space:]]*:[[:space:]]*true' || print_missing 'tsconfig compilerOptions.noImplicitOverride: true, mainly useful for class-heavy repos'
else
  print_missing 'tsconfig.json with strict TypeScript compiler options'
fi

section "Biome guardrails"
biome_config="$(first_existing_file biome.json biome.jsonc 2>/dev/null || true)"
if [ -n "$biome_config" ]; then
  printf 'config: %s\n' "${biome_config#"$TARGET/"}"
  file_has "$biome_config" '"formatter"[[:space:]]*:' || print_missing 'Biome formatter block'
  file_has "$biome_config" '"linter"[[:space:]]*:' || print_missing 'Biome linter block'
  file_has "$biome_config" '"noExplicitAny"[[:space:]]*:' || print_missing 'Biome rule suspicious/noExplicitAny'
  file_has "$biome_config" '"noDebugger"[[:space:]]*:' || print_missing 'Biome rule suspicious/noDebugger'
  file_has "$biome_config" '"useConst"[[:space:]]*:' || print_missing 'Biome rule style/useConst'
  file_has "$biome_config" '"noUnusedVariables"[[:space:]]*:' || print_missing 'Biome rule correctness/noUnusedVariables'
  file_has "$biome_config" '"useSortedClasses"[[:space:]]*:' || print_missing 'Biome Tailwind class sorting when Tailwind is used'
  file_has "$biome_config" '"noDuplicateClasses"[[:space:]]*:' || print_missing 'Biome assist source.noDuplicateClasses when Tailwind is used'
elif ! has_file eslint.config.js eslint.config.mjs eslint.config.cjs .eslintrc .eslintrc.json .eslintrc.js; then
  print_missing 'Biome or ESLint config'
fi

section "Prettier guardrails"
prettier_config="$(first_existing_file .prettierrc .prettierrc.json .prettierrc.js .prettierrc.cjs prettier.config.js prettier.config.cjs prettier.config.mjs 2>/dev/null || true)"
if [ -n "$prettier_config" ]; then
  printf 'config: %s\n' "${prettier_config#"$TARGET/"}"
  file_has "$prettier_config" 'singleQuote' || print_missing 'Prettier singleQuote policy'
  file_has "$prettier_config" 'semi' || print_missing 'Prettier semicolon policy'
  file_has "$prettier_config" 'trailingComma' || print_missing 'Prettier trailingComma policy'
  file_has "$prettier_config" 'printWidth' || print_missing 'Prettier printWidth policy'
  has_file .prettierignore || print_missing 'Prettier ignore file for generated and build output'
elif ! has_file biome.json biome.jsonc; then
  print_missing 'Prettier or Biome formatter config'
fi

section "ESLint guardrails"
eslint_config="$(first_existing_file eslint.config.js eslint.config.mjs eslint.config.cjs .eslintrc .eslintrc.json .eslintrc.js 2>/dev/null || true)"
if [ -n "$eslint_config" ]; then
  printf 'config: %s\n' "${eslint_config#"$TARGET/"}"
  file_has "$eslint_config" '@typescript-eslint/no-explicit-any' || print_missing 'ESLint @typescript-eslint/no-explicit-any'
  file_has "$eslint_config" '@typescript-eslint/no-unused-vars' || print_missing 'ESLint @typescript-eslint/no-unused-vars with underscore ignore patterns'
  file_has "$eslint_config" 'no-unused-vars' || print_missing 'ESLint base no-unused-vars explicitly off when TypeScript rule is on'
  file_has "$eslint_config" 'no-debugger' || print_missing 'ESLint no-debugger'
  file_has "$eslint_config" 'no-console' || print_missing 'ESLint no-console with allowed warn/error if the repo wants console errors'
  file_has "$eslint_config" 'prefer-const' || print_missing 'ESLint prefer-const'
  file_has "$eslint_config" 'eqeqeq' || print_missing 'ESLint eqeqeq with null exception when needed'
  if rg --quiet 'next|react' "$TARGET/package.json" "$eslint_config" 2>/dev/null; then
    file_has "$eslint_config" 'react-hooks/exhaustive-deps' || print_missing 'ESLint react-hooks/exhaustive-deps for React/Next repos'
  fi
fi

section "Other checker leads"
if [ -f "$TARGET/package.json" ]; then
  rg --quiet '"typescript"|tsc' "$TARGET/package.json" 2>/dev/null && rg --quiet '"(typecheck|type-check)"[[:space:]]*:' "$TARGET/package.json" 2>/dev/null || print_missing 'package.json typecheck script, usually tsc --noEmit'
  rg --quiet 'biome|eslint' "$TARGET/package.json" 2>/dev/null && rg --quiet '"lint"[[:space:]]*:' "$TARGET/package.json" 2>/dev/null || print_missing 'package.json lint script'
  rg --quiet 'biome|prettier' "$TARGET/package.json" 2>/dev/null && rg --quiet '"(format|format:check)"[[:space:]]*:' "$TARGET/package.json" 2>/dev/null || print_missing 'package.json format or format:check script'
  rg --quiet 'knip|ts-prune|fallow' "$TARGET/package.json" 2>/dev/null || print_missing 'optional dead-code checker such as fallow, knip, or ts-prune'
fi

section "Any and unknown pressure"
run_rg '(:[[:space:]]*any\b|<any>|as[[:space:]]+any\b|unknown\b)'

section "Unsafe casts"
run_rg '(as[[:space:]]+unknown[[:space:]]+as|as[[:space:]]+[A-Z][A-Za-z0-9_<>]*(\[\])?)'

section "TypeScript suppressions"
run_rg '(@ts-ignore|@ts-expect-error|@ts-nocheck)'

section "JavaScript files in typed source"
rg \
  --color never \
  --line-number \
  --glob '*.js' \
  --glob '*.jsx' \
  --glob '!**/node_modules/**' \
  --glob '!**/dist/**' \
  --glob '!**/build/**' \
  --glob '!**/.next/**' \
  '^' \
  "$TARGET/src" 2>/dev/null | limit_output || true

section "Hand-written API contract names"
run_rg '(type|interface)[[:space:]]+[A-Za-z0-9_]*(Request|Response|Payload|Dto|DTO|Api)[A-Za-z0-9_]*'

cat <<'NOTE'

== Notes ==
This script prints TypeScript hygiene candidates only. Do not rewrite types from this output alone.
Check whether each item is a real boundary, a migration leftover, generated output, or a justified escape hatch.
NOTE
