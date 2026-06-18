---
name: init-harness
description: Initialize the AI agent harness for any project. Generates AGENTS.md (canonical), CLAUDE.md that imports it, scoped .cursor/rules/*.mdc, a .agents/ context directory with on-demand refs, enforcement hooks, and bootstrap scripts — all tailored to the current codebase. Use when starting work on a new project or when the project lacks AI agent context files.
version: "2.1.0"
disable-model-invocation: true
---

Initialize the AI Agent Harness for the current project.

`init-harness` is a **one-shot generator** (run once per project) that installs a
**recurring session workflow** (runs every session). The two are different things —
do not confuse the generator with the harness it produces.

Optional argument via `$ARGUMENTS`: custom project name override.

Design philosophy:

- **Less prose, more enforcement.** Rules in markdown are followed ~80% of the time;
  hard constraints go in **hooks**, not documentation.
- **One source of truth.** `AGENTS.md` is canonical; `CLAUDE.md` imports it. Never
  copy identical content into multiple files.
- **Pilot's checklist, not a style guide.** Keep generated docs lean (~60 lines).
  Every line must trace to a real fact about the project — no speculation.
- **Just-in-time context.** Root files stay lean; detail lives in `.agents/refs/`
  and is loaded on demand, not dumped every session.
- **Handoffs carry decisions, not just summaries.**

Works across **Claude Code**, **Cursor**, and **OpenAI Codex**.

---

## STEP 0 — Pre-flight gate (run ALL checks, then branch on results before creating ANY file)

```bash
pwd
git rev-parse --is-inside-work-tree 2>/dev/null
git rev-parse HEAD 2>/dev/null
```

Resolve each gate before proceeding:

**Gate A — Version control**
- `git rev-parse --is-inside-work-tree` fails → **no git repo.** Ask:
  *"This project has no git repo. The harness session protocol relies on git. Initialize one now?"*
  If yes: run `git init`, optionally `git remote add origin <URL>`.
  If no: skip all git-dependent steps; note limitation in generated files (DEGRADED MODE).
- Repo exists but `git rev-parse HEAD` fails → **no commits yet.** Skip `git log`; continue normally.
- Both succeed → run `git log --oneline -10`, `git status`, `git branch --show-current`.

**Gate B — Project type (greenfield vs brownfield)**
- Look for a manifest: `package.json` / `Cargo.toml` / `pyproject.toml` / `go.mod` /
  `composer.json` / `build.gradle`.
- **No manifest + essentially empty repo** → **greenfield mode.** Ask the user for the
  intended stack (language, framework, package manager) instead of emitting `# TODO`.
  Generate a minimal seed harness from their answer.
- **Manifest found** → **brownfield mode** (happy path). Continue analysis below.

**Gate C — Existing harness detection**
Check for `.agents/harness.json` first; then fall back to root-level agent files.

- **`.agents/harness.json` found** and `generator === "init-harness"`:
  - `version === "2.1.0"` (current) → inform user, ask if they want to regenerate.
  - `version < "2.1.0"` → show upgrade summary (see UPGRADE MODE below); offer upgrade.
  - `version > "2.1.0"` → warn, ask before proceeding.
- **`.agents/harness.json` not found**, but `.agents/progress.md` or `.agents/features.json`
  exist → this is **v1.3.0**. Offer upgrade (see UPGRADE MODE).
- **No `.agents/`**, but root-level `agent-progress.md` or `agent-features.json` exist
  → this is **v1.2.0 or v2.0.0**. Offer upgrade (see UPGRADE MODE).
- **AGENTS.md, CLAUDE.md, or `.claude/settings.json` exist without a generator stamp**
  → human-authored. Do **not** clobber. Back up to `*.bak` and ask before overwriting.
- **Nothing found** → fresh install, proceed.

**UPGRADE MODE:**
Before generating new files, migrate existing data:
- **From v1.2.0** (root-level files): read `agent-progress.md` → wrap as "Last Session"
  in new `.agents/progress.md`; split `agent-features.json` → `.agents/features.json`
  (strip `steps`) + `.agents/features-detail.json` (id + steps only); delete old root files.
- **From v1.3.0** (`.agents/` exists): `.agents/progress.md` and `.agents/features.json`
  are already in place; split `features.json` into lean + `features-detail.json` if not
  already split; regenerate CLAUDE.md as `@import` + add `.cursor/rules/`.
- **From v2.0.0** (root-level `agent-progress.md`, `agent-features.json`): move both
  to `.agents/`; add `.agents/refs/` and `features-detail.json`.
- Then regenerate all other files normally.
- Inform user: "Migrated from vX.Y.Z. Changes: [list]."

**Gate D — Monorepo**
- Workspaces found (pnpm-workspace.yaml, `workspaces` field, Nx, Turbo, Lerna) → ask:
  single root harness or per-package? Default: root + a one-line pointer per package.

**Gate E — Team vs solo (commit policy)**
- Remote present → ask: commit `.agents/progress.md` and `.claude/settings.json`
  (shared team state) or gitignore them (personal)?
- Always append `CLAUDE.local.md` to `.gitignore` for personal overrides.

**Brownfield analysis** (after gates — skip parts that are gated out):
- Manifest → language, framework, package manager.
- List top-level dirs excluding: `.git`, `node_modules`, `__pycache__`, `vendor`,
  `dist`, `.next`, `target`, `.turbo`, `coverage`.
- Read first 80 lines of `README.md` if present.
- Read `src/` / `app/` / `lib/` one level deep for domain entities.
- Detect: monorepo?, key scripts (dev/build/test/lint/typecheck/migrate/seed),
  infra (auth, db, ORM, deploy), multi-tenant?, test strategy.

**Package-manager detection chain** (first hit wins):
`CLAUDE_PACKAGE_MANAGER` env → `packageManager` field in package.json →
lockfile (pnpm-lock.yaml / yarn.lock / package-lock.json / bun.lockb) →
first available in PATH.

---

## STEP 1 — Create directories and write harness metadata

```bash
mkdir -p scripts .claude .cursor/rules .agents/refs .agents/archive
```

Write `.agents/harness.json` — used by future runs to detect version and offer upgrades:

```json
{
  "_generatedBy": "init-harness",
  "version": "2.1.0",
  "generated": "{{TODAY_DATE}}",
  "source": "https://github.com/dhinojosac/init-harness"
}
```

---

## STEP 2 — Generate `AGENTS.md` (CANONICAL — single source of truth)

This is the one file that holds the real session protocol. Keep it a **pilot's
checklist, ≈60 lines max**. Every line must trace to a fact from Step 0.
Detail that doesn't fit here goes into `.agents/refs/` (Step 5), not into this file.

```markdown
<!-- generated-by: init-harness v2.1 -->
# {{PROJECT_NAME}} — Agent Harness

> Canonical agent instructions. `CLAUDE.md` imports this file; Cursor reads it
> natively. Edit **here**, not in copies. Detail → `.agents/refs/`.

## Stack
{{ONE_LINE_STACK}}  — e.g. "TypeScript / Next.js 15 / pnpm / Postgres+Prisma"

## Commands
- dev:        {{DEV_CMD}}
- build:      {{BUILD_CMD}}
- test:       {{TEST_CMD}}
- typecheck:  {{TYPECHECK_CMD}}
- lint:       {{LINT_CMD}}

## Session start (just-in-time — do NOT pre-load everything)
1. Read `.agents/progress.md` — it names the context to load and the next task.
2. `git log --oneline -5 && git status`
3. Pick the highest-priority `passes: false` entry in `.agents/features.json`.
4. Load only the files that entry's `done` criterion points to.
   → Stack & structure detail: `.agents/refs/stack.md`
   → Architecture patterns: `.agents/refs/patterns.md`

## Session end
1. Run typecheck + lint + test (hooks enforce this — do not skip).
2. Commit in small atomic units: `type(scope): description`.
3. Update `.agents/progress.md` with **decisions made and why**, not just "what".
4. Set `passes: true` ONLY after meeting the feature's `done` criterion end-to-end.

## Rules (hard — enforced by hooks where marked 🔒)
- 🔒 Never `git push --force` to main; never `rm -rf` outside the workspace.
- Never mark a feature `passes: true` without real, end-to-end verification.
- Never delete or rename entries in `.agents/features.json`.
- {{PROJECT_SPECIFIC_RULE_1_TRACEABLE_TO_A_REAL_FACT}}
- {{PROJECT_SPECIFIC_RULE_2_OR_OMIT}}

## Failure modes
| Symptom | Fix |
|---------|-----|
{{2-4 REAL ROWS derived from README warnings or git history — no invented ones}}
```

---

## STEP 3 — Generate `CLAUDE.md` (imports canonical; adds Claude specifics)

`CLAUDE.md` must NOT duplicate `AGENTS.md`. It uses `@AGENTS.md` to import it
at session start, then adds only Claude Code-specific notes:

```markdown
<!-- generated-by: init-harness v2.1 -->
@AGENTS.md

## Claude Code specifics
- Permissions and enforcement hooks: `.claude/settings.json`
- On-demand detail (read when needed, not at startup):
  - `.agents/refs/stack.md` — stack, structure, env vars
  - `.agents/refs/patterns.md` — architectural patterns
  - `.agents/refs/rules.md` — full coding rules
  - `.agents/refs/failures.md` — common failure modes
- Use plan mode for changes touching {{SENSITIVE_PATH_OR_OMIT_IF_NONE}}.
```

> `@AGENTS.md` is resolved by Claude Code at session start. The refs are listed here
> so the agent knows they exist and can load them on demand — they are not pre-loaded.

---

## STEP 4 — Generate `.cursor/rules/*.mdc` (scoped, not a flat file)

Replace the legacy flat `.cursorrules` with scoped `.mdc` files. Each has frontmatter
that controls exactly when it loads:

`.cursor/rules/00-core.mdc` — always loaded, the non-negotiables:
```markdown
---
alwaysApply: true
---
Source of truth is AGENTS.md. Follow its session start/end protocol exactly.
Hard rules: no force-push to main, no rm -rf outside workspace, never fake passes:true.
Commit atomically. Load .agents/refs/ for detail — do not ask for context already there.
```

`.cursor/rules/10-{{lang}}.mdc` — loads just-in-time on matching files:
```markdown
---
globs: {{e.g. src/**/*.ts,src/**/*.tsx}}
---
{{Language/framework conventions derived from the actual codebase — no invented rules.}}
```

`.cursor/rules/20-testing.mdc` — loads by relevance:
```markdown
---
description: USE WHEN writing or modifying tests
---
{{Test conventions: runner, file location pattern, naming, what must be covered.}}
```

> Only create rule files you have real content for. Do not invent conventions.
> Write a one-line legacy `.cursorrules` pointer only if needed for older Cursor:
> `# Rules moved to .cursor/rules/ — see AGENTS.md`

