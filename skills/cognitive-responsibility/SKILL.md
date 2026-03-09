---
name: cognitive-responsibility
description: "Sistema de razonamiento para minimizar carga cognitiva en código. Úsame siempre que escribas, refactorices, revises o hagas code review de cualquier bloque de código, independientemente del lenguaje. Aplica cuando nombres variables, diseñes funciones, estructures módulos, o evalúes si un fragmento es legible por otro humano."
---

# Cognitive Responsibility

Sistema de razonamiento para escribir código que otro humano pueda leer con la mínima fricción posible. No es un linter ni un conjunto de reglas: es un modelo mental sobre cómo funciona la comprensión humana aplicado a la escritura de código.

## Principio Fundacional

El compilador no se fatiga. El humano sí.

La memoria de trabajo humana puede sostener aproximadamente 7 ± 2 chunks de información simultáneos. Cada variable que el lector debe rastrear, cada nivel de anidamiento que debe recordar, cada nombre ambiguo que debe resolver consume uno de esos slots. Cuando se agotan, el lector comete errores o abandona.

Escribir con responsabilidad cognitiva es gestionar ese presupuesto de atención del lector como si fuera un recurso escaso — porque lo es.

---

## I. Los Tres Ejes de Carga Cognitiva

### 1.1 Carga Intrínseca — La complejidad del problema

No toda complejidad es evitable. Algunos dominios son inherentemente difíciles: criptografía, transformaciones matemáticas, algoritmos de scheduling. Esta complejidad no se elimina, se **aisla**.

**Principio:** La complejidad intrínseca debe vivir en el lugar más pequeño posible, con el nombre más honesto posible.

```js
// Mal: complejidad intrínseca mezclada con lógica de negocio
function processPayment(amount, user) {
  const hash = crypto.createHmac('sha256', SECRET)
    .update(`${user.id}:${amount}:${Date.now()}`)
    .digest('hex')
  if (user.balance >= amount && user.verified && !user.frozen) {
    // ... lógica de negocio
  }
}

// Bien: complejidad intrínseca aislada con nombre honesto
function generatePaymentSignature(userId, amount) {
  return crypto.createHmac('sha256', SECRET)
    .update(`${userId}:${amount}:${Date.now()}`)
    .digest('hex')
}

function processPayment(amount, user) {
  if (!isEligibleForPayment(user, amount)) return { error: 'not_eligible' }
  const signature = generatePaymentSignature(user.id, amount)
  // ...
}
```

### 1.2 Carga Extrínseca — La complejidad que introduce la presentación

Esta es la carga evitable. Nace de: anidamiento innecesario, nombres que mienten, funciones que hacen dos cosas, comentarios que repiten el código.

**Principio:** Si la carga extrínseca supera la intrínseca, el código está mal escrito independientemente de si funciona.

Indicadores de carga extrínseca alta:
- Un lector debe hacer scroll para entender el flujo de una función
- Un nombre requiere leer el cuerpo de la función para entenderse
- El mismo concepto aparece con dos nombres distintos en el mismo módulo
- Un comentario explica qué hace el código (el código debería hacerlo solo)

### 1.3 Carga Germana — El esfuerzo de construcción del modelo mental

Es la carga "buena": el esfuerzo que el lector invierte en entender la abstracción y luego puede reutilizar. Una función bien nombrada genera carga germana — el lector la estudia una vez y la reconoce siempre.

**Principio:** Maximizar carga germana (abstracciones útiles y reutilizables), minimizar extrínseca, aislar intrínseca.

---

## II. Nomenclatura como Contrato Semántico

Un nombre no es una etiqueta. Es un contrato entre quien escribe y quien lee.

### 2.1 Niveles de Precisión Semántica

```
Nivel 0 — Sin semántica:    d, tmp, data, result, flag
Nivel 1 — Tipo como nombre: userArray, isBoolean, strName
Nivel 2 — Qué es:           users, isActive, contractorName
Nivel 3 — Por qué existe:   eligibleContractors, requiresDocumentReview, primaryContactName
```

El código de producción no debería tener nombres en nivel 0 o 1. El nivel 2 es aceptable para variables de ciclo o scope mínimo. El nivel 3 es el estándar para cualquier cosa que atraviesa más de 5 líneas.

### 2.2 Verbos como Señales de Comportamiento

Los nombres de funciones son promesas sobre efectos:

