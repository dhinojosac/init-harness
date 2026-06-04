# init-harness

**Version:** 1.1.0 &nbsp;|&nbsp; **License:** MIT &nbsp;|&nbsp; **Platforms:** Claude Code · Cursor · OpenAI Codex

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

Running `/init-harness` in your project generates **8 files** tailored to your codebase:

| File | Purpose | Used by |
|------|---------|---------|
| `CLAUDE.md` | Full harness documentation | Claude Code (auto-loaded) |
| `AGENTS.md` | Same content, different platform note | OpenAI Codex (auto-loaded) |
| `.cursorrules` | Condensed rules | Cursor (auto-loaded) |
| `agent-progress.md` | Cross-session state tracker | All platforms |
| `agent-features.json` | Feature registry with pass/fail status | All platforms |
| `scripts/init.sh` | POSIX session bootstrap | All platforms (Linux/Mac) |
| `scripts/init.ps1` | PowerShell session bootstrap | All platforms (Windows) |
| `.claude/settings.json` | Permissions + session-end hook | Claude Code |

**Repo structure installed:**
```
your-project/
├── CLAUDE.md                ← Claude Code reads this automatically
├── AGENTS.md                ← Codex reads this automatically
├── .cursorrules             ← Cursor reads this automatically
├── agent-progress.md        ← shared session state
├── agent-features.json      ← feature registry
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

| Platform | Location |
|----------|---------|
| Claude Code | `~/.claude/commands/init-harness.md` |
| Cursor | `~/.cursor/commands/init-harness.md` |
| OpenAI Codex | `~/.codex/prompts/init-harness.md` |

---

### Usage

Open any project in your AI tool and type the command:

| Platform | Command | How to invoke |
|----------|---------|--------------|
| **Claude Code** | `/init-harness` | Type `/` in the chat input |
| **Cursor** | `/init-harness` | Type `/` in the AI chat panel |
| **OpenAI Codex** | `$init-harness` | Type `$` in the Codex terminal |

> **Codex note:** Codex uses a `skills/` format natively (`SKILL.md` with YAML frontmatter).
> The installer places the skill at `~/.agents/skills/init-harness/SKILL.md` (current standard)
> and `~/.codex/skills/init-harness/SKILL.md` (legacy compatibility).
> The repo also ships `skills/init-harness/SKILL.md` so Codex can load it
> directly when you point it to the GitHub URL.

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
| 0. Analysis | Reads git history, manifest files, source structure, existing README |
| 1. Directories | Creates `scripts/` and `.claude/` |
| 2. `CLAUDE.md` | Full documentation: stack, patterns, rules, startup/end protocols |
| 3. `AGENTS.md` | Copy of CLAUDE.md with Codex platform note |
| 4. `.cursorrules` | Condensed version (≤60 lines) for Cursor |
| 5. `agent-progress.md` | Seeded with current git state and uncommitted files |
| 6. `agent-features.json` | Features inferred from routes, controllers, commits, README |
| 7. `scripts/init.sh` | POSIX bootstrap: install deps, typecheck, print context |
| 8. `scripts/init.ps1` | PowerShell equivalent with native JSON parsing |
| 9. `.claude/settings.json` | Pre-approved commands + session-end checklist hook |
| 10. Report | Summary table with next steps |

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

- A project managed with `git`
- One of: Claude Code CLI, Cursor, or OpenAI Codex CLI
- Any language/framework — the command detects the stack automatically

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

Al ejecutar `/init-harness` en tu proyecto se generan **8 archivos** adaptados a tu código:

| Archivo | Propósito | Usado por |
|---------|----------|----------|
| `CLAUDE.md` | Documentación completa del harness | Claude Code (carga automática) |
| `AGENTS.md` | Mismo contenido, nota de plataforma diferente | OpenAI Codex (carga automática) |
| `.cursorrules` | Reglas condensadas | Cursor (carga automática) |
| `agent-progress.md` | Registro de estado entre sesiones | Todas las plataformas |
| `agent-features.json` | Registro de funcionalidades con estado pass/fail | Todas las plataformas |
| `scripts/init.sh` | Bootstrap de sesión POSIX | Todas las plataformas (Linux/Mac) |
| `scripts/init.ps1` | Bootstrap de sesión PowerShell | Todas las plataformas (Windows) |
| `.claude/settings.json` | Permisos + hook de fin de sesión | Claude Code |

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

El instalador copia `init-harness.md` al directorio de comandos de cada plataforma:

| Plataforma | Ubicación |
|------------|----------|
| Claude Code | `~/.claude/commands/init-harness.md` |
| Cursor | `~/.cursor/commands/init-harness.md` |
| OpenAI Codex | `~/.codex/prompts/init-harness.md` |

---

### Uso

Abre cualquier proyecto en tu herramienta de IA y escribe el comando:

| Plataforma | Comando | Cómo invocarlo |
|------------|---------|----------------|
| **Claude Code** | `/init-harness` | Escribe `/` en el input del chat |
| **Cursor** | `/init-harness` | Escribe `/` en el panel de chat de IA |
| **OpenAI Codex** | `$init-harness` | Escribe `$` en la terminal de Codex |

> **Nota Codex:** Codex usa el formato nativo `skills/` (`SKILL.md` con frontmatter YAML).
> El instalador coloca el skill en `~/.agents/skills/init-harness/SKILL.md` (estándar actual)
> y `~/.codex/skills/init-harness/SKILL.md` (compatibilidad legacy).
> El repo también incluye `skills/init-harness/SKILL.md` para que Codex lo cargue
> directamente cuando le apuntas a la URL de GitHub.

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
| 0. Análisis | Lee historial git, archivos de manifiesto, estructura fuente, README existente |
| 1. Directorios | Crea `scripts/` y `.claude/` |
| 2. `CLAUDE.md` | Documentación completa: stack, patrones, reglas, protocolos de inicio/fin |
| 3. `AGENTS.md` | Copia de CLAUDE.md con nota de plataforma Codex |
| 4. `.cursorrules` | Versión condensada (≤60 líneas) para Cursor |
| 5. `agent-progress.md` | Precargado con el estado git actual y archivos sin commit |
| 6. `agent-features.json` | Funcionalidades inferidas de rutas, controladores, commits, README |
| 7. `scripts/init.sh` | Bootstrap POSIX: instala deps, typecheck, imprime contexto |
| 8. `scripts/init.ps1` | Equivalente PowerShell con parsing nativo de JSON |
| 9. `.claude/settings.json` | Comandos pre-aprobados + hook de checklist de fin de sesión |
| 10. Reporte | Tabla resumen con próximos pasos |

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

- Un proyecto gestionado con `git`
- Alguna de: Claude Code CLI, Cursor, o OpenAI Codex CLI
- Cualquier lenguaje/framework — el comando detecta el stack automáticamente

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
