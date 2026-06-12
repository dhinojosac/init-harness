---
description: Initialize the AI agent harness for any project — creates CLAUDE.md, AGENTS.md, .cursorrules, .agents/ context directory, and bootstrap scripts tailored to the current codebase
argument-hint: (optional) override project name
---

# /init-harness

Initialize the AI Agent Harness for the current project, based on Anthropic's
"Effective Harnesses for Long-Running Agents" best practices.

Creates a complete cross-platform harness that works identically on
**Claude Code**, **Cursor**, and **OpenAI Codex** without any reconfiguration.

Optional argument passed via `$ARGUMENTS`: custom project name override.

---

## STEP 0 — Pre-flight analysis (run ALL in parallel, collect results before creating any file)

1. `pwd` — confirm working directory
2. `git log --oneline -10` — understand recent history and naming conventions
   **If this command fails:** git is not initialized. Ask the user:
   > "No git repository detected. Initialize one now? (recommended — the harness uses git for session tracking)"
   - If **yes**: run `git init`, then ask "Add a remote URL? (paste URL or press Enter to skip)"
     - If URL provided: run `git remote add origin <URL>`
     - Continue normally
   - If **no**: continue in **DEGRADED MODE** — note this in progress.md, skip all git
     commands from both session protocols, remove git entries from settings.json allow list
3. `git status` — see what is staged, modified, and untracked
4. `git branch --show-current` — current branch name
5. Read the root manifest: `package.json` / `Cargo.toml` / `pyproject.toml` / `go.mod` / `composer.json` / `build.gradle` — detect language and package manager
6. List top-level directories, excluding: `.git`, `node_modules`, `__pycache__`, `vendor`, `dist`, `.next`, `target`, `.turbo`, `coverage`
7. **Version and harness detection** — check in this order:

   **a. Check `.agents/harness.json`** (present from init-harness v1.3.0+):
   - If found and `generator === "init-harness"`:
     - If `version === "1.3.0"` (current): inform user, ask if they want to regenerate
     - If `version < "1.3.0"`: show upgrade summary → offer upgrade (see UPGRADE MODE below)
     - If `version > "1.3.0"`: warn that a newer harness was detected, ask before proceeding
   - If found and `generator !== "init-harness"`: treat as unknown harness, warn and ask before overwriting

   **b. `.agents/harness.json` not found, but root-level agent files exist**
   (`agent-progress.md` or `agent-features.json` in the project root):
   - This is init-harness **v1.2.0 or earlier**
   - Offer upgrade: inform user of what changes (see UPGRADE MODE below)

   **c. No harness detected** — proceed with fresh install

   ---

   **UPGRADE MODE** (from v1.2.0 → v1.3.0):
   Before generating new files, migrate existing data:
   1. If `agent-progress.md` exists in root → read its content → wrap it as the "Last Session"
      block in the new `.agents/progress.md` rolling-window format → delete old file
   2. If `agent-features.json` exists in root → split it:
      - `.agents/features.json`: copy all entries but strip `"steps"` field from each
      - `.agents/features-detail.json`: copy only `id` + `steps` for each entry
      - Delete old file
   3. Then regenerate all other files normally (CLAUDE.md slim, .agents/refs/, scripts/, settings.json)
   4. Inform user: "Migrated from v1.2.0. Old root files removed."
8. Read the first 80 lines of `README.md` (if present) for project description
9. Read `src/`, `app/`, `lib/`, or equivalent entry-point directories (one level deep) to understand domain entities

From this analysis, determine:
- **Project name** — from manifest name field, or repo folder name if not found
- **Primary language** — TypeScript, Python, Go, Rust, etc.
- **Framework** — Next.js, FastAPI, Gin, Axum, Django, Rails, Laravel, etc.
- **Package manager** — pnpm, npm, yarn, pip/uv, cargo, go, composer, gradle
- **Monorepo?** — yes/no; structure if yes
- **Key scripts** — dev, build, test, lint, typecheck, migrate, seed, etc.
- **Infrastructure stack** — auth system, database, ORM, deployment target
- **Multi-tenant?** — yes/no; tenant discriminator field if yes
- **Test strategy** — unit, integration, e2e, none
- **Git available?** — yes / degraded (no git)

---

## STEP 1 — Create required directories and write harness metadata

```bash
mkdir -p scripts
mkdir -p .claude
mkdir -p .agents/refs
mkdir -p .agents/archive
```

