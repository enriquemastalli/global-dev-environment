# Global Development Environment

A **universal, portable development system** with 9 integrated skills and senior-level development protocols. This environment applies to ANY project (not just a specific one) and can be installed and distributed across teams in seconds.

## Quick Start

**Install in 30 seconds:**

```bash
curl -fsSL https://raw.githubusercontent.com/enriquemastalli/global-dev-environment/main/install-from-github.sh | bash
```

**Verify installation:**

```bash
~/.opencode/bin/verify-installation.sh
```

**Validate a project:**

```bash
~/.opencode/bin/validate-project.sh /path/to/your/project
```

## What's Included

### 9 Integrated Skills

1. **zero-patch-policy** — Always fix root causes, never apply band-aids
2. **cognitive-responsibility** — Keep functions under 30 lines, maintain readability
3. **strict-typescript-contract** — Full-stack type safety across frontend/backend
4. **edge-performance-first** — Cloudflare Workers optimization patterns
5. **saas-security-enforcer** — Multi-tenant security, JWT, webhooks (Stripe)
6. **ui-state-guardian** — React architecture, state management, CSS patterns
7. **brand-i18n-guardian** — Unified branding, translations, localization
8. **ai-genome-protocol** — System prompts, XML structure, LLM integration
9. **senior-development-protocol** — Debugging, error handling, code quality

### Core Protocols

- **Behavioral Standards** — Pre-action checklist, debugging order, mandatory patterns
- **Development Standards** — D1 database patterns, validation, error handling architecture
- **Team Standards** — Guidelines for entire teams using this environment
- **Senior Development Protocol** — Complete debugging methodology, error propagation, code quality standards

## Installation Methods

### Method 1: Remote Installation (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/enriquemastalli/global-dev-environment/main/install-from-github.sh | bash
```

Installs to `~/.opencode/` automatically.

### Method 2: Clone Repository

```bash
git clone https://github.com/enriquemastalli/global-dev-environment.git
cd global-dev-environment
bash install.sh
```

### Method 3: Download Release

```bash
# Download tarball from releases
curl -fsSL -O https://github.com/enriquemastalli/global-dev-environment/releases/download/v1.0/global-dev-environment-v1.0.tar.gz

# Verify checksum
curl -fsSL https://github.com/enriquemastalli/global-dev-environment/releases/download/v1.0/global-dev-environment-v1.0.tar.gz.sha256 | sha256sum -c

# Extract
tar -xzf global-dev-environment-v1.0.tar.gz -C ~/.opencode/
```

## File Structure

```
~/.opencode/
├── config.json                      # Meta-configuration (intelligent skill loading)
├── BEHAVIORAL_STANDARDS.md          # Protocol for every action
├── DEVELOPMENT_STANDARDS.md         # Technical patterns (D1, validation, errors)
├── TEAM_STANDARDS.md                # Guide for entire teams
├── README.md                        # Full documentation
├── QUICK_START.md                   # 30-second setup guide
├── CHANGELOG.md                     # Version history
├── install.sh                       # Local installer
├── install-from-github.sh           # Remote installer
├── export.sh                        # Export to distribution package
├── bin/
│   ├── validate-project.sh          # Validate project structure
│   ├── auto-create-agents-md.sh     # Auto-generate AGENTS.md
│   └── verify-installation.sh       # Verify post-installation
└── skills/
    ├── zero-patch-policy/
    ├── cognitive-responsibility/
    ├── strict-typescript-contract/
    ├── edge-performance-first/
    ├── saas-security-enforcer/
    ├── ui-state-guardian/
    ├── brand-i18n-guardian/
    ├── ai-genome-protocol/
    └── senior-development-protocol/
