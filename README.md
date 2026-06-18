# init-harness

**Version:** 2.1.0 &nbsp;|&nbsp; **License:** MIT &nbsp;|&nbsp; **Platforms:** Claude Code · Cursor · OpenAI Codex

> A single command that bootstraps an AI agent harness for any project —
> works identically on Claude Code, Cursor, and OpenAI Codex.

[English](#english) &nbsp;·&nbsp; [Español](#español)

---

## English

### What is it?

`/init-harness` is a cross-platform AI slash command that analyzes your project and
generates a complete **AI agent harness**: a set of structured files that give any
AI coding assistant persistent memory, a feature registry, an environment bootstrap
script, and a session protocol — so every session starts informed and ends committed.

Based on Anthropic's engineering article
["Effective Harnesses for Long-Running Agents"](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
and patterns from [anthropics/cwc-long-running-agents](https://github.com/anthropics/cwc-long-running-agents).

---

### Why do you need it?

Every time you open a project in an AI coding tool, the agent starts with **zero context**:

- It doesn't know your tech stack, coding rules, or architectural decisions
- It doesn't know what was built last session or what's broken
- It may mark features as "done" without actually testing them
- Switching between Claude Code, Cursor, and Codex means re-explaining everything from scratch

`/init-harness` solves all of this once, for any project, for any platform.

---

### What it creates

Running `/init-harness` in your project generates **16 files** tailored to your codebase:

| File | Purpose | Used by |
|------|---------|---------|
| `AGENTS.md` | Canonical harness (~60 lines) — single source of truth | All platforms (auto-loaded) |
| `CLAUDE.md` | Imports `AGENTS.md` + Claude-specific notes | Claude Code (auto-loaded) |
| `.cursor/rules/00-core.mdc` | Hard rules, always loaded | Cursor (JIT) |
| `.cursor/rules/10-{lang}.mdc` | Language conventions, loads on matching files | Cursor (JIT) |
| `.cursor/rules/20-testing.mdc` | Test conventions, loads by relevance | Cursor (JIT) |
| `.agents/harness.json` | Version metadata — enables upgrade detection | init-harness |
| `.agents/refs/stack.md` | Tech stack, structure, env vars | On demand |
| `.agents/refs/patterns.md` | Architectural patterns | On demand |
| `.agents/refs/rules.md` | Full coding rules | On demand |
| `.agents/refs/failures.md` | Common failure modes | On demand |
| `.agents/progress.md` | Rolling-window handoff (decisions + why) | All platforms |
| `.agents/features.json` | Lean feature registry with acceptance criteria | All platforms |
| `.agents/features-detail.json` | Feature steps, read on demand | All platforms |
| `scripts/init.sh` | POSIX session bootstrap | All platforms (Linux/Mac) |
| `scripts/init.ps1` | PowerShell session bootstrap | All platforms (Windows) |
| `.claude/settings.json` | Permissions + deny list + enforcement hooks | Claude Code |

**Repo structure installed:**
```
your-project/
├── AGENTS.md                    ← canonical (~60 ln) — all platforms read this
├── CLAUDE.md                    ← Claude Code: @imports AGENTS.md + Claude notes
├── .cursor/
│   └── rules/
│       ├── 00-core.mdc          ← always loaded (alwaysApply: true)
│       ├── 10-{lang}.mdc        ← loads on matching file globs
│       └── 20-testing.mdc       ← loads by relevance
├── .agents/
│   ├── harness.json             ← version metadata
│   ├── refs/
│   │   ├── stack.md             ← stack, structure, env vars (on demand)
│   │   ├── patterns.md          ← architectural patterns (on demand)
│   │   ├── rules.md             ← full coding rules (on demand)
│   │   └── failures.md          ← common failure modes (on demand)
│   ├── archive/                 ← old sessions
│   ├── progress.md              ← rolling-window handoff (decisions + why)
│   ├── features.json            ← lean registry with done criteria
│   └── features-detail.json     ← steps per feature (read on demand)
├── scripts/
│   ├── init.sh
│   └── init.ps1
└── .claude/
    └── settings.json
```

Everything is derived from your actual project — no generic filler.

---

### Installation

> **One-time setup.** Install once, use in every project forever.

**Linux / macOS:**
```bash
git clone https://github.com/dhinojosac/init-harness.git
cd init-harness
bash install.sh
```

**Windows (PowerShell):**
```powershell
git clone https://github.com/dhinojosac/init-harness.git
cd init-harness
powershell -ExecutionPolicy Bypass -File install.ps1
```

The installer copies `init-harness.md` to the commands directory of each platform:

| Platform | Primary path | Format |
|----------|-------------|--------|
| Claude Code | `~/.claude/commands/init-harness.md` | Commands (`.md`) |
| Cursor | `~/.cursor/skills/init-harness/SKILL.md` | Skills (`SKILL.md`) |
| Cursor + Codex | `~/.agents/skills/init-harness/SKILL.md` | Cross-agent standard |
| Codex (legacy) | `~/.codex/skills/init-harness/SKILL.md` | Skills (`SKILL.md`) |

> **Note on Codex `rules/`:** Codex rules (`~/.codex/rules/*.rules`) are **Starlark files
> that control which shell commands are allowed or blocked** — they are a security/permissions
> system, not behavior instructions. The installer does not create anything there.

---

### Alternative: No installation — just send the URL

You don't need to install anything. You can give any AI agent the GitHub URL and
tell it to implement the harness directly in your project:

> *"Implement this in my project: https://github.com/dhinojosac/init-harness"*

The agent will fetch the repo, read `init-harness.md` (or `skills/init-harness/SKILL.md`
if it supports the skills format), and execute all 10 steps to generate the harness files.

**Works with any LLM or agent that can browse URLs:**

| Tool | What to say |
|------|------------|
| Claude Code | `Implement this: https://github.com/dhinojosac/init-harness` |
| Cursor | `Implement this: https://github.com/dhinojosac/init-harness` |
| OpenAI Codex | `Implement this: https://github.com/dhinojosac/init-harness` |
| ChatGPT / Claude.ai | Paste the URL + "implement this harness in my project" |
| Any agent with web access | Same — paste the URL and ask it to implement |

> **When to use this vs. the installer:**
> - **Install once** → best when you work across many projects; `/init-harness` is always one keystroke away
> - **Send the URL** → best for a one-off project, a teammate's machine, or any agent that doesn't support slash commands natively

---

### Usage

Open any project in your AI tool and type the command:

| Platform | Command | How to invoke |
|----------|---------|--------------|
| **Claude Code** | `/init-harness` | Type `/` in the chat input |
| **Cursor** | `/init-harness` | Type `/` in the Agent chat panel |
| **OpenAI Codex** | `$init-harness` | Type `$` in the Codex terminal |

**How each platform finds the skill:**

| Platform | Mechanism | Paths scanned (highest → lowest priority) |
|----------|----------|------------------------------------------|
| Claude Code | `commands/` directory | `~/.claude/commands/` |
| Cursor | Skills standard | `.agents/skills/` → `.cursor/skills/` → `~/.agents/skills/` → `~/.cursor/skills/` |
| Codex | Skills standard | `.agents/skills/` → `$REPO_ROOT/.agents/skills/` → `~/.agents/skills/` |

> **`disable-model-invocation: true`** is set in the `SKILL.md` frontmatter, which means
> the skill only runs when you explicitly invoke it — it will never trigger automatically
> in the middle of unrelated work.

The agent will:
1. Analyze your project (language, framework, git history, existing files)
2. Ask before overwriting any existing harness files
3. Generate all 8 files tailored to your codebase
4. Print a summary with next steps

**Example output:**
```
╔══════════════════════════════════════════════════╗
║           init-harness — Setup Complete          ║
╠══════════════════════════════════════════════════╣
║  Project : my-saas-app                           ║
║  Stack   : TypeScript / Next.js                  ║
╠══════════════════════════════════════════════════╣
║  Files created:                                  ║
║  ✓ CLAUDE.md            — Claude Code            ║
║  ✓ AGENTS.md            — OpenAI Codex           ║
║  ✓ .cursorrules         — Cursor                 ║
║  ✓ agent-progress.md    — session state          ║
║  ✓ agent-features.json  — 22 features (14 passing, 8 to verify)
║  ✓ scripts/init.sh      — POSIX bootstrap        ║
║  ✓ scripts/init.ps1     — Windows bootstrap      ║
║  ✓ .claude/settings.json — permissions + hook    ║
╚══════════════════════════════════════════════════╝
```

---

### How it works

The command runs 11 steps:

| Step | What happens |
|------|-------------|
| 0. Pre-flight gate | 5 checks: git init, greenfield/brownfield, existing harness + upgrade, monorepo, team/solo commit policy |
| 1. Directories + `.agents/harness.json` | Creates `scripts/`, `.claude/`, `.cursor/rules/`, `.agents/refs/`, `.agents/archive/`; writes version stamp |
| 2. `AGENTS.md` | Canonical ~60-line pilot's checklist: stack, commands, session protocol, hard rules |
| 3. `CLAUDE.md` | `@AGENTS.md` import + Claude-specific notes; lists `.agents/refs/` for on-demand loading |
| 4. `.cursor/rules/*.mdc` | Scoped rules with `alwaysApply`/`globs`/`description` frontmatter instead of flat file |
| 5. `.agents/refs/` | 4 detail files: stack, patterns, rules, failures — read on demand, not every session |
| 6. `.agents/progress.md` | Rolling-window handoff: decisions + why (not just summaries) |
| 7. `.agents/features.json` + `features-detail.json` | Lean registry with acceptance criteria + steps on demand |
| 8. `scripts/init.sh` | POSIX bootstrap: silent success/verbose failure; dumps context to file, not to agent context |
| 9. `scripts/init.ps1` | PowerShell equivalent with native JSON parsing |
| 10. `.claude/settings.json` | `deny` list (force-push, rm -rf) + `PostToolUse` typecheck hook + session-end checklist |
| 11. Report | Summary table with next steps |

---

### Session workflow (after harness is installed)

```
Open project in AI tool
      │
      ▼
AI reads AGENTS.md (all platforms) + CLAUDE.md (Claude Code) ← automatic
      │
      ▼
Session startup — just-in-time:
  → read .agents/progress.md     (handoff: decisions + what to load)
  → git log -5 + git status
  → bash scripts/init.sh         (deps, typecheck, pending features)
  → pick highest-priority passes:false feature from .agents/features.json
  → load only the detail files that feature needs (.agents/refs/)
      │
      ▼
Agent works on the chosen feature
(PostToolUse hook runs typecheck silently after each edit)
      │
      ▼
Session end — enforced by hooks:
  → typecheck + lint + test
  → git commit (atomic)
  → .agents/progress.md  →  record decisions + why (≤7 lines)
  → .agents/features.json  →  passes:true only if done criterion met e2e
      │
      ▼
Next session starts fully informed  ←── loop
```

---

### Requirements

- One of: Claude Code CLI, Cursor, or OpenAI Codex CLI
- Any language/framework — the command detects the stack automatically
- `git` is recommended but not required — if absent, the harness offers to initialize it
  and continues in degraded mode if declined

---

### Supported stacks

`/init-harness` adapts to any project. Tested with:

- TypeScript / JavaScript (Next.js, Express, NestJS, Vite)
- Python (FastAPI, Django, Flask)
- Go (Gin, Echo, standard library)
- Rust (Axum, Actix)
- PHP (Laravel, Symfony)
- Monorepos (pnpm workspaces + Turborepo, Nx, Lerna)

---

### Contributing

Contributions are welcome. Please open an issue before submitting a PR so we can
discuss the change.

To test locally:
```bash
git clone https://github.com/dhinojosac/init-harness.git
# Open any test project in Claude Code / Cursor / Codex
# Type /init-harness and verify the generated files
```

---

### License

MIT — use freely in personal and commercial projects.

---

---

## Español

### ¿Qué es?

`/init-harness` es un comando slash multiplataforma que analiza tu proyecto y
genera un **harness completo para agentes de IA**: un conjunto de archivos estructurados
que le dan a cualquier asistente de programación IA memoria persistente, un registro de
funcionalidades, un script de arranque del entorno y un protocolo de sesión — para que
cada sesión comience informada y termine con un commit.

Basado en el artículo de ingeniería de Anthropic
["Effective Harnesses for Long-Running Agents"](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
y en los patrones de [anthropics/cwc-long-running-agents](https://github.com/anthropics/cwc-long-running-agents).

---

### ¿Por qué lo necesitas?

Cada vez que abres un proyecto en una herramienta de IA, el agente comienza con **cero contexto**:

- No conoce tu stack tecnológico, reglas de código ni decisiones de arquitectura
- No sabe qué se construyó en la última sesión ni qué está roto
- Puede marcar funcionalidades como "listas" sin haberlas probado realmente
- Cambiar entre Claude Code, Cursor y Codex implica reexplicar todo desde cero

`/init-harness` resuelve todo esto una sola vez, para cualquier proyecto y cualquier plataforma.

---

### Qué crea

Al ejecutar `/init-harness` en tu proyecto se generan **16 archivos** adaptados a tu código:

| Archivo | Propósito | Usado por |
|---------|----------|----------|
| `AGENTS.md` | Harness canónico (~60 líneas) — fuente única de verdad | Todas las plataformas (auto) |
| `CLAUDE.md` | Importa `AGENTS.md` + notas específicas de Claude | Claude Code (auto) |
| `.cursor/rules/00-core.mdc` | Reglas duras, siempre cargadas | Cursor (JIT) |
| `.cursor/rules/10-{lang}.mdc` | Convenciones del lenguaje, carga por globs | Cursor (JIT) |
| `.cursor/rules/20-testing.mdc` | Convenciones de tests, carga por relevancia | Cursor (JIT) |
| `.agents/harness.json` | Metadatos de versión — permite detectar upgrades | init-harness |
| `.agents/refs/stack.md` | Stack, estructura, variables de entorno | On demand |
| `.agents/refs/patterns.md` | Patrones arquitectónicos | On demand |
| `.agents/refs/rules.md` | Reglas de código completas | On demand |
| `.agents/refs/failures.md` | Modos de fallo comunes | On demand |
| `.agents/progress.md` | Handoff con decisiones + por qué | Todas las plataformas |
| `.agents/features.json` | Registro liviano con criterios de aceptación | Todas las plataformas |
| `.agents/features-detail.json` | Steps por feature, se leen on demand | Todas las plataformas |
| `scripts/init.sh` | Bootstrap POSIX: silencioso en éxito, verboso en fallo | Todas las plataformas (Linux/Mac) |
| `scripts/init.ps1` | Bootstrap PowerShell equivalente | Todas las plataformas (Windows) |
| `.claude/settings.json` | Lista deny + hooks de enforcement + checklist fin | Claude Code |

Todo se deriva de tu proyecto real — sin relleno genérico.

---

### Instalación

> **Configuración única.** Instala una vez, usa en todos tus proyectos para siempre.

**Linux / macOS:**
```bash
git clone https://github.com/dhinojosac/init-harness.git
cd init-harness
bash install.sh
```

**Windows (PowerShell):**
```powershell
git clone https://github.com/dhinojosac/init-harness.git
cd init-harness
powershell -ExecutionPolicy Bypass -File install.ps1
```

El instalador copia los archivos a los directorios correctos de cada plataforma:

| Plataforma | Path principal | Formato |
|------------|---------------|---------|
| Claude Code | `~/.claude/commands/init-harness.md` | Commands (`.md`) |
| Cursor | `~/.cursor/skills/init-harness/SKILL.md` | Skills (`SKILL.md`) |
| Cursor + Codex | `~/.agents/skills/init-harness/SKILL.md` | Estándar cross-agent |
| Codex (legacy) | `~/.codex/skills/init-harness/SKILL.md` | Skills (`SKILL.md`) |

> **Nota sobre Codex `rules/`:** Las rules de Codex (`~/.codex/rules/*.rules`) son **archivos
> Starlark que controlan qué comandos shell están permitidos o bloqueados** — son un sistema
> de permisos/seguridad, no instrucciones de comportamiento. El instalador no crea nada ahí.

---

### Alternativa: Sin instalación — solo envía la URL

No necesitas instalar nada. Puedes darle a cualquier agente de IA la URL del repo de
GitHub y pedirle que implemente el harness directamente en tu proyecto:

> *"Implementa esto en mi proyecto: https://github.com/dhinojosac/init-harness"*

El agente buscará el repo, leerá `init-harness.md` (o `skills/init-harness/SKILL.md`
si soporta el formato skills), y ejecutará los 10 pasos para generar los archivos del harness.

**Funciona con cualquier LLM o agente que pueda navegar URLs:**

| Herramienta | Qué decirle |
|-------------|------------|
| Claude Code | `Implementa esto: https://github.com/dhinojosac/init-harness` |
| Cursor | `Implementa esto: https://github.com/dhinojosac/init-harness` |
| OpenAI Codex | `Implementa esto: https://github.com/dhinojosac/init-harness` |
| ChatGPT / Claude.ai | Pega la URL + "implementa este harness en mi proyecto" |
| Cualquier agente con acceso web | Igual — pega la URL y pedile que lo implemente |

> **Cuándo usar esto vs. el instalador:**
> - **Instalar una vez** → mejor si trabajás en muchos proyectos; `/init-harness` siempre a un teclazo
> - **Enviar la URL** → mejor para un proyecto puntual, la máquina de un compañero, o cualquier agente que no soporte slash commands nativamente

---

### Uso

Abre cualquier proyecto en tu herramienta de IA y escribe el comando:

| Plataforma | Comando | Cómo invocarlo |
|------------|---------|----------------|
| **Claude Code** | `/init-harness` | Escribe `/` en el input del chat |
| **Cursor** | `/init-harness` | Escribe `/` en el panel Agent chat |
| **OpenAI Codex** | `$init-harness` | Escribe `$` en la terminal de Codex |

**Cómo cada plataforma encuentra el skill:**

| Plataforma | Mecanismo | Paths escaneados (mayor → menor prioridad) |
|------------|----------|--------------------------------------------|
| Claude Code | Directorio `commands/` | `~/.claude/commands/` |
| Cursor | Estándar Skills | `.agents/skills/` → `.cursor/skills/` → `~/.agents/skills/` → `~/.cursor/skills/` |
| Codex | Estándar Skills | `.agents/skills/` → `$REPO_ROOT/.agents/skills/` → `~/.agents/skills/` |

> **`disable-model-invocation: true`** está configurado en el frontmatter del `SKILL.md`,
> lo que significa que el skill solo corre cuando lo invocás explícitamente — nunca se
> dispara solo en medio de otro trabajo.

El agente:
1. Analizará tu proyecto (lenguaje, framework, historial git, archivos existentes)
2. Preguntará antes de sobreescribir cualquier archivo del harness existente
3. Generará los 8 archivos adaptados a tu código
4. Mostrará un resumen con los próximos pasos

---

### Cómo funciona

El comando ejecuta 11 pasos:

| Paso | Qué ocurre |
|------|-----------|
| 0. Pre-flight gate | 5 checks: git, greenfield/brownfield, harness existente + upgrade, monorepo, política de commits |
| 1. Directorios + `.agents/harness.json` | Crea `scripts/`, `.claude/`, `.cursor/rules/`, `.agents/refs/`, `.agents/archive/`; escribe stamp de versión |
| 2. `AGENTS.md` | Checklist canónico ~60 líneas: stack, comandos, protocolo de sesión, reglas duras |
| 3. `CLAUDE.md` | `@AGENTS.md` import + notas específicas de Claude; lista `.agents/refs/` para carga on demand |
| 4. `.cursor/rules/*.mdc` | Reglas scoped con frontmatter `alwaysApply`/`globs`/`description` |
| 5. `.agents/refs/` | 4 archivos de detalle: stack, patrones, reglas, fallos — se leen on demand |
| 6. `.agents/progress.md` | Handoff con ventana deslizante: decisiones + por qué |
| 7. `.agents/features.json` + `features-detail.json` | Registro liviano con criterios de aceptación + steps on demand |
| 8. `scripts/init.sh` | Bootstrap POSIX: silencioso en éxito, verboso en fallo; vuelca contexto a archivo |
| 9. `scripts/init.ps1` | Equivalente PowerShell con parsing nativo de JSON |
| 10. `.claude/settings.json` | Lista `deny` + hook `PostToolUse` (typecheck) + checklist de fin de sesión |
| 11. Reporte | Tabla resumen con próximos pasos |

---

### Flujo de sesión (después de instalar el harness)

```
Abrís el proyecto en tu herramienta de IA
      │
      ▼
La IA lee CLAUDE.md / AGENTS.md / .cursorrules  ← automático
      │
      ▼
Protocolo de inicio de sesión:
  → cat agent-progress.md       (lee la última sesión)
  → git log + git status        (verifica el estado del repo)
  → bash scripts/init.sh        (arranca el entorno)
  → cat agent-features.json     (elige la próxima funcionalidad)
      │
      ▼
El agente trabaja en la funcionalidad elegida
      │
      ▼
Protocolo de fin de sesión:
  → typecheck + lint
  → git commit
  → actualiza agent-progress.md
  → actualiza agent-features.json
      │
      ▼
La próxima sesión comienza completamente informada  ←── ciclo
```

---

### Requisitos

- Alguna de: Claude Code CLI, Cursor, o OpenAI Codex CLI
- Cualquier lenguaje/framework — el comando detecta el stack automáticamente
- `git` es recomendado pero no obligatorio — si no está, el harness ofrece inicializarlo
  y continúa en modo degradado si se rechaza

---

### Stacks soportados

`/init-harness` se adapta a cualquier proyecto. Probado con:

- TypeScript / JavaScript (Next.js, Express, NestJS, Vite)
- Python (FastAPI, Django, Flask)
- Go (Gin, Echo, librería estándar)
- Rust (Axum, Actix)
- PHP (Laravel, Symfony)
- Monorepos (pnpm workspaces + Turborepo, Nx, Lerna)

---

### Contribuir

Las contribuciones son bienvenidas. Por favor abre un issue antes de enviar un PR
para que podamos discutir el cambio.

---

### Licencia

MIT — uso libre en proyectos personales y comerciales.

---

### Changelog

#### v2.1.0 — 2026-06-18

- **Merged v1.3.0 `.agents/` structure with v2.0.0 enforcement philosophy**
- **`AGENTS.md` is now canonical** — `CLAUDE.md` uses `@AGENTS.md` import; no more 3-way content duplication
- **`.cursor/rules/*.mdc`** replaces flat `.cursorrules`; scoped via `alwaysApply`/`globs`/`description` frontmatter
- **`deny` list in settings.json** — `git push --force` and `rm -rf /` blocked deterministically, not by prose
- **`PostToolUse` hook** — typecheck runs silently after every edit; speaks only on failure
- **5-gate pre-flight** — git, greenfield/brownfield, existing harness (with upgrade path from v1.2/v1.3/v2.0), monorepo, team/solo commit policy
- **`done` field in features.json** — explicit testable acceptance criterion per feature; replaces self-grading
- **Handoff carries decisions + why** — not just a "what I did" summary
- **`init.sh`/`init.ps1` offload large output** to `.harness-context.txt`; silent success, verbose failure
- **Generator stamps** on all generated files — distinguishes regenerable from human-authored
- **Root stays clean** — `AGENTS.md`, `CLAUDE.md`, `.cursor/rules/` at root; all agent state in `.agents/`
- **`.agents/refs/` kept** from v1.3.0 — 4 on-demand detail files; not pre-loaded every session

#### v1.3.0 — 2026-06-12

- **CLAUDE.md is now lean (≤55 lines)** — full details moved to `.agents/refs/` (stack, patterns, rules, failures), loaded on demand instead of every session
- **Session startup = one command** — protocol reduced to `bash scripts/init.sh` / `powershell scripts/init.ps1`; script output is structured and controlled
- **`.agents/` replaces root agent files** — `agent-progress.md` → `.agents/progress.md`, `agent-features.json` → `.agents/features.json`; root stays clean
- **features.json split into two** — lean registry (no steps, ~1KB) for session startup + `features-detail.json` for steps read on demand per feature
- **progress.md rolling window** — fixed 3-section structure (current / last / archive link); bounded size, archive to `.agents/archive/`
- **Git detection + recovery** — STEP 0 detects missing git, offers `git init` + optional remote, continues in degraded mode if declined
- **Risk-based settings.json** — `git push` excluded from auto-allow; `cat .agents/*` replaces individual file entries
- **Harness assumptions note** — final constraint reminds that scaffolding should be removed as model capability improves
- **Version detection + upgrade flow** — STEP 0 reads `.agents/harness.json`; detects if init-harness is already installed, offers upgrade, migrates data from v1.2.0 (root files → `.agents/`)

#### v1.2.0 — 2026-06-04
- Cursor: migrado de `commands/` a `skills/` (nuevo estándar); legacy `commands/` se mantiene como fallback
- Codex: path canónico ahora es `~/.agents/skills/` (cross-agent standard compartido con Cursor)
- `SKILL.md` frontmatter: agregado `disable-model-invocation: true` (invocación solo explícita)
- Aclarado que Codex `rules/` son archivos Starlark de permisos de shell, no reglas de comportamiento
- README: tablas de paths e invocación actualizadas para ambas plataformas

#### v1.1.0 — 2026-06-04
- Agregada estructura nativa `skills/init-harness/SKILL.md` para OpenAI Codex
- Instalador actualizado: instala en `~/.agents/skills/` (estándar) y `~/.codex/skills/` (legacy)
- Comando Codex corregido de `/prompts:init-harness` a `$init-harness`
- Instalación también en `~/.claude/skills/` (cross-agent standard)

#### v1.0.0 — 2026-06-04
- Lanzamiento inicial
- Soporte para Claude Code, Cursor y OpenAI Codex
- Scripts de instalación para Linux/macOS y Windows
- Detección automática de stack: TypeScript, Python, Go, Rust, PHP, monorepos
- 10 pasos de generación con análisis real del proyecto