Write `.agents/harness.json` — used by future runs to detect version and offer upgrades:

```json
{
  "generator": "init-harness",
  "version": "1.3.0",
  "generated": "{{TODAY_DATE}}",
  "source": "https://github.com/dhinojosac/init-harness"
}
```

---

## STEP 2 — Generate `CLAUDE.md` (slim — max 55 lines)

Write a lean `CLAUDE.md` tailored to THIS project. Replace every `{{placeholder}}` with
real values from Step 0. The goal is **≤55 lines** — full details go in `.agents/refs/`.
Write `# TODO: fill in` for any value that cannot be determined.

```markdown
# {{PROJECT_NAME}} — AI Agent Harness

> **Platform:** Claude Code auto-loads this file.
> Same content in `AGENTS.md` (Codex) and `.cursorrules` (Cursor).
> After editing this file, regenerate both: re-run `/init-harness --sync`.

---

## 1. Session Startup (MANDATORY)

```bash
bash scripts/init.sh        # Linux / macOS
powershell scripts/init.ps1  # Windows
```

The script prints last session summary, git state, and pending features. Start there — do not run git or cat commands manually before it.

---

## 2. Project

{{PROJECT_DESCRIPTION_ONE_PARAGRAPH}}

**Stack:** `{{LANGUAGE}}` / `{{FRAMEWORK}}` / `{{PACKAGE_MANAGER}}`
**Repo:** `{{REPO_FOLDER_NAME}}`

→ Stack details & structure: `.agents/refs/stack.md`
→ Architecture patterns: `.agents/refs/patterns.md`

---

## 3. Key Commands

```bash
{{DEV_COMMAND}}         # start dev server
{{BUILD_COMMAND}}       # build
{{TEST_COMMAND}}        # run tests
{{TYPECHECK_COMMAND}}   # type check
{{LINT_COMMAND}}        # lint
```

---

## 4. Hard Rules (always apply, no exceptions)

{{TOP_5_RULES_DERIVED_FROM_PROJECT}}
- Atomic commits — one logical change per commit
- Never set `"passes": true` without end-to-end verification
- Never remove features from `.agents/features.json` — only update `"passes"`

→ Full rules: `.agents/refs/rules.md`
→ Common failures: `.agents/refs/failures.md`

---

## 5. Session End (MANDATORY)

```bash
{{TYPECHECK_CMD}}
{{LINT_CMD}}
{{TEST_CMD}}
git add <specific files>
git commit -m "type(scope): description"
# Update .agents/progress.md  →  move current to "last session" (≤7 lines)
# Update .agents/features.json  →  set passes:true only if e2e verified
```

**Commit types:** `feat` · `fix` · `refactor` · `chore` · `docs` · `test`
```

---

## STEP 3 — Generate `.agents/refs/` (4 files)

These files hold the detail that was previously in CLAUDE.md. They are read on-demand — not loaded every session — which keeps the active context lean.

### `.agents/refs/stack.md`

```markdown
# {{PROJECT_NAME}} — Stack Reference

## Tech Stack

| Layer | Choice | Version |
|-------|--------|---------|
{{TECH_STACK_ROWS}}

## Repository Structure

```
{{ANNOTATED_DIRECTORY_TREE}}
```

## Environment Variables

{{ENV_TABLE}}
```

### `.agents/refs/patterns.md`

```markdown
# {{PROJECT_NAME}} — Architectural Patterns

{{PATTERNS_DETAILED — data flow, state management, API conventions, naming, etc.}}
```

### `.agents/refs/rules.md`

```markdown
# {{PROJECT_NAME}} — Coding Rules

{{RULES_DETAILED — style, imports, error handling, test requirements, security, etc.}}
```

### `.agents/refs/failures.md`

```markdown
# {{PROJECT_NAME}} — Common Failure Modes

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
{{FAILURE_TABLE_ROWS — derive from README warnings, known gotchas, git history}}
```

---

## STEP 4 — Generate `AGENTS.md`

Copy `CLAUDE.md` verbatim. Change only the platform note in the header to:

```
> **Platform:** OpenAI Codex auto-loads this file.
> Same content in `CLAUDE.md` (Claude Code) and `.cursorrules` (Cursor).
> After editing CLAUDE.md, regenerate this file: re-run `/init-harness --sync`.
```

---

## STEP 5 — Generate `.cursorrules`

Write a condensed version (maximum 45 lines). Must include:

