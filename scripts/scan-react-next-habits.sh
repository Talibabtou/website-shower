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

section "Target"
printf '%s\n' "$TARGET"

section "Framework signals"
for path in \
  package.json \
  next.config.js \
  next.config.mjs \
  src/app \
  app \
  src/pages \
  pages; do
  if [ -e "$TARGET/$path" ]; then
    printf '%s\n' "$path"
  fi
done

section "Client boundary signals"
run_rg "['\"]use client['\"]|use(State|Effect|Memo|Callback|Ref|Reducer|Transition|Optimistic)\\("

section "App Router files with client hooks but no directive"
if command -v rg >/dev/null 2>&1; then
  rg --files "$TARGET" \
    --glob '**/src/app/**/*.tsx' \
    --glob '**/app/**/*.tsx' 2>/dev/null |
    while IFS= read -r file; do
      if rg --quiet 'use(State|Effect|Memo|Callback|Ref|Reducer|Transition|Optimistic)\(' "$file" &&
        ! rg --quiet "^['\"]use client['\"]" "$file"; then
        printf '%s: uses client hook without top-level use client directive\n' "$file"
      fi
    done | limit_output
fi

section "Metadata and route config exports"
run_rg 'export[[:space:]]+const[[:space:]]+(metadata|dynamic|revalidate|fetchCache|runtime|preferredRegion|maxDuration)'

section "Fetch cache option leads"
run_rg 'fetch\(|cache:[[:space:]]*['\''"](no-store|force-cache)['\''"]|next:[[:space:]]*\{[[:space:]]*revalidate'

section "Route-like string leads"
run_rg "['\"]/(api|admin|dashboard|items|profile|settings|search|auth|login|logout)[^'\"]*['\"]"

section "Component prop type leads"
run_rg '(type|interface)[[:space:]]+[A-Za-z0-9_]*(Props|PageProps|Params)[[:space:]]*'

cat <<'NOTE'

== Notes ==
This script prints React and Next.js habit candidates only. Confirm framework version, router mode,
server/client ownership, and route conventions before reporting a cleanup task.
NOTE
