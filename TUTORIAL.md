# Global Development Environment — Tutorial Completo

## 📚 Introducción

Este documento es un tutorial completo sobre el **Global Development Environment**, un sistema universal y portable que proporciona 9 skills integrados y protocolos de desarrollo senior para cualquier proyecto.

Este entorno fue diseñado para ser:

- **Universal**: Funciona con cualquier proyecto, equipo o lenguaje
- **Portable**: Instalación en 30 segundos con un comando
- **Distributable**: Se puede exportar y compartir fácilmente
- **Centralizado**: Toda la configuración en `~/.opencode/`
- **Actualizable**: Siempre sincronizado con `git pull origin main`

---

## 🚀 Inicio Rápido

### Instalación (30 segundos)

```bash
curl -fsSL https://raw.githubusercontent.com/enriquemastalli/global-dev-environment/main/install-from-github.sh | bash
```

### Verificar Instalación

```bash
~/.opencode/bin/verify-installation.sh
```

### Comenzar a Usar

```bash
# Leer documentación
cat ~/.opencode/README.md

# Validar un proyecto
~/.opencode/bin/validate-project.sh /ruta/a/tu/proyecto

# Ver todos los skills disponibles
ls ~/.opencode/skills/
```

---

## 📦 ¿Qué Se Instala?

### Ubicación

```
~/.opencode/
```

### Contenido

**Archivos de Documentación (8)**

- `README.md` — Documentación completa
- `BEHAVIORAL_STANDARDS.md` — Protocolo de comportamiento
- `DEVELOPMENT_STANDARDS.md` — Patrones técnicos
- `TEAM_STANDARDS.md` — Guías para equipos
- `QUICK_START.md` — Guía de 30 segundos
- `DISTRIBUTION.md` — Guía de distribución
- `CHANGELOG.md` — Historial de versiones
- `ENVIRONMENT.md` — Información del entorno

**Scripts de Instalación (3)**

- `install.sh` — Instalador local
- `install-from-github.sh` — Instalador remoto
- `export.sh` — Script para exportar/distribuir

**Herramientas de Utilidad (3 en `bin/`)**

- `validate-project.sh` — Valida estructura de proyecto
- `auto-create-agents-md.sh` — Auto-genera AGENTS.md
- `verify-installation.sh` — Verifica post-instalación

**Skills (9 directorios)**

- `zero-patch-policy/` — Siempre causa raíz, nunca parches
- `cognitive-responsibility/` — Max 30 líneas, máxima legibilidad
- `strict-typescript-contract/` — Tipado fullstack
- `edge-performance-first/` — Optimización Cloudflare Workers
- `saas-security-enforcer/` — Multi-tenant, JWT, webhooks
- `ui-state-guardian/` — Arquitectura React
- `brand-i18n-guardian/` — Marca y traducciones
- `ai-genome-protocol/` — Prompts del sistema, XML
- `senior-development-protocol/` — Debugging, error handling

**Configuración (2)**

- `config.json` — Meta-configuración (carga inteligente de skills)
- `installer.json` — Metadatos del instalador

**Total**: 28 archivos, 404 KB, ~30 segundos de descarga

---

## 🎯 Los 9 Skills Integrados

### 1. **zero-patch-policy**

> Siempre arregla la causa raíz, nunca apliques parches

**Cuándo usarlo**: Cuando arregles bugs o hagas cambios en lógica existente

**Principio clave**: Identificar por qué ocurrió el problema, no solo ocultarlo

**Ejemplo**:

```typescript
// ❌ PARCHE — solo oculta el error
if (error) return null;

// ✅ CAUSA RAÍZ — arregla el problema
const validated = schema.safeParse(input);
if (!validated.success) {
  return c.json({ error: "Validación fallida", details: validated.error }, 400);
}
```

### 2. **cognitive-responsibility**

> Mantén funciones bajo 30 líneas, prioriza legibilidad

**Cuándo usarlo**: Cuando escribas o refactorices código

