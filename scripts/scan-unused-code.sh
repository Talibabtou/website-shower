#!/usr/bin/env bash

set -uo pipefail

TARGET="${1:-.}"
shift || true
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

basic_unused_scan() {
  if ! command -v rg >/dev/null 2>&1; then
    printf 'basic fallback unavailable: ripgrep (rg) is required.\n'
    return 0
  fi

  local export_tmp
  export_tmp="$(mktemp "${TMPDIR:-/tmp}/website-shower-exports.XXXXXX")"
  trap 'rm -f "$export_tmp"' RETURN

  section "Basic exported symbols to usage-check"
  rg \
    --color never \
    --line-number \
    --glob '*.ts' \
    --glob '*.tsx' \
    --glob '!*.d.ts' \
    --glob '!**/*.d.ts' \
    --glob '!**/__generated__/**' \
    --glob '!**/generated/**' \
    'export[[:space:]]+(const|function|class|type|interface|enum)[[:space:]]+[A-Za-z0-9_]+' \
    "$TARGET" > "$export_tmp" || true

  if [ ! -s "$export_tmp" ]; then
    printf 'No exported symbols found by the basic fallback.\n'
    return 0
  fi

  awk -F: '
    {
      line = $0
      if (match($0, /export[[:space:]]+(const|function|class|type|interface|enum)[[:space:]]+[A-Za-z0-9_]+/)) {
        chunk = substr($0, RSTART, RLENGTH)
        split(chunk, parts, /[[:space:]]+/)
        name = parts[3]
        print name "\t" line
      }
    }
  ' "$export_tmp" |
    while IFS="$(printf '\t')" read -r name line; do
      [ -z "$name" ] && continue
      count="$(rg --color never --glob '*.ts' --glob '*.tsx' --glob '!*.d.ts' --glob '!**/*.d.ts' --fixed-strings "$name" "$TARGET" 2>/dev/null | wc -l | tr -d ' ')"
      case "$count" in
        ''|*[!0-9]*) continue ;;
      esac
      if [ "$count" -le 1 ]; then
        printf '%s appears only at declaration: %s\n' "$name" "$line"
      fi
    done |
    limit_output

  cat <<'BASIC_NOTE'

== Basic fallback notes ==
This fallback is intentionally conservative and weaker than fallow. It only highlights exported symbols
whose name appears once in TypeScript files. Framework entrypoints, public package exports, dynamic imports,
and type-only usage can make this noisy. Treat every line as a lead, not a finding.
BASIC_NOTE
}

section "Target"
printf '%s\n' "$TARGET"

section "Tool"
if [ -x "$TARGET/node_modules/.bin/fallow" ]; then
  FALLOW_CMD=("$TARGET/node_modules/.bin/fallow")
  printf 'fallow: repo-local node_modules/.bin/fallow\n'
elif command -v fallow >/dev/null 2>&1; then
  FALLOW_CMD=(fallow)
  printf 'fallow: local executable\n'
elif [ "${FALLOW_USE_NPX:-0}" = "1" ] && command -v npx >/dev/null 2>&1; then
  FALLOW_CMD=(npx --yes fallow)
  printf 'fallow: npx --yes fallow\n'
else
  printf 'fallow unavailable: using basic rg fallback. Install fallow in the repo or rerun with FALLOW_USE_NPX=1 for stronger analysis.\n'
  basic_unused_scan
  exit 0
fi

section "Repo shape"
for path in \
  package.json \
  pnpm-workspace.yaml \
  yarn.lock \
  package-lock.json \
  turbo.json \
  nx.json \
  tsconfig.json \
  vite.config.ts \
  next.config.js \
  next.config.mjs; do
  if [ -e "$TARGET/$path" ]; then
    printf '%s\n' "$path"
  fi
done

section "Fallow dead-code"
"${FALLOW_CMD[@]}" dead-code --root "$TARGET" --format markdown "$@" || true

cat <<'NOTE'

== Notes ==
This script prints unused-code candidates only. Do not delete files, exports, or dependencies
from this output alone. Trace the finding, inspect usage, and ask for human permission before edits.
Useful follow-up commands:
  fallow dead-code --trace <file>:<export>
  fallow dead-code --trace-dependency <name>
NOTE
