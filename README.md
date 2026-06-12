# init-harness

**Version:** 1.2.0 &nbsp;|&nbsp; **License:** MIT &nbsp;|&nbsp; **Platforms:** Claude Code · Cursor · OpenAI Codex

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

Running `/init-harness` in your project generates **13 files** tailored to your codebase:

| File | Purpose | Used by |
|------|---------|---------|
| `CLAUDE.md` | Lean harness entry point (~50 lines) | Claude Code (auto-loaded) |
| `AGENTS.md` | Same content, different platform note | OpenAI Codex (auto-loaded) |
| `.cursorrules` | Condensed rules (~45 lines) | Cursor (auto-loaded) |
| `.agents/harness.json` | Version metadata — enables upgrade detection | init-harness |
| `.agents/refs/stack.md` | Tech stack, structure, env vars | On demand |
| `.agents/refs/patterns.md` | Architectural patterns | On demand |
| `.agents/refs/rules.md` | Full coding rules | On demand |
| `.agents/refs/failures.md` | Common failure modes | On demand |
| `.agents/progress.md` | Rolling-window session state | All platforms |
| `.agents/features.json` | Lean feature registry (no steps) | All platforms |
| `.agents/features-detail.json` | Feature steps, read on demand | All platforms |
| `scripts/init.sh` | POSIX session bootstrap | All platforms (Linux/Mac) |
| `scripts/init.ps1` | PowerShell session bootstrap | All platforms (Windows) |
| `.claude/settings.json` | Permissions + session-end hook | Claude Code |

**Repo structure installed:**
```
your-project/
├── CLAUDE.md                    ← Claude Code reads this automatically (~50 ln)
├── AGENTS.md                    ← Codex reads this automatically
├── .cursorrules                 ← Cursor reads this automatically (~45 ln)
├── .agents/
│   ├── refs/
│   │   ├── stack.md             ← stack, structure, env vars
│   │   ├── patterns.md          ← architectural patterns
│   │   ├── rules.md             ← full coding rules
│   │   └── failures.md          ← common failure modes
│   ├── archive/                 ← old sessions and done features
│   ├── progress.md              ← rolling-window session state
│   ├── features.json            ← lean feature registry
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

The command runs 10 steps:

| Step | What happens |
|------|-------------|
| 0. Analysis | Reads git history (or offers `git init` if absent), manifest files, source structure, README |
| 1. Directories | Creates `scripts/`, `.claude/`, `.agents/refs/`, `.agents/archive/` |
| 2. `CLAUDE.md` | Lean entry point ≤55 lines: stack summary, startup/end protocols, links to refs |
| 3. `.agents/refs/` | 4 detail files: stack, patterns, rules, failures — read on demand, not every session |
| 4. `AGENTS.md` | Copy of CLAUDE.md with Codex platform note |
| 5. `.cursorrules` | Condensed version (≤45 lines) for Cursor |
| 6. `.agents/progress.md` | Rolling-window session state: current + last session + archive link |
| 7. `.agents/features.json` + `features-detail.json` | Lean registry + steps on demand |
| 8. `scripts/init.sh` | POSIX bootstrap: install deps, typecheck, git state, print context |
| 9. `scripts/init.ps1` | PowerShell equivalent with native JSON parsing |
| 10. `.claude/settings.json` | Risk-based permissions + session-end checklist hook |
| 11. Report | Summary table with next steps |

---

### Session workflow (after harness is installed)

```
Open project in AI tool
      │
      ▼
AI reads CLAUDE.md / AGENTS.md / .cursorrules  ← automatic
      │
      ▼
Session startup protocol:
  → cat agent-progress.md       (reads last session)
  → git log + git status        (checks repo state)
  → bash scripts/init.sh        (bootstraps environment)
  → cat agent-features.json     (picks next feature)
      │
      ▼
Agent works on the chosen feature
      │
      ▼
Session end protocol:
  → typecheck + lint
  → git commit
  → updates agent-progress.md
  → updates agent-features.json
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

Al ejecutar `/init-harness` en tu proyecto se generan **13 archivos** adaptados a tu código:

| Archivo | Propósito | Usado por |
|---------|----------|----------|
| `CLAUDE.md` | Entry point liviano (~50 líneas) | Claude Code (carga automática) |
| `AGENTS.md` | Mismo contenido, nota de plataforma diferente | OpenAI Codex (carga automática) |
| `.cursorrules` | Reglas condensadas (~45 líneas) | Cursor (carga automática) |
| `.agents/harness.json` | Metadatos de versión — permite detectar upgrades | init-harness |
| `.agents/refs/stack.md` | Stack, estructura, variables de entorno | On demand |
| `.agents/refs/patterns.md` | Patrones arquitectónicos | On demand |
| `.agents/refs/rules.md` | Reglas de código completas | On demand |
| `.agents/refs/failures.md` | Modos de fallo comunes | On demand |
| `.agents/progress.md` | Estado de sesión con ventana deslizante | Todas las plataformas |
| `.agents/features.json` | Registro de features liviano (sin steps) | Todas las plataformas |
| `.agents/features-detail.json` | Steps por feature, se leen on demand | Todas las plataformas |
| `scripts/init.sh` | Bootstrap de sesión POSIX | Todas las plataformas (Linux/Mac) |
| `scripts/init.ps1` | Bootstrap de sesión PowerShell | Todas las plataformas (Windows) |
| `.claude/settings.json` | Permisos por clase de riesgo + hook de fin | Claude Code |

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

El comando ejecuta 10 pasos:

| Paso | Qué ocurre |
|------|-----------|
| 0. Análisis | Lee historial git (u ofrece `git init` si no existe), manifiestos, estructura, README |
| 1. Directorios | Crea `scripts/`, `.claude/`, `.agents/refs/`, `.agents/archive/` |
| 2. `CLAUDE.md` | Entry point liviano ≤55 líneas: resumen de stack, protocolos, links a refs |
| 3. `.agents/refs/` | 4 archivos de detalle: stack, patrones, reglas, fallos — se leen on demand |
| 4. `AGENTS.md` | Copia de CLAUDE.md con nota de plataforma Codex |
| 5. `.cursorrules` | Versión condensada (≤45 líneas) para Cursor |
| 6. `.agents/progress.md` | Ventana deslizante: sesión actual + última sesión + link al archivo |
| 7. `.agents/features.json` + `features-detail.json` | Registro liviano + steps on demand |
| 8. `scripts/init.sh` | Bootstrap POSIX: instala deps, typecheck, estado git, imprime contexto |
| 9. `scripts/init.ps1` | Equivalente PowerShell con parsing nativo de JSON |
| 10. `.claude/settings.json` | Permisos por clase de riesgo + hook de checklist de fin de sesión |
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
