#!/bin/bash

# EXPORT.SH
# Exporta el Entorno Global de Desarrollo a un archivo para distribución
# Este entorno aplica a CUALQUIER proyecto

set -e

EXPORT_DIR="${1:-.}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
ARCHIVE_NAME="dosa-environment_$TIMESTAMP.tar.gz"
TEMP_DIR="/tmp/dosa-export-$TIMESTAMP"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Exportador — DOSA Development Environment${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Validar que estamos en .opencode
if [ ! -f "./install.sh" ] || [ ! -f "./config.json" ]; then
  echo -e "${RED}❌ Error: Este script debe ejecutarse desde ~/.opencode${NC}"
  echo "Uso: cd ~/.opencode && bash export.sh"
  exit 1
fi

echo -e "${BLUE}📦 Preparando exportación...${NC}"
echo ""

# Crear directorio temporal
mkdir -p "$TEMP_DIR/dosa-environment"

echo "Copiando archivos..."

# Archivos de configuración
cp config.json "$TEMP_DIR/dosa-environment/"
cp BEHAVIORAL_STANDARDS.md "$TEMP_DIR/dosa-environment/"
cp TEAM_STANDARDS.md "$TEMP_DIR/dosa-environment/"
cp DEVELOPMENT_STANDARDS.md "$TEMP_DIR/dosa-environment/"
cp README.md "$TEMP_DIR/dosa-environment/"
cp CHANGELOG.md "$TEMP_DIR/dosa-environment/"
cp INSTALL.md "$TEMP_DIR/dosa-environment/"
cp installer.json "$TEMP_DIR/dosa-environment/"

# Scripts
mkdir -p "$TEMP_DIR/dosa-environment/bin"
cp bin/validate-project.sh "$TEMP_DIR/dosa-environment/bin/"
cp bin/auto-create-agents-md.sh "$TEMP_DIR/dosa-environment/bin/"
cp bin/verify-installation.sh "$TEMP_DIR/dosa-environment/bin/"
cp install.sh "$TEMP_DIR/dosa-environment/"
cp export.sh "$TEMP_DIR/dosa-environment/"

# Skills
if [ -d "skills" ]; then
  mkdir -p "$TEMP_DIR/dosa-environment/skills"
  cp -r skills/* "$TEMP_DIR/dosa-environment/skills/" 2>/dev/null || true
fi

# Templates (si existen)
if [ -d "templates" ]; then
  mkdir -p "$TEMP_DIR/dosa-environment/templates"
  cp -r templates/* "$TEMP_DIR/dosa-environment/templates/" 2>/dev/null || true
fi

# Crear archivo .gitkeep para directorios vacíos
touch "$TEMP_DIR/dosa-environment/.gitkeep"

echo -e "${GREEN}✓ Archivos copiados${NC}"
echo ""

# Crear README para distribución
cat > "$TEMP_DIR/dosa-environment/DISTRIBUTION.md" << 'EOF'
# DOSA Development Environment — Distribución

Este es el paquete completo del entorno consistente global de desarrollo.

## Instalación

### Opción A: Automática

```bash
# Extraer
tar -xzf dosa-environment_*.tar.gz
cd dosa-environment

# Instalar
bash install.sh
```

### Opción B: Manual

```bash
# Extraer
tar -xzf dosa-environment_*.tar.gz

# Copiar a ~/.opencode/
cp -r dosa-environment ~/.opencode

# Hacer scripts ejecutables
chmod +x ~/.opencode/bin/*.sh
chmod +x ~/.opencode/*.sh

# Verificar
~/.opencode/bin/verify-installation.sh
```

## Contenido

- **config.json** — Meta-configuración
- **BEHAVIORAL_STANDARDS.md** — Protocolo de comportamiento
- **TEAM_STANDARDS.md** — Guía para el equipo
- **DEVELOPMENT_STANDARDS.md** — Estándares técnicos
- **README.md** — Resumen ejecutivo
- **INSTALL.md** — Guía de instalación completa
- **CHANGELOG.md** — Historial de versiones
- **bin/validate-project.sh** — Validador de proyectos
- **bin/auto-create-agents-md.sh** — Auto-crear AGENTS.md
- **bin/verify-installation.sh** — Verificar instalación
- **skills/** — 9 skills integrados
- **templates/** — Templates para nuevos proyectos

## Próximos Pasos

1. Instala siguiendo opción A o B arriba
2. Lee ~./opencode/README.md
3. Lee ~/.opencode/BEHAVIORAL_STANDARDS.md
4. Valida un proyecto: ~/.opencode/bin/validate-project.sh /ruta

## Versión

Ver CHANGELOG.md para versión y cambios.
EOF

echo -e "${BLUE}Creando archivo comprimido...${NC}"

# Crear tarball
cd "$TEMP_DIR"
tar -czf "$ARCHIVE_NAME" dosa-environment/

# Copiar a directorio de destino
cp "$ARCHIVE_NAME" "$EXPORT_DIR/"
ARCHIVE_PATH="$EXPORT_DIR/$ARCHIVE_NAME"

echo -e "${GREEN}✓ Archivo creado${NC}"
echo ""

# Crear checksum
echo -e "${BLUE}Generando checksum...${NC}"
cd "$EXPORT_DIR"
sha256sum "$ARCHIVE_NAME" > "$ARCHIVE_NAME.sha256"
echo -e "${GREEN}✓ Checksum generado${NC}"
echo ""

# Limpiar
rm -rf "$TEMP_DIR"

# Información final
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Exportación Completada${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Estadísticas
ARCHIVE_SIZE=$(ls -lh "$ARCHIVE_PATH" | awk '{print $5}')

echo -e "${BLUE}📊 Información de Distribución${NC}"
echo ""
echo "Archivo: $(basename $ARCHIVE_PATH)"
echo "Tamaño: $ARCHIVE_SIZE"
echo "Ubicación: $ARCHIVE_PATH"
echo "Checksum: $ARCHIVE_PATH.sha256"
echo ""

echo -e "${BLUE}📝 Próximos Pasos para Distribución${NC}"
echo ""
echo "1. Compartir archivo con el equipo:"
echo "   - Subir a GitHub Releases"
echo "   - Enviar por email"
echo "   - Compartir en Slack"
echo ""

echo "2. Instrucciones para el equipo:"
echo "   tar -xzf dosa-environment_*.tar.gz"
echo "   cd dosa-environment"
echo "   bash install.sh"
echo ""

echo "3. Verificar integridad:"
echo "   sha256sum -c dosa-environment_*.sha256"
echo ""

echo -e "${BLUE}💡 Distribución por Git${NC}"
echo ""
echo "Si quieres distribución más simple, sube a GitHub:"
echo ""
echo "  1. git init dosa-environment"
echo "  2. git add ."
echo "  3. git commit -m 'Initial release: DOSA environment v1.0'"
echo "  4. git remote add origin https://github.com/org/dosa-environment.git"
echo "  5. git push -u origin main"
echo ""
echo "Luego comparte con:"
echo "  curl -fsSL https://raw.githubusercontent.com/org/dosa-environment/main/install.sh | bash"
echo ""
