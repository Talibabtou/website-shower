#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT="$(mktemp "${TMPDIR:-/tmp}/types-constants-smoke.XXXXXX")"
FILE_TREE_OUTPUT="$(mktemp "${TMPDIR:-/tmp}/website-shower-file-tree-smoke.XXXXXX")"
MONOREPO_OUTPUT="$(mktemp "${TMPDIR:-/tmp}/website-shower-monorepo-smoke.XXXXXX")"
UNUSED_OUTPUT="$(mktemp "${TMPDIR:-/tmp}/website-shower-unused-smoke.XXXXXX")"
TS_OUTPUT="$(mktemp "${TMPDIR:-/tmp}/website-shower-ts-smoke.XXXXXX")"
REACT_OUTPUT="$(mktemp "${TMPDIR:-/tmp}/website-shower-react-smoke.XXXXXX")"
TAILWIND_OUTPUT="$(mktemp "${TMPDIR:-/tmp}/website-shower-tailwind-smoke.XXXXXX")"
COMPONENT_OUTPUT="$(mktemp "${TMPDIR:-/tmp}/website-shower-component-smoke.XXXXXX")"
API_OUTPUT="$(mktemp "${TMPDIR:-/tmp}/website-shower-api-smoke.XXXXXX")"
DATA_OUTPUT="$(mktemp "${TMPDIR:-/tmp}/website-shower-data-smoke.XXXXXX")"
STATE_OUTPUT="$(mktemp "${TMPDIR:-/tmp}/website-shower-state-smoke.XXXXXX")"
NAMING_OUTPUT="$(mktemp "${TMPDIR:-/tmp}/website-shower-naming-smoke.XXXXXX")"
DEPENDENCY_OUTPUT="$(mktemp "${TMPDIR:-/tmp}/website-shower-dependency-smoke.XXXXXX")"
PERFORMANCE_OUTPUT="$(mktemp "${TMPDIR:-/tmp}/website-shower-performance-smoke.XXXXXX")"
SHOWER_OUTPUT="$(mktemp "${TMPDIR:-/tmp}/website-shower-smoke.XXXXXX")"
REPORT="$ROOT/examples/website-shower-report.md"
trap 'rm -f "$OUTPUT" "$FILE_TREE_OUTPUT" "$MONOREPO_OUTPUT" "$UNUSED_OUTPUT" "$TS_OUTPUT" "$REACT_OUTPUT" "$TAILWIND_OUTPUT" "$COMPONENT_OUTPUT" "$API_OUTPUT" "$DATA_OUTPUT" "$STATE_OUTPUT" "$NAMING_OUTPUT" "$DEPENDENCY_OUTPUT" "$PERFORMANCE_OUTPUT" "$SHOWER_OUTPUT"' EXIT

"$ROOT/scripts/scan-types-constants.sh" "$ROOT/examples/fixture" > "$OUTPUT"
"$ROOT/scripts/scan-file-tree-hygiene.sh" "$ROOT/examples/fixture" > "$FILE_TREE_OUTPUT"
"$ROOT/scripts/scan-monorepo-ownership.sh" "$ROOT/examples/fixture" > "$MONOREPO_OUTPUT"
"$ROOT/scripts/scan-unused-code.sh" "$ROOT/examples/fixture" > "$UNUSED_OUTPUT"
"$ROOT/scripts/scan-typescript-hygiene.sh" "$ROOT/examples/fixture" > "$TS_OUTPUT"
"$ROOT/scripts/scan-react-next-habits.sh" "$ROOT/examples/fixture" > "$REACT_OUTPUT"
"$ROOT/scripts/scan-tailwind-cleanup.sh" "$ROOT/examples/fixture" > "$TAILWIND_OUTPUT"
"$ROOT/scripts/scan-component-hygiene.sh" "$ROOT/examples/fixture" > "$COMPONENT_OUTPUT"
"$ROOT/scripts/scan-api-contracts.sh" "$ROOT/examples/fixture" > "$API_OUTPUT"
"$ROOT/scripts/scan-data-fetching-hygiene.sh" "$ROOT/examples/fixture" > "$DATA_OUTPUT"
"$ROOT/scripts/scan-state-domain-contracts.sh" "$ROOT/examples/fixture" > "$STATE_OUTPUT"
"$ROOT/scripts/scan-naming-drift.sh" "$ROOT/examples/fixture" > "$NAMING_OUTPUT"
"$ROOT/scripts/scan-dependency-hygiene.sh" "$ROOT/examples/fixture" > "$DEPENDENCY_OUTPUT"
"$ROOT/scripts/scan-performance-hygiene.sh" "$ROOT/examples/fixture" > "$PERFORMANCE_OUTPUT"
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

