# install.ps1 — init-harness installer for Windows (PowerShell)
# https://github.com/dhinojosac/init-harness

$VERSION = "2.0.0"

function Banner($msg) { Write-Host "`n> $msg" -ForegroundColor Cyan }
function Ok($msg)     { Write-Host "  v $msg" -ForegroundColor Green }
function Note($msg)   { Write-Host "  -> $msg" -ForegroundColor Yellow }
function Fail($msg)   { Write-Host "  X $msg" -ForegroundColor Red; exit 1 }
function Divider()    { Write-Host "--------------------------------------------" -ForegroundColor Cyan }

$ScriptDir   = Split-Path -Parent $MyInvocation.MyCommand.Path
$CommandFile = Join-Path $ScriptDir "init-harness.md"
$SkillFile   = Join-Path $ScriptDir "skills\init-harness\SKILL.md"

if (-not (Test-Path $CommandFile)) { Fail "init-harness.md not found — run from the repo root." }
if (-not (Test-Path $SkillFile))   { Fail "skills\init-harness\SKILL.md not found — run from the repo root." }

Divider
Write-Host "  init-harness v$VERSION — Installer" -ForegroundColor White
Divider

# ── Claude Code  (commands format, still current) ────────────────────────────
Banner "Claude Code"
$ClaudeCmd = "$env:USERPROFILE\.claude\commands"
New-Item -ItemType Directory -Force -Path $ClaudeCmd | Out-Null
Copy-Item $CommandFile "$ClaudeCmd\init-harness.md" -Force
Ok "~\.claude\commands\init-harness.md"
Note "Invoke: /init-harness"

# ── Cursor  (skills format — current standard) ────────────────────────────────
Banner "Cursor"
$CursorSkill = "$env:USERPROFILE\.cursor\skills\init-harness"
New-Item -ItemType Directory -Force -Path $CursorSkill | Out-Null
Copy-Item $SkillFile "$CursorSkill\SKILL.md" -Force
Ok "~\.cursor\skills\init-harness\SKILL.md  (current)"

# Legacy: keep commands/ for older Cursor versions
$CursorCmd = "$env:USERPROFILE\.cursor\commands"
New-Item -ItemType Directory -Force -Path $CursorCmd | Out-Null
Copy-Item $CommandFile "$CursorCmd\init-harness.md" -Force
Ok "~\.cursor\commands\init-harness.md       (legacy fallback)"
Note "Invoke: /init-harness  in Cursor Agent chat"

# ── Cross-agent standard (.agents/skills) ────────────────────────────────────
# Canonical path for both Cursor and Codex (highest priority in both tools)
Banner "Cross-agent standard  (~\.agents\skills)"
$AgentsSkill = "$env:USERPROFILE\.agents\skills\init-harness"
New-Item -ItemType Directory -Force -Path $AgentsSkill | Out-Null
Copy-Item $SkillFile "$AgentsSkill\SKILL.md" -Force
Ok "~\.agents\skills\init-harness\SKILL.md"
Note "Used by: Cursor, OpenAI Codex, and any agent supporting the Agent Skills standard"

# ── OpenAI Codex  (legacy path) ──────────────────────────────────────────────
Banner "OpenAI Codex  (legacy)"
$CodexSkill = "$env:USERPROFILE\.codex\skills\init-harness"
New-Item -ItemType Directory -Force -Path $CodexSkill | Out-Null
Copy-Item $SkillFile "$CodexSkill\SKILL.md" -Force
Ok "~\.codex\skills\init-harness\SKILL.md   (legacy fallback)"
Note "Invoke: `$init-harness  in Codex"

# NOTE: Codex 'rules' (~\.codex\rules\) are Starlark command-permission files,
# NOT behavior instructions — no init-harness rule file is created there.

# ── Summary ───────────────────────────────────────────────────────────────────
Divider
Write-Host "  Installation complete — v$VERSION" -ForegroundColor White
Divider
Write-Host ""
Write-Host "  Platform              Path                                        Command"
Write-Host "  --------------------  ------------------------------------------  --------------"
Write-Host "  Claude Code           ~\.claude\commands\                          /init-harness"
Write-Host "  Cursor                ~\.cursor\skills\  +  ~\.agents\skills\      /init-harness"
Write-Host "  OpenAI Codex          ~\.agents\skills\  +  ~\.codex\skills\       `$init-harness"
Write-Host ""
Write-Host "  Open any project in your AI tool and run the command above."
Write-Host ""
