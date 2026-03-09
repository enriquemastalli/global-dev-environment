# Behavioral Standards — Entorno Consistente Global

Protocolo de comportamiento que aplica a **TODA sesión**, **TODO proyecto**, **TODO desarrollador**.

Define cómo trabajo sin importar el contexto.

---

## 1. Sesión Inicio — Protocolo Obligatorio

Cada sesión:

```
1. ¿Estoy en un proyecto con AGENTS.md?
   → Sí:  Leer AGENTS.md
   → No:  Crear AGENTS.md desde template

2. SIEMPRE cargar: senior-development-protocol

3. Detectar contexto de la tarea:
   - ¿Backend/API/DB? → Cargar: edge-performance-first + saas-security-enforcer
   - ¿Frontend/React? → Cargar: ui-state-guardian + brand-i18n-guardian
   - ¿Editar código? → Cargar: zero-patch-policy + cognitive-responsibility
   - ¿IA/Prompts? → Cargar: ai-genome-protocol

   → Notificar: "Cargué X, Y, Z skills"

4. Aplica: este archivo (BEHAVIORAL_STANDARDS.md)
```

---

## 2. Pre-Acción Checklist — Mental, Implícito

Antes de cualquier cambio de código, fix, o commit:

```
CHECKLIST MENTAL (no pido confirmación, es implícito):

☐ ¿Los datos son REALES verificados, no asumidos?
  → Si no, investigar más (Network tab, Console, código real)

☐ ¿La causa raíz está 100% clara con evidencia?
  → Si no, orden de debugging científico (ver sección 3)

☐ ¿El error propaga contexto completo al usuario?
  → Si no, ApiError con details (ver DEVELOPMENT_STANDARDS.md)

☐ ¿El fix es permanente o es un band-aid?
  → Si es parche, reescribir desde causa raíz

☐ ¿Código queda más limpio que antes?
  → Regla del Boy Scout siempre

☐ ¿Todas las validaciones dinámicas usan .refine()?
  → Si hay .max() con expresiones dinámicas, cambiar a .refine()

Si ALGUNO es ❌ → DETENER y investigar/preguntar antes de proceder.
```

---

## 3. Debugging — Orden Obligatorio, Nunca Asumir

Cuando hay un problema, orden científico:

```
PASO 1: ¿Hay validación frontend que bloquea?
├─ HTML5 required
├─ JavaScript local
├─ Zod client-side
└─ Si la hay → verificar qué está bloqueando

PASO 2: ¿El request se envía? (Network tab)
├─ ¿Status correcto (200/400/500)?
├─ ¿Headers correctos?
└─ Si no se envía → problema es frontend puro

PASO 3: ¿Qué datos EXACTOS se envían? (Request body)
├─ Ver JSON del body
├─ Comparar con schema esperado
└─ NO asumir, VER datos reales

PASO 4: ¿Qué responde el servidor? (Response body completo)
├─ Status code
├─ Error message
├─ Details (si los hay)
└─ VER respuesta completa, no solo el status

PASO 5: ¿El frontend muestra los detalles del error?
├─ ¿Muestra error genérico?
├─ ¿Muestra detalles por campo?
└─ ¿O descarta los detalles?

→ CONCLUSIÓN: Con evidencia 100% clara, proponer fix
```

**Frases prohibidas:**

- ❌ "Esto probablemente significa..."
- ❌ "Asumo que el error es..."
- ❌ "Creo que debería ser..."

**Frases correctas:**

- ✅ "Los datos muestran que..."
- ✅ "Verifiqué en el código y confirmo que..."
- ✅ "La causa raíz es... porque [evidencia]"

---

## 4. Error Handling — Siempre Contexto Completo

### Backend (Hono + D1)

```typescript
// SIEMPRE incluir details en errores 400+
if (!parsed.success) {
  return c.json(
    { error: "Datos inválidos", details: parsed.error.format() },
    400,
  );
}

// Validación en D1
const row = await db.prepare("SELECT ...").first<Row | null>();
if (!row) return c.json({ error: "No encontrado" }, 404);

// Queries D1: nunca asumir results
const response = await db.prepare("SELECT ...").all<Row>();
const results = response?.results ?? [];
```

### Cliente (Frontend)

```typescript
// ApiError preserva details
export class ApiError extends Error {
  details?: Record<string, unknown>;
  constructor(message: string, details?: Record<string, unknown>) {
    super(message);
    this.details = details;
  }
}

// Catch en formularios: extraer y mostrar detalles específicos
} catch (err: unknown) {
  if (err instanceof ApiError && err.details) {
    const fieldErrors = Object.entries(err.details)
      .flatMap(([, v]) => (v as { _errors?: string[] })?._errors ?? [])
      .filter(Boolean);
    setFormError(fieldErrors.length > 0 ? fieldErrors.join(" · ") : err.message);
  } else {
    setFormError(err instanceof Error ? err.message : "Error desconocido");
  }
}
```

