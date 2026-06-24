#!/usr/bin/env bash

set -uo pipefail

TARGET="${1:-.}"

if [ ! -d "$TARGET" ]; then
  echo "error: target is not a directory: $TARGET" >&2
  exit 1
fi

section() {
  printf '\n== %s ==\n' "$1"
}

has_files() {
  (cd "$TARGET" && rg --files "$@" 2>/dev/null | sed "s#^#$TARGET/#" | head -n 40)
}

section "Target"
printf '%s\n' "$TARGET"

section "Website map"
has_files \
  -g 'package.json' \
  -g 'pnpm-workspace.yaml' \
  -g 'turbo.json' \
  -g 'nx.json' \
  -g 'next.config.*' \
  -g 'vite.config.*' \
  -g 'astro.config.*' \
  -g 'remix.config.*' \
  -g 'svelte.config.*' \
  -g 'tailwind.config.*' \
  -g 'tsconfig*.json' \
  -g 'biome.json' \
  -g 'eslint.config.*' \
  -g '.eslintrc*' \
  -g '.prettierrc*' \
  -g 'prettier.config.*'

section "App roots and packages"
has_files \
  -g 'src/app/**/*' \
  -g 'src/pages/**/*' \
  -g 'src/routes/**/*' \
  -g 'app/**/*' \
  -g 'pages/**/*' \
  -g 'routes/**/*' \
  -g 'apps/*/package.json' \
  -g 'packages/*/package.json'

section "Feature and domain roots"
has_files \
  -g 'src/features/**/*' \
  -g 'src/feature/**/*' \
  -g 'src/domain/**/*' \
  -g 'src/modules/**/*' \
  -g 'src/components/**/*' \
  -g 'src/ui/**/*' \
  -g 'src/lib/**/*' \
  -g 'src/server/**/*' \
  -g 'src/state/**/*' \
  -g 'src/store/**/*'

section "API and data boundaries"
has_files \
  -g 'src/app/api/**/*' \
  -g 'src/pages/api/**/*' \
  -g 'src/api/**/*' \
  -g 'src/server/**/*' \
  -g 'src/services/**/*' \
  -g 'src/lib/api/**/*' \
  -g 'src/graphql/**/*' \
  -g 'src/trpc/**/*'

section "Tests and stories"
has_files \
  -g '**/*.test.*' \
  -g '**/*.spec.*' \
  -g '**/*.stories.*' \
  -g 'tests/**/*' \
  -g '__tests__/**/*' \
  -g 'e2e/**/*'

section "Generated and ignored candidates"
has_files \
  -g 'src/generated/**/*' \
  -g 'generated/**/*' \
  -g '**/__generated__/**/*' \
  -g 'graphql/generated/**/*' \
  -g 'prisma/**/*' \
  -g 'supabase/migrations/**/*' \
  -g 'drizzle/**/*' \
  -g 'dist/**/*' \
  -g 'build/**/*'

section "Notes"
cat <<'NOTE'
Use this map before judging module findings. It should tell the agent which app roots,
feature owners, API/data boundaries, tests, generated outputs, and package boundaries exist.
If a section is empty, mention that in the inspected-scope report instead of inventing coverage.
NOTE
