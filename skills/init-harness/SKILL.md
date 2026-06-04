---
name: init-harness
description: Initialize the AI agent harness for any project. Generates CLAUDE.md, AGENTS.md, .cursorrules, agent-features.json, agent-progress.md, scripts/init.sh, scripts/init.ps1, and .claude/settings.json — all tailored to the current codebase. Use when starting work on a new project or when the project lacks AI agent context files.
version: "1.0.0"
---

Initialize the AI Agent Harness for the current project, based on Anthropic's
"Effective Harnesses for Long-Running Agents" best practices.

Creates a complete cross-platform harness that works identically on
**Claude Code**, **Cursor**, and **OpenAI Codex** without any reconfiguration.

---

## STEP 0 — Pre-flight analysis (run ALL in parallel, collect results before creating any file)

1. `pwd` — confirm working directory
2. `git log --oneline -10` — understand recent history and naming conventions
3. `git status` — see what is staged, modified, and untracked
4. `git branch --show-current` — current branch name
5. Read the root manifest: `package.json` / `Cargo.toml` / `pyproject.toml` / `go.mod` / `composer.json` / `build.gradle` — detect language and package manager
6. List top-level directories, excluding: `.git`, `node_modules`, `__pycache__`, `vendor`, `dist`, `.next`, `target`, `.turbo`, `coverage`
7. Check if any harness files already exist: `CLAUDE.md`, `AGENTS.md`, `.cursorrules`, `agent-progress.md`, `agent-features.json`, `.claude/settings.json`
   — If ANY exist: stop, report what was found, and ask the user whether to overwrite or skip each one before continuing
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

---

## STEP 1 — Create required directories

```bash
mkdir -p scripts
mkdir -p .claude
```

---

## STEP 2 — Generate `CLAUDE.md`

Write a `CLAUDE.md` tailored to THIS project. Replace every `{{placeholder}}` with
real values from the Step 0 analysis. Every section must reflect the actual project —
no generic filler. Write `# TODO: fill in` for any value that cannot be determined.

```markdown
# {{PROJECT_NAME}} — AI Agent Harness

> **Platform coverage:** Auto-loaded by **Claude Code**.
> Identical content in `AGENTS.md` (OpenAI Codex) and `.cursorrules` (Cursor).
> Keep all three in sync when updating.

---

## 1. Session Startup Protocol (MANDATORY — every session)

```bash
# 1. Confirm location
pwd   # must end with: {{REPO_FOLDER_NAME}}

# 2. Read recent context
cat agent-progress.md

# 3. Repo state
git log --oneline -5
git status

# 4. Bootstrap environment
bash scripts/init.sh          # Linux / macOS
powershell scripts/init.ps1   # Windows

# 5. Pick next feature
cat agent-features.json
# Choose the highest-priority entry where "passes": false
```

---

## 2. Project Overview

{{PROJECT_DESCRIPTION}}

---

## 3. Tech Stack

| Layer | Choice | Version |
|-------|--------|---------|
{{TECH_STACK_ROWS}}

---

## 4. Repository Structure

```
{{ANNOTATED_DIRECTORY_TREE}}
```

---

## 5. Development Commands

```bash
{{DEV_COMMANDS}}
```

---

## 6. Key Architectural Patterns

{{PATTERNS}}

---

## 7. Coding Rules

{{RULES}}

Always include:
1. Small atomic commits — one logical change per commit
2. Never mark a feature `"passes": true` without end-to-end verification
3. Never remove entries from `agent-features.json` — only update `"passes"` status

---

## 8. Environment Setup

{{ENV_TABLE}}

---

## 9. End of Session Protocol (MANDATORY — before stopping)

```bash
{{TYPECHECK_CMD}}
{{LINT_CMD}}
{{TEST_CMD}}
git add <specific files>
git commit -m "type(scope): description"
# Then update agent-progress.md and agent-features.json
```

---

## 10. Commit Convention

```
feat(scope):     new capability
fix(scope):      bug correction
refactor(scope): no behavior change
chore(scope):    deps, config, tooling
docs(scope):     documentation only
test(scope):     tests only
```

---

## 11. Common Failure Modes

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
{{FAILURE_TABLE_ROWS}}
```

---

## STEP 3 — Generate `AGENTS.md`

Copy `CLAUDE.md` verbatim. Change only the platform note in the header to:

```
> **Platform coverage:** Auto-loaded by **OpenAI Codex**.
> Identical content in `CLAUDE.md` (Claude Code) and `.cursorrules` (Cursor).
```

---

## STEP 4 — Generate `.cursorrules`

Write a condensed version (maximum 60 lines). Must include:

1. **Session Start** — 3–4 steps as a numbered list
2. **Session End** — 5 steps as a numbered list
3. **Hard Rules** — all non-negotiable constraints, one line each
4. **Stack** — one-line summary
5. **Key Commands** — dev, typecheck, lint, test with actual command text
6. Final line: `## See CLAUDE.md for full documentation`

---

## STEP 5 — Generate `agent-progress.md`

