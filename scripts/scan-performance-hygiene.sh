#!/usr/bin/env bash

set -uo pipefail

TARGET="${1:-.}"
MAX_SECTION_LINES="${MAX_SECTION_LINES:-300}"

if [ ! -d "$TARGET" ]; then
  echo "error: target is not a directory: $TARGET" >&2
  exit 1
fi

section() { printf '\n== %s ==\n' "$1"; }

limit_output() {
  awk -v max="$MAX_SECTION_LINES" 'NR <= max { print } NR == max + 1 { printf "... truncated after %d lines; narrow the target path for more detail.\n", max; exit }'
}

run_rg() {
  rg --color never --line-number --glob '*.ts' --glob '*.tsx' --glob '*.js' --glob '*.jsx' --glob '!**/node_modules/**' --glob '!**/dist/**' --glob '!**/build/**' "$1" "$TARGET" 2>/dev/null | limit_output || true
}

section "Target"
printf '%s\n' "$TARGET"

section "Client boundary leads"
run_rg '^[[:space:]]*["'\'']use client["'\'']'

section "Large TSX files"
rg --files "$TARGET" --glob '*.tsx' --glob '*.jsx' --glob '!**/node_modules/**' 2>/dev/null |
  while IFS= read -r file; do
    lines="$(wc -l < "$file" 2>/dev/null | tr -d ' ')"
    case "$lines" in ''|*[!0-9]*) continue ;; esac
    if [ "$lines" -ge 45 ]; then
      printf '%s lines %s\n' "$lines" "$file"
    fi
  done | sort -nr | limit_output

section "Dynamic import leads"
run_rg 'dynamic\(|import\(["'\''][^"'\'']+["'\'']\)'

section "Image optimization leads"
run_rg '<img[[:space:]]|background-image:[[:space:]]*url\('

section "Unbounded list render leads"
run_rg '\.map\([^)]+\)[[:space:]]*=>|[A-Za-z0-9_]+\.map\('

section "Bundle pressure leads"
run_rg 'from[[:space:]]+["'\''](lodash|moment|chart\.js|three|framer-motion|@mui|antd|react-icons)'

cat <<'NOTE'

== Notes ==
This script prints performance candidates only. Confirm route behavior, bundle tooling,
image requirements, and list size before reporting a performance cleanup task.
NOTE
