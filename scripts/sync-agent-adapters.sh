#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
SOURCE="$ROOT/adapters/website-shower-rule.md"
MODE="${1:-write}"

usage() {
  cat <<'USAGE'
usage: scripts/sync-agent-adapters.sh [--check]

Copy the canonical Website Shower adapter rule into host-specific rule paths.

Default mode rewrites generated adapter files. --check verifies they are in sync.
USAGE
}

write_standard() {
  local destination="$1"

  mkdir -p "$(dirname "$destination")"
  cp "$SOURCE" "$destination"
}

write_cursor() {
  local destination="$1"

  mkdir -p "$(dirname "$destination")"
  {
    printf '%s\n' '---'
    printf '%s\n' 'description: Read-only Website Shower cleanup audit.'
    printf '%s\n' 'alwaysApply: false'
    printf '%s\n\n' '---'
    cat "$SOURCE"
  } > "$destination"
}

check_file() {
  local expected="$1"
  local actual="$2"

  if ! cmp -s "$expected" "$actual"; then
    printf 'out of sync: %s\n' "${actual#$ROOT/}" >&2
    return 1
  fi
}

check_standard() {
  local destination="$1"

  check_file "$SOURCE" "$destination"
}

check_cursor() {
  local destination="$1"
  local expected

  expected="$(mktemp "${TMPDIR:-/tmp}/website-shower-cursor.XXXXXX")"
  {
    printf '%s\n' '---'
    printf '%s\n' 'description: Read-only Website Shower cleanup audit.'
    printf '%s\n' 'alwaysApply: false'
    printf '%s\n\n' '---'
    cat "$SOURCE"
  } > "$expected"
  check_file "$expected" "$destination"
  rm -f "$expected"
}

if [ "$MODE" = "-h" ] || [ "$MODE" = "--help" ]; then
  usage
  exit 0
fi

if [ "$MODE" = "--check" ]; then
  check_standard "$ROOT/AGENTS.md"
  check_standard "$ROOT/.agents/rules/website-shower.md"
  check_standard "$ROOT/.clinerules/website-shower.md"
  check_standard "$ROOT/.windsurf/rules/website-shower.md"
  check_standard "$ROOT/.kiro/steering/website-shower.md"
  check_standard "$ROOT/.github/copilot-instructions.md"
  check_cursor "$ROOT/.cursor/rules/website-shower.mdc"
  exit 0
fi

if [ "$MODE" != "write" ]; then
  printf 'unknown mode: %s\n\n' "$MODE" >&2
  usage >&2
  exit 1
fi

write_standard "$ROOT/AGENTS.md"
write_standard "$ROOT/.agents/rules/website-shower.md"
write_standard "$ROOT/.clinerules/website-shower.md"
write_standard "$ROOT/.windsurf/rules/website-shower.md"
write_standard "$ROOT/.kiro/steering/website-shower.md"
write_standard "$ROOT/.github/copilot-instructions.md"
write_cursor "$ROOT/.cursor/rules/website-shower.mdc"

printf 'agent adapters synced\n'