```markdown
# Agent Progress Log

> Update this file at the END of every session. Newest entry at the top.

---

## Session: {{TODAY_DATE}} — Harness Initialized

### Completed
- Initialized AI agent harness (CLAUDE.md, AGENTS.md, .cursorrules,
  agent-features.json, agent-progress.md, scripts/init.*, .claude/settings.json)

### In Progress
{{UNCOMMITTED_FILES_LIST}}

### Next
- Verify harness: bash scripts/init.sh (Linux/Mac) or powershell scripts/init.ps1 (Windows)
- Pick first incomplete feature from agent-features.json and work on it

### Blockers
- None known

### Key Decisions
{{KEY_DECISIONS_FROM_GIT_AND_README}}
```

---

## STEP 6 — Generate `agent-features.json`

Infer features from the codebase. Scan:
- Route / page / controller files
- README features section or changelog
- Navigation components / sidebar / menu files
- Existing test files
- Recent commit messages

Aim for **15–30 features** covering all major user-facing flows.
Use realistic `"passes"` values: `true` for clearly shipped functionality,
`false` for anything uncertain, in-progress, or untested.

```json
{
  "version": "1.0",
  "instructions": "NEVER remove or rename entries. ONLY set 'passes' to true after end-to-end verification. Pick the highest-priority 'passes: false' entry each session. Priority: 1=critical, 2=high, 3=medium, 4=low.",
  "features": [
    {
      "id": "{{category}}-001",
      "category": "{{category}}",
      "priority": {{1-4}},
      "description": "{{one sentence, subject-verb-object, testable in a real browser or terminal}}",
      "steps": [
        "{{step 1 — what a human would do}}",
        "{{step 2}}",
        "{{step 3 — what to verify as success}}"
      ],
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

---

## STEP 7 — Generate `scripts/init.sh` (POSIX)

Write a shell script that:
1. Verifies working directory via root sentinel file (`package.json` / `Cargo.toml` / `go.mod` / etc.)
2. Checks required runtime versions (node/python/go/rust — specific to the project)
3. Warns if `.env.local` / `.env` / equivalent config is missing
4. Installs / fetches dependencies (`pnpm install` / `pip install -r requirements.txt` / `cargo fetch` / `go mod download`)
5. Runs compile or type check
6. Prints last 5 git commits and `git status --short`
7. Prints last 20 lines of `agent-progress.md`
8. Parses `agent-features.json` using `python3 -c` or `node -e` and prints all `"passes": false` features with their priority

Use ANSI color output. Exit code 1 on fatal errors, 0 on success.

---

## STEP 8 — Generate `scripts/init.ps1` (PowerShell)

Write the PowerShell equivalent with identical behavior:
- `Write-Host` with `-ForegroundColor` for colors
- `ConvertFrom-Json` to parse agent-features.json natively
- `Get-Content ... | Select-Object -Last 20` instead of `tail`
- `Test-Path` instead of `[ -f ]`
- Print incomplete features as `[p{{priority}}] {{id}}: {{description}}`

---

## STEP 9 — Generate `.claude/settings.json`

```json
{
  "permissions": {
    "allow": [
      "Bash({{PACKAGE_MANAGER_CMD}} *)",
      "Bash(git log*)",
      "Bash(git status*)",
      "Bash(git diff*)",
      "Bash(git branch*)",
      "Bash(git add *)",
      "Bash(git commit *)",
      "Bash(cat agent-progress.md)",
      "Bash(cat agent-features.json)",
      "Bash(cat CLAUDE.md)",
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
            "command": "echo \"\n========================================\nSESSION END CHECKLIST:\n  1. {{TYPECHECK_CMD}}\n  2. {{LINT_CMD}}\n  3. git add <files> && git commit -m '...'\n  4. Update agent-progress.md\n  5. Update agent-features.json (passes: true if verified)\n========================================\""
          }
        ]
      }
    ]
  }
}
```

Replace `{{PACKAGE_MANAGER_CMD}}` with `pnpm` / `npm` / `pip` / `cargo` / `go` / `composer` as detected.

---

## STEP 10 — Final report

After all files are created, output:

```
╔══════════════════════════════════════════════════╗
║           init-harness — Setup Complete          ║
╠══════════════════════════════════════════════════╣
║  Project : {{PROJECT_NAME}}                      ║
║  Stack   : {{LANGUAGE}} / {{FRAMEWORK}}          ║
╠══════════════════════════════════════════════════╣
║  Files created:                                  ║
║  ✓ CLAUDE.md            — Claude Code            ║
║  ✓ AGENTS.md            — OpenAI Codex           ║
║  ✓ .cursorrules         — Cursor                 ║
║  ✓ agent-progress.md    — session state          ║
║  ✓ agent-features.json  — {{N}} features ({{P}} passing, {{F}} to verify)
║  ✓ scripts/init.sh      — POSIX bootstrap        ║
║  ✓ scripts/init.ps1     — Windows bootstrap      ║
║  ✓ .claude/settings.json — permissions + hook    ║
╚══════════════════════════════════════════════════╝
```

---

## IMPORTANT CONSTRAINTS

- **Never fabricate** tech stack, features, or commands — derive everything from Step 0
- **Never use generic filler** — be specific to the actual project
- **If you cannot determine** a value, write `# TODO: fill in` rather than guessing
- **If harness files already exist**, report them and ask before overwriting
- **All files go in the current working directory** (project root), except `.claude/settings.json`
- **The harness is for THIS project only** — never reference other projects
