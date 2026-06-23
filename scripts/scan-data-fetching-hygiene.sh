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

section "Fetch and client calls"
run_rg '\b(fetch|axios|ky|useQuery|useSWR|createQuery|queryOptions)\b'

section "Query key leads"
run_rg '(queryKey|QueryKey|useQuery\(|useSWR\(|\[[[:space:]]*["'\''][A-Za-z0-9_:/.-]+["'\''][[:space:]]*\])'

section "Cache policy leads"
run_rg '(cache:[[:space:]]*["'\''](no-store|force-cache|default-cache|reload)["'\'']|next:[[:space:]]*\{[[:space:]]*revalidate|revalidate:[[:space:]]*[0-9]+)'

section "Fetch wrapper leads"
run_rg '(export[[:space:]]+const[[:space:]]+(load|fetch|get|read)[A-Za-z0-9_]+|function[[:space:]]+(load|fetch|get|read)[A-Za-z0-9_]+)'

section "JSON validation leads"
run_rg '\.json\(\)|as[[:space:]]+Promise<|as[[:space:]]+[A-Z][A-Za-z0-9_<>]*|z\.object|safeParse|parse\('

section "Client server fetching mix leads"
run_rg '^[[:space:]]*["'\'']use client["'\'']|fetch\([^)]*["'\'']/(api|items)|Response\.json|NextResponse\.json'

cat <<'NOTE'

== Notes ==
This script prints data-fetching candidates only. Confirm framework cache rules,
client/server boundary, runtime validation, and query ownership before reporting.
NOTE
