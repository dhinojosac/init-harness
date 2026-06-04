#!/usr/bin/env bash
# install.sh — init-harness installer for Linux / macOS
# https://github.com/dhinojosac/init-harness
set -euo pipefail

VERSION="1.1.0"
CYAN='\033[0;36m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
banner() { echo -e "${CYAN}$1${NC}"; }
ok()     { echo -e "${GREEN}✓ $1${NC}"; }
warn()   { echo -e "${YELLOW}⚠ $1${NC}"; }
fail()   { echo -e "${RED}✗ $1${NC}"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMAND_FILE="$SCRIPT_DIR/init-harness.md"
SKILL_DIR="$SCRIPT_DIR/skills/init-harness"

[ -f "$COMMAND_FILE" ] || fail "init-harness.md not found. Run from the repo root."
[ -f "$SKILL_DIR/SKILL.md" ] || fail "skills/init-harness/SKILL.md not found. Run from the repo root."

banner "init-harness v$VERSION — Installer"
echo ""

# ── Claude Code (commands format) ────────────────────────────────────────────
echo "Installing for Claude Code..."
CLAUDE_CMD_DIR="$HOME/.claude/commands"
mkdir -p "$CLAUDE_CMD_DIR"
cp "$COMMAND_FILE" "$CLAUDE_CMD_DIR/init-harness.md"
ok "Claude Code  →  $CLAUDE_CMD_DIR/init-harness.md"
echo "   Invoke: /init-harness"
echo ""

# ── Cursor (commands format) ──────────────────────────────────────────────────
echo "Installing for Cursor..."
CURSOR_CMD_DIR="$HOME/.cursor/commands"
mkdir -p "$CURSOR_CMD_DIR"
cp "$COMMAND_FILE" "$CURSOR_CMD_DIR/init-harness.md"
ok "Cursor  →  $CURSOR_CMD_DIR/init-harness.md"
echo "   Invoke: /init-harness"
echo ""

# ── OpenAI Codex (skills format — current standard) ──────────────────────────
echo "Installing for OpenAI Codex (skills)..."
CODEX_SKILL_DIR="$HOME/.agents/skills/init-harness"
mkdir -p "$CODEX_SKILL_DIR"
cp "$SKILL_DIR/SKILL.md" "$CODEX_SKILL_DIR/SKILL.md"
ok "Codex (agents)  →  $CODEX_SKILL_DIR/SKILL.md"

# Also install to legacy ~/.codex/skills/ for older Codex versions
CODEX_LEGACY_DIR="$HOME/.codex/skills/init-harness"
mkdir -p "$CODEX_LEGACY_DIR"
cp "$SKILL_DIR/SKILL.md" "$CODEX_LEGACY_DIR/SKILL.md"
ok "Codex (legacy) →  $CODEX_LEGACY_DIR/SKILL.md"
echo "   Invoke: \$init-harness  or  /skills → init-harness"
echo ""

# ── Claude skills path (cross-agent standard) ─────────────────────────────────
CLAUDE_SKILL_DIR="$HOME/.claude/skills/init-harness"
mkdir -p "$CLAUDE_SKILL_DIR"
cp "$SKILL_DIR/SKILL.md" "$CLAUDE_SKILL_DIR/SKILL.md"
ok "Claude skills  →  $CLAUDE_SKILL_DIR/SKILL.md"
echo ""

# ── Done ──────────────────────────────────────────────────────────────────────
banner "Installation complete!"
echo ""
printf "  %-16s %-30s %s\n" "Platform" "Format installed" "Command"
printf "  %-16s %-30s %s\n" "────────────────" "──────────────────────────────" "──────────────────────────"
printf "  %-16s %-30s %s\n" "Claude Code"     "~/.claude/commands/"    "/init-harness"
printf "  %-16s %-30s %s\n" "Cursor"          "~/.cursor/commands/"    "/init-harness"
printf "  %-16s %-30s %s\n" "Codex (current)" "~/.agents/skills/"      "\$init-harness"
printf "  %-16s %-30s %s\n" "Codex (legacy)"  "~/.codex/skills/"       "\$init-harness"
echo ""
echo "Open any project in your AI tool and run the command above."
