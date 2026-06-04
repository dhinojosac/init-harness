#!/usr/bin/env bash
# install.sh — init-harness installer for Linux / macOS
# https://github.com/dhinojosac/init-harness
set -euo pipefail

VERSION="1.0.0"
CYAN='\033[0;36m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
banner() { echo -e "${CYAN}$1${NC}"; }
ok()     { echo -e "${GREEN}✓ $1${NC}"; }
warn()   { echo -e "${YELLOW}⚠ $1${NC}"; }
fail()   { echo -e "${RED}✗ $1${NC}"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPT_FILE="$SCRIPT_DIR/init-harness.md"
[ -f "$PROMPT_FILE" ] || fail "init-harness.md not found. Run from the repo root."

banner "init-harness v$VERSION — Installer"
echo ""

# ── Claude Code ───────────────────────────────────────────────────────────────
CLAUDE_DIR="$HOME/.claude/commands"
echo "Installing for Claude Code..."
mkdir -p "$CLAUDE_DIR"
cp "$PROMPT_FILE" "$CLAUDE_DIR/init-harness.md"
ok "Claude Code  →  $CLAUDE_DIR/init-harness.md"
echo "   Usage: type /init-harness in any Claude Code session"
echo ""

# ── Cursor ────────────────────────────────────────────────────────────────────
CURSOR_DIR="$HOME/.cursor/commands"
echo "Installing for Cursor..."
mkdir -p "$CURSOR_DIR"
cp "$PROMPT_FILE" "$CURSOR_DIR/init-harness.md"
ok "Cursor  →  $CURSOR_DIR/init-harness.md"
echo "   Usage: type /init-harness in any Cursor AI chat"
echo ""

# ── OpenAI Codex CLI ──────────────────────────────────────────────────────────
CODEX_DIR="$HOME/.codex/prompts"
echo "Installing for OpenAI Codex CLI..."
mkdir -p "$CODEX_DIR"
cp "$PROMPT_FILE" "$CODEX_DIR/init-harness.md"
ok "Codex  →  $CODEX_DIR/init-harness.md"
echo "   Usage: type /prompts:init-harness in any Codex session"
echo ""

# ── Done ──────────────────────────────────────────────────────────────────────
banner "Installation complete!"
echo ""
echo "  Platform        Command"
echo "  ──────────────  ──────────────────────────"
echo "  Claude Code     /init-harness"
echo "  Cursor          /init-harness"
echo "  Codex CLI       /prompts:init-harness"
echo ""
echo "Open any project in your AI tool and run the command above."
