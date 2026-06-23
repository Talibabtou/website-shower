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
    --glob '!*.d.ts' \
    --glob '!**/*.d.ts' \
    --glob '!**/__generated__/**' \
    --glob '!**/generated/**' \
    "$@" \
    "$pattern" \
    "$TARGET" 2>/dev/null | limit_output || true
}

section "Target"
printf '%s\n' "$TARGET"

section "Naming convention words"
run_rg '\b(status|state|phase|mode|kind|type|variant|step)\b'

section "Type names using convention words"
run_rg '(type|interface)[[:space:]]+[A-Za-z0-9_]*(Status|State|Phase|Mode|Kind|Type|Variant|Step)[A-Za-z0-9_]*'

section "Object fields using convention words"
run_rg '\b(status|state|phase|mode|kind|type|variant|step)[[:space:]]*[?:]?[[:space:]]*(:|=)'

section "Function names using convention words"
run_rg '(function|const)[[:space:]]+[A-Za-z0-9_]*(Status|State|Phase|Mode|Kind|Type|Variant|Step)[A-Za-z0-9_]*'

section "Literal unions with naming words"
run_rg '(Status|State|Phase|Mode|Kind|Type|Variant|Step)[A-Za-z0-9_]*[[:space:]]*=[[:space:]]*["'\''][A-Za-z0-9_-]+["'\''][[:space:]]*\|[[:space:]]*["'\''][A-Za-z0-9_-]+["'\'']'

literal_union_tmp="$(mktemp "${TMPDIR:-/tmp}/website-shower-naming-unions.XXXXXX")"
trap 'rm -f "$literal_union_tmp"' EXIT

run_rg '(type)[[:space:]]+[A-Za-z0-9_]*(Status|State|Phase|Mode|Kind|Type|Variant|Step)[A-Za-z0-9_]*[[:space:]]*=[[:space:]]*["'\''][A-Za-z0-9_-]+["'\''][[:space:]]*\|[[:space:]]*["'\''][A-Za-z0-9_-]+["'\'']' > "$literal_union_tmp"

section "Same literal set with different names"
awk -F: '
  {
    line = $0
    if (match($0, /type[[:space:]]+[A-Za-z0-9_]+/)) {
      chunk = substr($0, RSTART, RLENGTH)
      split(chunk, parts, /[[:space:]]+/)
      name = parts[2]
      values = $0
      sub(/^.*=[[:space:]]*/, "", values)
      gsub(/[[:space:]]+/, "", values)
      count[values] += 1
      seen_name[values, name] = 1
      if (count[values] <= 8) {
        locations[values] = locations[values] "\n  " line
      }
    }
  }
  END {
    found = 0
    for (values in count) {
      name_count = 0
      names = ""
      for (pair in seen_name) {
        split(pair, parts, SUBSEP)
        if (parts[1] == values) {
          name_count += 1
          names = names " " parts[2]
        }
      }
      if (name_count > 1) {
        found = 1
        printf "%s appears with names:%s%s\n", values, names, locations[values]
      }
    }
    if (!found) {
      print "No repeated literal sets with different names found."
    }
  }
' "$literal_union_tmp" | limit_output

section "Same prefix with different convention words"
awk -F: '
  {
    line = $0
    if (match($0, /(type|interface)[[:space:]]+[A-Za-z0-9_]*(Status|State|Phase|Mode|Kind|Type|Variant|Step)[A-Za-z0-9_]*/)) {
      chunk = substr($0, RSTART, RLENGTH)
      split(chunk, parts, /[[:space:]]+/)
      name = parts[2]
      prefix = name
      word = ""
      if (sub(/Status.*/, "", prefix) && name ~ /Status/) word = "Status"
      else if (sub(/State.*/, "", prefix) && name ~ /State/) word = "State"
      else if (sub(/Phase.*/, "", prefix) && name ~ /Phase/) word = "Phase"
      else if (sub(/Mode.*/, "", prefix) && name ~ /Mode/) word = "Mode"
      else if (sub(/Kind.*/, "", prefix) && name ~ /Kind/) word = "Kind"
      else if (sub(/Type.*/, "", prefix) && name ~ /Type/) word = "Type"
      else if (sub(/Variant.*/, "", prefix) && name ~ /Variant/) word = "Variant"
      else if (sub(/Step.*/, "", prefix) && name ~ /Step/) word = "Step"
      if (prefix != "" && word != "") {
        words[prefix, word] = 1
        count[prefix] += 1
        if (count[prefix] <= 8) {
          locations[prefix] = locations[prefix] "\n  " line
        }
      }
    }
  }
  END {
    found = 0
    for (prefix in count) {
      word_count = 0
      for (pair in words) {
        split(pair, parts, SUBSEP)
        if (parts[1] == prefix) word_count += 1
      }
      if (word_count > 1) {
        found = 1
        printf "%s uses %d convention words:%s\n", prefix, word_count, locations[prefix]
      }
    }
    if (!found) {
      print "No same-prefix naming drift found."
    }
  }
' "$literal_union_tmp" | limit_output

cat <<'NOTE'

== Notes ==
This script prints naming drift candidates only. Confirm semantic ownership before reporting.
Different names can be correct when lifecycles differ, even if they share literal values.
NOTE