| Prefijo | Promesa implícita | Violación típica |
|---|---|---|
| `get` / `find` | Solo lectura, sin efectos | Modificar estado dentro |
| `create` / `build` | Retorna algo nuevo, sin persistir | Guardar en DB dentro |
| `save` / `persist` | Escribe en almacenamiento | Hacer transformaciones complejas |
| `handle` / `process` | Orquesta, puede tener efectos | Usarlo para lógica pura |
| `is` / `has` / `can` | Retorna booleano | Retornar otra cosa |
| `calculate` / `compute` | Lógica pura, determinista | Llamar APIs o leer estado externo |

Si una función viola su promesa semántica, el nombre miente. Un nombre que miente es más peligroso que ningún nombre.

### 2.3 Consistencia del Vocabulario del Dominio

En un mismo proyecto, el mismo concepto debe tener siempre el mismo nombre. Si el dominio dice "contractor", el código no puede alternar entre `contractor`, `provider`, `vendor` y `supplier` según el archivo.

Construir y mantener un **glosario del dominio** es parte de la responsabilidad cognitiva. Ver skill `brand-i18n-guardian` para la estructura de glosario.

---

## III. Estructura y Flujo

### 3.1 Anidamiento como Deuda Cognitiva

Cada nivel de anidamiento agrega una condición que el lector debe mantener en memoria de trabajo mientras procesa el código interior. A dos niveles, el lector sostiene dos contextos simultáneos. A cuatro, la mayoría de los lectores comete errores.

**La heurística de dos niveles no es arbitraria:** es el límite empírico donde la memoria de trabajo empieza a saturarse con la estructura, no con el problema.

Técnicas de reducción en orden de preferencia:

**Early return** — para guardianes y validaciones:
```js
// Antes
function processDocument(doc) {
  if (doc) {
    if (doc.isValid) {
      if (!doc.isExpired) {
        return transform(doc)
      }
    }
  }
  return null
}

// Después
function processDocument(doc) {
  if (!doc) return null
  if (!doc.isValid) return null
  if (doc.isExpired) return null
  return transform(doc)
}
```

**Extracción de función** — para bloques con identidad semántica propia:
```js
// El bloque tiene nombre propio → extraer
const eligibleDocs = documents.filter(isEligibleForProcessing)

function isEligibleForProcessing(doc) {
  return doc && doc.isValid && !doc.isExpired
}
```

**Aplanamiento de datos** — para anidamiento que viene de la estructura del dato:
```js
// El anidamiento es del dato, no de la lógica → transformar primero
const contractors = response.data.entities.contractors  // una vez
contractors.filter(isActive).map(toSummary)             // lógica plana
```

### 3.2 Longitud de Función como Señal, No como Regla

30 líneas no es una ley. Es una señal de alarma. Una función de 40 líneas que hace una sola cosa con claridad es mejor que dos funciones de 15 que comparten estado implícito.

La pregunta correcta no es "¿cuántas líneas tiene?" sino:

1. **¿Tiene un único nivel de abstracción?** Una función no debería mezclar lógica de negocio de alto nivel con detalles de implementación en el mismo cuerpo.
2. **¿Tiene un único propósito declarable en el nombre?** Si el nombre requiere "y" o "o", la función hace dos cosas.
3. **¿El lector puede predecir el final desde el principio?** Si debe leer todo el cuerpo para entender qué retorna, está procesando demasiado a la vez.

### 3.3 Un Solo Nivel de Abstracción por Función

```js
// Mal: mezcla niveles de abstracción
async function syncContractors() {
  const response = await fetch('/api/contractors')       // I/O de bajo nivel
  const data = await response.json()                     // I/O de bajo nivel
  const active = data.filter(c => !c.deletedAt && c.status === 'active')  // lógica de dominio
  await db.contractors.bulkUpsert(active)                // persistencia
  logger.info(`Synced ${active.length} contractors`)     // logging
}

// Bien: un nivel de abstracción, detalles extraídos
async function syncContractors() {
  const contractors = await fetchActiveContractors()
  await persistContractors(contractors)
  logSyncResult(contractors.length)
}
```

---

## IV. Comentarios como Arqueología del Razonamiento

### 4.1 Lo que el código no puede decir

El código puede mostrar el **qué** y el **cómo**. No puede mostrar:
- Por qué se eligió este algoritmo sobre otro
- Qué invariante del negocio hace que esta condición sea necesaria
- Por qué este workaround existe (y el ticket/issue que lo originó)
- Qué pasó cuando se intentó el enfoque obvio y falló

Eso es lo que merece un comentario.

### 4.2 Taxonomía de Comentarios Válidos