---

## STEP 5 — Generate `.agents/refs/` (4 detail files — read on demand, not at startup)

These files hold the detail that would otherwise bloat `AGENTS.md`. They are never
pre-loaded — the agent reads them when a task actually requires the information.

### `.agents/refs/stack.md`

```markdown
<!-- generated-by: init-harness v2.1 -->
# {{PROJECT_NAME}} — Stack Reference

## Tech Stack

| Layer | Choice | Version |
|-------|--------|---------|
{{TECH_STACK_ROWS — derive from manifest and lock files}}

## Repository Structure

```
{{ANNOTATED_DIRECTORY_TREE — one-line annotation per top-level dir}}
```

## Environment Variables

| Variable | Purpose | Required |
|----------|---------|---------|
{{ENV_TABLE — derive from .env.example, README, or source code}}
```

### `.agents/refs/patterns.md`

```markdown
<!-- generated-by: init-harness v2.1 -->
# {{PROJECT_NAME}} — Architectural Patterns

{{DATA_FLOW, STATE_MANAGEMENT, API_CONVENTIONS, NAMING_PATTERNS — real, derived}}
```

### `.agents/refs/rules.md`

```markdown
<!-- generated-by: init-harness v2.1 -->
# {{PROJECT_NAME}} — Coding Rules

{{STYLE, IMPORTS, ERROR_HANDLING, TEST_REQUIREMENTS, SECURITY — real, derived}}
```

