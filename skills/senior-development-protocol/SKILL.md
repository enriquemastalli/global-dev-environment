# Skill: Senior Development Protocol

Protocolo de desarrollo con estándares de 20+ años de experiencia.
Aplica en TODA sesión, para TODA tarea, sin excepciones.

---

## 1. Protocolo Obligatorio de Inicio de Sesión

Antes de cualquier acción de código:

1. **Leer AGENTS.md** del proyecto activo — es la fuente de verdad
2. **Extraer y memorizar:** ruta base, variables críticas, reglas especiales
3. **Ejecutar:** `git pull origin master` con el `workdir` correcto
4. **Confirmar:** `git status` — verificar rama y estado

**Si no hay AGENTS.md:** preguntar al usuario antes de asumir nada.

---

## 2. Método de Debugging Científico

**NUNCA asumir. SIEMPRE verificar.**

Orden obligatorio antes de proponer cualquier fix:

```
1. ¿Hay validación en el frontend? (HTML5, JS local, esquemas del cliente)
2. ¿El request se envía? (Network tab del navegador)
3. ¿Qué datos exactos se envían? (Request body)
4. ¿Qué responde el servidor? (Response body completo, no solo status)
5. ¿El frontend muestra los detalles del error o los descarta?
```

**Si no tengo acceso a logs o Network:** preguntar al usuario antes de especular.

**Frases prohibidas:**

- ❌ "Esto probablemente significa..."
- ❌ "Asumo que el error es..."
- ❌ "Creo que debería ser..."

**Frases correctas:**

- ✅ "Los datos muestran que..."
- ✅ "Verifiqué en el código y confirmo que..."
- ✅ "La causa raíz es... porque [evidencia]"

---

## 3. Reglas Sagradas — No Negociables

### Rutas

- SIEMPRE leer AGENTS.md para obtener la ruta base correcta
- NUNCA inventar ni asumir rutas
- Verificar la ruta base en el PRIMER comando de cada sesión

### Datos antes de hipótesis

- Ver código real antes de proponer causa
- Ver datos de red antes de asumir qué se envía
- Ver respuesta completa del servidor antes de concluir dónde falla

### Error handling — siempre con contexto

```typescript
// Backend: incluir siempre details en errores 400+
return c.json(
  { error: "Datos inválidos", details: parsed.error.format() },
  400,
);

// Cliente: clase de error que preserva details
export class ApiError extends Error {
  details?: Record<string, unknown>;
  constructor(message: string, details?: Record<string, unknown>) {
    super(message);
    this.details = details;
  }
}

// UI: mostrar detalles específicos al usuario, no mensajes genéricos
const fieldErrors = Object.entries(err.details)
  .filter(([key]) => key !== "_errors")
  .flatMap(([, v]) => (v as { _errors?: string[] })?._errors ?? []);
```

### Validación dinámica en schemas — usar `.refine()`

```typescript
// ❌ MAL: .max() con expresión dinámica se evalúa en build-time
anio: z.number().max(new Date().getFullYear() + 1);

// ✅ BIEN: .refine() se evalúa en runtime en cada validación
anio: z.number().refine(
  (val) => val <= new Date().getFullYear() + 1,
  "El año no puede ser mayor al próximo año",
);
```

**Regla:** Cuando la validación depende de un valor dinámico (fecha, config, env), usar `.refine()` siempre.

### Fixes permanentes — no band-aids

- Buscar la causa raíz, no parchear el síntoma
- Si el fix agrega un `if` al final del archivo para esquivar un bug → reescribir
- Dejar el archivo más limpio de lo que estaba (Regla del Boy Scout)

---

## 4. Checklist Pre-Fix

Antes de proponer o implementar cualquier solución:

- [ ] ¿Leí AGENTS.md y estoy en la ruta base correcta?
- [ ] ¿Vi los datos reales del error (no supuse)?
- [ ] ¿La causa raíz está 100% identificada con evidencia?
- [ ] ¿Entiendo si el error es frontend, backend, o ambos?
- [ ] ¿El error propaga contexto suficiente al usuario?
- [ ] ¿Hay expresiones dinámicas que deberían usar `.refine()`?
- [ ] ¿Mi fix es permanente o es un parche temporal?
- [ ] ¿El código queda más limpio que antes?

---

## 5. Arquitectura de Error Handling

### Backend (Hono + D1)

```typescript
// Validación Zod
if (!parsed.success) {
  return c.json(
    { error: "Datos inválidos", details: parsed.error.format() },
    400,
  );
}

// Queries D1: nunca asumir que .first() retorna datos
const row = await db.prepare("SELECT ...").first<Row | null>();
if (!row) return c.json({ error: "No encontrado" }, 404);

// Queries D1: nunca asumir que .all() retorna results definido
const response = await db.prepare("SELECT ...").all<Row>();
const results = response?.results ?? [];

// Auditoría: fire-and-forget, no bloquea la respuesta
db.prepare("INSERT INTO audit_logs ...")
  .run()
  .catch((err) => console.error("[audit]", err));

// Respuesta post-INSERT: construir con datos ya disponibles
// NO hacer SELECT post-insert (D1 eventual consistency)
const created: Row = { id, ...data, created_at: now, updated_at: now };
return c.json(created, 201);
```

### Frontend (React + apiFetch)

```typescript
// apiFetch lanza ApiError con details
// Catch en formularios: extraer y mostrar detalles específicos
} catch (err: unknown) {
  if (err instanceof ApiError && err.details) {
    const fieldErrors = Object.entries(err.details)
      .filter(([key]) => key !== "_errors")
      .flatMap(([, v]) => (v as { _errors?: string[] })?._errors ?? [])
      .filter(Boolean);
    setFormError(fieldErrors.length > 0 ? fieldErrors.join(" · ") : err.message);
  } else {
    setFormError(err instanceof Error ? err.message : "Error desconocido");
  }
}
```

---

## 6. Conocimiento Específico de D1 (Cloudflare)

- **Eventual consistency:** Un SELECT inmediatamente después de un INSERT puede retornar `null`. Construir respuesta con datos en memoria.
- **Foreign keys:** D1 no permite NULL en columnas con FK constraint. Omitir la columna del INSERT si el valor es null.
- **tenant_id:** Siempre usar valor existente en tabla `tenants`. En producción: `"legacy"`.
- **`.all()` results:** Siempre usar `response?.results ?? []` — nunca destructurar directamente.
- **`.first()`:** Siempre tipar como `Type | null` y verificar antes de usar.

---

## 7. Flujo de Deploy

1. `git add . && git commit -m "tipo: descripción"`
2. `git push origin rama`
3. `gh pr create ...`
4. Merge via `gh pr merge N --merge --delete-branch`
5. GitHub Actions despliega automáticamente en 1-2 minutos

**NUNCA** hacer deploy manual con `wrangler pages deploy`.
**NUNCA** hacer push directo a master.