**Principio clave**: El código debe ser autodocumentado, fácil de entender

**Ejemplo**:

```typescript
// ❌ DIFÍCIL DE LEER — 50+ líneas, lógica compleja
function processData(items, filters, options) {
  // 50 líneas de lógica mezclada
}

// ✅ COGNITIVAMENTE RESPONSABLE — pequeñas funciones claras
function filterByStatus(items, status) {
  /* 5 líneas */
}
function sortByDate(items, descending) {
  /* 3 líneas */
}
function formatOutput(items, format) {
  /* 4 líneas */
}
```

### 3. **strict-typescript-contract**

> Tipado completo fullstack, frontend + backend

**Cuándo usarlo**: Cuando cruces datos entre backend (Worker) y frontend (UI)

**Principio clave**: Los tipos deben validarse en runtime también

**Ejemplo**:

```typescript
// Frontend y Backend comparten el mismo tipo
export const CreateContractorSchema = z.object({
  name: z.string().min(2),
  email: z.string().email(),
  client_id: z.string().uuid().optional(),
});

export type CreateContractorRequest = z.infer<typeof CreateContractorSchema>;
```

### 4. **edge-performance-first**

> Optimización para Cloudflare Workers

**Cuándo usarlo**: Cuando escribas código backend para Workers

**Principio clave**: Responder rápido, minimizar latencia, usar D1 eficientemente

**Patrones D1 seguros**:

```typescript
// ✅ SEGURO — .all() siempre puede retornar undefined
const response = await db.prepare("SELECT ...").all<Row>();
const results = response?.results ?? [];

// ✅ SEGURO — .first() puede retornar null
const row = await db.prepare("SELECT ...").first<Row | null>();
if (!row) return c.json({ error: "No encontrado" }, 404);

// ✅ SEGURO — POST INSERT, construir en memoria
const created: Row = { id, ...data, created_at: now };
return c.json(created, 201);
```

### 5. **saas-security-enforcer**

> Multi-tenant, JWT, webhooks (Stripe)

**Cuándo usarlo**: Cuando escribas endpoints de API, manejes autenticación o webhooks

**Principio clave**: Validar siempre, nunca confiar en datos del cliente

**Ejemplo**:

```typescript
// ✅ SEGURO — Validar JWT y tenant_id
async function getContractors(c: Context) {
  const user = await validateJWT(c);
  if (!user) return c.json({ error: "Unauthorized" }, 401);

  const contractors = await c.env.DB.prepare(
    "SELECT * FROM contractors WHERE tenant_id = ? AND deleted_at IS NULL",
  )
    .bind(user.tenant_id)
    .all();

  return c.json(contractors);
}
```

### 6. **ui-state-guardian**

> Arquitectura React, manejo de estado, CSS

**Cuándo usarlo**: Cuando crees o modifiques componentes React

**Principio clave**: Estado claro, componentes pequeños, gestión centralizada

**Ejemplo**:

```typescript
// ✅ COMPONENTE CLARO — Responsabilidad única
function ContractorForm({ onSubmit }: { onSubmit: (data: Contractor) => void }) {
  const [formData, setFormData] = useState<Partial<Contractor>>({});
  const [errors, setErrors] = useState<Record<string, string>>({});

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    // Validar, enviar, manejar errores
  };

  return <form onSubmit={handleSubmit}>...</form>;
}
```

### 7. **brand-i18n-guardian**

> Marca unificada, traducciones, localización

**Cuándo usarlo**: Cuando agregues textos a la UI, notificaciones de error, o modifiques idiomas

**Principio clave**: Consistencia visual y textual en todas partes

**Ejemplo**:

```typescript
// ✅ CENTRALIZADO — Todos los textos en un lugar
const i18n = {
  es: {
    contractor: {
      create_success: "Contratista creado exitosamente",
      create_error: "Error al crear contratista",
      delete_confirm: "¿Estás seguro de que deseas eliminar este contratista?",
    },
  },
  en: {
    contractor: {
      create_success: "Contractor created successfully",
      create_error: "Error creating contractor",
      delete_confirm: "Are you sure you want to delete this contractor?",
    },
  },
};
```

