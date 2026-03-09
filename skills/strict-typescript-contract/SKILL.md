---
name: strict-typescript-contract
description: "Sistema de razonamiento para diseñar y mantener contratos de tipado en aplicaciones fullstack TypeScript. Úsame siempre que crees tipos, interfaces o enums; diseñes la forma de datos que cruza entre backend y frontend; valides datos entrantes en cualquier frontera del sistema; o evalúes si una decisión de tipado introduce superficie de error en runtime."
---

# Strict TypeScript Contract

Sistema de razonamiento para usar el sistema de tipos de TypeScript como lo que realmente es: un contrato ejecutable entre las partes de un sistema. No es un conjunto de restricciones de estilo — es un modelo mental sobre dónde viven los errores en aplicaciones fullstack y cómo el sistema de tipos los hace imposibles o inevitables.

## Principio Fundacional

TypeScript compila a JavaScript. En runtime, no hay tipos.

Esa frase contiene toda la epistemología del tipado correcto: el compilador puede garantizar consistencia interna entre partes del sistema que controlas, pero no puede garantizar nada sobre lo que llega desde afuera — APIs externas, formularios, webhooks, localStorage, parámetros de URL. En esas fronteras, el tipo que declara tu código es una promesa unilateral que nadie más está obligado a cumplir.

El tipado con responsabilidad es saber exactamente dónde termina la garantía del compilador y dónde empieza la responsabilidad del runtime.

---

## I. La Topología del Sistema de Tipos

### 1.1 Zonas de Confianza

Un sistema fullstack tiene zonas con distintos niveles de garantía de tipos:

```
┌─────────────────────────────────────────────────────────┐
│  ZONA COMPILADA (TypeScript garantiza)                  │
│                                                         │
│  ┌──────────────┐         ┌──────────────┐             │
│  │   Frontend   │ ──────► │   types.ts   │ ◄────────── │
│  │   (React)    │         │  (contrato)  │    Backend  │
│  └──────────────┘         └──────────────┘  (Worker)  │
└─────────────────────────────────────────────────────────┘
         ▲                                        ▲
         │ HTTP / fetch                           │ D1 / KV / APIs
         │                                        │
┌─────────────────────────────────────────────────────────┐
│  ZONA RUNTIME (TypeScript NO garantiza nada)            │
│  - Respuestas de APIs externas                          │
│  - Payloads de POST/PUT desde el cliente                │
│  - Datos de D1 (el driver retorna unknown implícito)    │
│  - localStorage, URL params, query strings              │
│  - Webhooks de terceros                                 │
└─────────────────────────────────────────────────────────┘
```

**Regla de oro:** Cualquier dato que cruce la frontera entre zonas necesita validación en runtime. El tipo que declaras en TypeScript no protege nada en esa frontera — solo describe la forma que esperas.

### 1.2 Las Fronteras que Importan

| Frontera | Dirección | Riesgo si no se valida |
|---|---|---|
| Cliente → Worker (POST/PUT) | Entrada | Datos malformados, campos extra, tipos incorrectos |
| Worker → Cliente (response) | Salida | Contrato roto si el backend cambia sin actualizar frontend |
| D1 → Worker | Entrada | El driver retorna registros sin garantía de schema |
| API externa → Worker | Entrada | El contrato del proveedor puede cambiar sin aviso |
| Worker → KV | Salida/Entrada | Serialización sin garantía de schema en deserialización |
| URL params → Frontend | Entrada | Strings que se asumen números, IDs inválidos |

---

## II. Anatomía de un Tipo Bien Diseñado

### 2.1 El Tipo como Documentación Ejecutable

```ts
// Mal: tipo que documenta estructura pero no restricciones del dominio
interface Contractor {
  id: string
  status: string        // ¿qué valores son válidos?
  documentCount: number // ¿puede ser negativo?
  createdAt: string     // ¿ISO 8601? ¿timestamp Unix?
}

// Bien: tipo que documenta y restringe
type ContractorStatus = 'pending' | 'active' | 'suspended' | 'terminated'

interface Contractor {
  id: string
  status: ContractorStatus   // dominio cerrado y exhaustivo
  documentCount: number      // >= 0, validado en runtime
  createdAt: string          // ISO 8601 UTC, validado en runtime
}
```

