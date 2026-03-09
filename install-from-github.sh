#!/bin/bash

# INSTALL-FROM-GITHUB.SH — Instalador remoto desde GitHub
# Uso: curl -fsSL https://raw.githubusercontent.com/enriquemastalli/global-dev-environment/main/install-from-github.sh | bash

set -e

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Global Development Environment — Instalador${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

REPO="enriquemastalli/global-dev-environment"
BRANCH="main"
BASE_URL="https://raw.githubusercontent.com/${REPO}/${BRANCH}"
TARGET_DIR="${1:-$HOME/.opencode}"

# Validaciones
echo -e "${BLUE}📋 Validando requisitos...${NC}"

if ! command -v bash &> /dev/null; then
  echo -e "${RED}✗ bash no está instalado${NC}"
  exit 1
fi
echo -e "${GREEN}✓ bash${NC}"

if ! command -v curl &> /dev/null; then
  echo -e "${RED}✗ curl no está instalado${NC}"
  exit 1
fi
echo -e "${GREEN}✓ curl${NC}"

echo ""
echo -e "${BLUE}📁 Directorio de instalación${NC}"
echo "   $TARGET_DIR"
echo ""

# Crear directorio
mkdir -p "$TARGET_DIR"
mkdir -p "$TARGET_DIR/bin"
mkdir -p "$TARGET_DIR/skills"

echo -e "${BLUE}📦 Descargando archivos...${NC}"

# Descargar archivos de configuración
for file in config.json BEHAVIORAL_STANDARDS.md TEAM_STANDARDS.md README.md CHANGELOG.md DEVELOPMENT_STANDARDS.md ENVIRONMENT.md QUICK_START.md installer.json; do
  if curl -fsSL "$BASE_URL/$file" -o "$TARGET_DIR/$file" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} $file"
  fi
done

# Descargar scripts
for script in install.sh export.sh; do
  if curl -fsSL "$BASE_URL/$script" -o "$TARGET_DIR/$script" 2>/dev/null; then
    chmod +x "$TARGET_DIR/$script"
    echo -e "${GREEN}✓${NC} $script"
  fi
done

# Descargar scripts en bin/
for script in validate-project.sh auto-create-agents-md.sh verify-installation.sh; do
  if curl -fsSL "$BASE_URL/bin/$script" -o "$TARGET_DIR/bin/$script" 2>/dev/null; then
    chmod +x "$TARGET_DIR/bin/$script"
    echo -e "${GREEN}✓${NC} bin/$script"
  fi
done

# Descargar skills
SKILLS="zero-patch-policy cognitive-responsibility strict-typescript-contract edge-performance-first saas-security-enforcer ui-state-guardian brand-i18n-guardian ai-genome-protocol senior-development-protocol"

echo -e "${BLUE}📚 Descargando skills...${NC}"
for skill in $SKILLS; do
  mkdir -p "$TARGET_DIR/skills/$skill"
  if curl -fsSL "$BASE_URL/skills/$skill/SKILL.md" -o "$TARGET_DIR/skills/$skill/SKILL.md" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} $skill"
  fi
done

echo ""
echo -e "${BLUE}✔ Validando instalación...${NC}"

# Verificar archivos clave
FILES_TO_CHECK=(
  "config.json"
  "BEHAVIORAL_STANDARDS.md"
  "README.md"
  "bin/validate-project.sh"
)

MISSING=0
for file in "${FILES_TO_CHECK[@]}"; do
  if [ -f "$TARGET_DIR/$file" ]; then
    echo -e "${GREEN}✓${NC} $file"
  else
    echo -e "${RED}✗${NC} $file"
    ((MISSING++))
  fi
done

echo ""

if [ "$MISSING" -eq 0 ]; then
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${GREEN}✅ Instalación completada${NC}"
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  echo -e "${BLUE}PRÓXIMOS PASOS:${NC}"
  echo ""
  echo "1. Lee la documentación:"
  echo "   cat $TARGET_DIR/README.md"
  echo ""
  echo "2. Verifica la instalación:"
  echo "   $TARGET_DIR/bin/verify-installation.sh"
  echo ""
  echo "3. Valida un proyecto:"
  echo "   $TARGET_DIR/bin/validate-project.sh /ruta/al/proyecto"
  echo ""
else
  echo -e "${RED}❌ Instalación incompleta (faltan $MISSING archivos)${NC}"
  exit 1
fi
