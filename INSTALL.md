# Instalación — Global Development Environment

Guía paso a paso para instalar el entorno universal en tu máquina.

---

## 🚀 Instalación Rápida (Recomendado)

### Opción 1: Instalación Remota desde GitHub

```bash
curl -fsSL https://raw.githubusercontent.com/org/dosa-environment/main/install.sh | bash
```

### Opción 2: Instalación Remota con wget

```bash
wget -qO- https://raw.githubusercontent.com/org/dosa-environment/main/install.sh | bash
```

### Opción 3: Instalación Local desde Repositorio Clonado

```bash
git clone https://github.com/org/dosa-environment.git
cd dosa-environment
bash install.sh
```

---

## 📋 Requisitos Previos

Antes de instalar, verifica que tienes:

```bash
# Bash 4.0+
bash --version

# Git
git --version

# Node.js (opcional pero recomendado)
node --version
```

### En macOS

```bash
# Si no tienes Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Instalar bash 4+ (macOS por defecto tiene bash 3)
brew install bash

# Instalar git
brew install git

# (Opcional) Instalar jq para validación JSON mejorada
brew install jq
```

### En Linux (Ubuntu/Debian)

```bash
sudo apt update
sudo apt install -y bash git jq

# (Opcional) Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
```

### En WSL (Windows Subsystem for Linux)

```bash
# Desde PowerShell como admin:
wsl --install

# Desde WSL terminal:
sudo apt update
sudo apt install -y bash git jq nodejs npm
```

---

## 🔧 Proceso de Instalación Detallado

### Paso 1: Ejecutar el Instalador

```bash
# Opción A: Remota (más simple)
curl -fsSL https://raw.githubusercontent.com/org/dosa-environment/main/install.sh | bash

# Opción B: Local (más control)
cd ~/Downloads
git clone https://github.com/org/dosa-environment.git
cd dosa-environment
bash install.sh
```

### Paso 2: El instalador te preguntará:

```
¿Deseas reemplazar archivos existentes? (s/n):
```

Responde `s` si es primera vez o si quieres actualizar.

### Paso 3: Espera a que se complete

```
✓ config.json
✓ BEHAVIORAL_STANDARDS.md
✓ TEAM_STANDARDS.md
✓ README.md
✓ CHANGELOG.md
✓ bin/validate-project.sh
✓ bin/auto-create-agents-md.sh
✓ 9 skills copiados

✅ Instalación completada exitosamente
```

---

## ✅ Validación Post-Instalación

### Verificar que todo está en su lugar

```bash
# Ver estructura instalada
ls -lh ~/.opencode/

# Validar scripts
~/.opencode/bin/validate-project.sh --help

# Ver skills disponibles
ls ~/.opencode/skills/
```

### Test en un Proyecto Existente

```bash
# Ir a un proyecto DOSA
cd ~/mi-proyecto

# Validar estructura
~/.opencode/bin/validate-project.sh .

# Debería mostrar:
# ✓ AGENTS.md existe
# ✓ Git inicializado
# ...
# ✅ Proyecto listo para desarrollo
```

---

## 📚 Próximos Pasos

Después de instalar:

### 1. Lee la Documentación

```bash
# Resumen ejecutivo
cat ~/.opencode/README.md

# Protocolo de comportamiento
cat ~/.opencode/BEHAVIORAL_STANDARDS.md

# Guía para el equipo
cat ~/.opencode/TEAM_STANDARDS.md
```

### 2. Configura Proyectos

```bash
# Para cada proyecto, verifica que tiene AGENTS.md
~/.opencode/bin/validate-project.sh /ruta/al/proyecto

# Si falta, créalo automáticamente
~/.opencode/bin/auto-create-agents-md.sh /ruta/al/proyecto
```

### 3. Usa en tu Flujo de Trabajo

```bash
# Cada sesión en un proyecto:
1. Lee AGENTS.md
2. Sistema carga skills automáticamente
3. Aplica protocolo senior (implícito)
4. Desarrolla normalmente
```

---

## 🔗 Crear Symlink Global (Opcional)

Para usar `dosa-validate` desde cualquier lado:

```bash
# Con sudo
sudo ln -s ~/.opencode/bin/validate-project.sh /usr/local/bin/dosa-validate

# Ahora puedes usar desde cualquier lado
dosa-validate /ruta/al/proyecto
```

---

## 🔄 Actualizar a Nueva Versión

Cuando hay nueva versión disponible:

### Opción A: Ejecutar instalador nuevamente

