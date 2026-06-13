---
name: init-harness
description: Initialize the AI agent harness for any project. Generates a canonical AGENTS.md (single source of truth), CLAUDE.md (imports it), .cursor/rules/*.mdc, agent-features.json, agent-progress.md handoff, scripts/init.sh + init.ps1, and .claude/settings.json with enforcement hooks — all tailored to the current codebase. Use when starting work on a new project or when the project lacks AI agent context files.
version: "2.0.0"
disable-model-invocation: true
---

Initialize the AI Agent Harness for the current project.

`init-harness` is a **one-shot generator** (run once per project) that installs a
**recurring session workflow** (runs every session). The two are different things —
do not confuse the generator with the harness it produces.

Design philosophy (from current harness research — see `docs/HARNESS-RESEARCH.md`):

- **Less prose, more enforcement.** Rules in markdown are followed ~80% of the time;
  hard constraints go in **hooks**, not documentation.
- **One source of truth.** `AGENTS.md` is canonical; `CLAUDE.md` imports it. Never
  copy identical content into multiple files.
- **Pilot's checklist, not a style guide.** Keep generated docs lean (~60 lines).
  Every line should be traceable to a real fact about the project, not speculation.
- **Just-in-time context.** Hand the agent lightweight identifiers and let it load
  detail on demand — do not pre-dump everything every session.
- **Handoffs carry decisions, not just summaries.**

Works across **Claude Code**, **Cursor**, and **OpenAI Codex**.

---

## STEP 0 — Pre-flight gate (run, then branch on the results before creating ANY file)

Run these and decide the path. Do **not** assume the happy path.

```bash
pwd
git rev-parse --is-inside-work-tree 2>/dev/null   # is this a git repo at all?
git rev-parse HEAD 2>/dev/null                     # are there any commits?
```

Then resolve each gate:

**Gate A — Version control**
- If `git rev-parse --is-inside-work-tree` fails → **not a git repo.** Stop and ask:
  *"This project isn't under git. The harness session protocol relies on git. Run
  `git init` now?"* If yes, run it. If the user declines, proceed but skip every
  git-dependent step and note the limitation in the generated files.
- If it is a repo but `git rev-parse HEAD` fails → **no commits yet.** Skip history
  analysis (`git log`); seed everything else normally.
- If both succeed → run `git log --oneline -10`, `git status`, `git branch --show-current`.

**Gate B — Project type (greenfield vs brownfield)**
- Look for a manifest: `package.json` / `Cargo.toml` / `pyproject.toml` / `go.mod` /
  `composer.json` / `build.gradle`.
- If **none found and the repo is essentially empty** → **greenfield mode.** Ask the
  user for the intended stack (language, framework, package manager) instead of
  emitting `# TODO` everywhere. Generate a minimal seed harness.
- If a manifest exists → **brownfield mode** (happy path). Continue analysis below.

**Gate C — Existing harness files**
Check for: `AGENTS.md`, `CLAUDE.md`, `.cursorrules`, `.cursor/rules/`,
`agent-progress.md`, `agent-features.json`, `.claude/settings.json`.
- For each that exists, look for the stamp `<!-- generated-by: init-harness vX -->`
  (or `"_generatedBy": "init-harness"` in JSON).
  - **Stamped (we generated it)** → safe to regenerate; offer a section-level upgrade.
  - **Unstamped (human-authored)** → do **not** clobber. Back it up to `*.bak` and
    ask before overwriting. This is especially important for hand-written `AGENTS.md`.

**Gate D — Monorepo**
- If the manifest declares workspaces (pnpm-workspace.yaml, `workspaces` field, Nx,
  Turbo, Lerna) → ask: place a single root harness, or per-package `AGENTS.md`?
  Default to root + a short per-package pointer.

**Gate E — Team vs solo (commit policy)**
- Ask (or infer from a remote being present): should `agent-progress.md` and
  `.claude/settings.json` be committed (shared team state) or gitignored (personal)?
- Always generate/append `CLAUDE.local.md` to `.gitignore` for personal overrides.

Then do the brownfield analysis (skip parts gated out above):
- Read the manifest → language, framework, package manager.
- List top-level dirs, excluding: `.git`, `node_modules`, `__pycache__`, `vendor`,
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

## STEP 1 — Create directories

```bash
mkdir -p scripts .claude .cursor/rules
```

---

## STEP 2 — Generate `AGENTS.md` (CANONICAL — single source of truth)

This is the one file that holds the real content. Keep it a **pilot's checklist,
≈60 lines max**. Every line must trace to a fact from Step 0 — no generic filler.
Detail that doesn't fit goes into `.cursor/rules/*.mdc` (Step 4), not here.

```markdown
<!-- generated-by: init-harness v2 -->
# {{PROJECT_NAME}} — Agent Harness

> Canonical agent instructions. `CLAUDE.md` imports this file; Cursor reads it
> natively. Edit **here**, not in copies.

## Stack
{{ONE_LINE_STACK}}  — e.g. "TypeScript / Next.js 15 / pnpm / Postgres+Prisma"

## Commands
- dev:        {{DEV_CMD}}
- build:      {{BUILD_CMD}}
- test:       {{TEST_CMD}}
- typecheck:  {{TYPECHECK_CMD}}
- lint:       {{LINT_CMD}}

## Session start (just-in-time — do NOT cat everything)
1. Read `agent-progress.md` (the handoff) — it names what to load next.
2. `git log --oneline -5 && git status`
3. Pick the highest-priority `passes: false` entry in `agent-features.json`.
4. Load only the files that entry points to.

## Session end
1. Run typecheck + lint + test (the hooks enforce this; don't skip).
2. Commit in small atomic units: `type(scope): description`.
3. Update `agent-progress.md` with **decisions made and why**, not just "what".
4. Set `passes: true` ONLY after end-to-end verification (see Rules).

## Rules (hard — enforced by hooks where marked 🔒)
- 🔒 Never `git push --force` to main; never `rm -rf` outside the workspace.
- Never mark a feature `passes: true` without real verification.
- Never delete or rename entries in `agent-features.json`.
- {{PROJECT_SPECIFIC_RULE_TRACEABLE_TO_A_FACT}}

## Failure modes
{{2-4 ROWS: symptom → fix, only ones real to THIS project}}
```

> Keep it tight. If a section would exceed the budget, move it to `.cursor/rules/`.

---

## STEP 3 — Generate `CLAUDE.md` (imports the canonical file)

`CLAUDE.md` must NOT duplicate `AGENTS.md`. It imports it and adds only
Claude-specific notes:

```markdown
<!-- generated-by: init-harness v2 -->
@AGENTS.md

## Claude Code specifics
- Permissions & enforcement hooks live in `.claude/settings.json`.
- Use plan mode for changes touching {{SENSITIVE_PATH_OR_NONE}}.
- {{ANY_CLAUDE_ONLY_NOTE_OR_OMIT}}
```

> The `@AGENTS.md` import is loaded by Claude Code at session start. This is why we
> do not keep three synchronized copies anymore.

---

## STEP 4 — Generate `.cursor/rules/*.mdc` (scoped, not a flat file)

Replace the legacy flat `.cursorrules` with scoped rule files. Each `.mdc` has
frontmatter controlling WHEN it loads (just-in-time):

`.cursor/rules/00-core.mdc` — always on, the non-negotiables:
```markdown
---
alwaysApply: true
---
- Source of truth is AGENTS.md. Follow its session start/end protocol.
- Hard rules: no force-push to main, no rm -rf outside workspace.
- Commit in small atomic units; never fake `passes: true`.
```

`.cursor/rules/10-{{lang}}.mdc` — loads only on matching files:
```markdown
---
globs: {{e.g. src/**/*.ts,src/**/*.tsx}}
---
{{language/framework conventions traceable to the codebase}}
```

`.cursor/rules/20-testing.mdc` — loads by relevance:
```markdown
---
description: USE WHEN writing or modifying tests
---
{{test conventions: runner, location, patterns to follow}}
```

> Only create rule files you have real content for. Do not invent conventions.
> A legacy flat `.cursorrules` with `## See AGENTS.md` may be written as a one-line
> pointer for older Cursor versions, nothing more.

