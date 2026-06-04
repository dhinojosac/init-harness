# install.ps1 — init-harness installer for Windows (PowerShell)
# https://github.com/dhinojosac/init-harness

$VERSION = "1.1.0"

function Banner($msg) { Write-Host $msg -ForegroundColor Cyan }
function Ok($msg)     { Write-Host "v $msg" -ForegroundColor Green }
function Warn($msg)   { Write-Host "! $msg" -ForegroundColor Yellow }
function Fail($msg)   { Write-Host "X $msg" -ForegroundColor Red; exit 1 }

$ScriptDir   = Split-Path -Parent $MyInvocation.MyCommand.Path
$CommandFile = Join-Path $ScriptDir "init-harness.md"
$SkillFile   = Join-Path $ScriptDir "skills\init-harness\SKILL.md"

if (-not (Test-Path $CommandFile)) { Fail "init-harness.md not found. Run from the repo root." }
if (-not (Test-Path $SkillFile))   { Fail "skills\init-harness\SKILL.md not found. Run from the repo root." }

Banner "init-harness v$VERSION — Installer"
Write-Host ""

# ── Claude Code (commands format) ────────────────────────────────────────────
Write-Host "Installing for Claude Code..."
$ClaudeCmdDir = "$env:USERPROFILE\.claude\commands"
New-Item -ItemType Directory -Force -Path $ClaudeCmdDir | Out-Null
Copy-Item $CommandFile "$ClaudeCmdDir\init-harness.md" -Force
Ok "Claude Code  ->  $ClaudeCmdDir\init-harness.md"
Write-Host "   Invoke: /init-harness"
Write-Host ""

# ── Cursor (commands format) ──────────────────────────────────────────────────
Write-Host "Installing for Cursor..."
$CursorCmdDir = "$env:USERPROFILE\.cursor\commands"
New-Item -ItemType Directory -Force -Path $CursorCmdDir | Out-Null
Copy-Item $CommandFile "$CursorCmdDir\init-harness.md" -Force
Ok "Cursor  ->  $CursorCmdDir\init-harness.md"
Write-Host "   Invoke: /init-harness"
Write-Host ""

# ── OpenAI Codex (skills format — current standard) ──────────────────────────
Write-Host "Installing for OpenAI Codex (skills)..."
$CodexSkillDir = "$env:USERPROFILE\.agents\skills\init-harness"
New-Item -ItemType Directory -Force -Path $CodexSkillDir | Out-Null
Copy-Item $SkillFile "$CodexSkillDir\SKILL.md" -Force
Ok "Codex (agents)  ->  $CodexSkillDir\SKILL.md"

$CodexLegacyDir = "$env:USERPROFILE\.codex\skills\init-harness"
New-Item -ItemType Directory -Force -Path $CodexLegacyDir | Out-Null
Copy-Item $SkillFile "$CodexLegacyDir\SKILL.md" -Force
Ok "Codex (legacy) ->  $CodexLegacyDir\SKILL.md"
Write-Host "   Invoke: `$init-harness  or  /skills -> init-harness"
Write-Host ""

# ── Claude skills path (cross-agent standard) ─────────────────────────────────
$ClaudeSkillDir = "$env:USERPROFILE\.claude\skills\init-harness"
New-Item -ItemType Directory -Force -Path $ClaudeSkillDir | Out-Null
Copy-Item $SkillFile "$ClaudeSkillDir\SKILL.md" -Force
Ok "Claude skills  ->  $ClaudeSkillDir\SKILL.md"
Write-Host ""

# ── Done ──────────────────────────────────────────────────────────────────────
Banner "Installation complete!"
Write-Host ""
Write-Host "  Platform         Format installed               Command"
Write-Host "  ---------------  -----------------------------  -------------------------"
Write-Host "  Claude Code      ~/.claude/commands/            /init-harness"
Write-Host "  Cursor           ~/.cursor/commands/            /init-harness"
Write-Host "  Codex (current)  ~/.agents/skills/              `$init-harness"
Write-Host "  Codex (legacy)   ~/.codex/skills/               `$init-harness"
Write-Host ""
Write-Host "Open any project in your AI tool and run the command above."
