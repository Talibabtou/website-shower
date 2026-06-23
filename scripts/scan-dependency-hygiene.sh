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
    --glob '*.json' \
    --glob '*.ts' \
    --glob '*.tsx' \
    --glob '*.js' \
    --glob '*.jsx' \
    --glob '!**/node_modules/**' \
    --glob '!**/dist/**' \
    --glob '!**/build/**' \
    "$@" \
    "$pattern" \
    "$TARGET" 2>/dev/null | limit_output || true
}

section "Target"
printf '%s\n' "$TARGET"

section "Package manager signals"
for path in \
  package.json \
  pnpm-lock.yaml \
  pnpm-workspace.yaml \
  yarn.lock \
  package-lock.json \
  bun.lock \
  bun.lockb; do
  if [ -e "$TARGET/$path" ]; then
    printf '%s\n' "$path"
  fi
done

lock_count=0
for path in pnpm-lock.yaml yarn.lock package-lock.json bun.lock bun.lockb; do
  if [ -e "$TARGET/$path" ]; then
    lock_count=$((lock_count + 1))
  fi
done
if [ "$lock_count" -gt 1 ]; then
  printf 'mixed package manager locks detected\n'
fi

section "Package manifests"
rg --files "$TARGET" \
  --glob 'package.json' \
  --glob '!**/node_modules/**' \
  --glob '!**/dist/**' \
  --glob '!**/build/**' 2>/dev/null |
  sort |
  limit_output

section "Dependency declarations"
run_rg '"(dependencies|devDependencies|peerDependencies|optionalDependencies)"[[:space:]]*:' --glob 'package.json'

section "Declared package names"
run_rg '"(@?[A-Za-z0-9_.-]+(/[A-Za-z0-9_.-]+)?)"[[:space:]]*:[[:space:]]*"([^"]+)"' --glob 'package.json'

section "Import package names"
run_rg 'from[[:space:]]+["'\''](@[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+|[A-Za-z][A-Za-z0-9_.-]*)(/[^"'\'']*)?["'\'']|import\(["'\''](@[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+|[A-Za-z][A-Za-z0-9_.-]*)(/[^"'\'']*)?["'\'']\)'

section "Tooling dependencies in dependencies"
awk '
  /"dependencies"[[:space:]]*:/ { in_deps = 1; next }
  /"devDependencies"[[:space:]]*:/ || /"peerDependencies"[[:space:]]*:/ || /"optionalDependencies"[[:space:]]*:/ { in_deps = 0 }
  in_deps && /"(@types\/|typescript|eslint|prettier|biome|tailwindcss|vitest|jest|playwright|ts-node|tsx|knip|fallow)"/ { print FILENAME ":" FNR ":" $0 }
' $(rg --files "$TARGET" --glob 'package.json' --glob '!**/node_modules/**' 2>/dev/null) 2>/dev/null | limit_output

section "Runtime dependencies in devDependencies"
awk '
  /"devDependencies"[[:space:]]*:/ { in_dev = 1; next }
  /"dependencies"[[:space:]]*:/ || /"peerDependencies"[[:space:]]*:/ || /"optionalDependencies"[[:space:]]*:/ { if (in_dev) in_dev = 0 }
  in_dev && /"(react|react-dom|next|vue|svelte|zod|axios|ky|date-fns|lodash|lodash-es|clsx|classnames)"/ { print FILENAME ":" FNR ":" $0 }
' $(rg --files "$TARGET" --glob 'package.json' --glob '!**/node_modules/**' 2>/dev/null) 2>/dev/null | limit_output

section "Duplicate dependency family leads"
run_rg '"(clsx|classnames)"[[:space:]]*:' --glob 'package.json'
run_rg '"(axios|ky|got)"[[:space:]]*:' --glob 'package.json'
run_rg '"(moment|dayjs|date-fns)"[[:space:]]*:' --glob 'package.json'
run_rg '"(lodash|lodash-es|underscore)"[[:space:]]*:' --glob 'package.json'

section "Workspace dependency leads"
run_rg '"workspace:[^"]*"' --glob 'package.json'

cat <<'NOTE'

== Notes ==
This script prints dependency candidates only. Confirm package manager policy, import usage,
runtime needs, peer dependency needs, and workspace boundaries before reporting a cleanup task.
Do not delete dependencies from this output alone.
NOTE