section_line() {
  local pattern="$1"
  local file="$2"
  rg --line-number --fixed-strings "$pattern" "$file" | head -n 1 | cut -d: -f1
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

assert_contains "== Root signals ==" "$FILE_TREE_OUTPUT"
assert_contains "package.json" "$FILE_TREE_OUTPUT"
assert_contains "== App and package layout ==" "$FILE_TREE_OUTPUT"
assert_contains "src/app" "$FILE_TREE_OUTPUT"
assert_contains "== Feature boundary leads ==" "$FILE_TREE_OUTPUT"
assert_contains "src/feature" "$FILE_TREE_OUTPUT"
assert_contains "src/features" "$FILE_TREE_OUTPUT"
assert_contains "mixed feature folders" "$FILE_TREE_OUTPUT"
assert_contains "src/components" "$FILE_TREE_OUTPUT"
assert_contains "src/ui" "$FILE_TREE_OUTPUT"
assert_contains "mixed UI folders" "$FILE_TREE_OUTPUT"
assert_contains "== Route layout leads ==" "$FILE_TREE_OUTPUT"
assert_contains "app/items/page.tsx" "$FILE_TREE_OUTPUT"

assert_contains "== Workspace signals ==" "$MONOREPO_OUTPUT"
assert_contains "pnpm-workspace.yaml" "$MONOREPO_OUTPUT"
assert_contains "apps" "$MONOREPO_OUTPUT"
assert_contains "packages" "$MONOREPO_OUTPUT"
assert_contains "== Package manifests ==" "$MONOREPO_OUTPUT"
assert_contains "apps/web/package.json" "$MONOREPO_OUTPUT"
assert_contains "packages/shared/package.json" "$MONOREPO_OUTPUT"
assert_contains "== Cross-package imports ==" "$MONOREPO_OUTPUT"
assert_contains "@fixture/shared" "$MONOREPO_OUTPUT"
assert_contains "== Deep package import leads ==" "$MONOREPO_OUTPUT"
assert_contains "@fixture/shared/internal" "$MONOREPO_OUTPUT"
assert_contains "== Cross-package repeated contract names ==" "$MONOREPO_OUTPUT"
assert_contains "SharedStatus appears" "$MONOREPO_OUTPUT"

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

assert_contains "== Tailwind signals ==" "$TAILWIND_OUTPUT"
assert_contains "tailwind.config.ts" "$TAILWIND_OUTPUT"
assert_contains "== Content and source configuration ==" "$TAILWIND_OUTPUT"
assert_contains "content:" "$TAILWIND_OUTPUT"
assert_contains "== Arbitrary value leads ==" "$TAILWIND_OUTPUT"
assert_contains "rounded-[18px]" "$TAILWIND_OUTPUT"
assert_contains "== Dynamic class construction leads ==" "$TAILWIND_OUTPUT"
assert_contains 'bg-${tone}-600' "$TAILWIND_OUTPUT"
assert_contains "== Duplicate utility leads ==" "$TAILWIND_OUTPUT"
assert_contains "px-4 px-4" "$TAILWIND_OUTPUT"
assert_contains "== CSS files ==" "$TAILWIND_OUTPUT"
assert_contains "globals.css" "$TAILWIND_OUTPUT"
assert_contains "== CSS raw value leads ==" "$TAILWIND_OUTPUT"
assert_contains "#d7dde8" "$TAILWIND_OUTPUT"
assert_contains "18px" "$TAILWIND_OUTPUT"
assert_contains "== Repeated CSS raw values ==" "$TAILWIND_OUTPUT"
assert_contains "24px appears" "$TAILWIND_OUTPUT"

assert_contains "== Large component files ==" "$COMPONENT_OUTPUT"
assert_contains "DashboardPanel.tsx" "$COMPONENT_OUTPUT"
assert_contains "== Variant prop leads ==" "$COMPONENT_OUTPUT"
assert_contains "variant: 'primary' | 'secondary'" "$COMPONENT_OUTPUT"
assert_contains "== Loading error empty state leads ==" "$COMPONENT_OUTPUT"
assert_contains "isLoading" "$COMPONENT_OUTPUT"
assert_contains "== Client component server-work leads ==" "$COMPONENT_OUTPUT"
assert_contains "fetch('/api/items')" "$COMPONENT_OUTPUT"

assert_contains "== API signals ==" "$API_OUTPUT"
assert_contains "src/app/api" "$API_OUTPUT"
assert_contains "== Route handler files ==" "$API_OUTPUT"
assert_contains "app/api/items/route.ts" "$API_OUTPUT"
assert_contains "== Request body parsing ==" "$API_OUTPUT"
assert_contains "request.json" "$API_OUTPUT"
assert_contains "== API contract type names ==" "$API_OUTPUT"
assert_contains "CreateItemRequest" "$API_OUTPUT"
assert_contains "CreateItemResponse" "$API_OUTPUT"

assert_contains "== Fetch and client calls ==" "$DATA_OUTPUT"
assert_contains "fetch('/api/items')" "$DATA_OUTPUT"
assert_contains "== Query key leads ==" "$DATA_OUTPUT"
assert_contains "itemQueryKey" "$DATA_OUTPUT"
assert_contains "== Cache policy leads ==" "$DATA_OUTPUT"
assert_contains "cache: 'no-store'" "$DATA_OUTPUT"
assert_contains "== JSON validation leads ==" "$DATA_OUTPUT"
assert_contains "response.json()" "$DATA_OUTPUT"

assert_contains "== State and domain signals ==" "$STATE_OUTPUT"
assert_contains "src/state" "$STATE_OUTPUT"
assert_contains "src/features" "$STATE_OUTPUT"
assert_contains "== Store, slice, and reducer files ==" "$STATE_OUTPUT"
assert_contains "workSlice.ts" "$STATE_OUTPUT"
assert_contains "== State contract type names ==" "$STATE_OUTPUT"
assert_contains "AppState" "$STATE_OUTPUT"
assert_contains "DomainEvent" "$STATE_OUTPUT"
assert_contains "== State creators and selectors ==" "$STATE_OUTPUT"
assert_contains "selectQueuedItems" "$STATE_OUTPUT"
assert_contains "== Status machine literal leads ==" "$STATE_OUTPUT"
assert_contains "'queued'" "$STATE_OUTPUT"
assert_contains "== Repeated state/domain type names ==" "$STATE_OUTPUT"
assert_contains "DomainEvent appears" "$STATE_OUTPUT"

assert_contains "== Type names using convention words ==" "$NAMING_OUTPUT"
assert_contains "ItemStatus" "$NAMING_OUTPUT"
assert_contains "ItemPhase" "$NAMING_OUTPUT"
assert_contains "ProcessStep" "$NAMING_OUTPUT"
assert_contains "== Same literal set with different names ==" "$NAMING_OUTPUT"
assert_contains "'draft'|'active'|'archived'; appears with names:" "$NAMING_OUTPUT"
assert_contains "== Same prefix with different convention words ==" "$NAMING_OUTPUT"
assert_contains "Item uses" "$NAMING_OUTPUT"

assert_contains "== Package manager signals ==" "$DEPENDENCY_OUTPUT"
assert_contains "pnpm-workspace.yaml" "$DEPENDENCY_OUTPUT"
assert_contains "package-lock.json" "$DEPENDENCY_OUTPUT"
assert_contains "== Tooling dependencies in dependencies ==" "$DEPENDENCY_OUTPUT"
assert_contains "typescript" "$DEPENDENCY_OUTPUT"
assert_contains "== Runtime dependencies in devDependencies ==" "$DEPENDENCY_OUTPUT"
assert_contains "react" "$DEPENDENCY_OUTPUT"
assert_contains "== Duplicate dependency family leads ==" "$DEPENDENCY_OUTPUT"
assert_contains "classnames" "$DEPENDENCY_OUTPUT"
assert_contains "clsx" "$DEPENDENCY_OUTPUT"

assert_contains "== Client boundary leads ==" "$PERFORMANCE_OUTPUT"
assert_contains "'use client'" "$PERFORMANCE_OUTPUT"
assert_contains "== Dynamic import leads ==" "$PERFORMANCE_OUTPUT"
assert_contains "dynamic(() => import('./MetricCard'))" "$PERFORMANCE_OUTPUT"
assert_contains "== Image optimization leads ==" "$PERFORMANCE_OUTPUT"
assert_contains "<img src={item.imageUrl}" "$PERFORMANCE_OUTPUT"
assert_contains "== Unbounded list render leads ==" "$PERFORMANCE_OUTPUT"
assert_contains "records.map" "$PERFORMANCE_OUTPUT"

assert_contains "# Website Shower Candidate Scan" "$SHOWER_OUTPUT"
assert_contains "# File Tree Hygiene" "$SHOWER_OUTPUT"
assert_contains "# Monorepo Ownership" "$SHOWER_OUTPUT"
assert_contains "# Types And Constants" "$SHOWER_OUTPUT"
assert_contains "# Unused Code" "$SHOWER_OUTPUT"
assert_contains "# TypeScript Hygiene" "$SHOWER_OUTPUT"
assert_contains "# React And Next.js Habits" "$SHOWER_OUTPUT"
assert_contains "# Tailwind Cleanup" "$SHOWER_OUTPUT"
assert_contains "# Component Hygiene" "$SHOWER_OUTPUT"
assert_contains "# API Contracts" "$SHOWER_OUTPUT"
assert_contains "# Data Fetching Hygiene" "$SHOWER_OUTPUT"
assert_contains "# State And Domain Contracts" "$SHOWER_OUTPUT"
assert_contains "# Naming Drift" "$SHOWER_OUTPUT"
assert_contains "# Dependency Hygiene" "$SHOWER_OUTPUT"
assert_contains "# Performance Hygiene" "$SHOWER_OUTPUT"
assert_contains "This orchestrator gathers module outputs only." "$SHOWER_OUTPUT"

file_tree_line="$(section_line "# File Tree Hygiene" "$SHOWER_OUTPUT")"
monorepo_line="$(section_line "# Monorepo Ownership" "$SHOWER_OUTPUT")"
typescript_line="$(section_line "# TypeScript Hygiene" "$SHOWER_OUTPUT")"
tailwind_line="$(section_line "# Tailwind Cleanup" "$SHOWER_OUTPUT")"
component_line="$(section_line "# Component Hygiene" "$SHOWER_OUTPUT")"
api_line="$(section_line "# API Contracts" "$SHOWER_OUTPUT")"
data_line="$(section_line "# Data Fetching Hygiene" "$SHOWER_OUTPUT")"
state_line="$(section_line "# State And Domain Contracts" "$SHOWER_OUTPUT")"
naming_line="$(section_line "# Naming Drift" "$SHOWER_OUTPUT")"
dependency_line="$(section_line "# Dependency Hygiene" "$SHOWER_OUTPUT")"
performance_line="$(section_line "# Performance Hygiene" "$SHOWER_OUTPUT")"
types_constants_line="$(section_line "# Types And Constants" "$SHOWER_OUTPUT")"
if [ "$file_tree_line" -ge "$typescript_line" ]; then
  echo "file-tree hygiene should run before TypeScript hygiene" >&2
  cat "$SHOWER_OUTPUT" >&2
  exit 1
fi
if [ "$monorepo_line" -le "$file_tree_line" ] || [ "$monorepo_line" -ge "$typescript_line" ]; then
  echo "monorepo ownership should run after file-tree and before TypeScript hygiene" >&2
  cat "$SHOWER_OUTPUT" >&2
  exit 1
fi
if [ "$tailwind_line" -ge "$component_line" ] || [ "$component_line" -ge "$api_line" ] || [ "$api_line" -ge "$data_line" ]; then
  echo "component and data scans should run after styling and around API contracts" >&2
  cat "$SHOWER_OUTPUT" >&2
  exit 1
fi
if [ "$state_line" -ge "$naming_line" ] || [ "$naming_line" -ge "$dependency_line" ] || [ "$dependency_line" -ge "$performance_line" ] || [ "$performance_line" -ge "$types_constants_line" ]; then
  echo "naming, dependency, and performance scans should run before types/constants" >&2
  cat "$SHOWER_OUTPUT" >&2
  exit 1
fi

assert_contains "# Website Shower Report" "$REPORT"
assert_contains "WS-001 Choose one feature folder convention" "$REPORT"
assert_contains "WS-002 Decide the shared UI folder boundary" "$REPORT"
assert_contains "WS-003 Stop importing package internals" "$REPORT"
assert_contains "WS-004 Use the shared package contract" "$REPORT"
assert_contains "WS-005 Replace unsafe input escape hatch" "$REPORT"
assert_contains "WS-006 Add repeatable checker guardrails" "$REPORT"
assert_contains "WS-007 Split client behavior out of the route page" "$REPORT"
assert_contains "WS-008 Name repeated item route literals" "$REPORT"
assert_contains "WS-009 Replace dynamic Tailwind class construction" "$REPORT"
assert_contains "WS-010 Promote repeated arbitrary values" "$REPORT"
assert_contains "WS-011 Split \`DashboardPanel\` responsibilities" "$REPORT"
assert_contains "WS-012 Name item data-fetching policy" "$REPORT"
assert_contains "WS-013 Check client-side performance pressure" "$REPORT"
assert_contains "WS-014 Consolidate create-item API contracts" "$REPORT"
assert_contains "WS-015 Validate create-item request body" "$REPORT"
assert_contains "WS-016 Pick one workflow lifecycle name" "$REPORT"
assert_contains "WS-017 Clean package metadata drift" "$REPORT"
assert_contains "WS-018 Deduplicate" "$REPORT"
assert_contains "WS-020 Consolidate preview worker messages" "$REPORT"
assert_contains "WS-023 Remove stale env helpers" "$REPORT"
assert_contains "No audited files were changed." "$REPORT"

echo "smoke test ok"
