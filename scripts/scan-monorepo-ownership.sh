#!/usr/bin/env bash

set -uo pipefail

TARGET="${1:-.}"
MAX_SECTION_LINES="${MAX_SECTION_LINES:-300}"

if [ ! -d "$TARGET" ]; then
  echo "error: target is not a directory: $TARGET" >&2
  exit 1
fi

section() {
  printf '\n== %s ==\n' "$1"
}

limit_output() {
  awk -v max="$MAX_SECTION_LINES" '
    NR <= max { print }
    NR == max + 1 {
      printf "... truncated after %d lines; narrow the target path for more detail.\n", max
      exit
    }
  '
}

run_rg() {
  local pattern="$1"
  shift

  rg \
    --color never \
    --line-number \
    --glob '*.ts' \
    --glob '*.tsx' \
    --glob '*.js' \
    --glob '*.jsx' \
    --glob '*.json' \
    --glob '!*.d.ts' \
    --glob '!**/*.d.ts' \
    --glob '!**/node_modules/**' \
    --glob '!**/dist/**' \
    --glob '!**/build/**' \
    --glob '!**/.next/**' \
    "$@" \
    "$pattern" \
    "$TARGET" 2>/dev/null | limit_output || true
}

section "Target"
printf '%s\n' "$TARGET"

section "Workspace signals"
for path in \
  pnpm-workspace.yaml \
  turbo.json \
  nx.json \
  lerna.json \
  rush.json \
  package.json \
  apps \
  packages; do
  if [ -e "$TARGET/$path" ]; then
    printf '%s\n' "$path"
  fi
done

if [ ! -d "$TARGET/apps" ] && [ ! -d "$TARGET/packages" ] && [ ! -f "$TARGET/pnpm-workspace.yaml" ]; then
  printf 'No common monorepo layout detected; treat this module as low signal.\n'
fi

section "Package manifests"
rg --files "$TARGET" \
  --glob 'package.json' \
  --glob '!**/node_modules/**' \
  --glob '!**/dist/**' \
  --glob '!**/build/**' 2>/dev/null |
  sort |
  limit_output

section "Workspace package names"
run_rg '"name"[[:space:]]*:[[:space:]]*"(@[^"]+/[^"]+|[^"]+)"' --glob 'package.json'

section "Cross-package imports"
run_rg 'from[[:space:]]+["'\''](@[^"'\'']+/[^"'\'']+|[.][.]/[.][.]/packages/[^"'\'']+|[.][.]/packages/[^"'\'']+)["'\'']|import\(["'\''](@[^"'\'']+/[^"'\'']+|[.][.]/[.][.]/packages/[^"'\'']+|[.][.]/packages/[^"'\'']+)["'\'']\)'

section "Deep package import leads"
run_rg 'from[[:space:]]+["'\'']@[^"'\'']+/[^"'\'']+/.+["'\'']|import\(["'\'']@[^"'\'']+/[^"'\'']+/.+["'\'']\)'

section "Private boundary import leads"
run_rg 'from[[:space:]]+["'\''][^"'\'']*(/internal|/private|/src/|/feature/|/features/)[^"'\'']*["'\'']|import\(["'\''][^"'\'']*(/internal|/private|/src/|/feature/|/features/)[^"'\'']*["'\'']\)'

section "Broad shared package leads"
rg --files "$TARGET" 2>/dev/null |
  rg '(^|/)(packages|libs)/(shared|common|utils|types|config|ui)(/|$)' |
  limit_output || true

section "App-global junk drawer leads"
rg --files "$TARGET" 2>/dev/null |
  rg '(^|/)(apps/[^/]+/src|src)/(lib|utils|shared|common|types|constants)/|(^|/)(apps/[^/]+/src|src)/(types|constants|utils|helpers)\.(ts|tsx|js|jsx)$' |
  limit_output || true

symbol_tmp="$(mktemp "${TMPDIR:-/tmp}/website-shower-monorepo-symbols.XXXXXX")"
trap 'rm -f "$symbol_tmp"' EXIT

run_rg '(type|interface)[[:space:]]+[A-Za-z0-9_]*(Status|State|Event|Payload|Request|Response|Config|Options)[A-Za-z0-9_]*' \
  --glob 'apps/**/*.ts' \
  --glob 'apps/**/*.tsx' \
  --glob 'packages/**/*.ts' \
  --glob 'packages/**/*.tsx' > "$symbol_tmp"

section "Cross-package repeated contract names"
awk -F: '
  {
    line = $0
    if (match($0, /(type|interface)[[:space:]]+[A-Za-z0-9_]+/)) {
      chunk = substr($0, RSTART, RLENGTH)
      split(chunk, parts, /[[:space:]]+/)
      name = parts[2]
      owner = $1
      sub(/^.*\/(apps|packages)\//, "", owner)
      sub(/\/.*$/, "", owner)
      key = name
      count[key] += 1
      owners[key, owner] = 1
      if (count[key] <= 8) {
        locations[key] = locations[key] "\n  " line
      }
    }
  }
  END {
    found = 0
    for (key in count) {
      owner_count = 0
      for (pair in owners) {
        split(pair, parts, SUBSEP)
        if (parts[1] == key) {
          owner_count += 1
        }
      }
      if (count[key] > 1 && owner_count > 1) {
        found = 1
        printf "%s appears across %d owners:%s\n", key, owner_count, locations[key]
      }
    }
    if (!found) {
      print "No repeated cross-package contract names found."
    }
  }
' "$symbol_tmp" | limit_output

cat <<'NOTE'

== Notes ==
This script prints monorepo ownership candidates only. Confirm package exports,
workspace policy, build graph, and intended public API before reporting a task.
Deep imports can be valid during migrations, but they should be deliberate.
NOTE
