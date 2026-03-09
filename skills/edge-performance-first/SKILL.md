---
name: edge-performance-first
description: "Sistema de razonamiento para escribir código eficiente en entornos edge y serverless. Úsame siempre que escribas o revises código backend: Workers, D1, KV, R2, APIs externas, procesamiento de archivos, o cualquier operación que involucre I/O, memoria o latencia. Aplica también al diseñar arquitecturas de caché, estrategias de fetch, o evaluar si una dependencia externa es apropiada para el entorno."
---

# Edge Performance First

Sistema de razonamiento para escribir código que respete los constraints reales del entorno edge. No es una lista de APIs prohibidas: es un modelo mental sobre cómo funciona la ejecución en V8 Isolates y cómo ese modelo determina cada decisión de código.

## Principio Fundacional

Un servidor tradicional tiene estado persistente, memoria abundante y conexiones de larga vida. Un V8 Isolate tiene ninguna de esas tres cosas.

Cada request en Cloudflare Workers arranca en un contexto casi vacío, ejecuta, y termina. El código que ignora esto no falla con errores obvios — falla con latencias inesperadas, cold starts lentos, memory limits silenciosos, y costos que escalan mal. Entender el modelo de ejecución es el prerequisito de cualquier decisión de performance.

---

## I. El Modelo de Ejecución V8 Isolate

### 1.1 Qué es y qué no es un Isolate

Un Isolate **no es** un proceso Node.js. No tiene:
- Sistema de archivos accesible
- Memoria heap ilimitada (~128MB hard limit en Workers)
- Conexiones TCP persistentes entre requests
- Módulos npm con dependencias nativas (no hay binarios compilados)
- `setTimeout` con tiempos largos o tareas en background reales

Un Isolate **sí tiene**:
- V8 engine completo con Web APIs estándar
- CPU time limitado por request (~50ms CPU en el free tier, más en paid)
- Wall time más generoso (~30s) — para I/O asíncrono
- Acceso a APIs de Cloudflare: KV, D1, R2, Queues, Durable Objects

### 1.2 Cold Start vs Warm Isolate

El cold start ocurre cuando no hay Isolate disponible para el request. El costo principal no es la inicialización del runtime (V8 es rápido) sino **el código que se ejecuta en el top level del módulo**.

```js
// Mal: inicialización costosa en top level — se paga en cada cold start
const config = await fetchRemoteConfig()  // I/O en top level = imposible en Workers
const schema = buildValidationSchema(HUGE_JSON)  // CPU en top level = lento

// Bien: lazy initialization — se paga solo cuando se necesita
let schema = null
function getSchema() {
  if (!schema) schema = buildValidationSchema(HUGE_JSON)
  return schema
}
```

**Regla:** El top level del módulo solo debe contener definiciones. Cero I/O, cero computación costosa.

### 1.3 El Presupuesto de CPU

CPU time y wall time son distintos en Workers:
- **CPU time:** tiempo que el hilo V8 está activo procesando
- **Wall time:** tiempo total incluyendo espera de I/O async

Un Worker puede esperar 10 segundos una respuesta de API externa (wall time) usando casi cero CPU time durante la espera. Lo que agota el presupuesto es el procesamiento síncrono: transformaciones, validaciones, serialización de payloads grandes.

**Implicación:** El cuello de botella raramente es el I/O. Es el procesamiento de lo que retorna el I/O.

---

## II. Gestión de Memoria

### 2.1 Por Qué Importa Más que en Node

En Node.js, cargar un archivo de 50MB en memoria es imprudente pero no catastrófico — el GC lo maneja eventualmente. En un Isolate de 128MB que puede estar sirviendo múltiples requests concurrentes, 50MB de un archivo deja poco margen para el resto de la ejecución.

El principio no es "usa Streams porque es buena práctica". Es: **el Isolate no tiene margen para errores de memoria**.

### 2.2 Cuándo Usar Streams

Usar streams cuando el dato es mayor a ~1MB o cuando el tamaño es desconocido:

```js
// Mal: carga completa en memoria — falla silenciosamente con archivos grandes
async function uploadToR2(request, env) {
  const buffer = await request.arrayBuffer()  // todo en memoria
  await env.R2.put('file.pdf', buffer)
}

// Bien: stream directo — memoria constante independiente del tamaño
async function uploadToR2(request, env) {
  await env.R2.put('file.pdf', request.body)  // ReadableStream directo
}
```

**Cuándo NO usar Streams:**
- Datos pequeños y acotados (< 100KB, JSON de APIs)
- Cuando necesitás acceder a múltiples partes del contenido no secuencialmente
- Cuando la API destino no acepta streams

**Regla de decisión:** Si el tamaño es desconocido o potencialmente grande → Stream. Si es pequeño y acotado → Buffer está bien.

### 2.3 Serialización como Costo Oculto

JSON.parse y JSON.stringify son operaciones de CPU, no de I/O. Un payload de 1MB requiere ~10ms de CPU para parsear. En un presupuesto de 50ms, eso es 20% del budget.

