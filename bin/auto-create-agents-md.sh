#!/bin/bash

# AUTO-CREATE-AGENTS-MD.SH
# Crea automáticamente AGENTS.md en un proyecto si no existe

set -e

PROJECT_DIR="${1:-.}"
PROJECT_NAME=$(basename "$PROJECT_DIR")
TEMPLATE_SOURCE="$HOME/.opencode/templates/_shared/AGENTS.md.template"

if [ ! -d "$PROJECT_DIR" ]; then
  echo "❌ Directorio no existe: $PROJECT_DIR"
  exit 1
fi

if [ -f "$PROJECT_DIR/AGENTS.md" ]; then
  echo "✓ AGENTS.md ya existe en $PROJECT_NAME"
  exit 0
fi

if [ ! -f "$TEMPLATE_SOURCE" ]; then
  echo "⚠ Template no encontrado: $TEMPLATE_SOURCE"
  echo "  Creando AGENTS.md mínimo..."
  
  cat > "$PROJECT_DIR/AGENTS.md" << 'EOF'
# Reglas de Desarrollo — {{PROJECT_NAME}}

## Reglas Fundamentales

### 0. Inicio de Sesión — Verificación Obligatoria

1. Leer este archivo (AGENTS.md)
2. Ejecutar: git pull origin master
3. Verificar: git status

### 1. Skills Disponibles

Todos los proyectos cargan automáticamente:
- senior-development-protocol (SIEMPRE)
- 8 skills adicionales según contexto

Ver ~/.opencode/config.json para carga inteligente.

### 2. Comportamiento Global

Seguir BEHAVIORAL_STANDARDS.md de ~/.opencode/

Esto incluye:
- Debugging científico (nunca asumir)
- Error handling con contexto completo
- Code quality: causa raíz, nunca parches
- Checklist pre-acción (mental)

### 3. Referencia Rápida

- DEVELOPMENT_STANDARDS.md — Estándares técnicos
- BEHAVIORAL_STANDARDS.md — Protocolo de comportamiento
- TEAM_STANDARDS.md — Guía para el equipo

---

**Personaliza este archivo con reglas específicas de tu proyecto.**
EOF
  
  echo "✓ AGENTS.md mínimo creado en $PROJECT_NAME"
else
  # Reemplazar placeholders en template
  sed "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" "$TEMPLATE_SOURCE" > "$PROJECT_DIR/AGENTS.md"
  echo "✓ AGENTS.md creado desde template en $PROJECT_NAME"
fi

exit 0
