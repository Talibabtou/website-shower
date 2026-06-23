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
    --glob '*.css' \
    --glob '!*.d.ts' \
    --glob '!**/*.d.ts' \
    --glob '!**/__generated__/**' \
    --glob '!**/generated/**' \
    "$@" \
    "$pattern" \
    "$TARGET" 2>/dev/null | limit_output || true
}

is_tailwind_project() {
  [ -f "$TARGET/tailwind.config.js" ] ||
    [ -f "$TARGET/tailwind.config.cjs" ] ||
    [ -f "$TARGET/tailwind.config.mjs" ] ||
    [ -f "$TARGET/tailwind.config.ts" ] ||
    { [ -f "$TARGET/package.json" ] && rg --quiet '"tailwindcss"|@tailwindcss/' "$TARGET/package.json" 2>/dev/null; } ||
    rg --quiet '(@import[[:space:]]+["'\'']tailwindcss["'\'']|@tailwind[[:space:]]+(base|components|utilities))' \
      "$TARGET" --glob '*.css' 2>/dev/null
}

has_css_source() {
  rg --files "$TARGET" --glob '*.css' --glob '!**/node_modules/**' --glob '!**/dist/**' --glob '!**/build/**' 2>/dev/null |
    head -n 1 |
    rg --quiet '.'
}

print_css_design_system_leads() {
  section "CSS files"
  rg --files "$TARGET" \
    --glob '*.css' \
    --glob '!**/node_modules/**' \
    --glob '!**/dist/**' \
    --glob '!**/build/**' 2>/dev/null | limit_output || true

  section "CSS token definitions"
  rg --color never --line-number \
    --glob '*.css' \
    --glob '!**/node_modules/**' \
    --glob '!**/dist/**' \
    --glob '!**/build/**' \
    '(^|[[:space:]])--(color|spacing|radius|font|text|shadow|breakpoint|[A-Za-z0-9_-]+)[[:space:]]*:' \
    "$TARGET" 2>/dev/null | limit_output || true

  section "CSS raw value leads"
  rg --color never --line-number \
    --glob '*.css' \
    --glob '!**/node_modules/**' \
    --glob '!**/dist/**' \
    --glob '!**/build/**' \
    '(#[0-9a-fA-F]{3,8}|[0-9]+px|[0-9]+rem|rgba?\([^)]*\)|box-shadow:[^;]+|border-radius:[^;]+)' \
    "$TARGET" 2>/dev/null | limit_output || true

  section "CSS selector leads"
  rg --color never --line-number \
    --glob '*.css' \
    --glob '!**/node_modules/**' \
    --glob '!**/dist/**' \
    --glob '!**/build/**' \
    '^\.[A-Za-z0-9_-]+[[:space:]]*\{' \
    "$TARGET" 2>/dev/null | limit_output || true

  section "Repeated CSS raw values"
  rg --color never --only-matching \
    --glob '*.css' \
    --glob '!**/node_modules/**' \
    --glob '!**/dist/**' \
    --glob '!**/build/**' \
    '(#[0-9a-fA-F]{3,8}|[0-9]+px|[0-9]+rem|rgba?\([^)]*\))' \
    "$TARGET" 2>/dev/null |
    awk '
      {
        value = $0
        count[value] += 1
      }
      END {
        found = 0
        for (value in count) {
          if (count[value] > 1) {
            found = 1
            printf "%s appears %d times\n", value, count[value]
          }
        }
        if (!found) {
          print "No repeated CSS raw values found."
        }
      }
    ' | limit_output
}

section "Target"
printf '%s\n' "$TARGET"

if ! is_tailwind_project; then
  section "Tailwind"
  printf 'Tailwind not detected; skipping Tailwind-specific cleanup audit.\n'
  if has_css_source; then
    section "CSS migration leads"
    printf 'CSS files detected without Tailwind. Consider a Tailwind transition only if the repo has repeated design tokens, utility-like CSS, or component style drift.\n'
    print_css_design_system_leads
  fi
  exit 0
fi

section "Tailwind signals"
for path in \
  package.json \
  tailwind.config.js \
  tailwind.config.cjs \
  tailwind.config.mjs \
  tailwind.config.ts \
  postcss.config.js \
  postcss.config.mjs \
  src/app/globals.css \
  app/globals.css \
  src/styles/globals.css; do
  if [ -e "$TARGET/$path" ]; then
    printf '%s\n' "$path"
  fi
done
run_rg '(@import[[:space:]]+["'\'']tailwindcss["'\'']|@tailwind[[:space:]]+(base|components|utilities)|@theme|@source)'

section "Content and source configuration"
run_rg '(content:[[:space:]]*\[|@source[[:space:]]+|source\()' \
  --glob 'tailwind.config.*' \
  --glob '*.css'

section "Theme token definitions"
run_rg '(theme:[[:space:]]*\{|extend:[[:space:]]*\{|@theme|--(color|spacing|radius|font|text|shadow|breakpoint)-)' \
  --glob 'tailwind.config.*' \
  --glob '*.css'

section "Arbitrary value leads"
run_rg '[A-Za-z0-9_:/.-]+-\[[^]]+\]'

section "Dynamic class construction leads"
run_rg '(className=.*[`][^`]*\$\{|className=.*\+|bg-\$\{|text-\$\{|border-\$\{|from-\$\{|to-\$\{|grid-cols-\$\{|w-\$\{|h-\$\{)'

section "Long className leads"
run_rg 'className=["'\''][^"'\'']{120,}["'\'']|className=\{[^}]{160,}\}'

section "Duplicate utility leads"
run_rg 'className=' |
  awk '
    {
      delete seen
      duplicate = ""
      for (i = 1; i <= NF; i++) {
        token = $i
        gsub(/^[`"{(]+|[`",;)}]+$/, "", token)
        if (index(token, "-") > 0) {
          if (seen[token] == 1) {
            duplicate = duplicate token " "
          }
          seen[token] = 1
        }
      }
      if (duplicate != "") {
        print $0
      }
    }
  ' | limit_output

section "Class composition helpers"
run_rg '\b(cn|clsx|cva|twMerge|tailwind-merge)\b'

section "Apply and custom CSS leads"
run_rg '(@apply|@layer[[:space:]]+components|@layer[[:space:]]+utilities)'

print_css_design_system_leads

cat <<'NOTE'

== Notes ==
This script prints Tailwind and CSS design-system candidates only. Confirm Tailwind version,
source detection, theme ownership, CSS ownership, and component ownership before reporting a task.
NOTE
