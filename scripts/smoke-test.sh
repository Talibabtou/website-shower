#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT="$(mktemp "${TMPDIR:-/tmp}/types-constants-smoke.XXXXXX")"
trap 'rm -f "$OUTPUT"' EXIT

"$ROOT/scripts/scan-types-constants.sh" "$ROOT/examples/fixture" > "$OUTPUT"

assert_contains() {
  local pattern="$1"
  if ! rg --fixed-strings "$pattern" "$OUTPUT" >/dev/null; then
    echo "missing expected scanner output: $pattern" >&2
    echo "--- scanner output ---" >&2
    cat "$OUTPUT" >&2
    exit 1
  fi
}

assert_contains "== Target =="
assert_contains "examples/fixture"
assert_contains "ignore: repo ignore files"
assert_contains "== Repo shape =="
assert_contains "package.json"
assert_contains "src/"

assert_contains "== Candidate type and constant files =="
assert_contains "src/state/contracts.ts"

assert_contains "== Imports from type/constant barrels =="
assert_contains "export * from './contracts';"

assert_contains "== Repeated domain literals =="
assert_contains "queued appears"
assert_contains "done appears"

assert_contains "== Likely literal unions =="
assert_contains "'left' | 'right'"
assert_contains "'queued' | 'done' | 'error'"

assert_contains "== Repeated type/interface names =="
assert_contains "AppState appears"
assert_contains "WorkItem appears"
assert_contains "DomainEvent appears"
assert_contains "ResourceMap appears"

echo "smoke test ok"
