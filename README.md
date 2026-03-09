# Global Development Environment

Sistema centralizado y universal que garantiza comportamiento consistente en TODO desarrollo, sin importar proyecto, tecnología o desarrollador.

---

## 🎯 Propósito

Definir y mantener **estándares senior de desarrollo** que se aplican automáticamente en cada sesión:

- ✅ **Debugging científico** — Sin asumir, siempre verificar datos reales
- ✅ **Error handling robusto** — Contexto completo siempre
- ✅ **Code quality** — Causa raíz, nunca band-aids
- ✅ **9 skills integrados** — Se cargan inteligentemente según contexto
- ✅ **Comportamiento predecible** — Mismo protocolo en 100 proyectos

---

## 📁 Estructura

```
/home/usuario/.opencode/
├── config.json                          (Meta-configuración)
├── BEHAVIORAL_STANDARDS.md              (Cómo me comporto)
├── TEAM_STANDARDS.md                    (Guía para el equipo)
├── README.md                            (Este archivo)
├── CHANGELOG.md                         (Versiones)
│
├── skills/                              (9 skills integrados)
│   ├── zero-patch-policy/
│   ├── cognitive-responsibility/
│   ├── strict-typescript-contract/
│   ├── edge-performance-first/
│   ├── saas-security-enforcer/
│   ├── ui-state-guardian/
│   ├── brand-i18n-guardian/
│   ├── ai-genome-protocol/
│   └── senior-development-protocol/
│
├── agents/                              (Agentes especializados)
│   ├── devops-chief.md
│   ├── ui-guardian.md
│   ├── stripe-integrator.md
│   └── dba-edge.md
│
├── bin/                                 (Scripts auxiliares)
│   ├── validate-project.sh              (Validar proyecto)
│   └── auto-create-agents-md.sh         (Auto-crear AGENTS.md)
│
└── templates/                           (Para nuevos proyectos)
    └── _shared/
        └── AGENTS.md.template
```

---

## 🚀 Cómo Funciona

### 1. Sesión Inicio

```
Abro proyecto → Sistema detecta:
├─ ¿AGENTS.md existe?
├─ ¿Git inicializado?
├─ ¿Qué tipo de proyecto?
│
└─ Cargar automáticamente:
   ├─ senior-development-protocol (SIEMPRE)
   ├─ Skills relevantes según contexto
   └─ Notificar cuáles se cargaron
```

### 2. Carga Inteligente de Skills

```
¿Qué estoy haciendo?
│
├─ Backend (Node/API/DB)
│  └─ Cargar: edge-performance-first + saas-security-enforcer
├─ Frontend (React/CSS)
│  └─ Cargar: ui-state-guardian + brand-i18n-guardian
├─ Código (cualquier edit)
│  └─ Cargar: zero-patch-policy + cognitive-responsibility
├─ IA/Prompts
│  └─ Cargar: ai-genome-protocol
└─ SIEMPRE ACTIVO:
   └─ senior-development-protocol
```

### 3. Protocolo Automático

```
ANTES de cualquier cambio:
├─ Checklist mental (datos reales, causa raíz, contexto)
├─ Orden de debugging científico
├─ Validación pre-acción
│
DURANTE implementación:
├─ Seguir BEHAVIORAL_STANDARDS.md
├─ Código más limpio que antes
├─ Error handling robusto
│
DESPUÉS de commit:
├─ Notificar skills cargados
├─ Validar estructura
```

---

## 📚 Documentación Clave

### Para Desarrolladores

**BEHAVIORAL_STANDARDS.md**

- Cómo me comporto en TODA sesión
- Orden de debugging
- Protocolo pre-acción
- Patrones seguros D1
- Validación dinámica con .refine()

**TEAM_STANDARDS.md**

- Guía para el equipo
- Qué esperar del entorno
- Ejemplos reales
- Valores del equipo

### Para Proyectos

Cada proyecto DEBE tener:

- **AGENTS.md** — Ruta base, reglas específicas, skills referenciados
- **DEVELOPMENT_STANDARDS.md** — Estándares técnicos globales

### Para Meta-Configuración

**config.json**

- Reglas de carga inteligente
- Validaciones de proyecto
- Comportamiento global

---

## 🛠️ Herramientas Disponibles

### Scripts

```bash
# Validar que un proyecto cumple estándares
~/.opencode/bin/validate-project.sh /ruta/al/proyecto

# Auto-crear AGENTS.md si no existe
~/.opencode/bin/auto-create-agents-md.sh /ruta/al/proyecto
```

### Skills (Cargados Automáticamente)

```bash
# Ver qué skills hay disponibles
ls ~/.opencode/skills/

# Ver descripción de un skill
cat ~/.opencode/skills/zero-patch-policy/SKILL.md
```

---

## 🔄 Flujo de Uso Típico

