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

section "Types And Constants"
"$ROOT/scripts/scan-types-constants.sh" "$TARGET"

section "Unused Code"
"$ROOT/scripts/scan-unused-code.sh" "$TARGET"

section "TypeScript Hygiene"
"$ROOT/scripts/scan-typescript-hygiene.sh" "$TARGET"

section "React And Next.js Habits"
"$ROOT/scripts/scan-react-next-habits.sh" "$TARGET"

cat <<'NOTE'

# Notes
This orchestrator gathers module outputs only. It does not decide final cleanup tasks.
Convert these candidates into a checklist report with concrete paths, confidence, and human approval status before editing.
NOTE
