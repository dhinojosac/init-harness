# install.ps1 — init-harness installer for Windows (PowerShell)
# https://github.com/dhinojosac/init-harness

$VERSION = "1.0.0"

function Banner($msg) { Write-Host $msg -ForegroundColor Cyan }
function Ok($msg)     { Write-Host "v $msg" -ForegroundColor Green }
function Warn($msg)   { Write-Host "! $msg" -ForegroundColor Yellow }
function Fail($msg)   { Write-Host "X $msg" -ForegroundColor Red; exit 1 }

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PromptFile = Join-Path $ScriptDir "init-harness.md"
if (-not (Test-Path $PromptFile)) { Fail "init-harness.md not found. Run from the repo root." }

Banner "init-harness v$VERSION — Installer"
Write-Host ""

# ── Claude Code ───────────────────────────────────────────────────────────────
$ClaudeDir = "$env:USERPROFILE\.claude\commands"
Write-Host "Installing for Claude Code..."
New-Item -ItemType Directory -Force -Path $ClaudeDir | Out-Null
Copy-Item $PromptFile "$ClaudeDir\init-harness.md" -Force
Ok "Claude Code  ->  $ClaudeDir\init-harness.md"
Write-Host "   Usage: type /init-harness in any Claude Code session"
Write-Host ""

# ── Cursor ────────────────────────────────────────────────────────────────────
$CursorDir = "$env:USERPROFILE\.cursor\commands"
Write-Host "Installing for Cursor..."
New-Item -ItemType Directory -Force -Path $CursorDir | Out-Null
Copy-Item $PromptFile "$CursorDir\init-harness.md" -Force
Ok "Cursor  ->  $CursorDir\init-harness.md"
Write-Host "   Usage: type /init-harness in any Cursor AI chat"
Write-Host ""

# ── OpenAI Codex CLI ──────────────────────────────────────────────────────────
$CodexDir = "$env:USERPROFILE\.codex\prompts"
Write-Host "Installing for OpenAI Codex CLI..."
New-Item -ItemType Directory -Force -Path $CodexDir | Out-Null
Copy-Item $PromptFile "$CodexDir\init-harness.md" -Force
Ok "Codex  ->  $CodexDir\init-harness.md"
Write-Host "   Usage: type /prompts:init-harness in any Codex session"
Write-Host ""

# ── Done ──────────────────────────────────────────────────────────────────────
Banner "Installation complete!"
Write-Host ""
Write-Host "  Platform        Command"
Write-Host "  --------------  --------------------------"
Write-Host "  Claude Code     /init-harness"
Write-Host "  Cursor          /init-harness"
Write-Host "  Codex CLI       /prompts:init-harness"
Write-Host ""
Write-Host "Open any project in your AI tool and run the command above."