### `.agents/refs/failures.md`

```markdown
<!-- generated-by: init-harness v2.1 -->
# {{PROJECT_NAME}} — Common Failure Modes

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
{{FAILURE_ROWS — derive from README warnings, known gotchas, git history}}
```

---

## STEP 6 — Generate `.agents/progress.md` (rolling window + decisions)

```markdown
<!-- generated-by: init-harness v2.1 -->
# Agent Progress — Handoff Log

> Newest entry on top. A fresh agent reads ONLY the top entry to resume.
> Record decisions and WHY, not just what changed.
> At session end: condense current entry to ≤7 lines, move old entry to
> `.agents/archive/progress-{{YYYY-MM}}.md`.

---

## {{TODAY_DATE}} — Harness initialized

### State
Harness generated. Repo: {{BRANCH}} @ {{SHORT_SHA_OR_"no commits yet"}}.

### Decisions (and why)
{{KEY_DECISIONS_FROM_GIT_AND_README — or "none yet" for greenfield}}

### Next
- Run `bash scripts/init.sh` (Linux/Mac) or `powershell scripts/init.ps1` (Windows).
- Pick the top `passes: false` feature in `.agents/features.json`.

### Blockers
{{UNCOMMITTED_FILES_OR_"none"}}
```

---

## STEP 7 — Generate `.agents/features.json` and `.agents/features-detail.json`