### 2.2 La Distinción `unknown` vs `any`

`any` desactiva el sistema de tipos. `unknown` lo mantiene activo y fuerza la verificación antes del uso.

```ts
// any: el compilador confía ciegamente
function processPayload(payload: any) {
  return payload.event.type  // sin verificación, explota si la estructura difiere
}

// unknown: el compilador fuerza verificación antes de acceder
function processPayload(payload: unknown) {
  const validated = PayloadSchema.parse(payload)  // runtime check obligatorio
  return validated.event.type                      // solo accesible después de validar
}
```

**`any` nunca es correcto en código de producción.** Si el tipo exacto es genuinamente desconocido en tiempo de diseño, `unknown` + validación en runtime es siempre la respuesta.

### 2.3 Tipos Derivados vs Tipos Duplicados

TypeScript tiene utilidades para derivar tipos de otros. Usarlas evita la sincronización manual y la divergencia silenciosa.

```ts
// Base del dominio — fuente de verdad
interface Contractor {
  id: string
  tenantId: string
  name: string
  status: ContractorStatus
  documentCount: number
  createdAt: string
  updatedAt: string
}

// Derivados — siempre en sync con la base
type ContractorSummary  = Pick<Contractor, 'id' | 'name' | 'status'>
type ContractorCreate   = Omit<Contractor, 'id' | 'createdAt' | 'updatedAt'>
type ContractorUpdate   = Partial<ContractorCreate>
type ContractorWithDocs = Contractor & { documents: Document[] }
```

Si un campo cambia en `Contractor`, todos los derivados se actualizan automáticamente. Los tipos duplicados manualmente divergen silenciosamente — el compilador no puede detectarlo porque son tipos distintos.

---

## III. El Contrato Compartido Fullstack

### 3.1 La Única Fuente de Verdad

Los tipos que describen la interfaz entre backend y frontend deben existir en exactamente un lugar. Si existen en dos lugares, eventualmente divergen. Si divergen, el compilador no puede detectarlo — son dos tipos distintos que coinciden en nombre.

**Estructura de módulo compartido:**

```
src/
├── shared/
│   ├── types/
│   │   ├── contractor.ts    ← tipos de dominio
│   │   ├── api.ts           ← contratos de endpoints (request/response)
│   │   └── index.ts
│   └── schemas/
│       ├── contractor.ts    ← schemas de validación runtime (zod)
│       └── index.ts
├── worker/                  ← importa desde shared/
└── frontend/                ← importa desde shared/
```

### 3.2 Separar Tipo de Dominio de Tipo de API

El tipo de dominio representa la entidad en su forma canónica interna. El tipo de API representa lo que se expone en la interfaz HTTP. No son lo mismo.

```ts
// Tipo de dominio (interno)
interface Contractor {
  id: string
  tenantId: string
  name: string
  status: ContractorStatus
  passwordHash: string    // NUNCA en la respuesta de API
}

// Contrato de API (externo)
interface ContractorResponse {
  id: string
  name: string
  status: ContractorStatus
  // tenantId: ausente — no se expone al cliente
  // passwordHash: ausente — nunca
}

// Mapeo explícito — el compilador verifica que no se filtren campos internos
function toContractorResponse(c: Contractor): ContractorResponse {
  const { tenantId, passwordHash, ...response } = c
  return response
}
```

---

## IV. Validación en Fronteras de Runtime

### 4.1 Schema como Fuente de Verdad del Tipo

El tipo TypeScript se infiere del schema de validación — no se declara separadamente. Así son matemáticamente la misma cosa y no pueden diverger.