```js
// Considerar: ¿realmente necesito todo el objeto?
const fullResponse = await fetch(api).then(r => r.json())  // parsea todo
const { status, id } = fullResponse  // usa solo dos campos

// Mejor cuando la API lo permite:
// Filtrar en la query, no después de parsear
```

---

## III. Arquitectura de Caché

### 3.1 El Modelo de Capas

El caché no es una optimización opcional en el edge — es la arquitectura. Cada capa tiene características distintas:

| Capa | Latencia | Persistencia | Límite | Caso de uso |
|---|---|---|---|---|
| Memoria del Isolate | ~0ms | Solo el request actual | ~128MB total | Deduplicación dentro del request |
| Cache API (Workers) | ~1ms | TTL configurable | Ilimitado | Respuestas HTTP cacheables |
| KV | ~5-50ms | Persistente, eventual consistency | 25MB por valor | Configuración, sesiones, datos leídos frecuentemente |
| D1 | ~10-30ms | Persistente, strong consistency | Según plan | Datos relacionales que cambian |
| APIs externas | ~50-500ms | N/A | N/A | Fuente de verdad cuando no hay caché válido |

### 3.2 Razonamiento sobre Qué Cachear

No todo dato merece el mismo nivel de caché. La decisión se basa en tres ejes:

**Frecuencia de lectura:** ¿Con qué frecuencia se consulta este dato?
**Frecuencia de cambio:** ¿Con qué frecuencia cambia este dato?
**Costo de obtenerlo:** ¿Cuánto cuesta (latencia + $) consultarlo desde la fuente?

```
Alta lectura + bajo cambio + costo alto   → KV con TTL largo
Alta lectura + cambio frecuente + costo medio → KV con TTL corto o Cache API
Baja lectura + cualquier cambio           → D1 directamente, sin caché intermedio
Dato único por request                    → sin caché (overhead > beneficio)
```

### 3.3 Implementación del Patrón Cache-First

```js
async function getContractor(id, env) {
  // 1. Cache de memoria (dentro del mismo request, evita doble fetch)
  if (requestCache.has(id)) return requestCache.get(id)

  // 2. KV (lectura frecuente, tolerante a eventual consistency)
  const cached = await env.KV.get(`contractor:${id}`, 'json')
  if (cached) {
    requestCache.set(id, cached)
    return cached
  }

  // 3. D1 (fuente de verdad relacional)
  const contractor = await env.DB
    .prepare('SELECT * FROM contractors WHERE id = ?')
    .bind(id)
    .first()

  if (!contractor) return null

  // Poblar KV para próximas lecturas (fire and forget — no bloquea el response)
  env.KV.put(`contractor:${id}`, JSON.stringify(contractor), { expirationTtl: 300 })

  requestCache.set(id, contractor)
  return contractor
}
```

**Nota sobre fire and forget:** `waitUntil()` es la forma correcta de ejecutar trabajo después de retornar el response. Sin `waitUntil`, Workers puede terminar el Isolate antes de que el KV.put complete.

```js
export default {
  async fetch(request, env, ctx) {
    const contractor = await getContractor(id, env)
    const response = new Response(JSON.stringify(contractor))

    // Revalidar caché después de retornar — no bloquea la respuesta
    ctx.waitUntil(revalidateIfStale(id, env))

    return response
  }
}
```

---

## IV. Dependencias y Web APIs Nativas

### 4.1 El Costo Real de una Dependencia npm

En un entorno Node.js, agregar una dependencia tiene costo de mantenimiento. En Workers, tiene además:

- **Costo de bundle size:** más código = cold start más lento = más CPU en inicialización
- **Riesgo de incompatibilidad:** muchos paquetes npm usan APIs de Node que no existen en V8 (fs, path, buffer nativo, net)
- **Deuda de auditoría:** cada dependencia es superficie de ataque en un entorno donde las claves y secretos viven en `env`

### 4.2 Tabla de Equivalencias Web API → npm

Antes de instalar un paquete, verificar si existe equivalente nativo:

| Necesidad | npm típico | Web API nativa |
|---|---|---|
| Hash / HMAC | `crypto-js`, `bcrypt` | `crypto.subtle.digest`, `crypto.subtle.sign` |
| UUID | `uuid` | `crypto.randomUUID()` |
| Encoding | `base64-js` | `btoa()`, `atob()`, `TextEncoder` |
| Fetch con retries | `axios`, `got` | `fetch` + wrapper propio |
| Validación de schema | `joi` (pesado) | `zod` (tree-shakeable) o validación manual |
| JWT | `jsonwebtoken` (Node-only) | `jose` (Web API compatible) |
| Fechas | `moment` (350KB) | `Temporal` API o `Intl` nativo |

### 4.3 Criterio para Aceptar una Dependencia

Una dependencia externa es aceptable si:
1. No usa APIs exclusivas de Node.js (verificar con `wrangler deploy` o el Workers runtime)
2. Es tree-shakeable (importar solo lo necesario)
3. El beneficio de funcionalidad supera claramente el costo de bundle

Si un paquete hace una sola cosa y tiene menos de 100 líneas efectivas → implementar directamente.