### Dev Abre Proyecto

```
$ cd mi-proyecto
$ cat AGENTS.md

# Ve: Reglas del proyecto + 9 skills + configuración específica

# Sistema automáticamente:
✓ Cargar: senior-development-protocol
✓ Detectar: Frontend (React) + Backend (API)
✓ Cargar: ui-state-guardian, edge-performance-first
✓ Notificar: "Cargué 3 skills para tu contexto"
```

### Dev Arregla un Bug

```
1. Verificar datos reales (Network tab)
2. Aplicar orden de debugging científico
3. Identificar causa raíz
4. Implementar fix (causa raíz, no parche)
5. Code quality: más limpio que antes
6. Commit: "fix: descripción clara"
7. Push y PR
```

### Dev Escribe Código Nuevo

```
1. Leer AGENTS.md
2. Cargar skills (automático)
3. Aplicar checklist pre-acción (mental)
4. Escribir código siguiendo:
   - BEHAVIORAL_STANDARDS.md
   - Skill relevante (edge-performance-first, ui-state-guardian, etc)
5. Test local
6. Commit + PR
```

---

## ✅ Validaciones

### Validar Proyecto

```bash
~/.opencode/bin/validate-project.sh .

✓ AGENTS.md existe
✓ Git inicializado
✓ DEVELOPMENT_STANDARDS.md existe
✓ package.json válido
✓ No hay placeholders sin reemplazar
✓ AGENTS.md referencia skills
✓ Git tiene commits

✅ Proyecto listo para desarrollo
```

### Auto-Crear AGENTS.md

```bash
~/.opencode/bin/auto-create-agents-md.sh mi-proyecto

✓ AGENTS.md creado desde template
```

---

## 🔑 Principios Clave

### 1. Nunca Asumir

```
❌ "Esto probablemente significa..."
✅ "Los datos muestran que..."
```

### 2. Causa Raíz, No Síntomas

```
❌ "Voy a agregar un if para esquivar esto"
✅ "La causa raíz es X, voy a resolver aquí"
```

### 3. Contexto Completo

```
❌ "Error al procesar solicitud"
✅ "Marca requerida · Placa requerida"
```

### 4. Código Más Limpio

```
❌ "Hago funcionar, después limpio"
✅ "Esto quedará más limpio que antes"
```

### 5. Consistencia Global

```
❌ "Cada proyecto tiene su estándar"
✅ "Los 9 skills + protocolo senior en TODO lado"
```

---

## 📋 Checklist para Nuevo Dev

Cuando entras a un proyecto DOSA:

- [ ] Leí este README.md
- [ ] Leí AGENTS.md del proyecto
- [ ] Leí BEHAVIORAL_STANDARDS.md
- [ ] Leí TEAM_STANDARDS.md
- [ ] Entiendo carga inteligente de skills
- [ ] Sé qué esperar del entorno
- [ ] He clonado el repo
- [ ] Validé con: `validate-project.sh .`
- [ ] Ejecuté: `npm install` (o equivalente)
- [ ] Estoy listo para desarrollar

---

## 🚨 Troubleshooting

### ❓ AGENTS.md no existe

```bash
# Auto-crear desde template
~/.opencode/bin/auto-create-agents-md.sh .

# Personalizar según tu proyecto
vim AGENTS.md
```

### ❓ Skills no se cargan

```bash
# Verificar que ~/.opencode/skills/ tiene 9 carpetas
ls ~/.opencode/skills/

# Verificar config.json
cat ~/.opencode/config.json | jq '.intelligent_skill_loading'
```

### ❓ Validación falla

```bash
# Ver cuáles validaciones fallan
~/.opencode/bin/validate-project.sh .

# Arreglar issues específicos (AGENTS.md, git, etc)
```

---

## 📞 Soporte

Si algo no funciona:

1. Revisar BEHAVIORAL_STANDARDS.md
2. Revisar TEAM_STANDARDS.md
3. Ejecutar `validate-project.sh .`
4. Revisar config.json
5. Contactar al equipo con contexto claro

---

## 🔄 Versiones

Ver `CHANGELOG.md` para historial de cambios.

**Versión actual:** 1.0 (2026-03-08)

---

## 📄 Archivos Principales

| Archivo                   | Propósito                   |
| ------------------------- | --------------------------- |
| `config.json`             | Meta-configuración global   |
| `BEHAVIORAL_STANDARDS.md` | Protocolo de comportamiento |
| `TEAM_STANDARDS.md`       | Guía para el equipo         |
| `README.md`               | Este archivo                |
| `CHANGELOG.md`            | Historial de versiones      |

Cada proyecto además debe tener:
| Archivo | Propósito |
|---------|-----------|
| `AGENTS.md` | Reglas específicas del proyecto |
| `DEVELOPMENT_STANDARDS.md` | Estándares técnicos globales |