```ts
import { z } from 'zod'

const CreateContractorSchema = z.object({
  name: z.string().min(2).max(100).trim(),
  status: z.enum(['pending', 'active']).default('pending'),
  email: z.string().email(),
  taxId: z.string().regex(/^\d{11,12}$/, 'RUT inválido'),
})

// El tipo se deriva del schema — una sola fuente de verdad
type CreateContractorInput = z.infer<typeof CreateContractorSchema>
```

### 4.2 El Patrón de Frontera en Endpoints

```ts
async function handleCreateContractor(request: Request, env: Env) {
  // 1. Leer como unknown — sin asumir forma
  let rawBody: unknown
  try {
    rawBody = await request.json()
  } catch {
    return errorResponse(400, 'Invalid JSON')
  }

  // 2. Validar en runtime — convierte unknown a tipo confiable
  const result = CreateContractorSchema.safeParse(rawBody)
  if (!result.success) {
    return errorResponse(422, formatValidationErrors(result.error))
  }

  // 3. A partir de aquí, result.data tiene tipo garantizado por el compilador
  const contractor = await createContractor(result.data, env)
  return jsonResponse(toContractorResponse(contractor))
}
```

### 4.3 D1 y el Problema del Driver sin Schema

D1 retorna registros sin conocimiento del schema de la tabla. Hacer cast directo es asumir que la DB nunca tiene datos inconsistentes — una suposición que tarde o temprano falla.

```ts
// Mal: cast directo — explota silenciosamente si hay null inesperado
const contractor = await db
  .prepare('SELECT * FROM contractors WHERE id = ?')
  .bind(id)
  .first() as Contractor

// Bien: validar el resultado del query
const raw = await db
  .prepare('SELECT id, name, status, created_at FROM contractors WHERE id = ?')
  .bind(id)
  .first()

const result = ContractorSchema.safeParse(raw)
if (!result.success) {
  logger.error('DB schema mismatch', { error: result.error, raw })
  throw new DataIntegrityError('Contractor data malformed')
}
const contractor: Contractor = result.data
```

### 4.4 APIs Externas como Fronteras No Confiables

```ts
const StripeCustomerSchema = z.object({
  id: z.string().startsWith('cus_'),
  email: z.string().email().nullable(),
  metadata: z.record(z.string()).default({}),
})

async function getStripeCustomer(customerId: string) {
  const response = await fetch(`https://api.stripe.com/v1/customers/${customerId}`, {
    headers: { Authorization: `Bearer ${env.STRIPE_SECRET_KEY}` }
  })

  const raw = await response.json()
  const result = StripeCustomerSchema.safeParse(raw)

  if (!result.success) {
    // Loguear para detectar cuando el proveedor cambia su schema
    logger.error('Stripe schema mismatch', { error: result.error })
    throw new ExternalServiceError('Stripe response malformed')
  }

  return result.data
}
```

---

## V. Discriminated Unions para Estados del Dominio

Los estados de una entidad no son solo valores de un campo — determinan qué otros campos tienen sentido. Un tipo que ignora esta relación permite estados imposibles.

```ts
// Mal: permite estados imposibles (aprobado sin approvedBy, rechazado sin razón)
interface DocumentVerification {
  status: 'pending' | 'approved' | 'rejected'
  approvedBy?: string
  rejectedReason?: string
}

// Bien: cada estado tiene exactamente los campos que le corresponden
type DocumentVerification =
  | { status: 'pending' }
  | { status: 'approved'; approvedBy: string; approvedAt: string }
  | { status: 'rejected'; rejectedReason: string; rejectedAt: string }

