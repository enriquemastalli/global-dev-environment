#!/bin/bash

# VALIDATE-PROJECT.SH
# Valida que un proyecto cumple con estándares DOSA

PROJECT_DIR="${1:-.}"
PROJECT_NAME=$(basename "$PROJECT_DIR")

echo "🔍 Validando proyecto: $PROJECT_NAME"
echo ""

# Contador de validaciones
PASS=0
FAIL=0

# Validación 1: AGENTS.md existe
if [ -f "$PROJECT_DIR/AGENTS.md" ]; then
  echo "✓ AGENTS.md existe"
  ((PASS++))
else
  echo "✗ AGENTS.md NO existe"
  ((FAIL++))
fi

# Validación 2: Git inicializado
if [ -d "$PROJECT_DIR/.git" ]; then
  echo "✓ Git inicializado"
  ((PASS++))
else
  echo "✗ Git NO inicializado"
  ((FAIL++))
fi

# Validación 3: DEVELOPMENT_STANDARDS.md existe (opcional pero bueno tener)
if [ -f "$PROJECT_DIR/DEVELOPMENT_STANDARDS.md" ]; then
  echo "✓ DEVELOPMENT_STANDARDS.md existe"
  ((PASS++))
else
  echo "⚠ DEVELOPMENT_STANDARDS.md no encontrado (opcional)"
fi

# Validación 4: package.json bien formado
if [ -f "$PROJECT_DIR/package.json" ]; then
  if command -v jq &> /dev/null; then
    if jq empty "$PROJECT_DIR/package.json" 2>/dev/null; then
      echo "✓ package.json válido"
      ((PASS++))
    else
      echo "✗ package.json NO es JSON válido"
      ((FAIL++))
    fi
  else
    echo "✓ package.json presente (jq no disponible para validación)"
    ((PASS++))
  fi
else
  echo "⚠ package.json no encontrado (opcional)"
fi

# Validación 5: .gitignore presente
if [ -f "$PROJECT_DIR/.gitignore" ]; then
  echo "✓ .gitignore presente"
  ((PASS++))
else
  echo "⚠ .gitignore no encontrado (recomendado crear)"
fi

# Validación 6: No hay placeholders sin reemplazar en AGENTS.md
if [ -f "$PROJECT_DIR/AGENTS.md" ]; then
  if grep -q "{{" "$PROJECT_DIR/AGENTS.md" 2>/dev/null; then
    echo "✗ AGENTS.md tiene placeholders sin reemplazar"
    ((FAIL++))
  else
    echo "✓ AGENTS.md no tiene placeholders"
    ((PASS++))
  fi
fi

# Validación 7: AGENTS.md tiene referencias a los 9 skills (al menos 5)
if [ -f "$PROJECT_DIR/AGENTS.md" ]; then
  SKILLS_FOUND=0
  
  grep -q "zero-patch-policy" "$PROJECT_DIR/AGENTS.md" && ((SKILLS_FOUND++))
  grep -q "cognitive-responsibility" "$PROJECT_DIR/AGENTS.md" && ((SKILLS_FOUND++))
  grep -q "strict-typescript-contract" "$PROJECT_DIR/AGENTS.md" && ((SKILLS_FOUND++))
  grep -q "edge-performance-first" "$PROJECT_DIR/AGENTS.md" && ((SKILLS_FOUND++))
  grep -q "saas-security-enforcer" "$PROJECT_DIR/AGENTS.md" && ((SKILLS_FOUND++))
  grep -q "ui-state-guardian" "$PROJECT_DIR/AGENTS.md" && ((SKILLS_FOUND++))
  grep -q "brand-i18n-guardian" "$PROJECT_DIR/AGENTS.md" && ((SKILLS_FOUND++))
  grep -q "ai-genome-protocol" "$PROJECT_DIR/AGENTS.md" && ((SKILLS_FOUND++))
  grep -q "senior-development-protocol" "$PROJECT_DIR/AGENTS.md" && ((SKILLS_FOUND++))
  
  if [ "$SKILLS_FOUND" -ge 5 ]; then
    echo "✓ AGENTS.md referencia skills ($SKILLS_FOUND/9)"
    ((PASS++))
  else
    echo "⚠ AGENTS.md solo referencia $SKILLS_FOUND/9 skills"
  fi
fi

# Validación 8: Git tiene commits
if [ -d "$PROJECT_DIR/.git" ]; then
  COMMIT_COUNT=$(cd "$PROJECT_DIR" && git rev-list --count HEAD 2>/dev/null || echo "0")
  if [ "$COMMIT_COUNT" -gt 0 ]; then
    echo "✓ Git tiene commits ($COMMIT_COUNT)"
    ((PASS++))
  else
    echo "⚠ Git no tiene commits aún"
  fi
fi

# Resumen
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Validaciones: $PASS pasadas"
if [ "$FAIL" -gt 0 ]; then
  echo "             $FAIL CRÍTICAS FALLIDAS"
  echo ""
  echo "❌ Proyecto NO está listo"
  exit 1
else
  echo ""
  echo "✅ Proyecto listo para desarrollo"
  exit 0
fi
