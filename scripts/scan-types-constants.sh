#!/usr/bin/env bash

set -uo pipefail

TARGET="${1:-.}"

if ! command -v rg >/dev/null 2>&1; then
  echo "error: ripgrep (rg) is required" >&2
  exit 1
fi

if [ ! -d "$TARGET" ]; then
  echo "error: target is not a directory: $TARGET" >&2
  exit 1
fi

FALLBACK_IGNORE_GLOBS=(
  --glob '!node_modules/**'
  --glob '!.git/**'
  --glob '!.next/**'
  --glob '!.turbo/**'
  --glob '!.vercel/**'
  --glob '!dist/**'
  --glob '!build/**'
  --glob '!coverage/**'
)

IGNORE_GLOBS=()
IGNORE_SOURCE="repo ignore files"

if command -v git >/dev/null 2>&1 && git -C "$TARGET" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  repo_root="$(git -C "$TARGET" rev-parse --show-toplevel 2>/dev/null || true)"
  if [ -z "$repo_root" ] ||
    { [ ! -f "$repo_root/.gitignore" ] && [ ! -f "$TARGET/.gitignore" ] && [ ! -f "$TARGET/.ignore" ]; }; then
    IGNORE_GLOBS=("${FALLBACK_IGNORE_GLOBS[@]}")
    IGNORE_SOURCE="fallback generated-folder globs"
  fi
elif [ ! -f "$TARGET/.gitignore" ] && [ ! -f "$TARGET/.ignore" ]; then
  IGNORE_GLOBS=("${FALLBACK_IGNORE_GLOBS[@]}")
  IGNORE_SOURCE="fallback generated-folder globs"
fi

RG_COMMON=(
  --color never
  --line-number
)

RG_FILES_COMMON=()

if [ "${#IGNORE_GLOBS[@]}" -gt 0 ]; then
  RG_COMMON+=("${IGNORE_GLOBS[@]}")
  RG_FILES_COMMON+=("${IGNORE_GLOBS[@]}")
fi

TS_GLOBS=(
  --glob '*.ts'
  --glob '*.tsx'
)

section() {
  printf '\n== %s ==\n' "$1"
}

scan() {
  rg "${RG_COMMON[@]}" "${TS_GLOBS[@]}" "$@" "$TARGET" || true
}

files() {
  if [ "${#RG_FILES_COMMON[@]}" -gt 0 ]; then
    rg --files "${RG_FILES_COMMON[@]}" "$TARGET" || true
  else
    rg --files "$TARGET" || true
  fi
}

section "Target"
printf '%s\n' "$TARGET"
printf 'ignore: %s\n' "$IGNORE_SOURCE"

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
  next.config.mjs \
  remix.config.js; do
  if [ -e "$TARGET/$path" ]; then
    printf '%s\n' "$path"
  fi
done

for dir in src app pages features domains packages apps; do
  if [ -d "$TARGET/$dir" ]; then
    printf '%s/\n' "$dir"
  fi
done

section "Candidate type and constant files"
files | rg '(^|/)(types|constants|contracts|enums|status|statuses|roles|variants|modes|config)\.(ts|tsx)$' || true

section "Large candidate files"
files |
  rg '\.(ts|tsx)$' |
  while IFS= read -r file; do
    lines="$(wc -l < "$file" 2>/dev/null | tr -d ' ')"
    case "$lines" in
      ''|*[!0-9]*) continue ;;
    esac
    if [ "$lines" -ge 200 ]; then
      printf '%s lines %s\n' "$lines" "$file"
    fi
  done |
  sort -nr |
  head -n 30

section "Type aliases"
scan '(^|export[[:space:]]+)type[[:space:]]+[A-Za-z0-9_]+[[:space:]]*='

section "Interfaces"
scan '(^|export[[:space:]]+)interface[[:space:]]+[A-Za-z0-9_]+'

section "Enum declarations"
scan '(^|export[[:space:]]+)?enum[[:space:]]+[A-Za-z0-9_]+'

section "as const values"
scan 'as const'

section "Uppercase constants"
scan '(^|export[[:space:]]+)?const[[:space:]]+[A-Z][A-Z0-9_]+[[:space:]]*=' |
  rg -v '=[[:space:]]*(async[[:space:]]*)?\(' |
  rg -v 'export[[:space:]]+const[[:space:]]+(GET|POST|PUT|PATCH|DELETE|HEAD|OPTIONS)[[:space:]]*=' ||
  true