```bash
# Remota
curl -fsSL https://raw.githubusercontent.com/org/dosa-environment/main/install.sh | bash

# Local
git clone https://github.com/org/dosa-environment.git
cd dosa-environment
bash install.sh
```

El instalador preservará archivos personalizados en `AGENTS.md` locales.

### Opción B: Actualizar manualmente

```bash
# Ir al repositorio clonado
cd ~/dosa-environment

# Traer cambios
git pull origin main

# Copiar actualizaciones
cp config.json BEHAVIORAL_STANDARDS.md ~/.opencode/
cp bin/*.sh ~/.opencode/bin/
cp -r skills/* ~/.opencode/skills/
```

---

## 🚨 Troubleshooting

### ❌ "bash: command not found"

```bash
# Bash no está instalado o no en PATH
# Solución:
/bin/bash install.sh  # Ruta completa
```

### ❌ "Permission denied" en scripts

```bash
# Los scripts no tienen permiso de ejecución
# Solución:
chmod +x ~/.opencode/bin/*.sh
```

### ❌ "Could not create symlink" (sudo required)

```bash
# No tienes permisos para crear symlinks en /usr/local/bin
# Solución:
sudo ln -s ~/.opencode/bin/validate-project.sh /usr/local/bin/dosa-validate
```

### ❌ "Directory already exists" pero vacío

```bash
# El directorio existe pero está vacío, confunde al instalador
# Solución:
rm -rf ~/.opencode
curl -fsSL https://raw.githubusercontent.com/org/dosa-environment/main/install.sh | bash
```

### ❌ Scripts no funcionan después de instalar

```bash
# Probablemente falta bash 4+
# Solución:
bash --version  # Verifica versión
# Si es bash 3.x, instala versión más nueva

# macOS
brew install bash
```

---

## 📦 Contenido de Instalación

### Archivos Copiados

```
~/.opencode/
├── config.json                          (Meta-configuración)
├── BEHAVIORAL_STANDARDS.md              (Protocolo de comportamiento)
├── TEAM_STANDARDS.md                    (Guía para el equipo)
├── DEVELOPMENT_STANDARDS.md             (Estándares técnicos)
├── README.md                            (Resumen ejecutivo)
├── CHANGELOG.md                         (Historial de versiones)
├── installer.json                       (Metadatos de instalador)
├── bin/
│   ├── validate-project.sh              (Validar proyectos)
│   └── auto-create-agents-md.sh         (Auto-crear AGENTS.md)
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

### Tamaño Total

Aproximadamente **100-150 MB** (la mayoría son los skills, que son referencias).

---

## 👥 Instalación en Equipo

### Para Distribución en el Equipo

1. **Repositorio Compartido:**

   ```bash
   git clone https://github.com/org/dosa-environment.git
   # Compartir URL con el equipo
   ```

2. **Instrucciones para el Equipo:**

   ```
   Copia esto en tu terminal:
   curl -fsSL https://raw.githubusercontent.com/org/dosa-environment/main/install.sh | bash
   ```

3. **Documentación Centralizada:**
   - Todos leen README.md
   - Todos leen BEHAVIORAL_STANDARDS.md
   - Todos siguen el mismo protocolo

---

## 🔐 Seguridad

### Verificar Integridad del Script

```bash
# Descargar y verificar antes de ejecutar
curl -fsSL https://raw.githubusercontent.com/org/dosa-environment/main/install.sh -o /tmp/install.sh

# Revisar el contenido
cat /tmp/install.sh

# Si confías, ejecutar
bash /tmp/install.sh
```

### Permisos

El script solo:

- ✅ Copia archivos a `~/.opencode/`
- ✅ Crea symlinks en `/usr/local/bin/` (requiere sudo)
- ✅ NO modifica otros directorios
- ✅ NO instala dependencias globales

---

## ✨ Resumen

```
1. Ejecutar instalador:
   curl -fsSL https://raw.githubusercontent.com/org/dosa-environment/main/install.sh | bash

2. Validar instalación:
   ls ~/.opencode/

3. Leer documentación:
   cat ~/.opencode/README.md

4. Usar en proyectos:
   ~/.opencode/bin/validate-project.sh /ruta/al/proyecto

5. Comenzar a desarrollar con estándares senior integrados ✅
```

---

## 📞 Soporte

Si hay problemas con la instalación:

1. Verifica requisitos previos (bash 4+, git)
2. Lee esta documentación (INSTALL.md)
3. Revisa troubleshooting arriba
4. Abre issue en GitHub: https://github.com/org/dosa-environment/issues
5. Contacta al equipo