// El compilador garantiza exhaustividad en switch
function renderStatus(v: DocumentVerification): string {
  switch (v.status) {
    case 'pending':  return 'Pendiente'
    case 'approved': return `Aprobado por ${v.approvedBy}`  // garantizado presente
    case 'rejected': return `Rechazado: ${v.rejectedReason}`
    // Sin default — si se agrega un estado nuevo, el compilador avisa aquí
  }
}
```

---

## VI. Proceso de Auditoría

### Fase 1: Uso de `any`
```
1. ¿Hay algún uso de `any` explícito?
2. ¿Hay casts `as TipoX` sin validación previa?
3. ¿Hay @ts-ignore sin justificación documentada?
```

### Fase 2: Fronteras de Runtime
```
1. ¿Hay llamadas a .json() sin validación posterior?
2. ¿Hay queries a D1 con cast directo al resultado?
3. ¿Hay acceso a URL params o localStorage sin parsear?
4. ¿Los schemas de validación y los tipos TypeScript son la misma fuente de verdad?
```

### Fase 3: Contrato Compartido
```
1. ¿Los tipos de respuesta de API están en el módulo compartido?
2. ¿Hay tipos duplicados en frontend y backend?
3. ¿El mapeo de dominio a respuesta de API es explícito?
4. ¿Los tipos derivados usan utilidades en lugar de redeclaración?
```

### Fase 4: Modelado de Dominio
```
1. ¿Hay campos opcionales que deberían ser discriminated unions?
2. ¿Hay string types que deberían ser union types cerrados?
3. ¿Hay estados imposibles representables en el sistema de tipos?
```

### Formato de reporte

```
AUDITORÍA DE TIPADO — [archivo/módulo]

CRÍTICO (errores silenciosos en runtime):
- [línea X] Cast directo `as Contractor` sin validación → usar schema.parse()
- [línea X] response.json() sin validación → frontera sin contrato verificado
- [línea X] `any` explícito → reemplazar con `unknown` + validación

CONTRATO ROTO:
- [tipo X] Duplicado en frontend y backend → consolidar en shared/types
- [tipo X] Schema y tipo TypeScript declarados separadamente → inferir tipo del schema

MODELADO DÉBIL:
- [interface X] Campos opcionales que implican estado → discriminated union
- [campo X] `status: string` sin restricción → union type o enum

DEUDA DE SINCRONIZACIÓN:
- [archivo X] Tipo de API expone campos internos → agregar mapeo explícito
```

---

## VII. Tradeoffs y Cuándo Ceder

**Validación completa vs performance**
Parsear con Zod tiene costo de CPU (~1-2ms para objetos medianos). En endpoints de alta frecuencia bajo presupuesto de CPU de Workers, considerar validación selectiva de campos críticos. El performance debe ser medido, no asumido.

**Tipos derivados vs tipos explícitos**
`Pick<Contractor, 'id' | 'name'>` es preciso pero puede ser menos legible que `ContractorSummary` cuando el tipo tiene semántica de dominio propia. Si el tipo derivado tiene nombre de negocio, declararlo explícitamente y agregar un type assertion que verifique su compatibilidad con la base.

**Zod vs validación manual**
Zod agrega ~12KB al bundle. Para Workers donde el bundle size afecta el cold start, validación manual de campos críticos puede ser preferible en endpoints simples. Para cualquier schema complejo, Zod es tree-shakeable y el tradeoff vale.

**`as const` vs enum**
Los enums de TypeScript compilan a objetos JavaScript con overhead de runtime. `as const` con tipo derivado es más ligero y más predecible en el contexto de Workers:
```ts
const ContractorStatus = { PENDING: 'pending', ACTIVE: 'active' } as const
type ContractorStatus = typeof ContractorStatus[keyof typeof ContractorStatus]
```

**Criterio de decisión siempre:** ¿Si este tipo fuera incorrecto, el compilador lo detectaría antes del deploy? Si la respuesta es no, hay una frontera de runtime sin validación.

---

## Filosofía Operativa

> TypeScript no elimina los errores de tipo — los mueve. Sin disciplina de fronteras, los mueve de "error de compilación fácil de encontrar" a "excepción en runtime difícil de reproducir".

El sistema de tipos es tan fuerte como su punto más débil. Un `any` en el medio de la cadena anula las garantías de todo lo que viene después. Una frontera sin validación es una suposición sin fundamento sobre quién controla los datos que entran al sistema.