---

## STEP 5 — Generate `agent-progress.md` (handoff with decisions, not a summary)

```markdown
<!-- generated-by: init-harness v2 -->
# Agent Progress — Handoff Log

> Newest entry on top. A fresh agent reads ONLY the top entry to resume.
> Record decisions and WHY, not just what changed (the trace, per Cognition).

---

## {{TODAY_DATE}} — Harness initialized

### State
- Harness generated. Repo: {{BRANCH}} @ {{SHORT_SHA_OR_"no commits yet"}}.

### Decisions (and why)
{{KEY_DECISIONS_FROM_GIT_AND_README — or "none yet" in greenfield}}

### Next (actionable, with the files to load)
- Verify harness: `bash scripts/init.sh` (or `powershell scripts/init.ps1`).
- Pick the top `passes: false` feature in `agent-features.json` and load the files
  it names.

### Blockers
- {{UNCOMMITTED_FILES_OR_"none"}}
```

---

## STEP 6 — Generate `agent-features.json` (seed minimal; verifiable done-criteria)

Derive features from real signals only (routes, controllers, nav, tests, README,
commits). In **greenfield mode**, seed 3–5 intended features from the user's stated
goal instead of inventing 20. Prefer a small, honest seed that the team ratchets
upward over a speculative wall of features.