```

## Usage

### Load a Skill

When working on code that matches a skill's domain, the skill is automatically loaded with:

```bash
# In Claude Code or another IDE with skill support
mcp_skill --name zero-patch-policy
```

**Intelligent Skill Loading Rules:**

- **Backend/API/Database** → `edge-performance-first`, `saas-security-enforcer`
- **Frontend/React/CSS** → `ui-state-guardian`, `brand-i18n-guardian`
- **Code edits** → `zero-patch-policy`, `cognitive-responsibility`
- **IA/Prompts/XML** → `ai-genome-protocol`
- **ALWAYS** → `senior-development-protocol`

### Validate Your Project

```bash
~/.opencode/bin/validate-project.sh /path/to/project
```

Checks for:
- Required configuration files
- Git repository status
- Project structure
- Dependency issues

### Create AGENTS.md

```bash
~/.opencode/bin/auto-create-agents-md.sh /path/to/project
```

Auto-generates `AGENTS.md` with skill references and guidelines.

### Export for Distribution

```bash
~/.opencode/export.sh
```

Creates `dosa-environment_TIMESTAMP.tar.gz` for sharing with teams.

## Key Principles

### 1. Root Cause, Never Band-Aids
Every fix must address the underlying issue, not apply temporary patches. Use the debugging checklist in `BEHAVIORAL_STANDARDS.md`.

### 2. Code Quality
- Functions under 30 lines
- Self-documenting code
- Clear naming conventions
- Comprehensive error messages

### 3. Full-Stack Type Safety
- TypeScript everywhere (frontend + backend)
- Strict schemas (Zod)
- Contract validation
- Runtime checks

### 4. Error Handling Architecture
- Backend: Always return `{ error: "...", details: {...} }`
- Client: Preserve error details
- UI: Show specific error messages per field

### 5. Validation Patterns
```typescript
// ❌ WRONG — Dynamic validation at build-time
.max(new Date().getFullYear() + 1)

// ✅ CORRECT — Dynamic validation at runtime
.refine(val => val <= new Date().getFullYear() + 1, "...")
```

## Debugging Checklist (MANDATORY)

Before proposing any fix, verify in this order:

1. **Frontend validation** — Does the frontend block submission?
2. **Network request** — Is the request being sent? (Network tab)
3. **Request data** — What exact data is being sent?
4. **Server response** — What does the server return?
5. **Error handling** — Does the UI show detailed errors or generic messages?

**If no access to logs:** Ask the user before speculating.

## D1 Database Patterns

### Safe `.all()` Usage
```typescript
const response = await db.prepare("SELECT ...").all<Row>();
const results = response?.results ?? [];
```

### Safe `.first()` Usage
```typescript
const row = await db.prepare("SELECT ...").first<Row | null>();
if (!row) return c.json({ error: "Not found" }, 404);
```

### POST INSERT Response
```typescript
// Build response in memory, DON'T SELECT after INSERT
// (eventual consistency may return null immediately)
const created: Row = { id, ...data, created_at: now, updated_at: now };
return c.json(created, 201);
```

## Documentation

- **README.md** — Full overview
- **QUICK_START.md** — 30-second setup
- **BEHAVIORAL_STANDARDS.md** — How to think and act
- **DEVELOPMENT_STANDARDS.md** — Technical patterns
- **TEAM_STANDARDS.md** — Guidelines for teams
- **config.json** — Meta-configuration

## Support

### Verify Installation

```bash
~/.opencode/bin/verify-installation.sh
```

### Check Skill Contents

```bash
ls -la ~/.opencode/skills/
cat ~/.opencode/skills/zero-patch-policy/SKILL.md
```

### Manual Installation (if remote fails)

```bash
git clone https://github.com/enriquemastalli/global-dev-environment.git
cd global-dev-environment
bash install.sh
```

## Portability

This environment is designed to be:

✅ **Universal** — Works with any project, any team, any language (focus: Node.js/TypeScript)
✅ **Portable** — Install to any machine in 30 seconds
✅ **Distributable** — Export as tarball for offline sharing
✅ **Updatable** — Always synced with `git pull origin main`
✅ **Centralized** — All config in `~/.opencode/` (single source of truth)

## Release History

- **v1.0** (2026-03-08) — Initial release with 9 skills + senior protocol + intelligent loading

## Contributing

To improve this environment:

1. Submit issues at https://github.com/enriquemastalli/global-dev-environment/issues
2. Fork and create pull requests
3. Update documentation when adding new skills

## License

MIT — Free for anyone to use, modify, and distribute.

---

**Get started now:**

```bash
curl -fsSL https://raw.githubusercontent.com/enriquemastalli/global-dev-environment/main/install-from-github.sh | bash
```