Two files: lean registry for session startup, full steps on demand.

### `.agents/features.json` — lean registry (no steps at startup)

Derive features from real signals only: routes, controllers, nav components, tests,
README features section, recent commits. In **greenfield mode**, seed 3–5 intended
features from the user's stated goal; prefer a small honest seed over 20 invented ones.

```json
{
  "version": "2.1",
  "_generatedBy": "init-harness",
  "instructions": "Never remove or rename entries. Set 'passes' true ONLY after meeting the 'done' criterion end-to-end — ideally verified by a run separate from the agent that wrote the code. Pick the highest-priority passes:false entry each session. Priority: 1=critical, 2=high, 3=medium, 4=low. Steps are in features-detail.json.",
  "features": [
    {
      "id": "{{category}}-001",
      "category": "{{category}}",
      "priority": 1,
      "description": "{{subject-verb-object, testable in a real browser or terminal}}",
      "done": "{{explicit, testable acceptance criterion — the sprint contract}}",
      "passes": false
    }
  ]
}
```

Rules: group by category (auth, routing, domain-entities, ui, api, jobs…); include an
auth entry if auth exists; include a data-isolation entry if multi-tenant; mark
in-progress items `passes:false`; never invent features.

### `.agents/features-detail.json` — steps per feature (read only when starting that feature)

```json
{
  "version": "2.1",
  "_generatedBy": "init-harness",
  "instructions": "Read this file only when starting work on a specific feature. Look up by id. Do NOT load at session start — it is not needed until you pick a feature.",
  "features": [
    {
      "id": "{{category}}-001",
      "steps": [
        "{{step 1 — what a human tester would do}}",
        "{{step 2}}",
        "{{step 3 — what success looks like}}"
      ]
    }
  ]
}
```

---

## STEP 8 — Generate `scripts/init.sh` (POSIX; silent success, verbose failure)

A bootstrap script that:
1. Verifies the working dir via a root sentinel file (manifest).
2. Checks required runtime versions for the detected stack.
3. Warns if `.env` / `.env.local` is missing.
4. Installs/fetches deps with the detected package manager.
5. Runs typecheck/compile. **On success: one line. On failure: print the error.**
6. Writes full git + context dump to `.harness-context.txt`; prints only a
   2–3 line summary + the file path (do not flood the agent context).
7. Prints `.agents/progress.md` (bounded by rolling window — safe to print whole file).
8. Parses `.agents/features.json` and prints all `passes:false` features sorted by
   priority ascending, formatted as `[p{{priority}}] {{id}}: {{description}}`.
   Use `node -e` or `python3 -c` for JSON parsing.

Use ANSI color output. Exit 1 on fatal errors, 0 on success.

---

## STEP 9 — Generate `scripts/init.ps1` (PowerShell equivalent)

Identical behavior:
- `Write-Host -ForegroundColor` for color output.
- `ConvertFrom-Json` to parse `.agents/features.json` natively.
- `Get-Content .agents/progress.md` to print the handoff.
- `Test-Path` instead of `[ -f ]`.
- `git rev-parse --git-dir` + `$LASTEXITCODE` for git detection.
- Write context dump to `.harness-context.txt`, print summary + path.
- Print incomplete features as `[p{{priority}}] {{id}}: {{description}}`.

---

## STEP 10 — Generate `.claude/settings.json` (enforcement, not just an echo)

