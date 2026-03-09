---
name: saas-security-enforcer
description: "Sistema de razonamiento para diseñar y auditar seguridad en aplicaciones SaaS multi-tenant. Úsame siempre que escribas endpoints de API, consultas a D1 o KV, validación de JWT, configuración de webhooks, manejo de secretos, o cualquier operación donde una decisión incorrecta pueda exponer datos de un tenant a otro, permitir acceso no autorizado, o filtrar información sensible."
---

# SaaS Security Enforcer

Sistema de razonamiento para escribir código seguro en aplicaciones multi-tenant. No es una lista de validaciones a agregar: es un modelo mental sobre cómo los vectores de ataque explotan las suposiciones que el código hace sobre quién está del otro lado de cada request.

## Principio Fundacional

En seguridad, el error no es hacer algo mal — es asumir que algo es seguro sin verificarlo.

Un endpoint multi-tenant tiene una propiedad única: el código correcto y el código vulnerable pueden verse casi idénticos. La diferencia es una cláusula WHERE, una verificación de firma, una lectura desde `env` en lugar de una constante. El atacante no necesita romper el sistema — solo necesitar encontrar el lugar donde el código confió en algo que no debería haber confiado.

---

## I. El Modelo de Amenaza Multi-Tenant

Antes de escribir cualquier endpoint, tener claro el modelo de amenaza específico del entorno multi-tenant:

### 1.1 Los Tres Vectores Principales

**Vector 1 — Escalación horizontal de tenant**
Un usuario autenticado legítimamente accede a datos de otro tenant manipulando parámetros de la request (IDs en URL, body, query string). Es el vector más común y el más silencioso — no genera errores, simplemente retorna datos incorrectos.

```
GET /api/contractors/8823        ← ID en URL, no en JWT
Authorization: Bearer <jwt_tenant_A>

// Si el código no verifica que 8823 pertenece al tenant del JWT,
// tenant_A puede leer datos de tenant_B
```

**Vector 2 — Escalación vertical de privilegios**
Un usuario accede a funcionalidades para las que su rol o plan no tienen permiso. Ocurre cuando la autorización se verifica solo en la UI, no en el backend, o cuando se verifica el rol pero no el plan del tenant.

**Vector 3 — Inyección de contexto externo**
Un actor externo (webhook, API de terceros) envía payloads que el sistema procesa sin verificar su autenticidad. El caso clásico: webhooks de Stripe sin verificación de firma que pueden ser disparados por cualquiera con la URL.

### 1.2 La Regla de Desconfianza Estructurada

Clasificar cada input según su nivel de confianza inherente:

| Fuente | Nivel de Confianza | Qué verificar |
|---|---|---|
| JWT firmado (claims) | Alta — si la firma es válida | Expiración, issuer, estructura de claims |
| Parámetros de URL / query | Cero | Pertenencia al tenant del JWT |
| Body de request | Cero | Schema + pertenencia al tenant |
| Headers arbitrarios | Cero | No usar para decisiones de autorización |
| Webhooks externos | Cero hasta verificar firma | Firma criptográfica antes de cualquier procesamiento |
| Variables de entorno (`env`) | Alta | No necesitan verificación en runtime |

**Regla:** Los claims del JWT son la única fuente de verdad sobre quién hace el request. Todo lo demás se valida contra esa fuente.

---

## II. Aislamiento de Tenant

### 2.1 El Único Lugar Donde Vive el Tenant ID

El `tenant_id` que determina el scope de una operación debe venir **exclusivamente del JWT verificado**, nunca de la request misma.

```js
// Mal: tenant_id viene del body — el cliente controla su propio scope
async function getContractors(request, env) {
  const { tenant_id } = await request.json()  // ← controlado por el atacante
  return db.prepare('SELECT * FROM contractors WHERE tenant_id = ?').bind(tenant_id).all()
}

// Bien: tenant_id viene del JWT verificado
async function getContractors(request, env) {
  const { tenant_id } = await verifyAndExtractJWT(request, env)  // ← fuente de verdad
  return db.prepare('SELECT * FROM contractors WHERE tenant_id = ?').bind(tenant_id).all()
}
```

### 2.2 El Patrón de Verificación de Propiedad

Cuando se opera sobre un recurso específico (por ID), la consulta debe verificar simultáneamente existencia **y** pertenencia al tenant. Nunca en dos queries separadas.