1. **Session Start** — 2 steps: run init script, pick pending feature
2. **Session End** — 4 steps: typecheck, lint, commit, update .agents/progress.md
3. **Hard Rules** — all non-negotiable constraints, one line each
4. **Stack** — one-line summary
5. **Key Commands** — dev, typecheck, lint, test with actual command text
6. Final line: `## Full docs: CLAUDE.md · .agents/refs/`

---

## STEP 6 — Generate `.agents/progress.md` (rolling window)

```markdown
# Agent Progress

> Rolling window — 3 visible states maximum.
> At end of each session: condense "Current Session" into "Last Session" (≤7 lines),
> move old "Last Session" to `.agents/archive/progress-{{YYYY-MM}}.md`.

---

## Current Session
_Started: {{TODAY_DATE}}_
<!-- Fill this in as you work. Clear completely at session end. -->

## Last Session — {{TODAY_DATE}}
- Initialized harness: CLAUDE.md, AGENTS.md, .cursorrules, .agents/, scripts/, .claude/settings.json
{{UNCOMMITTED_FILES_NOTE — one line if files exist, omit if clean}}
- Next: run scripts/init.sh → pick first pending feature from .agents/features.json

## Archive
→ `.agents/archive/` (sessions older than last)
```

---

## STEP 7 — Generate `.agents/features.json` and `.agents/features-detail.json`

Two files, one purpose: lean lookup at startup, detailed steps on demand.

### `.agents/features.json` — lean registry (no steps)

Infer features from the codebase. Scan:
- Route / page / controller files
- README features section or changelog
- Navigation components / sidebar / menu files
- Existing test files
- Recent commit messages

Aim for **10–25 features** covering all major user-facing flows.
Use realistic `"passes"` values: `true` for clearly shipped functionality,
`false` for anything uncertain, in-progress, or untested.

```json
{
  "version": "2.0",
  "instructions": "NEVER remove or rename entries. Set 'passes': true only after e2e verification. Pick the highest-priority 'passes: false' entry each session. Priority: 1=critical, 2=high, 3=medium, 4=low. Steps for each feature → features-detail.json",
  "features": [
    {
      "id": "{{category}}-001",
      "category": "{{category}}",
      "priority": {{1-4}},
      "description": "{{one sentence, subject-verb-object, testable in a real browser or terminal}}",
      "passes": {{true|false}}
    }
  ]
}
```

Rules:
- Group by category (auth, routing, [domain-entities], ui, i18n, api, jobs, etc.)
- Include an auth flow entry if authentication exists
- Include a data-isolation entry if the project is multi-tenant
- Mark in-progress items (from git status / recent commits) as `"passes": false`
- Never invent features — derive everything from observed files and commits

### `.agents/features-detail.json` — steps per feature (read on demand)

```json
{
  "version": "2.0",
  "instructions": "Read this file when starting work on a specific feature. Look up by id. Do not load this file at session start.",
  "features": [
    {
      "id": "{{category}}-001",
      "steps": [
        "{{step 1 — what a human would do}}",
        "{{step 2}}",
        "{{step 3 — what to verify as success}}"
      ]
    }
  ]
}
```

---

## STEP 8 — Generate `scripts/init.sh` (POSIX)

Write a shell script that:
1. Verifies working directory via root sentinel file (`package.json` / `Cargo.toml` / `go.mod` / etc.)
2. Checks required runtime versions (node/python/go/rust — specific to the project)
3. Warns if `.env` / `.env.local` / equivalent config is missing
4. Installs / fetches dependencies (`pnpm install` / `pip install -r requirements.txt` / `cargo fetch` / `go mod download`)
5. Runs compile or type check
6. Checks if git is available (`git rev-parse --git-dir 2>/dev/null`):
   - If yes: prints last 5 commits (`git log --oneline -5`) and `git status --short`
   - If no: prints `[WARN] No git repository — session tracking is limited`
7. Prints the full `.agents/progress.md` (bounded by rolling window design)
8. Parses `.agents/features.json` using `python3 -c` or `node -e` and prints all
   `"passes": false` features with their priority, sorted by priority ascending

Use ANSI color output. Exit code 1 on fatal errors, 0 on success.

---

## STEP 9 — Generate `scripts/init.ps1` (PowerShell)