section "Imports from type/constant barrels"
scan 'from[[:space:]]+["'\''][^"'\'']*(types|constants|contracts|enums|status|statuses|roles|variants|modes|config)[^"'\'']*["'\'']'

literal_tmp="$(mktemp "${TMPDIR:-/tmp}/types-constants-literals.XXXXXX")"
trap 'rm -f "$literal_tmp"' EXIT

scan --only-matching '["'\''](draft|published|pending|queued|done|approved|rejected|active|inactive|enabled|disabled|archived|deleted|failed|admin|moderator|user|owner|viewer|editor|success|error|warning|info|primary|secondary|default|compact|expanded|create|read|update|delete|view|edit|public|private)["'\'']' > "$literal_tmp"

section "Repeated domain literals"
awk -F: '
  {
    literal = $NF
    gsub(/^["'\''"]|["'\''"]$/, "", literal)
    count[literal] += 1
    if (count[literal] <= 8) {
      locations[literal] = locations[literal] "\n  " $0
    }
  }
  END {
    found = 0
    for (literal in count) {
      if (count[literal] > 1) {
        found = 1
        printf "%s appears %d times:%s\n", literal, count[literal], locations[literal]
      }
    }
    if (!found) {
      print "No repeated watched literals found."
    }
  }
' "$literal_tmp"

section "Likely literal unions"
scan '["'\''][A-Za-z0-9_-]+["'\''][[:space:]]*\|[[:space:]]*["'\''][A-Za-z0-9_-]+["'\'']'

symbol_tmp="$(mktemp "${TMPDIR:-/tmp}/types-constants-symbols.XXXXXX")"
const_tmp="$(mktemp "${TMPDIR:-/tmp}/types-constants-consts.XXXXXX")"
trap 'rm -f "$literal_tmp" "$symbol_tmp" "$const_tmp"' EXIT

scan '(^|export[[:space:]]+)(type|interface)[[:space:]]+[A-Za-z0-9_]+' > "$symbol_tmp"

section "Repeated type/interface names"
awk -F: '
  {
    line = $0
    if (match($0, /(type|interface)[[:space:]]+[A-Za-z0-9_]+/)) {
      chunk = substr($0, RSTART, RLENGTH)
      split(chunk, parts, /[[:space:]]+/)
      name = parts[2]
      count[name] += 1
      if (count[name] <= 8) {
        locations[name] = locations[name] "\n  " line
      }
    }
  }
  END {
    found = 0
    for (name in count) {
      if (count[name] > 1) {
        found = 1
        printf "%s appears %d times:%s\n", name, count[name], locations[name]
      }
    }
    if (!found) {
      print "No repeated type/interface names found."
    }
  }
' "$symbol_tmp"

scan '(^|export[[:space:]]+)?const[[:space:]]+[A-Z][A-Z0-9_]+[[:space:]]*=[[:space:]]*(["'\''][^"'\'']+["'\'']|[0-9][0-9_]*(\.[0-9]+)?)[;[:space:]]*$' > "$const_tmp"

section "Repeated primitive constant values"
awk -F: '
  {
    line = $0
    value = $0
    sub(/^.*=[[:space:]]*/, "", value)
    sub(/[;[:space:]].*$/, "", value)
    count[value] += 1
    if (count[value] <= 8) {
      locations[value] = locations[value] "\n  " line
    }
  }
  END {
    found = 0
    for (value in count) {
      if (count[value] > 1) {
        found = 1
        printf "%s appears %d times:%s\n", value, count[value], locations[value]
      }
    }
    if (!found) {
      print "No repeated primitive constant values found."
    }
  }
' "$const_tmp"

section "Exported uppercase constants to usage-check"
scan 'export[[:space:]]+const[[:space:]]+[A-Z][A-Z0-9_]+[[:space:]]*=' |
  rg -v '=[[:space:]]*(async[[:space:]]*)?\(' |
  rg -v 'export[[:space:]]+const[[:space:]]+(GET|POST|PUT|PATCH|DELETE|HEAD|OPTIONS)[[:space:]]*=' ||
  true

cat <<'NOTE'

== Notes ==
This script prints audit candidates only. It does not decide whether a symbol should be inline,
feature-local, app-global, or deleted. Inspect usage and apply the placement rules before reporting findings.
NOTE
