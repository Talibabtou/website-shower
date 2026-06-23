#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT="$(mktemp "${TMPDIR:-/tmp}/types-constants-smoke.XXXXXX")"
UNUSED_OUTPUT="$(mktemp "${TMPDIR:-/tmp}/website-shower-unused-smoke.XXXXXX")"
TS_OUTPUT="$(mktemp "${TMPDIR:-/tmp}/website-shower-ts-smoke.XXXXXX")"
REACT_OUTPUT="$(mktemp "${TMPDIR:-/tmp}/website-shower-react-smoke.XXXXXX")"
SHOWER_OUTPUT="$(mktemp "${TMPDIR:-/tmp}/website-shower-smoke.XXXXXX")"
REPORT="$ROOT/examples/website-shower-report.md"
trap 'rm -f "$OUTPUT" "$UNUSED_OUTPUT" "$TS_OUTPUT" "$REACT_OUTPUT" "$SHOWER_OUTPUT"' EXIT

"$ROOT/scripts/scan-types-constants.sh" "$ROOT/examples/fixture" > "$OUTPUT"
"$ROOT/scripts/scan-unused-code.sh" "$ROOT/examples/fixture" > "$UNUSED_OUTPUT"
"$ROOT/scripts/scan-typescript-hygiene.sh" "$ROOT/examples/fixture" > "$TS_OUTPUT"
"$ROOT/scripts/scan-react-next-habits.sh" "$ROOT/examples/fixture" > "$REACT_OUTPUT"
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

assert_contains "== Any and unknown pressure ==" "$TS_OUTPUT"
assert_contains "== Checker config files ==" "$TS_OUTPUT"
assert_contains "== TypeScript config guardrails ==" "$TS_OUTPUT"
assert_contains "missing recommended guardrail: tsconfig.json" "$TS_OUTPUT"
assert_contains "missing recommended guardrail: Biome or ESLint config" "$TS_OUTPUT"
assert_contains "missing recommended guardrail: Prettier or Biome formatter config" "$TS_OUTPUT"
assert_contains "== Other checker leads ==" "$TS_OUTPUT"
assert_contains "unsafeInput.ts" "$TS_OUTPUT"
assert_contains ": any" "$TS_OUTPUT"
assert_contains "as unknown as" "$TS_OUTPUT"
assert_contains "== JavaScript files in typed source ==" "$TS_OUTPUT"
assert_contains "legacyWidget.js" "$TS_OUTPUT"

assert_contains "== Framework signals ==" "$REACT_OUTPUT"
assert_contains "src/app" "$REACT_OUTPUT"
assert_contains "== App Router files with client hooks but no directive ==" "$REACT_OUTPUT"
assert_contains "items/page.tsx" "$REACT_OUTPUT"
assert_contains "== Metadata and route config exports ==" "$REACT_OUTPUT"
assert_contains "export const metadata" "$REACT_OUTPUT"
assert_contains "== Route-like string leads ==" "$REACT_OUTPUT"
assert_contains "\"/items/new\"" "$REACT_OUTPUT"

assert_contains "# Website Shower Candidate Scan" "$SHOWER_OUTPUT"
assert_contains "# Types And Constants" "$SHOWER_OUTPUT"
assert_contains "# Unused Code" "$SHOWER_OUTPUT"
assert_contains "# TypeScript Hygiene" "$SHOWER_OUTPUT"
assert_contains "# React And Next.js Habits" "$SHOWER_OUTPUT"
assert_contains "This orchestrator gathers module outputs only." "$SHOWER_OUTPUT"

assert_contains "# Website Shower Report" "$REPORT"
assert_contains "WS-001 Deduplicate" "$REPORT"
assert_contains "WS-003 Consolidate preview worker messages" "$REPORT"
assert_contains "WS-004 Remove stale env helpers" "$REPORT"
assert_contains "WS-007 Replace unsafe input escape hatch" "$REPORT"
assert_contains "WS-008 Add repeatable checker guardrails" "$REPORT"
assert_contains "WS-009 Split client behavior out of the route page" "$REPORT"
assert_contains "WS-010 Name repeated item route literals" "$REPORT"
assert_contains "No audited files were changed." "$REPORT"

echo "smoke test ok"
