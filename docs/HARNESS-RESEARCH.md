# init-harness — Research & Design Notes

> Consolidated findings from a review of the most current literature on agent
> harnesses (vendor blogs, the most-starred GitHub repos, and community
> discussion on Reddit / HN / Medium / Substack), plus a lifecycle/edge-case
> analysis of the current `init-harness` tool.
>
> **Date:** 2026-06-13 · **Reviewed version:** v1.2.0 · **Status:** input for v2.0 refactor

---

## TL;DR — the one idea behind everything

Every source, from Anthropic's engineering team down to anonymous Reddit threads,
converges on the same shift:

> **What the model does not do well is not fixed with *more prose* — it is fixed
> with *less prose* + *deterministic enforcement* (hooks) + *just-in-time* context.**

`init-harness` v1.2.0 is built on the opposite, older assumption: *"the agent knows
nothing, so document everything up front."* The v2 refactor moves the tool from
**"exhaustive documentation generator"** to **"installer of a minimal, self-improving
harness ratchet."**

---

## 1. The canon (vendor & primary sources)

| Source | Core idea | Implication for init-harness |
|--------|-----------|------------------------------|
| [Anthropic — Effective context engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) | "Smallest set of high-signal tokens." Load **just-in-time** (paths/IDs, not dumping everything). Structured note-taking. System prompt at the "right altitude." | Startup protocol `cat`s *everything* every session → that is pre-loading. Move to JIT. |
| [Anthropic — Harness design for long-running apps](https://www.anthropic.com/engineering/harness-design-long-running-apps) | Separate generation from evaluation; context resets with structured handoff; **stress-test the scaffolding** (remove components as models improve). | Self-grading `passes: true` is the documented anti-pattern. Add a sequential evaluator. |
| [Anthropic — Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) | Initializer agent (run once) + coding agent (every session) leaving artifacts. | This is the pattern init-harness implements — keep it. |
| [Anthropic — Writing effective tools for agents](https://www.anthropic.com/engineering/writing-tools-for-agents) | Minimal, non-overlapping, token-efficient tools. Paginate/truncate large outputs. | `init.sh` should offload large output to a file, not dump to context. |
| [Cursor — Best practices for coding with agents](https://cursor.com/blog/agent-best-practices) | Harness = instructions + tools + model. **Add rules only after a repeated mistake.** Reference files, don't copy. Verifiable goals (TDD/types/linters). | The MANDATORY 11-section protocol is front-loaded by speculation — anti-pattern. |
| [Cognition — Don't build multi-agents](https://cognition.ai/blog/dont-build-multi-agents) | Single-threaded linear. **Share full traces, not summaries.** Actions carry implicit decisions. | Handoff (`agent-progress.md`) must carry decisions/traces, not just a "what I did" summary. |
| [Geoffrey Huntley — everything is a ralph loop](https://ghuntley.com/loop/) | The loop is the hero, not the model: fresh context + one task per iteration. | The session loop is already a manual Ralph loop — can be formalized with `/loop`. |
| [OpenAI — A practical guide to building agents](https://openai.com/business/guides-and-resources/a-practical-guide-to-building-ai-agents/) | Start single-agent; evolve to multi-agent only when needed. Guardrails validate I/O. | Reinforces single-agent + deterministic guardrails over prose. |

### The multi-agent tension (resolved)

Anthropic recommends **sub-agents** with isolated context returning ~1–2K-token
summaries. Cognition says **don't** build multi-agents and **don't** pass summaries.
These reconcile cleanly:

- Cognition attacks **parallel** sub-agents that can't see each other → conflicting
  implicit decisions. **Avoid.**
- Anthropic recommends **sequential** sub-agents for scoped tasks. **OK.**
- **Verdict for init-harness:** a sequential **evaluator** pass (runs after the
  generator, sees its work) is endorsed by both. Parallel generators are not.

---

## 2. The most-starred GitHub harness repos

> ⚠️ Some "awesome list" star counts (200K+) are inflated/unreliable. The credible
> signal is **ECC ~82K⭐** as the dominant config/harness repo.

### ECC — Everything Claude Code ([repo](https://github.com/affaan-m/everything-claude-code))
Borrowable patterns:
- **One source → idiomatic per-harness artifacts** (not lowest-common-denominator
  copies). Root `AGENTS.md` universal; harness-specific layers in subdirectories.
- **Shared hook logic via adapter**: one `scripts/hooks/*.js`, each harness adapts
  input. No script duplication.
- **SessionStart hook injects prior context** (capped ~8000 chars, toggleable).
- **Language-scoped rules** (`rules/common`, `rules/typescript`, …) — install only
  what you need.
- **Skill-first, command-second** migration; old commands kept as legacy shims.
- **Package-manager detection chain**: env var → config → `packageManager` field →
  lockfile → PATH.
- Install-state tracking for safe uninstall (probably overkill for init-harness).

### wshobson/agents — multi-harness marketplace ([repo](https://github.com/wshobson/agents))
- *"One source-of-truth, five harnesses. Each gets idiomatic, harness-native
  artifacts — not lowest-common-denominator translations."*
- `make generate-all` transforms the single source; `make garden` does drift /
  dead-link / cap detection.
- Registry-as-pointer: marketplace files reference the source, never duplicate.

**Takeaway:** the winning pattern is neither "copy identical to 3 files" (current
init-harness) nor "one flat file for all" — it is **one source + generated idiomatic
per-harness output.** For init-harness's scale, `@import` achieves ~90% of the
benefit with zero build step.

---

## 3. Community signal (Reddit / HN / Medium / Substack)

> Scope note: Twitter/X is login-gated and could not be fetched directly; only
> search snippets were available. One Substack post redirected to a paywall.

- **"Rules get ignored ~20% of the time" — consensus, not anecdote.** Across
  r/ClaudeAI, HN, dev.to: *"no agent will reliably follow any such instructions,
  nor is such behavior enforceable by the orchestrator."* The Cursor agent decides
  if a rule is "relevant" before applying it — `MANDATORY` in markdown is a
  *suggestion*, not enforcement. → **Hard constraints belong in hooks, not prose.**
- **[Addy Osmani — Agent Harness Engineering](https://addyosmani.com/blog/agent-harness-engineering/)** (most complete community piece):
  - *"A decent model with excellent scaffolding outperforms a great model with poor
    infrastructure."*
  - **Keep AGENTS.md under ~60 lines — "a pilot's checklist, not a style guide."**
  - **The Ratchet:** *"Every line in a good AGENTS.md should be traceable back to a
    specific thing that went wrong."* Rules are *earned by failures*, not generated
    by speculation.
  - **Silent success, verbose failure**: pass → no output; fail → inject error and
    loop.
  - Guardrail hooks: block `rm -rf` / `git push --force` / `DROP TABLE`; require
    approval before push to `main`; auto-format on write.
  - *"Harnesses don't shrink, they move"* + trend toward **just-in-time dynamic
    assembly** ("closer to a compiler than static config").
  - **"Skill issue" reframe:** most agent failures are config gaps, not model limits.
- **[Cursor Rules: Why Your AI Agent Is Ignoring You](https://sdrmike.medium.com/cursor-rules-why-your-ai-agent-is-ignoring-you-and-how-to-fix-it-5b4d2ac0b1b0)** — `.mdc` frontmatter mechanics:
  - `alwaysApply: true` → non-negotiable, always in context.
  - `globs: src/**/*.ts` → attaches just-in-time on matching files.
  - `description: "USE WHEN writing tests"` → loads by relevance.
- **Vercel's "doing less" lesson** (via Firecrawl/Faros): started with huge tool
  libraries → agents confused, redundant calls. Stripped to essentials → faster,
  more reliable. *"Constraints outperform instructions."*
- **Trend framing:** *"2025 was Agents. 2026 is Agent Harnesses."* Production
  harnesses have five layers: tool orchestration, verification loops, context/memory,
  guardrails, observability.

---

## 4. Lifecycle & edge-case gaps (current tool)

### Conceptual clarification
There are **two artifacts**, currently conflated in the README:
1. **The generator** (`init-harness`) — runs **once per project** (the skill/command).
2. **The harness it produces** (CLAUDE.md protocol + `init.*` + `features.json` +
   hooks) — runs **every session** (the workflow).

→ README should state plainly: *"init-harness is a one-shot generator that installs
a recurring workflow."*

### Repo-state matrix

| Case | Today | Should |
|------|-------|--------|
| Brownfield (existing project) | ✅ Happy path | Keep |
| Greenfield / empty repo | ⚠️ Manifest/README/src absent → CLAUDE.md full of `# TODO` | Greenfield branch: ask stack, seed minimal |
| **No git initialized** | ❌ **Breaks** — `git log/status/branch` fail | Detect + offer `git init` (highest-priority fix) |
| Git init'd but 0 commits | ❌ `git log` still fails | Skip history analysis if `git rev-parse HEAD` fails |
| Git without remote | ✅ Works (nothing needs a remote) | Add one optional line on where work goes |
| "Tell the agent to add it" | ✅ `/init-harness` or "implement this: \<URL\>" | Fails only offline / no web access |
| Re-run on harnessed project | ⚠️ Overwrite-or-skip per file, **no merge** | Version stamp → section-level upgrade |

### Edge cases not previously surfaced
1. **Clobbering human-authored files** — a hand-written `AGENTS.md`/`.cursorrules`
   is treated as overwritable. Distinguish generated (regenerable) from
   human-authored (back up / ask harder).
2. **Monorepo placement** — Step 0 detects monorepo but Steps 2–9 assume one root.
   Per-package CLAUDE.md? Global vs per-workspace features.json? Undefined.
3. **Commit vs gitignore (team decision, not technical):**
   - `agent-progress.md`: shared team state (commit) or personal log (gitignore)?
   - `.claude/settings.json`: committing it changes permissions for everyone who
     clones (security consideration).
   - Canon suggests a gitignored `CLAUDE.local.md` for personal prefs — not generated.
4. **No version stamp** in generated files → no intelligent upgrade path.
5. **No detectable language** (docs-only, data/notebooks, Terraform) → all TODOs;
   scope question.
6. **Who runs `init.sh`** — human (once) or agent (every session)? Ambiguous; on
   Windows the agent must pick `.ps1`; triggers permission prompts.
7. **Hook/CI conflicts** — the `Stop` hook may collide with existing pre-commit/CI.
8. **Non-git VCS** (hg, jj, svn) — unsupported, no clear message.
9. **No uninstall** — no clean way to remove 8 files + 2 dirs.

### Proposed Step 0 pre-flight gate (decision tree)
```
Step 0 — Pre-flight gate
├─ git init'd?        NO → offer `git init` (or proceed without history)
│                      └─ 0 commits? → skip history analysis
├─ manifest/language? NO → greenfield mode: ask stack
├─ monorepo?         YES → ask: single root or per-package
├─ harness exists?   YES → generated (stamp) → offer section upgrade
│                          human-authored      → back up + ask
└─ team or solo?         → decide commit vs gitignore of progress/settings
```

---

## 5. Prioritized backlog for v2

**Content (what gets generated):**
1. Single-source `@import`: canonical `AGENTS.md` (~50–60 lines) + `CLAUDE.md`
   that imports it. Kills duplication; zero build step.
2. Trim generated docs to the "pilot's checklist" altitude; detail → `.claude/rules/`.
3. Enforcement via **hooks**, not prose: guardrails (block destructive bash, gate
   push to main) + post-edit verify (typecheck/lint), **silent-success/verbose-fail**.
4. `.cursor/rules/*.mdc` with `alwaysApply`/`globs`/`description` instead of a flat
   `.cursorrules`.
5. Just-in-time startup: lightweight identifiers, not `cat`-everything.
6. Handoff carries decisions/traces (Cognition), not just a summary.
7. Sequential evaluator step + verifiable goals; stop self-grading.
8. Package-manager detection chain (ECC).

**Lifecycle (how it installs / what state it handles):**
9. **No-git / no-commits handling** — the only case that *breaks today*. (Do first.)
10. Greenfield mode (ask stack instead of emitting TODOs).
11. Version stamp in generated files → upgrade path.
12. Commit-vs-gitignore decision + generate `CLAUDE.local.md`.
13. Don't clobber human-authored files (generated-vs-authored detection).
14. Monorepo placement; uninstall docs — later.

**Suggested first implementation slice:** #9 (git gate) + #1 (single-source) +
#3 (enforcement hooks) — together they convert the harness from "a document that
gets ignored" into "a ratchet that gets enforced," and all touch `SKILL.md` /
`init-harness.md` / the `settings.json` block.

---

## 6. Sources

**Vendor / primary**
- https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
- https://www.anthropic.com/engineering/harness-design-long-running-apps
- https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents
- https://www.anthropic.com/engineering/writing-tools-for-agents
- https://cursor.com/blog/agent-best-practices
- https://cognition.ai/blog/dont-build-multi-agents
- https://ghuntley.com/loop/
- https://openai.com/business/guides-and-resources/a-practical-guide-to-building-ai-agents/

**Repos**
- https://github.com/affaan-m/everything-claude-code (ECC ~82K⭐)
- https://github.com/wshobson/agents
- https://github.com/rohitg00/awesome-claude-code-toolkit
- https://github.com/anthropics/cwc-long-running-agents

**Community / trends**
- https://addyosmani.com/blog/agent-harness-engineering/
- https://addyosmani.com/blog/long-running-agents/
- https://sdrmike.medium.com/cursor-rules-why-your-ai-agent-is-ignoring-you-and-how-to-fix-it-5b4d2ac0b1b0
- https://www.faros.ai/blog/harness-engineering
- https://aakashgupta.medium.com/2025-was-agents-2026-is-agent-harnesses-heres-why-that-changes-everything-073e9877655e
- https://www.langchain.com/blog/the-anatomy-of-an-agent-harness
- https://resources.anthropic.com/hubfs/2026%20Agentic%20Coding%20Trends%20Report.pdf
- https://www.firecrawl.dev/blog/best-ai-coding-agents