### 8. **ai-genome-protocol**

> Prompts del sistema, estructura XML, integración LLM

**Cuándo usarlo**: Cuando modifiques prompts del sistema, manejo de IA, o archivos XML

**Principio clave**: Prompts claros, bien estructurados, versionados

**Ejemplo**:

```xml
<!-- ✅ BIEN ESTRUCTURADO -->
<prompt>
  <role>Senior Developer Architect</role>
  <context>
    <project>DOSA</project>
    <language>TypeScript</language>
  </context>
  <instructions>
    <instruction priority="critical">Always fix root cause, never apply patches</instruction>
    <instruction>Keep functions under 30 lines</instruction>
  </instructions>
</prompt>
```

### 9. **senior-development-protocol**

> Debugging científico, error handling, calidad de código

**Cuándo usarlo**: SIEMPRE (se carga automáticamente)

**Principio clave**: Antes de proponer cualquier fix, verifica en este orden obligatorio

**Checklist de Debugging Obligatorio**:

```
1. ¿Hay validación en el FRONTEND que bloquea el envío?
2. ¿El REQUEST se envía? (Network tab del navegador)
3. ¿Qué DATOS exactos se envían? (Request body)
4. ¿Qué RESPONDE el servidor? (Response body completo)
5. ¿El frontend MUESTRA los detalles del error o los descarta?
```

---

## 📋 Carga Inteligente de Skills

El sistema carga automáticamente los skills apropiados según el contexto:

### Backend / API / Base de Datos

```
→ edge-performance-first
→ saas-security-enforcer
```

Aplica cuando edites:

- Endpoints de API
- Handlers de Cloudflare Workers
- Consultas a D1
- Lógica de autenticación

### Frontend / React / CSS

```
→ ui-state-guardian
→ brand-i18n-guardian
```

Aplica cuando edites:

- Componentes React
- Estilos CSS / Tailwind
- Formularios
- Páginas completas

### Edición de Código (SIEMPRE)

```
→ zero-patch-policy
→ cognitive-responsibility
```

Aplica a cualquier cambio de código:

- Bug fixes
- Refactorización
- Nuevas features
- Mejoras

### IA / Prompts / XML

```
→ ai-genome-protocol
```

Aplica cuando edites:

- Prompts del sistema
- Archivos XML
- Configuración de LLM

### SIEMPRE Cargado

```
→ senior-development-protocol
```

El protocolo de desarrollo senior está SIEMPRE activo, independientemente del contexto.

---

## 🛠️ Herramientas Disponibles

### Validar un Proyecto

```bash
~/.opencode/bin/validate-project.sh /ruta/al/proyecto
```

**Verifica:**

- Estructura de proyecto
- Archivos requeridos
- Repositorio Git
- Dependencias

### Auto-generar AGENTS.md

```bash
~/.opencode/bin/auto-create-agents-md.sh /ruta/al/proyecto
```

**Genera automáticamente:**

- Referencias a todos los skills
- Protocolos aplicables
- Pautas de desarrollo
- Estándares del equipo

### Verificar Instalación

```bash
~/.opencode/bin/verify-installation.sh
```

**Verifica:**

- Todos los archivos están presentes
- Todos los skills están descargados
- Permisos correctos
- Configuración completa

### Exportar para Distribución

```bash
~/.opencode/export.sh
```

**Crea:**

- `dosa-environment_TIMESTAMP.tar.gz` (comprimido)
- `dosa-environment_TIMESTAMP.tar.gz.sha256` (checksum)
- Listo para compartir con equipos

---

## 🔧 Estándares de Desarrollo Core

### Error Handling Architecture

**Backend siempre retorna detalles:**

