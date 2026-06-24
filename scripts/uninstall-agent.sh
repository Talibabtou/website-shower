#!/usr/bin/env bash

set -euo pipefail

AGENT="${1:-}"
TARGET="${2:-$PWD}"

usage() {
  cat <<'USAGE'
usage: scripts/uninstall-agent.sh <agent> [target-project]

Remove Website Shower adapters installed by scripts/install-agent.sh.

Agents:
  codex       Remove ~/.codex/skills/website-shower
  opencode    Remove opencode.json and .opencode from the target project
  openclaw    Remove ~/.openclaw/skills/website-shower
  cursor      Remove .cursor/rules/website-shower.mdc from the target project
  windsurf    Remove .windsurf/rules/website-shower.md from the target project
  cline       Remove .clinerules/website-shower.md from the target project
  kiro        Remove .kiro/steering/website-shower.md from the target project
  copilot     Remove .github/copilot-instructions.md from the target project
  agents      Remove AGENTS.md from the target project
  all-local   Remove all project-local instruction adapters from the target project

Examples:
  scripts/uninstall-agent.sh codex
  scripts/uninstall-agent.sh cursor /path/to/project
  scripts/uninstall-agent.sh all-local /path/to/project
USAGE
}

remove_path() {
  local path="$1"

  if [ -e "$path" ] || [ -L "$path" ]; then
    rm -rf "$path"
    printf 'removed %s\n' "$path"
  else
    printf 'not found %s\n' "$path"
  fi
}

uninstall_project_local() {
  remove_path "$TARGET/AGENTS.md"
  remove_path "$TARGET/.github/copilot-instructions.md"
  remove_path "$TARGET/.cursor/rules/website-shower.mdc"
  remove_path "$TARGET/.windsurf/rules/website-shower.md"
  remove_path "$TARGET/.clinerules/website-shower.md"
  remove_path "$TARGET/.kiro/steering/website-shower.md"
  remove_path "$TARGET/.agents/rules/website-shower.md"
  remove_path "$TARGET/opencode.json"
  remove_path "$TARGET/.opencode"
}

if [ -z "$AGENT" ] || [ "$AGENT" = "-h" ] || [ "$AGENT" = "--help" ]; then
  usage
  exit 0
fi

case "$AGENT" in
  codex)
    remove_path "$HOME/.codex/skills/website-shower"
    ;;
  opencode)
    remove_path "$TARGET/opencode.json"
    remove_path "$TARGET/.opencode"
    ;;
  openclaw)
    remove_path "$HOME/.openclaw/skills/website-shower"
    ;;
  cursor)
    remove_path "$TARGET/.cursor/rules/website-shower.mdc"
    ;;
  windsurf)
    remove_path "$TARGET/.windsurf/rules/website-shower.md"
    ;;
  cline)
    remove_path "$TARGET/.clinerules/website-shower.md"
    ;;
  kiro)
    remove_path "$TARGET/.kiro/steering/website-shower.md"
    ;;
  copilot)
    remove_path "$TARGET/.github/copilot-instructions.md"
    ;;
  agents)
    remove_path "$TARGET/AGENTS.md"
    ;;
  all-local)
    uninstall_project_local
    ;;
  *)
    printf 'unknown agent: %s\n\n' "$AGENT" >&2
    usage >&2
    exit 1
    ;;
esac
