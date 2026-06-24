#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
AGENT="${1:-}"
TARGET="${2:-$PWD}"

usage() {
  cat <<'USAGE'
usage: scripts/install-agent.sh <agent> [target-project]

Install Website Shower adapters.

Agents:
  codex       Link this repo into ~/.codex/skills/website-shower
  opencode    Copy opencode.json and .opencode/ into the target project
  openclaw    Copy .openclaw/skills/website-shower into ~/.openclaw/skills/
  cursor      Copy .cursor/rules/website-shower.mdc into the target project
  windsurf    Copy .windsurf/rules/website-shower.md into the target project
  cline       Copy .clinerules/website-shower.md into the target project
  kiro        Copy .kiro/steering/website-shower.md into the target project
  copilot     Copy .github/copilot-instructions.md into the target project
  agents      Copy AGENTS.md into the target project
  all-local   Install all project-local instruction adapters into the target project

Examples:
  scripts/install-agent.sh codex
  scripts/install-agent.sh cursor /path/to/project
  scripts/install-agent.sh all-local /path/to/project
USAGE
}

copy_file() {
  local source="$1"
  local destination="$2"

  mkdir -p "$(dirname "$destination")"
  cp "$source" "$destination"
  printf 'installed %s\n' "$destination"
}

copy_dir() {
  local source="$1"
  local destination="$2"

  mkdir -p "$(dirname "$destination")"
  rm -rf "$destination"
  cp -R "$source" "$destination"
  printf 'installed %s\n' "$destination"
}

install_project_local() {
  copy_file "$ROOT/AGENTS.md" "$TARGET/AGENTS.md"
  copy_file "$ROOT/.github/copilot-instructions.md" "$TARGET/.github/copilot-instructions.md"
  copy_file "$ROOT/.cursor/rules/website-shower.mdc" "$TARGET/.cursor/rules/website-shower.mdc"
  copy_file "$ROOT/.windsurf/rules/website-shower.md" "$TARGET/.windsurf/rules/website-shower.md"
  copy_file "$ROOT/.clinerules/website-shower.md" "$TARGET/.clinerules/website-shower.md"
  copy_file "$ROOT/.kiro/steering/website-shower.md" "$TARGET/.kiro/steering/website-shower.md"
  copy_file "$ROOT/.agents/rules/website-shower.md" "$TARGET/.agents/rules/website-shower.md"
  copy_file "$ROOT/opencode.json" "$TARGET/opencode.json"
  copy_dir "$ROOT/.opencode" "$TARGET/.opencode"
}

if [ -z "$AGENT" ] || [ "$AGENT" = "-h" ] || [ "$AGENT" = "--help" ]; then
  usage
  exit 0
fi

case "$AGENT" in
  codex)
    mkdir -p "$HOME/.codex/skills"
    ln -sfn "$ROOT" "$HOME/.codex/skills/website-shower"
    printf 'linked %s\n' "$HOME/.codex/skills/website-shower"
    ;;
  opencode)
    copy_file "$ROOT/opencode.json" "$TARGET/opencode.json"
    copy_dir "$ROOT/.opencode" "$TARGET/.opencode"
    ;;
  openclaw)
    mkdir -p "$HOME/.openclaw/skills"
    copy_dir "$ROOT/.openclaw/skills/website-shower" "$HOME/.openclaw/skills/website-shower"
    ;;
  cursor)
    copy_file "$ROOT/.cursor/rules/website-shower.mdc" "$TARGET/.cursor/rules/website-shower.mdc"
    ;;
  windsurf)
    copy_file "$ROOT/.windsurf/rules/website-shower.md" "$TARGET/.windsurf/rules/website-shower.md"
    ;;
  cline)
    copy_file "$ROOT/.clinerules/website-shower.md" "$TARGET/.clinerules/website-shower.md"
    ;;
  kiro)
    copy_file "$ROOT/.kiro/steering/website-shower.md" "$TARGET/.kiro/steering/website-shower.md"
    ;;
  copilot)
    copy_file "$ROOT/.github/copilot-instructions.md" "$TARGET/.github/copilot-instructions.md"
    ;;
  agents)
    copy_file "$ROOT/AGENTS.md" "$TARGET/AGENTS.md"
    ;;
  all-local)
    install_project_local
    ;;
  *)
    printf 'unknown agent: %s\n\n' "$AGENT" >&2
    usage >&2
    exit 1
    ;;
esac
