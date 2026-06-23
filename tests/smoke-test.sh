#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT="$(mktemp "${TMPDIR:-/tmp}/types-constants-smoke.XXXXXX")"
UNUSED_OUTPUT="$(mktemp "${TMPDIR:-/tmp}/website-shower-unused-smoke.XXXXXX")"
SHOWER_OUTPUT="$(mktemp "${TMPDIR:-/tmp}/website-shower-smoke.XXXXXX")"
REPORT="$ROOT/examples/website-shower-report.md"
trap 'rm -f "$OUTPUT" "$UNUSED_OUTPUT" "$SHOWER_OUTPUT"' EXIT

"$ROOT/scripts/scan-types-constants.sh" "$ROOT/examples/fixture" > "$OUTPUT"
"$ROOT/scripts/scan-unused-code.sh" "$ROOT/examples/fixture" > "$UNUSED_OUTPUT"
MAX_SECTION_LINES=10 "$ROOT/scripts/scan-website-shower.sh" "$ROOT/examples/fixture" > "$SHOWER_OUTPUT"

assert_contains() {
  local pattern="$1"
  local file="${2:-$OUTPUT}"
  if ! rg --fixed-strings "$pattern" "$file" >/dev/null; then
    echo "missing expected scanner output: $pattern" >&2
    echo "--- scanner output ---" >&2
    cat "$file" >&2
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
assert_contains "PreviewWorkerRequest appears"
assert_contains "PreviewWorkerResponse appears"

assert_contains "== Target ==" "$UNUSED_OUTPUT"
assert_contains "examples/fixture" "$UNUSED_OUTPUT"
assert_contains "== Tool ==" "$UNUSED_OUTPUT"

if rg --fixed-strings "fallow unavailable" "$UNUSED_OUTPUT" >/dev/null; then
  assert_contains "== Basic exported symbols to usage-check ==" "$UNUSED_OUTPUT"
  assert_contains "Treat every line as a lead, not a finding." "$UNUSED_OUTPUT"
  assert_contains "getLegacyApiUrl" "$UNUSED_OUTPUT"
  assert_contains "getUnusedCallbackUrl" "$UNUSED_OUTPUT"
  assert_contains "buildPreviewUrl" "$UNUSED_OUTPUT"
else
  assert_contains "fallow:" "$UNUSED_OUTPUT"
  assert_contains "== Fallow dead-code ==" "$UNUSED_OUTPUT"
fi

assert_contains "# Website Shower Candidate Scan" "$SHOWER_OUTPUT"
assert_contains "# Types And Constants" "$SHOWER_OUTPUT"
assert_contains "# Unused Code" "$SHOWER_OUTPUT"
assert_contains "This orchestrator gathers module outputs only." "$SHOWER_OUTPUT"

assert_contains "# Website Shower Report" "$REPORT"
assert_contains "WS-001 Deduplicate" "$REPORT"
assert_contains "WS-003 Consolidate preview worker messages" "$REPORT"
assert_contains "WS-004 Remove stale env helpers" "$REPORT"
assert_contains "No audited files were changed." "$REPORT"

echo "smoke test ok"