---

## V. D1 y Acceso a Base de Datos

### 5.1 Queries como Contratos de Latencia

Cada query a D1 tiene latencia fija de red (~10-30ms) más el tiempo de ejecución de la query. En un request que hace 5 queries secuenciales, el piso de latencia es 5 × 30ms = 150ms antes de cualquier procesamiento.

**Principio:** Minimizar roundtrips, no solo optimizar queries individuales.

```js
// Mal: N+1 query — latencia lineal con el número de contractors
const contractors = await db.prepare('SELECT id FROM contractors WHERE active = 1').all()
for (const c of contractors.results) {
  const docs = await db.prepare('SELECT * FROM documents WHERE contractor_id = ?').bind(c.id).all()
  // ...
}

// Bien: JOIN o query única — latencia constante
const result = await db.prepare(`
  SELECT c.*, d.id as doc_id, d.status as doc_status
  FROM contractors c
  LEFT JOIN documents d ON d.contractor_id = c.id
  WHERE c.active = 1
`).all()
```

### 5.2 Transacciones y Consistencia

D1 soporta transacciones. Usarlas cuando múltiples writes deben ser atómicos:

```js
// Operaciones relacionadas → transacción
const result = await env.DB.batch([
  db.prepare('UPDATE contractors SET status = ? WHERE id = ?').bind('active', id),
  db.prepare('INSERT INTO audit_log (contractor_id, action) VALUES (?, ?)').bind(id, 'activated'),
])
```

`batch()` ejecuta múltiples statements en una sola roundtrip — reduce latencia y garantiza atomicidad.

---

## VI. Proceso de Auditoría

Dado un fragmento de código backend, revisar en este orden:

### Fase 1: Modelo de Memoria
```
1. ¿Hay operaciones de I/O o computación costosa en el top level del módulo?
2. ¿Se carga contenido de tamaño desconocido o grande en memoria (arrayBuffer, text())?
3. ¿Hay deserialización de payloads grandes que podría filtrarse?
```

### Fase 2: Arquitectura de Caché
```
1. ¿Se consulta D1 o una API externa para datos que raramente cambian?
2. ¿Se repite la misma consulta más de una vez dentro del mismo request?
3. ¿Las escrituras a KV usan waitUntil() o bloquean el response?
```

### Fase 3: Dependencias
```
1. ¿Existe Web API nativa que reemplace esta dependencia?
2. ¿La dependencia usa APIs de Node.js incompatibles con Workers?
3. ¿El bundle size de la dependencia está justificado por su uso?
```

### Fase 4: Acceso a Datos
```
1. ¿Hay patrones N+1 en queries a D1?
2. ¿Las queries seleccionan más columnas de las necesarias?
3. ¿Las operaciones relacionadas están en batch o transacción?
```

### Formato de reporte

```
AUDITORÍA EDGE PERFORMANCE — [archivo/módulo]

RIESGO DE MEMORIA:
- [línea X] arrayBuffer() sobre body de tamaño desconocido → usar stream directo
- [línea X] Inicialización costosa en top level → mover a lazy init

ARQUITECTURA DE CACHÉ:
- [función X] Consulta D1 para dato de configuración estática → cachear en KV
- [línea X] KV.put sin waitUntil → puede no ejecutarse antes del fin del Isolate

DEPENDENCIAS:
- `crypto-js` importado completo → reemplazar con crypto.subtle nativo
- `uuid` → reemplazar con crypto.randomUUID()

ACCESO A DATOS:
- [función X] N+1 query en loop → consolidar con JOIN o batch
- [línea X] SELECT * donde solo se usan 3 campos → seleccionar columnas explícitas
```

---

## VII. Tradeoffs y Cuándo Ceder

**Stream vs Buffer**
Si el procesamiento requiere acceso no secuencial al contenido (ej: parsear un CSV buscando una fila específica por valor), el overhead de convertir stream a buffer controladamente puede ser aceptable si el tamaño máximo es conocido y acotado.

**Caché vs Consistencia**
KV tiene eventual consistency. Para datos donde la inconsistencia tiene consecuencias de negocio (saldos, permisos de acceso, estado de documentos críticos), D1 directamente es la decisión correcta aunque sea más lento.

**Web API nativa vs dependencia**
Si implementar la funcionalidad nativamente requiere más de 50 líneas y la dependencia es madura, bien mantenida, tree-shakeable y compatible con Workers — la dependencia gana. El tiempo de desarrollo también es un recurso.

**Criterio de decisión siempre:** ¿Qué pasa cuando este código sirve 1000 requests concurrentes? Si la respuesta cambia respecto a 1 request, hay un problema de modelo mental.

---

## Filosofía Operativa

> En el edge, el entorno no perdona los supuestos que funcionan en servidores tradicionales. El código que no entiende dónde corre eventualmente falla donde más duele: en producción, bajo carga.

Cada decisión de arquitectura en Workers es una decisión sobre qué tan bien modelaste el entorno de ejecución. Los errores de performance no son bugs — son brechas entre el modelo mental y la realidad del Isolate.