```json
{
  "version": "2.0",
  "_generatedBy": "init-harness",
  "instructions": "Never remove or rename entries. Set 'passes' true ONLY after meeting 'done' end-to-end. A separate verification pass (not the agent that wrote the code) should confirm it. Pick the highest-priority passes:false entry each session. Priority 1=critical..4=low.",
  "features": [
    {
      "id": "{{category}}-001",
      "category": "{{category}}",
      "priority": 1,
      "description": "{{subject-verb-object, testable in a real browser/terminal}}",
      "steps": ["{{human step 1}}", "{{step 2}}", "{{verify success}}"],
      "done": "{{explicit, testable acceptance criterion — the 'sprint contract'}}",
      "passes": false
    }
  ]
}
```

Rules: group by category (auth, routing, domain entities, ui, api, jobs…); include
an auth entry if auth exists and a data-isolation entry if multi-tenant; mark
in-progress items `passes:false`; never invent features.

---

## STEP 7 — Generate `scripts/init.sh` (POSIX; offload large output)

A bootstrap script that:
1. Verifies the working dir via a root sentinel (manifest file).
2. Checks required runtime versions for the detected stack.
3. Warns if `.env` / `.env.local` is missing.
4. Installs/fetches deps with the detected package manager.
5. Runs typecheck/compile. **On success, print one line; on failure, print the
   error.** (Silent success, verbose failure.)
6. Writes the full git/context dump to `.harness-context.txt` and prints only a
   2–3 line summary + the path (tool-call offloading — don't flood context).
7. Prints the top `passes:false` features (parse JSON via `node -e`/`python3 -c`).

ANSI color; exit 1 on fatal errors, 0 otherwise.

---

## STEP 8 — Generate `scripts/init.ps1` (PowerShell equivalent)

Identical behavior: `Write-Host -ForegroundColor`, `ConvertFrom-Json`,
`Get-Content -Tail`, `Test-Path`, silent-success/verbose-failure, offload full dump
to `.harness-context.txt`, print incomplete features as `[p{{priority}}] {{id}}: {{desc}}`.

---

## STEP 9 — Generate `.claude/settings.json` (ENFORCEMENT, not just an echo)

Hooks enforce what prose cannot. Adapt the typecheck/lint commands to the stack.

```json
{
  "_generatedBy": "init-harness",
  "permissions": {
    "allow": [
      "Read(//**)",
      "Bash({{PACKAGE_MANAGER_CMD}} *)",
      "Bash(git log*)", "Bash(git status*)", "Bash(git diff*)",
      "Bash(git branch*)", "Bash(git add *)", "Bash(git commit *)"
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
            "command": "echo 'Session end: typecheck+lint+test, commit atomically, update agent-progress.md with DECISIONS, set passes:true only if verified.'"
          }
        ]
      }
    ]
  }
}
```

Notes:
- `deny` blocks the destructive commands deterministically (the 🔒 rules in AGENTS.md).
- The `PostToolUse` hook is **silent on success, verbose on failure** — it only
  speaks when typecheck breaks. Adjust the matcher/command to the stack; if a fast
  typecheck isn't available, omit the PostToolUse hook rather than running something slow.
- On Windows, Claude Code runs hook commands via the configured shell; keep commands
  POSIX-ish or provide a `.ps1` wrapper if the project is Windows-only.

---

## STEP 10 — Final report

```
╔══════════════════════════════════════════════════╗
║           init-harness v2 — Setup Complete       ║
╠══════════════════════════════════════════════════╣
║  Project : {{PROJECT_NAME}}                      ║
║  Stack   : {{LANGUAGE}} / {{FRAMEWORK}}          ║
║  Mode    : {{brownfield|greenfield}}  Git: {{ok|initialized|none}}
╠══════════════════════════════════════════════════╣
║  ✓ AGENTS.md            — canonical (single source)
║  ✓ CLAUDE.md            — @imports AGENTS.md
║  ✓ .cursor/rules/*.mdc  — scoped rules
║  ✓ agent-progress.md    — handoff (decisions)
║  ✓ agent-features.json  — {{N}} features ({{P}} pass, {{F}} to verify)
║  ✓ scripts/init.sh|ps1  — bootstrap
║  ✓ .claude/settings.json — permissions + enforcement hooks
╚══════════════════════════════════════════════════╝
Next: run scripts/init.* , review agent-features.json, then commit.
```

---

## IMPORTANT CONSTRAINTS

- **Never fabricate** stack/features/commands — derive everything from Step 0.
- **Never duplicate content** across files — `AGENTS.md` is canonical, others import/point.
- **Never clobber human-authored files** — back up unstamped files and ask.
- **If a value is unknown**, write `# TODO: fill in` (brownfield) or ask (greenfield).
- **Hooks over prose** for hard constraints.
- All files go in the project root, except `.claude/settings.json` and `.cursor/rules/`.
