#!/bin/bash

# INSTALL.SH — Instalador del Entorno Global de Desarrollo

# Este es un entorno universal que aplica a CUALQUIER proyecto, no solo DOSA
# 
# Uso:
#   curl -fsSL https://raw.githubusercontent.com/org/dosa-environment/main/install.sh | bash
#   o
#   bash install.sh
#
# Este script copia la configuración global a ~/.opencode/ de otro usuario

set -e

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Instalador: Entorno Consistente Global DOSA${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Detectar fuente del script
if [ -d ".opencode" ] && [ -f ".opencode/install.sh" ]; then
  INSTALL_SOURCE="."
  echo -e "${YELLOW}Modo: Instalación desde repositorio local${NC}"
elif [ -d "~/.opencode" ]; then
  INSTALL_SOURCE="$HOME/.opencode"
  echo -e "${YELLOW}Modo: Instalación desde directorio existente${NC}"
else
  echo -e "${RED}❌ Error: No se encontró fuente de instalación${NC}"
  echo "   Clona el repo o ejecuta desde la carpeta .opencode"
  exit 1
fi

echo "Fuente: $INSTALL_SOURCE"
echo ""

# Validaciones previas
echo -e "${BLUE}📋 Validando requisitos...${NC}"

# Bash
if ! command -v bash &> /dev/null; then
  echo -e "${RED}✗ bash no está instalado${NC}"
  exit 1
fi
echo -e "${GREEN}✓ bash${NC}"

# Git
if ! command -v git &> /dev/null; then
  echo -e "${RED}✗ git no está instalado${NC}"
  exit 1
fi
echo -e "${GREEN}✓ git${NC}"

# Node (opcional pero recomendado)
if command -v node &> /dev/null; then
  echo -e "${GREEN}✓ node${NC}"
else
  echo -e "${YELLOW}⚠ node no está instalado (opcional)${NC}"
fi

echo ""

# Detectar directorio de instalación
TARGET_DIR="${1:-$HOME/.opencode}"

echo -e "${BLUE}📁 Directorio de instalación${NC}"
echo "   $TARGET_DIR"
echo ""

# Si ya existe, preguntar
if [ -d "$TARGET_DIR" ] && [ "$(ls -A $TARGET_DIR)" ]; then
  echo -e "${YELLOW}⚠ Directorio ya existe y tiene archivos${NC}"
  read -p "¿Deseas reemplazarlos? (s/n): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    echo -e "${YELLOW}Instalación cancelada${NC}"
    exit 0
  fi
fi

# Crear directorio
mkdir -p "$TARGET_DIR"
mkdir -p "$TARGET_DIR/bin"
mkdir -p "$TARGET_DIR/skills"

echo -e "${BLUE}📦 Copiando archivos...${NC}"

# Copiar archivos de configuración
for file in config.json BEHAVIORAL_STANDARDS.md TEAM_STANDARDS.md README.md CHANGELOG.md installer.json; do
  if [ -f "$INSTALL_SOURCE/$file" ]; then
    cp "$INSTALL_SOURCE/$file" "$TARGET_DIR/$file"
    echo -e "${GREEN}✓${NC} $file"
  fi
done

# Copiar scripts
for script in bin/validate-project.sh bin/auto-create-agents-md.sh; do
  if [ -f "$INSTALL_SOURCE/$script" ]; then
    cp "$INSTALL_SOURCE/$script" "$TARGET_DIR/$script"
    chmod +x "$TARGET_DIR/$script"
    echo -e "${GREEN}✓${NC} $script"
  fi
done

# Copiar skills (si existen)
if [ -d "$INSTALL_SOURCE/skills" ]; then
  cp -r "$INSTALL_SOURCE/skills"/* "$TARGET_DIR/skills/" 2>/dev/null || true
  echo -e "${GREEN}✓${NC} 9 skills copiados"
fi

echo ""

# Crear symlinks útiles
echo -e "${BLUE}🔗 Creando symlinks...${NC}"

# Symlink global para validate-project
if [ ! -L "/usr/local/bin/dosa-validate" ]; then
  if sudo ln -s "$TARGET_DIR/bin/validate-project.sh" /usr/local/bin/dosa-validate 2>/dev/null; then
    echo -e "${GREEN}✓${NC} /usr/local/bin/dosa-validate"
  else
    echo -e "${YELLOW}⚠${NC} No se pudo crear symlink global (requiere sudo)"
    echo "   Usa manualmente: $TARGET_DIR/bin/validate-project.sh"
  fi
fi

echo ""

# Validación post-instalación
echo -e "${BLUE}✔ Validando instalación...${NC}"

# Verificar archivos clave
FILES_TO_CHECK=(
  "config.json"
  "BEHAVIORAL_STANDARDS.md"
  "TEAM_STANDARDS.md"
  "README.md"
  "bin/validate-project.sh"
  "bin/auto-create-agents-md.sh"
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
  echo -e "${GREEN}✅ Instalación completada exitosamente${NC}"
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  echo -e "${BLUE}PRÓXIMOS PASOS:${NC}"
  echo ""
  echo "1. Lee la documentación:"
  echo "   cat $TARGET_DIR/README.md"
  echo ""
  echo "2. Valida un proyecto:"
  echo "   $TARGET_DIR/bin/validate-project.sh /ruta/al/proyecto"
  echo ""
  echo "3. Verifica que los skills están disponibles:"
  echo "   ls $TARGET_DIR/skills/"
  echo ""
  echo -e "${BLUE}Documentación:${NC}"
  echo "   - README.md → Resumen ejecutivo"
  echo "   - BEHAVIORAL_STANDARDS.md → Protocolo de comportamiento"
  echo "   - TEAM_STANDARDS.md → Guía para el equipo"
  echo "   - config.json → Meta-configuración"
  echo ""
else
  echo -e "${RED}❌ Instalación incompleta (faltan $MISSING archivos)${NC}"
  exit 1
fi