Hooks enforce what prose cannot. `deny` blocks destructive commands deterministically.
The `PostToolUse` hook runs typecheck silently after every edit — **only include it
if the project has a fast typecheck command (< ~10 seconds)**; omit it otherwise.

```json
{
  "_generatedBy": "init-harness",
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
    ],
    "deny": [
      "Bash(git push --force*)",
      "Bash(git push -f*)",
      "Bash(rm -rf /*)"
    ]
  },
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "{{TYPECHECK_CMD}} > .harness-verify.log 2>&1 || (echo '⚠ typecheck failed — see .harness-verify.log'; tail -n 20 .harness-verify.log)"
          }
        ]
      }
    ],
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "echo \"\n========================================\nSESSION END:\n  1. {{TYPECHECK_CMD}} && {{LINT_CMD}}\n  2. git add <files> && git commit -m 'type(scope): description'\n  3. .agents/progress.md  → record decisions + why (≤7 lines)\n  4. .agents/features.json → passes:true ONLY if done criterion met e2e\n========================================\""
          }
        ]
      }
    ]
  }
}
```

Notes:
- In DEGRADED MODE (no git): remove all `Bash(git *)` entries from `allow` and `deny`.
- `PostToolUse` is silent on success, verbose on failure — never clutters the context
  unless something breaks.
- If the project has no fast typecheck, omit `PostToolUse` entirely rather than
  running something slow after every file edit.

---

## STEP 11 — Final report

```
╔══════════════════════════════════════════════════╗
║        init-harness v2.1.0 — Setup Complete      ║
╠══════════════════════════════════════════════════╣
║  Project : {{PROJECT_NAME}}                      ║
║  Stack   : {{LANGUAGE}} / {{FRAMEWORK}}          ║
║  Mode    : {{brownfield|greenfield}}             ║
║  Git     : {{available | initialized | DEGRADED}}║
╠══════════════════════════════════════════════════╣
║  Root (platform-required):                       ║
║  ✓ AGENTS.md              — canonical (~60 ln)   ║
║  ✓ CLAUDE.md              — @imports AGENTS.md   ║
║  ✓ .cursor/rules/*.mdc    — scoped JIT rules     ║
║  Agent context (.agents/):                       ║
║  ✓ harness.json           — version metadata     ║
║  ✓ refs/stack.md          — stack & structure    ║
║  ✓ refs/patterns.md       — architecture         ║
║  ✓ refs/rules.md          — coding rules         ║
║  ✓ refs/failures.md       — failure modes        ║
║  ✓ progress.md            — handoff (decisions)  ║
║  ✓ features.json          — {{N}} features ({{P}} passing, {{F}} to verify)
║  ✓ features-detail.json   — steps (read on demand)
║  Bootstrap:                                      ║
║  ✓ scripts/init.sh        — POSIX                ║
║  ✓ scripts/init.ps1       — Windows              ║
║  ✓ .claude/settings.json  — permissions + hooks  ║
╠══════════════════════════════════════════════════╣
║  Next steps:                                     ║
║  1. bash scripts/init.sh  (Linux/Mac)            ║
║     powershell scripts/init.ps1  (Windows)       ║
║  2. Review .agents/features.json                 ║
║  3. git add . && git commit -m "chore: init AI agent harness v2.1"
╚══════════════════════════════════════════════════╝
```

---

## IMPORTANT CONSTRAINTS

- **Never fabricate** stack, features, or commands — derive everything from Step 0.
- **Never duplicate content** — `AGENTS.md` is canonical; `CLAUDE.md` imports it.
- **Never clobber human-authored files** — check for the generator stamp; back up
  unstamped files and ask before overwriting.
- **If a value is unknown**, write `# TODO: fill in` (brownfield) or ask (greenfield).
- **Hooks over prose** for hard constraints — the `deny` list and `PostToolUse`
  enforce what markdown cannot.
- **Root stays lean** — only `AGENTS.md`, `CLAUDE.md`, and `.cursor/rules/` belong
  at the root; all agent state lives in `.agents/`.
- **`features-detail.json` is never loaded at session start** — read it only when
  picking up a specific feature.
- **Harness assumptions expire** — as models improve, some scaffolding becomes
  unnecessary overhead; prefer removing complexity over keeping it.