---

## 5. Code Quality — Zero Band-Aids Ever

### Prohibido

```typescript
// ❌ Parche: agregar bloque al final para esquivar un bug
if (edge_case) {
  // arreglo rápido
}

// ❌ Non-null assertion que oculta el verdadero problema
return toPolicy(updated!);

// ❌ try-catch sin contexto
try { ... } catch { return c.json({ error: "Error" }, 500); }
```

### Correcto

```typescript
// ✅ Causa raíz identificada y resuelta
const updated = await db.prepare(...).first<Row | null>();
if (!updated) return c.json({ error: "Política no encontrada" }, 404);
return c.json(toPolicy(updated));

// ✅ Construir respuesta sin depender de SELECT post-insert
const created: Row = { id, ...data, created_at: now, updated_at: now };
return c.json(created, 201);

// ✅ Try-catch con contexto
} catch (error) {
  console.error("[endpoint POST]", error);
  return c.json({ error: "Error al crear recurso" }, 500);
}
```

### Regla del Boy Scout

Cada archivo que edito queda más limpio que antes:

- ✅ Tipos corregidos
- ✅ Imports sin usar eliminados
- ✅ Variables innecesarias removidas
- ✅ Comentarios mejorados
- ✅ Código simplificado

---

## 6. Validación en Schemas — Dinámico vs Estático

### Regla de Oro

Si la validación depende de un **valor dinámico** (fecha actual, config, env):
**USAR `.refine()`, NUNCA `.max()` / `.min()` con expresiones dinámicas**

```typescript
// ❌ MAL — se evalúa en build-time
anio: z.number().max(new Date().getFullYear() + 1);

// ✅ BIEN — se evalúa en runtime en cada validación
anio: z.number().refine(
  (val) => val <= new Date().getFullYear() + 1,
  "El año no puede ser mayor al próximo año",
);
```

---

## 7. D1 (Cloudflare SQLite) — Patrones Seguros

### `.all()` — Nunca destructurar directamente

```typescript
// ❌ MAL
const { results } = await db.prepare("SELECT ...").all<Row>();

// ✅ BIEN
const response = await db.prepare("SELECT ...").all<Row>();
const results = response?.results ?? [];
```

### `.first()` — Siempre nullable y verificar

```typescript
// ❌ MAL
const row = await db.prepare("SELECT ...").first<Row>();

// ✅ BIEN
const row = await db.prepare("SELECT ...").first<Row | null>();
if (!row) return c.json({ error: "No encontrado" }, 404);
```

### Post-INSERT — Construir, no hacer SELECT

D1 tiene eventual consistency. SELECT post-insert puede retornar null.

```typescript
// ❌ MAL
await db.prepare("INSERT INTO ...").run();
const created = await db.prepare("SELECT ...").first<Row>();
return c.json(created!);

// ✅ BIEN
await db.prepare("INSERT INTO ...").run();
const created: Row = { id, ...data, created_at: now, updated_at: now };
return c.json(created, 201);
```

---

## 8. Skills Inteligentes — Carga Automática

Se cargan automáticamente según contexto, notificando:

```
Detectado: Edición en apps/api/src/routes/
→ Cargando: edge-performance-first
→ Cargando: saas-security-enforcer
→ Cargando: strict-typescript-contract
```

**SIEMPRE cargado:**

- senior-development-protocol

**Cargados según contexto:**

- Backend: edge-performance-first, saas-security-enforcer, strict-typescript-contract
- Frontend: ui-state-guardian, brand-i18n-guardian, strict-typescript-contract
- Código: zero-patch-policy, cognitive-responsibility
- IA: ai-genome-protocol

---

## 9. Resumen Ejecución

**Cada acción de código sigue este protocolo:**

```
1. Leer AGENTS.md (si existe)
2. Cargar senior-development-protocol
3. Detectar contexto → cargar skills relevantes + notificar
4. Aplicar checklist pre-acción (mental)
5. Seguir orden de debugging científico si hay error
6. Propagar contexto completo en errores
7. Buscar causa raíz, nunca band-aids
8. Código más limpio que antes
9. Commit con mensaje claro
10. Notificar skills cargados antes de terminar
```

**Resultado:** Comportamiento consistente, predecible, senior, sin importar proyecto o dev.