Write the PowerShell equivalent with identical behavior:
- `Write-Host` with `-ForegroundColor` for colors
- `ConvertFrom-Json` to parse `.agents/features.json` natively (access `.features` array)
- `Get-Content .agents/progress.md` to print progress (whole file — it's bounded)
- `Test-Path` instead of `[ -f ]`
- `git rev-parse --git-dir` with `$LASTEXITCODE` check for git detection
- Print incomplete features as `[p{{priority}}] {{id}}: {{description}}`

---

## STEP 10 — Generate `.claude/settings.json`

Permissions grouped by risk class. `git commit` is included as it is a core
workflow step; `git push` is intentionally excluded and requires explicit user action.

```json
{
  "permissions": {
    "allow": [
      "Bash({{PACKAGE_MANAGER_CMD}} install*)",
      "Bash({{PACKAGE_MANAGER_CMD}} run *)",
      "Bash(git log*)",
      "Bash(git status*)",
      "Bash(git diff*)",
      "Bash(git branch*)",
      "Bash(git add *)",
      "Bash(git commit *)",
      "Bash(cat .agents/*)",
      "Bash(cat CLAUDE.md)",
      "Bash(cat AGENTS.md)",
      "Bash(bash scripts/init.sh)",
      "Bash(powershell scripts/init.ps1)"
    ]
  },
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "echo \"\n========================================\nSESSION END CHECKLIST:\n  1. {{TYPECHECK_CMD}}\n  2. {{LINT_CMD}}\n  3. git add <files> && git commit -m 'type(scope): description'\n  4. .agents/progress.md  →  condense current session to ≤7 lines\n  5. .agents/features.json  →  set passes:true only if e2e verified\n========================================\""
          }
        ]
      }
    ]
  }
}
```

Replace `{{PACKAGE_MANAGER_CMD}}` with `pnpm` / `npm` / `pip` / `cargo` / `go` / `composer` as detected.

If git is unavailable (DEGRADED MODE): remove all `Bash(git *)` entries from the allow list.

---

## STEP 11 — Final report

After all files are created, output:

```
╔══════════════════════════════════════════════════╗
║       init-harness v1.3.0 — Setup Complete       ║
╠══════════════════════════════════════════════════╣
║  Project : {{PROJECT_NAME}}                      ║
║  Stack   : {{LANGUAGE}} / {{FRAMEWORK}}          ║
║  Git     : {{available | DEGRADED — no repo}}    ║
╠══════════════════════════════════════════════════╣
║  Root (platform-required):                       ║
║  ✓ CLAUDE.md              — Claude Code (~50 ln) ║
║  ✓ AGENTS.md              — OpenAI Codex         ║
║  ✓ .cursorrules           — Cursor (~45 ln)      ║
║  Agent context (.agents/):                       ║
║  ✓ harness.json           — version metadata     ║
║  ✓ refs/stack.md          — stack & structure    ║
║  ✓ refs/patterns.md       — architecture         ║
║  ✓ refs/rules.md          — coding rules         ║
║  ✓ refs/failures.md       — failure modes        ║
║  ✓ progress.md            — session state        ║
║  ✓ features.json          — {{N}} features ({{P}} passing, {{F}} to verify)
║  ✓ features-detail.json   — steps (read on demand)
║  Bootstrap:                                      ║
║  ✓ scripts/init.sh        — POSIX                ║
║  ✓ scripts/init.ps1       — Windows              ║
║  ✓ .claude/settings.json  — permissions + hook   ║
╠══════════════════════════════════════════════════╣
║  Next steps:                                     ║
║  1. bash scripts/init.sh         (Linux/Mac)     ║
║     powershell scripts/init.ps1  (Windows)       ║
║  2. Review .agents/features.json                 ║
║  3. git add . && git commit -m "chore: init AI agent harness"
╚══════════════════════════════════════════════════╝
```

---

## IMPORTANT CONSTRAINTS

- **Never fabricate** tech stack, features, or commands — derive everything from Step 0
- **Never use generic filler** — be specific to the actual project
- **If you cannot determine** a value, write `# TODO: fill in` rather than guessing
- **If harness files already exist**, report them and ask before overwriting
- **CLAUDE.md must stay ≤55 lines** — move any detail that exceeds this to `.agents/refs/`
- **features-detail.json is never loaded at session start** — the agent reads it only when starting a specific feature
- **The harness is for THIS project only** — never reference other projects
- **Harness assumptions expire** — as models improve, some scaffolding becomes unnecessary overhead; prefer removing complexity over keeping it