```js
// Mal: dos queries — ventana de TOCTOU y doble latencia
const contractor = await db.prepare('SELECT * FROM contractors WHERE id = ?').bind(id).first()
if (!contractor) return notFound()
if (contractor.tenant_id !== tenant_id) return forbidden()  // ← llegamos aquí con datos del otro tenant

// Bien: una query con doble condición — existencia y pertenencia son la misma verificación
const contractor = await db
  .prepare('SELECT * FROM contractors WHERE id = ? AND tenant_id = ?')
  .bind(id, tenant_id)
  .first()

if (!contractor) return notFound()  // no revelar si existe pero pertenece a otro tenant
```

**Nota sobre información de existencia:** Retornar 403 cuando el recurso existe pero pertenece a otro tenant revela que el recurso existe. Retornar 404 en ambos casos (no encontrado O no pertenece) es más seguro — no filtra información sobre la existencia de datos de otros tenants.

### 2.3 KV y el Namespace como Frontera

En KV, el aislamiento no es automático — depende de la convención de claves. Una clave sin tenant prefix es accesible desde cualquier tenant si el código lo permite.

```js
// Mal: clave sin tenant scope
await env.KV.get(`contractor:${id}`)

// Bien: tenant_id como parte estructural de la clave
await env.KV.get(`tenant:${tenant_id}:contractor:${id}`)
```

**Convención de estructura de claves KV:**
```
[entidad_raíz]:[tenant_id]:[entidad]:[id]
tenant:abc123:contractor:8823
tenant:abc123:session:xyz
```

Cualquier lectura de KV que no incluya `tenant_id` en la clave es una potencial fuga de datos entre tenants.

---

## III. Autenticación JWT

### 3.1 Verificación No Es Decodificación

Decodificar un JWT (base64 del payload) y verificar un JWT (validar la firma criptográfica) son operaciones distintas. Decodificar sin verificar es confiar en un documento sin autenticar su firma.

```js
// Mal: decodifica pero no verifica — cualquier JWT malformado pasa
function extractClaims(token) {
  const payload = token.split('.')[1]
  return JSON.parse(atob(payload))  // ← sin verificación de firma
}

// Bien: verifica criptográficamente antes de extraer claims
async function verifyAndExtractJWT(request, env) {
  const token = request.headers.get('Authorization')?.replace('Bearer ', '')
  if (!token) throw new UnauthorizedError()

  const key = await importJWTSecret(env.JWT_SECRET)
  const { payload } = await jwtVerify(token, key, {
    issuer: 'your-app',
    audience: 'your-api',
  })

  // Verificar estructura de claims esperada
  if (!payload.tenant_id || !payload.user_id || !payload.role) {
    throw new UnauthorizedError('Malformed token claims')
  }

  return payload
}
```

### 3.2 Claims que Deben Verificarse Siempre

| Claim | Por qué verificar | Consecuencia de omitir |
|---|---|---|
| `exp` | Token expirado sigue siendo criptográficamente válido | Tokens de sesiones cerradas siguen funcionando |
| `iss` | Verifica que el token fue emitido por tu sistema | Tokens de otros sistemas o ambientes pasan |
| `aud` | Verifica el destinatario intended del token | Tokens de otros servicios del mismo issuer pasan |
| `tenant_id` | Existencia del claim en el payload | Tokens sin scope de tenant causan queries sin filtro |

### 3.3 Cuándo Re-verificar vs Confiar en Caché

Si cacheas el resultado de verificación de JWT en KV para reducir latencia:
- La clave de caché debe incluir el hash del token completo, no solo el `jti`
- El TTL del caché no debe superar el `exp` del token
- La invalidación explícita (logout) debe borrar la entrada de KV

---

## IV. Verificación Criptográfica de Webhooks

### 4.1 Por Qué la URL No Es Suficiente

Una URL de webhook es semi-pública — aparece en logs, headers de referrer, configuraciones de terceros. Cualquiera que la conozca puede enviar POST requests. La firma criptográfica es lo que convierte "un request llegó a esta URL" en "Stripe (o el sistema X) realmente envió este payload".

### 4.2 El Orden Importa: Firma Antes de Todo

La verificación de firma debe ocurrir **antes** de cualquier otro procesamiento del payload — antes de parsear, antes de validar schema, antes de queries a DB.

```js
// Mal: parsea primero, verifica después — el parser puede ser explotado con payloads maliciosos
async function handleStripeWebhook(request, env) {
  const payload = await request.json()  // ← procesamiento antes de verificar autenticidad
  const signature = request.headers.get('Stripe-Signature')
  if (!isValidSignature(payload, signature, env.STRIPE_WEBHOOK_SECRET)) {
    return new Response('Invalid signature', { status: 401 })
  }
  // ...
}

// Bien: texto crudo primero, verificar firma, luego parsear
async function handleStripeWebhook(request, env) {
  const rawBody = await request.text()  // ← texto crudo, sin parsear
  const signature = request.headers.get('Stripe-Signature')

  if (!await verifyStripeSignature(rawBody, signature, env.STRIPE_WEBHOOK_SECRET)) {
    return new Response('Invalid signature', { status: 401 })
  }

  const payload = JSON.parse(rawBody)  // ← parsear solo después de verificar
  // ...
}
```

