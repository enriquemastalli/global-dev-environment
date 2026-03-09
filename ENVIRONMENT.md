# Global Development Environment

Este es el **Entorno Global de Desarrollo** — un sistema consistente y portable que aplica a **CUALQUIER proyecto**, sin importar el tipo, tecnología o equipo.

No es específico de DOSA. Es una configuración universal que:

- ✅ Se instala en 30 segundos
- ✅ Funciona en cualquier máquina
- ✅ Aplica a cualquier proyecto
- ✅ Trae 9 skills integrados
- ✅ Garantiza comportamiento consistente
- ✅ Es completamente exportable

## Instalación

```bash
curl -fsSL https://raw.githubusercontent.com/org/global-dev-environment/main/install.sh | bash
```

## Documentación

- **README.md** — Qué es y cómo funciona
- **INSTALL.md** — Instalación paso a paso
- **BEHAVIORAL_STANDARDS.md** — Protocolo de comportamiento
- **TEAM_STANDARDS.md** — Guía para el equipo
- **DEVELOPMENT_STANDARDS.md** — Estándares técnicos

## Para Cualquier Proyecto

```bash
# Validar proyecto
~/.opencode/bin/validate-project.sh /ruta/al/proyecto

# Crear AGENTS.md si no existe
~/.opencode/bin/auto-create-agents-md.sh /ruta/al/proyecto

# Verificar instalación
~/.opencode/bin/verify-installation.sh
```

Este es tu entorno. Úsalo en cualquier lado.
