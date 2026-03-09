#!/bin/bash

# VERIFY-INSTALLATION.SH
# Verifica que la instalación se completó correctamente

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

OPENCODE_DIR="${1:-$HOME/.opencode}"
PASS=0
FAIL=0

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Verificador de Instalación — Global Development Environment${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [ ! -d "$OPENCODE_DIR" ]; then
  echo -e "${RED}✗ Directorio no existe: $OPENCODE_DIR${NC}"
  exit 1
fi

echo "Verificando en: $OPENCODE_DIR"
echo ""

# === CONFIGURACIÓN ===
echo -e "${BLUE}📋 Archivos de Configuración${NC}"

CONFIG_FILES=(
  "config.json"
  "BEHAVIORAL_STANDARDS.md"
  "TEAM_STANDARDS.md"
  "DEVELOPMENT_STANDARDS.md"
  "README.md"
  "CHANGELOG.md"
  "INSTALL.md"
)

for file in "${CONFIG_FILES[@]}"; do
  if [ -f "$OPENCODE_DIR/$file" ]; then
    SIZE=$(ls -lh "$OPENCODE_DIR/$file" | awk '{print $5}')
    echo -e "${GREEN}✓${NC} $file ($SIZE)"
    ((PASS++))
  else
    echo -e "${RED}✗${NC} $file"
    ((FAIL++))
  fi
done

echo ""

# === SCRIPTS ===
echo -e "${BLUE}🔧 Scripts Ejecutables${NC}"

SCRIPTS=(
  "bin/validate-project.sh"
  "bin/auto-create-agents-md.sh"
  "bin/verify-installation.sh"
)

for script in "${SCRIPTS[@]}"; do
  if [ -x "$OPENCODE_DIR/$script" ]; then
    echo -e "${GREEN}✓${NC} $script (executable)"
    ((PASS++))
  elif [ -f "$OPENCODE_DIR/$script" ]; then
    echo -e "${YELLOW}⚠${NC} $script (exists but not executable)"
    chmod +x "$OPENCODE_DIR/$script"
    echo -e "${GREEN}  → Fixed permisos${NC}"
    ((PASS++))
  else
    echo -e "${RED}✗${NC} $script"
    ((FAIL++))
  fi
done

echo ""

# === SKILLS ===
echo -e "${BLUE}🎯 Skills Integrados${NC}"

SKILLS=(
  "zero-patch-policy"
  "cognitive-responsibility"
  "strict-typescript-contract"
  "edge-performance-first"
  "saas-security-enforcer"
  "ui-state-guardian"
  "brand-i18n-guardian"
  "ai-genome-protocol"
  "senior-development-protocol"
)

SKILLS_FOUND=0
for skill in "${SKILLS[@]}"; do
  if [ -d "$OPENCODE_DIR/skills/$skill" ]; then
    echo -e "${GREEN}✓${NC} $skill"
    ((SKILLS_FOUND++))
  else
    echo -e "${YELLOW}⚠${NC} $skill (no encontrado, es opcional)"
  fi
done
echo "Encontrados: $SKILLS_FOUND/9 skills"
((PASS++))

echo ""

# === VALIDACIONES ===
echo -e "${BLUE}✔ Validaciones${NC}"

# Config.json válido
if command -v jq &> /dev/null; then
  if jq empty "$OPENCODE_DIR/config.json" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} config.json es JSON válido"
    ((PASS++))
  else
    echo -e "${RED}✗${NC} config.json JSON inválido"
    ((FAIL++))
  fi
else
  echo -e "${YELLOW}⚠${NC} config.json (jq no disponible para validación)"
fi

# BEHAVIORAL_STANDARDS.md tiene contenido
if grep -q "Behavioral Standards" "$OPENCODE_DIR/BEHAVIORAL_STANDARDS.md"; then
  echo -e "${GREEN}✓${NC} BEHAVIORAL_STANDARDS.md contiene contenido"
  ((PASS++))
else
  echo -e "${RED}✗${NC} BEHAVIORAL_STANDARDS.md vacío o corrupto"
  ((FAIL++))
fi

# README.md tiene contenido
if grep -q "opencode" "$OPENCODE_DIR/README.md"; then
  echo -e "${GREEN}✓${NC} README.md contiene contenido"
  ((PASS++))
else
  echo -e "${RED}✗${NC} README.md vacío o corrupto"
  ((FAIL++))
fi

echo ""

# === SYMLINKS ===
echo -e "${BLUE}🔗 Symlinks (Opcional)${NC}"

if [ -L "/usr/local/bin/dosa-validate" ]; then
  echo -e "${GREEN}✓${NC} /usr/local/bin/dosa-validate existe"
  ((PASS++))
else
  echo -e "${YELLOW}⚠${NC} /usr/local/bin/dosa-validate no configurado"
  echo "   Puedes crear con: sudo ln -s $OPENCODE_DIR/bin/validate-project.sh /usr/local/bin/dosa-validate"
fi

echo ""

# === REQUISITOS PREVIOS ===
echo -e "${BLUE}🛠 Requisitos Previos${NC}"

# Bash version
BASH_VERSION=$(bash --version | head -1)
if [[ $BASH_VERSION == *"version 4"* ]] || [[ $BASH_VERSION == *"version 5"* ]]; then
  echo -e "${GREEN}✓${NC} Bash 4+ ($BASH_VERSION)"
  ((PASS++))
else
  echo -e "${YELLOW}⚠${NC} Bash version: $BASH_VERSION (se recomienda 4+)"
fi

# Git
if command -v git &> /dev/null; then
  GIT_VERSION=$(git --version)
  echo -e "${GREEN}✓${NC} Git instalado ($GIT_VERSION)"
  ((PASS++))
else
  echo -e "${RED}✗${NC} Git NO instalado"
  ((FAIL++))
fi

# Node (opcional)
if command -v node &> /dev/null; then
  NODE_VERSION=$(node --version)
  echo -e "${GREEN}✓${NC} Node.js instalado ($NODE_VERSION)"
  ((PASS++))
else
  echo -e "${YELLOW}⚠${NC} Node.js no instalado (opcional)"
fi

echo ""

# === RESUMEN ===
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ "$FAIL" -eq 0 ]; then
  echo -e "${GREEN}✅ Instalación Verificada Exitosamente${NC}"
  echo ""
  echo -e "${BLUE}PRÓXIMOS PASOS:${NC}"
  echo ""
  echo "1. Lee la documentación:"
  echo "   cat $OPENCODE_DIR/README.md"
  echo ""
  echo "2. Valida un proyecto:"
  echo "   $OPENCODE_DIR/bin/validate-project.sh /ruta/al/proyecto"
  echo ""
  echo "3. Crea symlink global (opcional):"
  echo "   sudo ln -s $OPENCODE_DIR/bin/validate-project.sh /usr/local/bin/dosa-validate"
  echo ""
  exit 0
else
  echo -e "${RED}⚠ Instalación Incompleta${NC}"
  echo "Pasadas: $PASS"
  echo "Fallidas: $FAIL"
  echo ""
  echo "Intenta:"
  echo "1. Re-ejecutar el instalador"
  echo "2. Revisar permisos en $OPENCODE_DIR"
  echo "3. Verificar espacio en disco"
  echo ""
  exit 1
fi