**Por qué `request.text()` y no `request.json()`:** La firma se calcula sobre el payload raw (bytes exactos). JSON.parse + JSON.stringify puede alterar el orden de claves o el whitespace, invalidando la firma. El body raw debe preservarse intacto para la verificación.

### 4.3 Implementación de Verificación HMAC

```js
async function verifyHMACSignature(rawBody, signatureHeader, secret) {
  const encoder = new TextEncoder()

  const key = await crypto.subtle.importKey(
    'raw',
    encoder.encode(secret),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['verify']
  )

  // Extraer timestamp y firma del header (formato específico del provider)
  // Stripe: "t=timestamp,v1=signature"
  const [timestampPart, signaturePart] = signatureHeader.split(',')
  const timestamp = timestampPart.replace('t=', '')
  const expectedSig = signaturePart.replace('v1=', '')

  // Verificar que el timestamp no sea demasiado antiguo (replay attack)
  const age = Date.now() / 1000 - parseInt(timestamp)
  if (age > 300) throw new Error('Webhook timestamp too old')  // 5 minutos

  // El payload firmado incluye timestamp para prevenir replay
  const signedPayload = `${timestamp}.${rawBody}`

  const signatureBytes = hexToBytes(expectedSig)
  return crypto.subtle.verify('HMAC', key, signatureBytes, encoder.encode(signedPayload))
}
```

**Verificación de timestamp:** Sin ella, un webhook válido capturado puede ser re-enviado indefinidamente (replay attack). El window de 5 minutos es el estándar de Stripe; ajustar según el proveedor.

---

## V. Control de Acceso Basado en Roles y Plan

### 5.1 Dos Dimensiones Ortogonales

El acceso a una funcionalidad depende de dos dimensiones independientes:

- **Rol:** qué puede hacer este usuario dentro de su tenant (admin, operator, viewer)
- **Plan:** qué funcionalidades tiene habilitadas el tenant (free, pro, enterprise)

Ambas deben verificarse. Verificar solo el rol permite que un tenant free con un admin acceda a features premium. Verificar solo el plan permite que un viewer ejecute acciones de admin.

```js
// Middleware de autorización con ambas dimensiones
async function authorize(claims, requiredRole, requiredFeature, env) {
  // Verificar rol del usuario
  if (!hasRole(claims.role, requiredRole)) {
    throw new ForbiddenError(`Role ${claims.role} cannot perform this action`)
  }

  // Verificar plan del tenant (desde KV o D1)
  const tenantPlan = await getTenantPlan(claims.tenant_id, env)
  if (!planIncludes(tenantPlan, requiredFeature)) {
    throw new PaymentRequiredError(`Feature ${requiredFeature} requires upgrade`)
  }
}

// Uso en endpoint
export async function handleBulkExport(request, env) {
  const claims = await verifyAndExtractJWT(request, env)
  await authorize(claims, 'admin', 'bulk_export', env)
  // ...
}
```

### 5.2 Jerarquía de Roles

Diseñar roles como jerarquía, no como lista plana:

```js
const ROLE_HIERARCHY = {
  superadmin: 4,
  admin: 3,
  operator: 2,
  viewer: 1,
}

function hasRole(userRole, requiredRole) {
  return (ROLE_HIERARCHY[userRole] ?? 0) >= (ROLE_HIERARCHY[requiredRole] ?? Infinity)
}
```

Un admin tiene todo lo que tiene un operator. No duplicar lógica de permisos por cada combinación.

---

## VI. Gestión de Secretos

### 6.1 El Principio de Segregación de Secretos

Un secreto en el código fuente es un secreto comprometido — no al momento del deploy, sino en el momento en que el repositorio existe. Los secretos tienen ciclos de vida distintos al código y deben gestionarse por separado.

```js
// Mal: secreto en código
const STRIPE_KEY = 'sk_live_abc123...'

// Mal: secreto en variable de entorno de desarrollo commiteada
// .env con SK_LIVE en el repo

// Bien: secreto en env del Worker — solo accesible en runtime
const stripe = new Stripe(env.STRIPE_SECRET_KEY)
```

### 6.2 Taxonomía de Secretos y su Scope