```js
// ✓ Decisión de negocio no obvia
// Los contractors con status 'pending' más de 30 días se consideran
// inactivos por regulación contractual (ver cláusula 4.2 del contrato marco)
const INACTIVITY_THRESHOLD_DAYS = 30

// ✓ Workaround con contexto
// La API de Kemira retorna timestamps en UTC-3 sin indicarlo en headers.
// Compensación manual hasta que corrijan en v2.1 (ticket #KEM-447)
const adjustedDate = new Date(timestamp.getTime() + 3 * 60 * 60 * 1000)

// ✓ Advertencia sobre consecuencias no evidentes
// NO modificar el orden de estas operaciones: la validación de firma
// debe ocurrir antes de deserializar para evitar padding oracle attacks
validateSignature(payload)
const data = deserialize(payload)

// ✗ Comenta el qué (el código ya lo dice)
// Filtra los contractors activos
const active = contractors.filter(c => c.isActive)

// ✗ Historia que pertenece a git, no al código
// Cambiado por Juan el 15/03 porque antes fallaba
```

---

## V. Adaptación por Lenguaje y Paradigma

Las heurísticas no son universales. Se aplican con criterio según el contexto:

### JavaScript / TypeScript
- Early returns son idiomáticos y esperados
- Callbacks anidados son señal de deuda cognitiva; preferir async/await o composición
- Los tipos son documentación: un tipo bien nombrado reemplaza un comentario

### Python
- La filosofía "flat is better than nested" está en el Zen del lenguaje — aplicar sin fricción
- List comprehensions de una línea son idiomáticas; anidadas o con condición compleja → extraer
- Docstrings para funciones públicas no son opcionales: son el contrato del módulo

### SQL
- Las reglas de anidamiento se traducen a CTEs (WITH clauses) en lugar de subqueries anidadas
- Los nombres de CTEs son la oportunidad de documentar el propósito de cada paso
- Un alias de columna es un contrato semántico igual que una variable

### Funcional (cualquier lenguaje)
- La composición de funciones es el mecanismo primario de reducción de carga
- Funciones puras son inherentemente más legibles: sin estado oculto que rastrear
- El pipeline de transformación debe leerse como prosa de dominio

---

## VI. Proceso de Auditoría

Dado un archivo o fragmento de código, revisar en este orden:

### Fase 1: Vocabulario
```
1. ¿Existen nombres en nivel 0 o 1? (ver II.1)
2. ¿Alguna función viola su promesa semántica? (ver II.2)
3. ¿El mismo concepto tiene múltiples nombres en el módulo?
```

### Fase 2: Estructura
```
1. ¿Alguna función supera dos niveles de anidamiento?
2. ¿Alguna función mezcla niveles de abstracción?
3. ¿Alguna función tiene más de un propósito declarable?
```

### Fase 3: Comentarios
```
1. ¿Hay comentarios que repiten lo que el código ya dice?
2. ¿Hay decisiones de negocio no obvias sin comentario?
3. ¿Hay workarounds sin contexto de por qué existen?
```

### Formato de reporte

```
AUDITORÍA COGNITIVA — [archivo/módulo]

CARGA EXTRÍNSECA ALTA:
- [línea X] Nombre sin semántica: `data` → sugerir: `pendingContractorDocuments`
- [línea X-Y] Tres niveles de anidamiento → aplicar early return
- [línea X] Función viola promesa: `getUser` modifica estado

MEZCLA DE ABSTRACCIÓN:
- [función X] Combina I/O, lógica de dominio y logging → extraer en 3 funciones

COMENTARIOS:
- [línea X] Comentario redundante: eliminar
- [función X] Decisión no obvia sin documentar: agregar contexto de negocio

VOCABULARIO INCONSISTENTE:
- `contractor` / `provider` / `vendor` usados para el mismo concepto → unificar
```

---

## VII. Tradeoffs y Cuándo Ceder

La responsabilidad cognitiva no es dogma. Hay tensiones reales:

**Early return vs un solo nivel de abstracción**
Si los guardianes son complejos, extraerlos a `isEligible()` es mejor que acumular early returns que distraen del flujo principal.

**Nombre descriptivo vs nombre breve**
En scope mínimo (iteradores, lambdas de una línea), `c` es aceptable si el contexto es obvio. `c` en una función de 20 líneas no lo es.

**Función pura pequeña vs función orquestadora legible**
No toda extracción mejora la legibilidad. Una función de 8 líneas que llama a cuatro funciones de 2 líneas cada una puede generar más fricción que mantenerla plana.

**Criterio de decisión siempre:** ¿Qué versión requiere menos memoria de trabajo para ser entendida por alguien que no escribió el código?

---

## Filosofía Operativa

> El código se escribe una vez. Se lee docenas de veces. La deuda cognitiva se paga en cada lectura.

Cada nombre vago, cada nivel de anidamiento innecesario, cada comentario ausente es un impuesto que paga el próximo lector — que puede ser vos mismo en seis meses.
