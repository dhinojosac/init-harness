#!/usr/bin/env bash
# install.sh — init-harness installer for Linux / macOS
# https://github.com/dhinojosac/init-harness
set -euo pipefail

VERSION="1.2.0"
CYAN='\033[0;36m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; BOLD='\033[1m'; NC='\033[0m'
banner()   { echo -e "\n${CYAN}${BOLD}▸ $1${NC}"; }
ok()       { echo -e "  ${GREEN}✓${NC} $1"; }
note()     { echo -e "  ${YELLOW}→${NC} $1"; }
fail()     { echo -e "  ${RED}✗ $1${NC}"; exit 1; }
divider()  { echo -e "${CYAN}────────────────────────────────────────────${NC}"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMAND_FILE="$SCRIPT_DIR/init-harness.md"
SKILL_FILE="$SCRIPT_DIR/skills/init-harness/SKILL.md"

[ -f "$COMMAND_FILE" ] || fail "init-harness.md not found — run from the repo root."
[ -f "$SKILL_FILE"   ] || fail "skills/init-harness/SKILL.md not found — run from the repo root."

divider
echo -e "  ${BOLD}init-harness v$VERSION — Installer${NC}"
divider

# ── Claude Code  (commands format, still current) ────────────────────────────
banner "Claude Code"
CLAUDE_CMD="$HOME/.claude/commands"
mkdir -p "$CLAUDE_CMD"
cp "$COMMAND_FILE" "$CLAUDE_CMD/init-harness.md"
ok "~/.claude/commands/init-harness.md"
note "Invoke: /init-harness"

# ── Cursor  (skills format — current standard) ────────────────────────────────
banner "Cursor"
CURSOR_SKILL="$HOME/.cursor/skills/init-harness"
mkdir -p "$CURSOR_SKILL"
cp "$SKILL_FILE" "$CURSOR_SKILL/SKILL.md"
ok "~/.cursor/skills/init-harness/SKILL.md  (current)"

# Legacy: keep commands/ for older Cursor versions
CURSOR_CMD="$HOME/.cursor/commands"
mkdir -p "$CURSOR_CMD"
cp "$COMMAND_FILE" "$CURSOR_CMD/init-harness.md"
ok "~/.cursor/commands/init-harness.md       (legacy fallback)"
note "Invoke: /init-harness  in Cursor Agent chat"

# ── Cross-agent standard (.agents/skills) ────────────────────────────────────
# Canonical path for both Cursor and Codex (highest priority in both tools)
banner "Cross-agent standard  (~/.agents/skills)"
AGENTS_SKILL="$HOME/.agents/skills/init-harness"
mkdir -p "$AGENTS_SKILL"
cp "$SKILL_FILE" "$AGENTS_SKILL/SKILL.md"
ok "~/.agents/skills/init-harness/SKILL.md"
note "Used by: Cursor, OpenAI Codex, and any agent supporting the Agent Skills standard"

# ── OpenAI Codex  (legacy path) ──────────────────────────────────────────────
banner "OpenAI Codex  (legacy)"
CODEX_SKILL="$HOME/.codex/skills/init-harness"
mkdir -p "$CODEX_SKILL"
cp "$SKILL_FILE" "$CODEX_SKILL/SKILL.md"
ok "~/.codex/skills/init-harness/SKILL.md   (legacy fallback)"
note "Invoke: \$init-harness  in Codex"

# NOTE: Codex 'rules' (~/.codex/rules/) are Starlark command-permission files,
# NOT behavior instructions — no init-harness rule file is created there.

# ── Summary ───────────────────────────────────────────────────────────────────
divider
echo -e "  ${BOLD}Installation complete — v$VERSION${NC}"
divider
printf "\n  %-20s %-42s %s\n" "Platform" "Path" "Command"
printf "  %-20s %-42s %s\n" "──────────────────" "────────────────────────────────────────" "──────────────"
printf "  %-20s %-42s %s\n" "Claude Code"     "~/.claude/commands/"                       "/init-harness"
printf "  %-20s %-42s %s\n" "Cursor"          "~/.cursor/skills/  +  ~/.agents/skills/"   "/init-harness"
printf "  %-20s %-42s %s\n" "OpenAI Codex"    "~/.agents/skills/  +  ~/.codex/skills/"    "\$init-harness"
echo ""
echo "  Open any project in your AI tool and run the command above."
echo ""
