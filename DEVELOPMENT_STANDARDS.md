# Development Standards — DOSA

Guía de estándares de desarrollo para el equipo. Aplica a todo el código del proyecto.

---

## 1. Protocolo de Inicio de Sesión

Antes de cualquier cambio de código:

1. Leer `AGENTS.md` — fuente de verdad del proyecto
2. Verificar ruta base: `/home/usuario/Documentos/opencode/dosa`
3. `git pull origin master` — sincronizar con remote
4. `git status` — confirmar rama correcta

---

## 2. Debugging — Método Científico

**Nunca asumir. Siempre verificar.**

```
Síntoma
  ↓
¿Hay validación local en el frontend? (HTML5, JS, Zod client-side)
  ↓
¿El request se envía? (Network tab)
  ↓
¿Qué datos exactos van al servidor? (Request body)
  ↓
¿Qué responde el servidor? (Response body completo, no solo status)
  ↓
¿El frontend muestra todos los detalles del error?
  ↓
Causa raíz → Fix permanente
```

Si no hay acceso a Network/Console: **preguntar al usuario** antes de especular.

---

## 3. Error Handling — Arquitectura

### Backend (Hono)

Todos los errores 400+ deben incluir `details`:

```typescript
// Validación Zod
if (!parsed.success) {
  return c.json(
    { error: "Datos inválidos", details: parsed.error.format() },
    400,
  );
}

// Error de negocio
return c.json({ error: "Cliente no encontrado" }, 404);

// Error de servidor — incluir log
console.error("[ruta POST]", error);
return c.json({ error: "Error al crear recurso" }, 500);
```

### Cliente (apiFetch + ApiError)

```typescript
// api.ts — ApiError preserva details del servidor
export class ApiError extends Error {
  details?: Record<string, unknown>;
  constructor(message: string, details?: Record<string, unknown>) {
    super(message);
    this.details = details;
  }
}

// En formularios: mostrar detalles específicos por campo
} catch (err: unknown) {
  if (err instanceof ApiError && err.details) {
    const fieldErrors = Object.entries(err.details)
      .filter(([key]) => key !== "_errors")
      .flatMap(([, v]) => (v as { _errors?: string[] })?._errors ?? [])
      .filter(Boolean);
    setFormError(
      fieldErrors.length > 0 ? fieldErrors.join(" · ") : err.message,
    );
  } else {
    setFormError(err instanceof Error ? err.message : "Error desconocido");
  }
}
```

---

## 4. Validación en Schemas (Zod)

### Regla fundamental

Si la validación depende de un valor **dinámico** (fecha actual, configuración, env var):
usar `.refine()` — nunca `.max()` / `.min()` con expresiones dinámicas.

```typescript
// ❌ MAL — se evalúa en build-time, puede quedar hardcodeado
anio: z.number().max(new Date().getFullYear() + 1);

// ✅ BIEN — se evalúa en runtime, siempre correcto
anio: z.number().refine(
  (val) => val <= new Date().getFullYear() + 1,
  "El año no puede ser mayor al próximo año",
);
```

### Transformaciones

```typescript
// Convertir string vacío a null antes de validar FK
client_id: z
  .string()
  .transform((val) => (val === "" ? null : val))
  .optional()
  .nullable(),
```

---

## 5. Patrones Seguros para D1 (Cloudflare SQLite)

### `.all()` — nunca destructurar directamente

```typescript
// ❌ MAL — results puede ser undefined si falla la query
const { results } = await db.prepare("SELECT ...").all<Row>();

// ✅ BIEN — defensivo
const response = await db.prepare("SELECT ...").all<Row>();
const results = response?.results ?? [];
```

### `.first()` — siempre nullable

```typescript
// ❌ MAL — asume que siempre retorna datos
const row = await db.prepare("SELECT ...").first<Row>();
doSomething(row!); // crash si es null

// ✅ BIEN — verificar antes de usar
const row = await db.prepare("SELECT ...").first<Row | null>();
if (!row) return c.json({ error: "No encontrado" }, 404);
```

### Post-INSERT — construir respuesta en memoria

D1 tiene eventual consistency. Un SELECT inmediatamente después de un INSERT puede retornar `null`.

```typescript
// ❌ MAL — SELECT post-insert puede retornar null
await db.prepare("INSERT INTO ...").run();
const created = await db.prepare("SELECT ...").first<Row>();
return c.json(created!); // crash

// ✅ BIEN — construir con datos ya disponibles
await db.prepare("INSERT INTO ...").run();
const created: Row = { id, ...data, created_at: now, updated_at: now };
return c.json(created, 201);
```

### Auditoría — fire-and-forget

```typescript
// No bloquear la respuesta si falla la auditoría
db.prepare("INSERT INTO audit_logs ...")
  .bind(...)
  .run()
  .catch((err) => console.error("[audit]", err));
```

### tenant_id

En producción, siempre usar valor existente en tabla `tenants`:

```typescript
let tenantId = "legacy"; // NO "default" ni valores inventados
```

---

## 6. Flujo Git

```bash
# 1. Crear rama descriptiva
git checkout -b tipo/descripcion-corta

# 2. Hacer cambios

# 3. Commit con prefijo correcto
git add .
git commit -m "fix: descripción clara del cambio"

# 4. Push y PR
git push origin tipo/descripcion-corta
gh pr create --title "..." --body "..."

# 5. Merge
gh pr merge N --merge --delete-branch
```

### Prefijos de commit

| Prefijo     | Cuándo usarlo                                |
| ----------- | -------------------------------------------- |
| `feat:`     | Nueva funcionalidad                          |
| `fix:`      | Corrección de bug                            |
| `refactor:` | Refactorización sin cambio de comportamiento |
| `docs:`     | Documentación                                |
| `style:`    | Cambios de formato/estilo                    |
| `chore:`    | Mantenimiento (deps, config)                 |

**NUNCA** hacer push directo a `master`. Siempre PR.

---

## 7. Checklist Pre-Merge

Antes de hacer merge de cualquier PR:

- [ ] ¿La causa raíz del bug está documentada?
- [ ] ¿El error propaga detalles suficientes al usuario?
- [ ] ¿Las queries D1 usan patrones seguros (`.results ?? []`, `.first<T | null>()`)?
- [ ] ¿Las validaciones dinámicas usan `.refine()` en lugar de `.max()`?
- [ ] ¿La auditoría es fire-and-forget?
- [ ] ¿El código queda más limpio que antes? (Regla del Boy Scout)
- [ ] ¿El mensaje de commit es claro y usa el prefijo correcto?

---

## 8. Reglas de UX

- Los errores de formulario deben mostrar **qué campo** falló, no solo "Error genérico"
- Mientras se procesa una request: mostrar estado de loading (`disabled`, `Spinner`)
- Mensajes de éxito: usar Toast, no alert()
- Mensajes de error de backend: nunca mostrar stack traces al usuario final
