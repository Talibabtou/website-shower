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
  rg --color never --line-number --glob '*.tsx' --glob '*.jsx' --glob '!**/node_modules/**' --glob '!**/dist/**' --glob '!**/build/**' "$1" "$TARGET" 2>/dev/null | limit_output || true
}

section "Target"
printf '%s\n' "$TARGET"

section "Component files"
rg --files "$TARGET" --glob '*.tsx' --glob '*.jsx' --glob '!**/node_modules/**' 2>/dev/null |
  rg '(^|/)(components|ui|app|pages|features|feature)/|[A-Z][A-Za-z0-9_]+\.tsx$' |
  limit_output || true

section "Large component files"
rg --files "$TARGET" --glob '*.tsx' --glob '*.jsx' --glob '!**/node_modules/**' 2>/dev/null |
  while IFS= read -r file; do
    lines="$(wc -l < "$file" 2>/dev/null | tr -d ' ')"
    case "$lines" in ''|*[!0-9]*) continue ;; esac
    if [ "$lines" -ge 45 ]; then
      printf '%s lines %s\n' "$lines" "$file"
    fi
  done | sort -nr | limit_output

section "Variant prop leads"
run_rg '\b(variant|mode|tone|size|intent|appearance)[?:]?[[:space:]]*:[[:space:]]*["'\''][A-Za-z0-9_-]+["'\''][[:space:]]*\|'

section "Loading error empty state leads"
run_rg '\b(isLoading|loading|error|isError|empty|isEmpty)\b|>(Loading|Error|Empty)<'

section "Client component server-work leads"
run_rg '^[[:space:]]*["'\'']use client["'\'']|fetch\(|process\.env|cookies\(|headers\(|db\.|prisma\.'

section "Repeated component pattern leads"
run_rg 'className=.*(p-6|text-sm|text-slate|text-red)|<img[[:space:]]|records\.map|items\.map'

cat <<'NOTE'

== Notes ==
This script prints component hygiene candidates only. Confirm component ownership,
framework rules, props API, and user-visible states before reporting a cleanup task.
NOTE