```typescript
return c.json(
  {
    error: "Datos inválidos",
    details: parsed.error.format(),
  },
  400,
);
```

**Cliente preserva detalles:**

```typescript
class ApiError extends Error {
  constructor(
    public error: string,
    public details: any,
  ) {
    super(error);
  }
}
```

**UI muestra errores específicos:**

```typescript
{errors.email && <span className="text-error">{errors.email}</span>}
{errors.name && <span className="text-error">{errors.name}</span>}
```

### Validación Dinámica en Schemas

```typescript
// ❌ MAL — Validación dinámica en build-time
anio: z.number().max(new Date().getFullYear() + 1);

// ✅ BIEN — Validación dinámica en runtime
anio: z.number().refine(
  (val) => val <= new Date().getFullYear() + 1,
  "El año no puede ser mayor al próximo año",
);
```

### Patrones D1 Seguros

```typescript
// .all() — Nunca asumir que results existe
const response = await db.prepare("SELECT ...").all<Row>();
const results = response?.results ?? [];

// .first() — Siempre verificar null
const row = await db.prepare("SELECT ...").first<Row | null>();
if (!row) return c.json({ error: "No encontrado" }, 404);

// POST INSERT — Responder con datos en memoria
const created: Row = { id, ...data, created_at: now, updated_at: now };
return c.json(created, 201);

// Auditoría — Fire-and-forget, no bloquea respuesta
db.prepare("INSERT INTO audit_logs ...")
  .run()
  .catch((err) => console.error("[audit]", err));
```

---

## 📖 Documentación Disponible

Después de instalar, tienes acceso a:

```bash
# Resumen ejecutivo
cat ~/.opencode/README.md

# Protocolo de comportamiento
cat ~/.opencode/BEHAVIORAL_STANDARDS.md

# Patrones técnicos
cat ~/.opencode/DEVELOPMENT_STANDARDS.md

# Guías para equipos
cat ~/.opencode/TEAM_STANDARDS.md

# Guía rápida (30 segundos)
cat ~/.opencode/QUICK_START.md

# Guía de distribución
cat ~/.opencode/DISTRIBUTION.md

# Meta-configuración
cat ~/.opencode/config.json
```

---

## 🌐 Repository GitHub

**URL Principal:**

```
https://github.com/enriquemastalli/global-dev-environment
```

**Release v1.0:**

```
https://github.com/enriquemastalli/global-dev-environment/releases/tag/v1.0
```

**Instalador Remoto:**

```
https://raw.githubusercontent.com/enriquemastalli/global-dev-environment/main/install-from-github.sh
```

---

## 👥 Para Equipos

### Distribuir a tu Equipo

1. **Comparte el enlace del repositorio:**

   ```
   https://github.com/enriquemastalli/global-dev-environment
   ```

2. **Todos corren un comando:**

   ```bash
   curl -fsSL https://raw.githubusercontent.com/enriquemastalli/global-dev-environment/main/install-from-github.sh | bash
   ```

3. **Verifican instalación:**

   ```bash
   ~/.opencode/bin/verify-installation.sh
   ```

4. **Leen documentación:**
   ```bash
   cat ~/.opencode/README.md
   ```

**Resultado:** Todos tienen el mismo entorno, los mismos skills, los mismos estándares.

---

## 🔄 Mantener Actualizado

### Actualizar a la Última Versión

```bash
cd ~/.opencode
git pull origin main
```

### O Re-ejecutar Instalador

```bash
curl -fsSL https://raw.githubusercontent.com/enriquemastalli/global-dev-environment/main/install-from-github.sh | bash
```

(Te pedirá confirmación para reemplazar archivos)

---

## 🚨 Solucionar Problemas

### Instalación Falla

**Solución 1 — Clonar Repositorio:**

```bash
git clone https://github.com/enriquemastalli/global-dev-environment.git
cd global-dev-environment
bash install.sh
```

**Solución 2 — Verificar Conexión:**

