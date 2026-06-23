#!/usr/bin/env bash

set -uo pipefail

TARGET="${1:-.}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"

if [ ! -d "$TARGET" ]; then
  echo "error: target is not a directory: $TARGET" >&2
  exit 1
fi

section() {
  printf '\n# %s\n' "$1"
}

section "Website Shower Candidate Scan"
printf 'Target: %s\n' "$TARGET"
printf 'Mode: read-only candidate gathering\n'

section "File Tree Hygiene"
"$ROOT/scripts/scan-file-tree-hygiene.sh" "$TARGET"

section "Monorepo Ownership"
"$ROOT/scripts/scan-monorepo-ownership.sh" "$TARGET"

section "TypeScript Hygiene"
"$ROOT/scripts/scan-typescript-hygiene.sh" "$TARGET"

section "React And Next.js Habits"
"$ROOT/scripts/scan-react-next-habits.sh" "$TARGET"

section "Tailwind Cleanup"
"$ROOT/scripts/scan-tailwind-cleanup.sh" "$TARGET"

section "Component Hygiene"
"$ROOT/scripts/scan-component-hygiene.sh" "$TARGET"

section "API Contracts"
"$ROOT/scripts/scan-api-contracts.sh" "$TARGET"

section "Data Fetching Hygiene"
"$ROOT/scripts/scan-data-fetching-hygiene.sh" "$TARGET"

section "State And Domain Contracts"
"$ROOT/scripts/scan-state-domain-contracts.sh" "$TARGET"

section "Naming Drift"
"$ROOT/scripts/scan-naming-drift.sh" "$TARGET"

section "Dependency Hygiene"
"$ROOT/scripts/scan-dependency-hygiene.sh" "$TARGET"

section "Performance Hygiene"
"$ROOT/scripts/scan-performance-hygiene.sh" "$TARGET"

section "Types And Constants"
"$ROOT/scripts/scan-types-constants.sh" "$TARGET"

section "Unused Code"
"$ROOT/scripts/scan-unused-code.sh" "$TARGET"

cat <<'NOTE'

# Notes
This orchestrator gathers module outputs only. It does not decide final cleanup tasks.
Convert these candidates into a checklist report with concrete paths, confidence, and human approval status before editing.
NOTE