| Tipo de secreto | Scope correcto | Rotación |
|---|---|---|
| JWT signing secret | Env del Worker (`env.JWT_SECRET`) | Con cada breach + periódicamente |
| API keys de terceros | Env del Worker | Según política del proveedor |
| Webhook secrets | Env del Worker por proveedor | Al reconfigurar el webhook |
| Credenciales de DB | No aplica en D1 (IAM del Worker) | N/A |
| Claves de cifrado de datos | Env + KMS si el volumen lo justifica | Rotación con re-cifrado de datos |

### 6.3 Auditoría de Secretos en Código

Antes de cualquier commit, verificar:

```
grep -r "sk_live\|sk_test\|Bearer \|password\s*=\s*['\"]" --include="*.js" --include="*.ts" .
```

Automatizar esto como pre-commit hook o en CI. Un secreto que llega al repositorio debe considerarse comprometido aunque el commit sea revertido — los secretos aparecen en el historial de git.

---

## VII. Proceso de Auditoría

Dado un endpoint o módulo, revisar en este orden:

### Fase 1: Flujo de Autenticación
```
1. ¿Se verifica la firma del JWT o solo se decodifica?
2. ¿Se verifican exp, iss, aud y la estructura de claims?
3. ¿El tenant_id viene del JWT o de la request?
```

### Fase 2: Aislamiento de Tenant
```
1. ¿Toda query a D1 incluye tenant_id como condición?
2. ¿Toda clave de KV incluye tenant_id como prefijo estructural?
3. ¿Los recursos por ID se verifican con WHERE id = ? AND tenant_id = ??
4. ¿Los 404 y 403 son indistinguibles para recursos de otros tenants?
```

### Fase 3: Webhooks y Contexto Externo
```
1. ¿Se lee el body como texto raw antes de verificar la firma?
2. ¿Se verifica el timestamp para prevenir replay attacks?
3. ¿La verificación ocurre antes de cualquier otro procesamiento?
```

### Fase 4: Control de Acceso
```
1. ¿Se verifican tanto rol como plan del tenant?
2. ¿La verificación ocurre en el backend, no solo en la UI?
3. ¿Los errores de autorización no revelan información sobre el recurso?
```

### Fase 5: Secretos
```
1. ¿Hay claves, tokens o passwords hardcodeados?
2. ¿Hay archivos .env commiteados al repositorio?
3. ¿Toda lectura de secreto usa env.VARIABLE_NAME?
```

### Formato de reporte

```
AUDITORÍA DE SEGURIDAD — [archivo/módulo]

CRÍTICO (exploitable):
- [línea X] tenant_id tomado del body, no del JWT → escalación horizontal posible
- [línea X] JWT decodificado sin verificar firma → tokens forjados aceptados
- [línea X] Webhook procesado antes de verificar firma → injection de payloads externos

ALTO (requiere condiciones específicas):
- [función X] Query sin tenant_id en WHERE → scope leak si JWT malformado
- [función X] Solo verifica rol, no plan → feature access sin autorización de plan
- [línea X] 403 revela existencia de recurso de otro tenant → information disclosure

MEDIO (buenas prácticas):
- [línea X] KV key sin tenant prefix → potencial confusión de datos entre tenants
- [función X] Verificación de rol duplicada en lugar de usar jerarquía

SECRETOS:
- [línea X] API key hardcodeada → mover a env.VARIABLE_NAME inmediatamente
```

---

## VIII. Tradeoffs y Cuándo Ceder

**404 vs 403 para recursos de otro tenant**
En APIs internas donde los tenants nunca interactúan entre sí, 403 puede ser aceptable para mejorar debuggability. En APIs públicas o donde la existencia de datos es información sensible, siempre 404.

**Verificación de plan en caché vs en DB**
El plan de un tenant cambia raramente (upgrade/downgrade). Cachear en KV con TTL de minutos es aceptable. Cachear indefinidamente sin mecanismo de invalidación no lo es — un downgrade debe surtir efecto rápidamente.

**Granularidad de roles**
Más roles = más precisión de acceso = más complejidad de mantenimiento. Para la mayoría de SaaS B2B, 3-4 roles cubren el 95% de los casos. Agregar roles por cada combinación de permisos es deuda de mantenimiento que raramente se justifica.

**Criterio de decisión siempre:** Si este endpoint fuera descubierto por alguien con una cuenta válida en cualquier tenant, ¿qué podría hacer que no debería poder hacer?

---

## Filosofía Operativa

> En multi-tenant, el bug de seguridad más peligroso no es el que rompe el sistema — es el que funciona perfectamente para el atacante mientras el sistema sigue sirviendo requests sin error.

La escalación horizontal no lanza excepciones. No genera alertas. Retorna HTTP 200 con datos que no deberían haberse retornado. El único momento para detectarla es antes de que exista: en el modelo mental con el que se escribe cada query.