```bash
# Verificar que curl funciona
curl -I https://raw.githubusercontent.com/enriquemastalli/global-dev-environment/main/README.md
```

### Skills No Aparecen

```bash
# Verificar que están instalados
ls ~/.opencode/skills/

# Reinstalar específicamente
curl -fsSL https://raw.githubusercontent.com/enriquemastalli/global-dev-environment/main/install-from-github.sh | bash
```

### Permisos Denegados

```bash
# Hacer scripts ejecutables
chmod +x ~/.opencode/bin/*.sh
chmod +x ~/.opencode/*.sh
```

### Verificar Instalación Completa

```bash
~/.opencode/bin/verify-installation.sh
```

---

## 📊 Métricas de Éxito

Después de instalar, deberías poder:

✅ Instalar en menos de 30 segundos  
✅ Verificar instalación con `verify-installation.sh`  
✅ Acceder a todos los 9 skills automáticamente  
✅ Validar proyectos con `validate-project.sh`  
✅ Auto-generar AGENTS.md con `auto-create-agents-md.sh`  
✅ Leer documentación completa en `~/.opencode/`  
✅ Exportar entorno para compartir offline  
✅ Mantenerte sincronizado con `git pull`

---

## 🎓 Casos de Uso

### Caso 1: Desarrollador Individual

```bash
# Instalar entorno
curl -fsSL https://raw.githubusercontent.com/enriquemastalli/global-dev-environment/main/install-from-github.sh | bash

# Comenzar nuevo proyecto
mkdir mi-proyecto
cd mi-proyecto
git init

# Generar AGENTS.md automáticamente
~/.opencode/bin/auto-create-agents-md.sh .

# Leer guías
cat ~/.opencode/BEHAVIORAL_STANDARDS.md

# Comenzar a desarrollar con skills integrados
```

### Caso 2: Equipo de Desarrollo

```bash
# Líder técnico instala
curl -fsSL ... | bash

# Comparte con el equipo
# → "Todos corran este comando:
#   curl -fsSL ... | bash"

# Todos tienen mismos estándares, mismos skills

# En nuevos proyectos:
~/.opencode/bin/auto-create-agents-md.sh /proyecto
```

### Caso 3: Migración a un Nuevo Equipo

```bash
# Exportar entorno actual
~/.opencode/export.sh

# Compartir archivo .tar.gz

# Nuevo equipo extrae
tar -xzf dosa-environment_*.tar.gz -C ~/

# Mismo entorno, mismos estándares
```

### Caso 4: Integración en Docker

```dockerfile
FROM node:18-alpine

# Instalar entorno global
RUN curl -fsSL https://raw.githubusercontent.com/enriquemastalli/global-dev-environment/main/install-from-github.sh | bash

# Agregar a PATH si es necesario
ENV PATH="$HOME/.opencode/bin:$PATH"

# Copiar proyecto
COPY . /app
WORKDIR /app

# Validar proyecto
RUN /root/.opencode/bin/validate-project.sh .

# Continuar con build
RUN npm install && npm run build
```

---

## 📝 Conclusión

El **Global Development Environment** es un sistema universal, portable y bien documentado que proporciona:

- **9 skills integrados** con protocolos claros
- **4 protocolos core** (Behavioral, Development, Team, Senior)
- **Installation system** (local, remoto, tarball, docker)
- **Complete documentation** (8+ guías)
- **GitHub repository** con releases

**Objetivo**: Que cualquier equipo, en cualquier proyecto, pueda instalar en 30 segundos un entorno de desarrollo completo con estándares senior y protocolos probados.

---

## 🚀 Comienza Ahora

```bash
curl -fsSL https://raw.githubusercontent.com/enriquemastalli/global-dev-environment/main/install-from-github.sh | bash
```

¡Listo! Ya tienes todo lo que necesitas.

---

**Última actualización:** 2026-03-08  
**Versión:** v1.0  
**Mantenedor:** https://github.com/enriquemastalli/global-dev-environment
