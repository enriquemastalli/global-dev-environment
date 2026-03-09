---
name: zero-patch-policy
description: "Sistema de razonamiento para intervenir código existente sin aumentar deuda técnica. Úsame siempre que arregles un bug, modifiques lógica existente, añadas una feature sobre código legacy, o evalúes si una solución propuesta ataca la causa raíz o parchea el síntoma. Aplica también cuando debas decidir entre refactorizar en el momento o diferir la mejora."
---

# Zero Patch Policy

Sistema de razonamiento para intervenir código existente de forma que lo deje mejor de lo que estaba — no solo funcionando. No es una prohibición de cambios rápidos: es un modelo mental para distinguir cuándo un cambio rápido es la decisión correcta y cuándo es deuda técnica disfrazada de solución.

## Principio Fundacional

Todo bug es un síntoma. El código que lo contiene es el diagnóstico. La pregunta no es "¿cómo hago que esto deje de fallar?" sino "¿por qué el sistema permitió que esto fallara?".

Un parche responde la primera pregunta. Una solución responde la segunda. La diferencia no es el tiempo que toma — es el nivel de análisis que precede al cambio. Un parche puede escribirse en dos líneas; una solución a veces también. Lo que las distingue es si el problema puede volver por la misma puerta.

---

## I. El Diagnóstico Antes del Cambio

### 1.1 La Taxonomía de Causas

Antes de escribir una sola línea, clasificar la naturaleza del problema:

**Causa de implementación** — el código hace algo distinto a lo que se intentó. La lógica es correcta en el diseño, incorrecta en la ejecución. La solución está en el mismo nivel de abstracción.

**Causa de diseño** — el código hace exactamente lo que se intentó, pero el diseño estaba equivocado. La solución requiere cambiar la abstracción, no solo la implementación.

**Causa de contrato** — el código asume algo sobre su entorno (una API, un tipo de dato, un comportamiento de una dependencia) que dejó de ser cierto. La solución está en el límite del sistema, no en su interior.

**Causa de estado** — el problema solo ocurre bajo una secuencia específica de operaciones. El código no gestiona correctamente el ciclo de vida de su estado. La solución requiere modelar el estado posible, no agregar condiciones ad hoc.

Identificar la taxonomía antes de tocar código evita el error más frecuente: aplicar una solución del nivel equivocado. Un bug de diseño no se resuelve con una mejor implementación — se posterga.

### 1.2 El Árbol de Causas

Para bugs no triviales, trazar el árbol de causas antes de intervenir:

```
Síntoma observable
└─ ¿Por qué ocurre esto?
   └─ Causa directa
      └─ ¿Por qué existe esa causa?
         └─ Causa intermedia
            └─ ¿Por qué existe esa causa?
               └─ Causa raíz ← aquí interviene una solución real
```

**La señal de que se llegó a la causa raíz:** la respuesta a "¿por qué?" ya no es código — es una decisión de diseño, un supuesto incorrecto, o una responsabilidad mal asignada.

```
Síntoma: "El listado de contractors muestra datos de otro tenant"

¿Por qué? → La query no filtra por tenant_id
¿Por qué? → La función getContractors no recibe tenant_id como parámetro
¿Por qué? → El servicio asume que tenant_id se filtra en la capa de autorización
¿Por qué? → No existe una convención establecida sobre dónde ocurre el filtrado de tenant

Causa raíz: Ausencia de convención arquitectural sobre el scope de tenant
Solución: Establecer la convención + corregir todas las queries afectadas
Parche: Agregar WHERE tenant_id = ? solo a esta query
```

El parche cierra esta instancia del bug. La solución cierra la clase de bugs.

---

## II. El Espectro de Intervención

### 2.1 Cuatro Modos de Intervención

No toda intervención debe ser una refactorización completa. La elección del modo depende del riesgo, el alcance y el contexto:

**Modo 1 — Corrección puntual con mejora local**
Corregir el bug + aplicar Boy Scout en el archivo tocado. Sin cambios de abstracción. Apropiado cuando la causa es de implementación y el diseño es correcto.

**Modo 2 — Corrección con refactorización de función**
Corregir el bug reescribiendo la función afectada. La interfaz pública no cambia. Apropiado cuando la causa es de implementación compleja o cuando la función tiene múltiples problemas relacionados.

**Modo 3 — Corrección con refactorización de módulo**
Corregir el bug reorganizando responsabilidades dentro del módulo. Puede implicar cambios de interfaz. Apropiado cuando la causa es de diseño y el problema está contenido en un módulo.

**Modo 4 — Corrección con cambio arquitectural**
Corregir el bug introduciendo una nueva abstracción o moviendo responsabilidades entre capas. Requiere análisis de impacto. Apropiado cuando la causa es de contrato o diseño sistémico.

**Criterio de selección:** el modo mínimo que elimina la causa raíz sin introducir riesgo desproporcionado. Siempre documentar por qué se eligió el modo y qué deuda queda pendiente si se eligió uno menor al ideal.

### 2.2 El Costo Real de un Parche

Un parche no es gratis — tiene un costo diferido:

```
Costo de un parche =
  Tiempo ahorrado ahora
  - (Probabilidad de recurrencia × Costo de la próxima instancia)
  - (Complejidad añadida × Número de lecturas futuras del código)
  - (Superficie de bugs relacionados que no se cierran)
```

En la mayoría de los casos, este cálculo produce un número negativo — el parche es más caro que la solución si se mide en el tiempo correcto. La ilusión de que el parche es más barato viene de no contabilizar los costos diferidos.

### 2.3 Cuándo el Parche Es la Decisión Correcta

Existen contextos donde parchear es legítimo y documentarlo es responsabilidad:

- **Hotfix en producción:** el sistema está caído o degradado, el tiempo de resolución completa supera el tiempo de tolerancia. Parchear ahora + crear ticket de resolución real es la decisión correcta.
- **Código en proceso de eliminación:** si el módulo será reemplazado en menos de un sprint, invertir en una solución completa es desperdicio.
- **Causa raíz fuera del alcance del ticket:** el problema real requiere cambios en otra capa o sistema que excede el scope acordado.

En los tres casos, el parche debe ir acompañado de:
1. Un comentario en el código que documenta la causa raíz conocida
2. Un ticket creado con la resolución pendiente
3. El riesgo de recurrencia explicitado

---

## III. La Regla del Boy Scout como Práctica Sistemática

### 3.1 El Alcance Correcto de "Dejar Más Limpio"

La regla del Boy Scout no significa refactorizar todo lo que se toca — significa no añadir desorden al desorden existente y corregir lo que está al alcance sin riesgo.

**Dentro del alcance siempre:**
- Imports no usados en el archivo modificado
- Variables declaradas y no usadas
- `console.log` de debugging
- Tipos implícitos donde el tipo es obvio
- Nombres de variables que violan las convenciones del proyecto
- Comentarios que describen código eliminado

**Dentro del alcance si el riesgo es bajo:**
- Extracción de constantes mágicas a variables con nombre
- Simplificación de condiciones booleanas complejas
- Extracción de bloques de lógica repetidos en la misma función

**Fuera del alcance (requiere ticket separado):**
- Cambios que afectan la interfaz pública del módulo
- Refactorizaciones que requieren cambios en múltiples archivos
- Mejoras que no tienen relación con el cambio que se está haciendo

### 3.2 El Orden de las Operaciones

Al intervenir un archivo, el orden importa para mantener claridad sobre qué fue el cambio funcional y qué fue la mejora de calidad:

```
1. Entender el código tal como está (no editar aún)
2. Identificar la causa raíz del problema
3. Diseñar la solución
4. Aplicar la solución (cambio funcional)
5. Aplicar Boy Scout (mejoras de calidad en el mismo archivo)
6. Revisar que las mejoras de calidad no introdujeron cambios funcionales
```

Este orden permite que el diff sea interpretable: los cambios funcionales son separables de las mejoras de calidad.

---

## IV. Inmutabilidad como Modelo Mental, No como Regla de Sintaxis

### 4.1 Por Qué `const` No Es la Solución

La preferencia por `const` sobre `let` es una consecuencia de un principio más profundo: **el estado mutable es la principal fuente de bugs que solo ocurren bajo secuencias específicas de operaciones**.

`const` no garantiza inmutabilidad — garantiza que la referencia no cambia. Un objeto declarado con `const` es perfectamente mutable:

```ts
const contractor = { status: 'active' }
contractor.status = 'suspended'  // válido, const no lo previene
```

El principio real es: **minimizar el estado que puede cambiar a lo largo de la ejecución de una función o módulo**.

### 4.2 Señales de Estado Mutable Problemático

```ts
// Señal 1: variable que se reasigna en múltiples ramas
let result
if (condition1) {
  result = computeA()
} else if (condition2) {
  result = computeB()
} else {
  result = computeC()
}

// Solución: expresión que retorna valor, sin estado intermedio mutable
const result = condition1 ? computeA()
             : condition2 ? computeB()
             : computeC()

// O si la lógica es compleja:
const result = resolveResult(condition1, condition2)
```

```ts
// Señal 2: acumulación por mutación
let total = 0
for (const item of items) {
  total += item.value
}

// Solución: transformación sin estado mutable
const total = items.reduce((sum, item) => sum + item.value, 0)
```

```ts
// Señal 3: objeto construido por mutación sucesiva
const payload: any = {}
payload.name = contractor.name
if (contractor.email) payload.email = contractor.email
payload.status = 'active'

// Solución: construcción declarativa
const payload = {
  name: contractor.name,
  ...(contractor.email && { email: contractor.email }),
  status: 'active' as const,
}
```

### 4.3 Cuándo la Mutación Es Legítima

La mutación no es inherentemente mala — es innecesaria cuando existe una alternativa igualmente clara. Es legítima cuando:

- La transformación sobre una colección grande haría copias costosas innecesarias
- El algoritmo es inherentemente imperativo (ordenamiento in-place, procesamiento de streams)
- La claridad de la versión mutante es superior a la declarativa para ese caso específico

El criterio es si un lector puede razonar sobre todos los estados posibles de la variable a lo largo de su vida. Si la respuesta es no, la mutación está generando carga cognitiva que no paga.

---

## V. Gestión de Deuda Técnica Existente

### 5.1 El Inventario de Deuda

Al intervenir código legacy, la deuda existente puede ser de distintos tipos con distinto costo de resolución:

| Tipo de deuda | Costo de resolución | Costo de ignorar | Prioridad |
|---|---|---|---|
| Tipos `any` / casting sin validación | Bajo-medio | Alto (bugs silenciosos) | Alta |
| Funciones con múltiples responsabilidades | Medio | Medio (mantenibilidad) | Media |
| Duplicación de lógica | Medio | Alto (inconsistencia) | Alta |
| Nombres sin semántica | Bajo | Medio (legibilidad) | Alta (bajo riesgo) |
| Ausencia de manejo de errores | Medio | Alto (resiliencia) | Alta |
| Arquitectura incorrecta | Alto | Variable | Requiere planificación |

### 5.2 El Protocolo de Deuda Descubierta

Cuando se descubre deuda durante una intervención que excede el alcance del cambio:

```
1. Documentar en el código con un comentario estructurado:
   // TODO(deuda): [descripción del problema] [causa raíz si se conoce]
   // Contexto: [por qué existe] [riesgo si no se resuelve]
   // Resolución: [qué requeriría arreglarlo]

2. Crear ticket con:
   - El fragmento de código afectado
   - La causa raíz conocida
   - El riesgo de no resolverlo
   - El alcance estimado de la solución

3. No resolver en el mismo PR si:
   - El cambio afecta la interfaz pública del módulo
   - Requiere cambios en múltiples archivos no relacionados con el ticket actual
   - El riesgo de introducir regresiones supera el beneficio inmediato
```

---

## VI. Proceso de Diagnóstico y Resolución

### Para cada intervención, seguir este protocolo:

**Paso 1 — Reproducir antes de leer código**
Entender el comportamiento observable antes de leer la implementación. La reproducción guía la lectura; sin ella, se lee buscando confirmar hipótesis en lugar de entender el sistema.

**Paso 2 — Trazar el árbol de causas**
Aplicar el árbol de causas (sección I.2) hasta llegar a una causa que no sea código — sea una decisión de diseño o un supuesto incorrecto.

**Paso 3 — Elegir el modo de intervención**
Seleccionar el modo de intervención (sección II.1) con justificación explícita. Si se elige un modo menor al ideal, documentar la deuda pendiente.

**Paso 4 — Escribir la solución**
Implementar el cambio funcional. Si la solución requiere cambios en múltiples lugares, hacerlos todos — una solución parcial es un parche más sofisticado.

**Paso 5 — Aplicar Boy Scout**
Mejoras de calidad en el archivo tocado, dentro del alcance definido (sección III.1).

**Paso 6 — Verificar que el árbol de causas está cerrado**
¿Puede el mismo bug volver por la misma puerta? Si la respuesta es sí, el paso 4 fue insuficiente.

### Formato de reporte para intervenciones complejas:

```
DIAGNÓSTICO — [descripción del bug/feature]

CAUSA RAÍZ:
[descripción de la causa raíz, no del síntoma]

TAXONOMÍA: [Implementación | Diseño | Contrato | Estado]

MODO DE INTERVENCIÓN ELEGIDO: [1-4]
JUSTIFICACIÓN: [por qué este modo y no uno mayor]

CAMBIOS FUNCIONALES:
- [archivo]: [descripción del cambio y por qué]

MEJORAS BOY SCOUT:
- [archivo:línea]: [mejora aplicada]

DEUDA DOCUMENTADA:
- [descripción]: [ticket creado / comentario en código]

VERIFICACIÓN:
¿Puede el bug volver por la misma puerta? [Sí/No + justificación]
```

---

## VII. Tradeoffs y Cuándo Ceder

**Causa raíz vs scope del ticket**
Resolver la causa raíz a veces requiere cambios que exceden el scope acordado. En ese caso, la decisión correcta es hacer el parche documentado + el ticket, no resolver silenciosamente más de lo acordado. Los cambios de scope no documentados son riesgo de regresión no controlado.

**Boy Scout vs riesgo de regresión**
En código sin tests, cada mejora de calidad es un cambio que podría romper algo. El Boy Scout debe calibrarse al nivel de cobertura de tests existente. Sin tests, limitarse a cambios de cero impacto funcional (imports, nombres locales, comentarios).

**Inmutabilidad vs legibilidad**
Una cadena de `.reduce()` anidada que "evita mutación" pero requiere 10 minutos de análisis para entenderse es peor que un loop imperativo claro. La inmutabilidad sirve a la legibilidad — cuando compite con ella, la legibilidad gana.

**Refactorizar ahora vs diferir**
Si el código que necesita refactorización no será tocado nuevamente en el futuro previsible, diferir es legítimo. El Boy Scout aplica cuando se abre el archivo, no como tarea proactiva en código estable.

**Criterio de decisión siempre:** ¿El sistema tiene menos formas de llegar al estado de error después de esta intervención que antes? Si la respuesta es no, no es una solución — es un parche.

---

## Filosofía Operativa

> Un bug no es un accidente — es el sistema comportándose exactamente como fue diseñado, bajo condiciones que el diseño no anticipó.

Entender eso cambia la pregunta. No es "¿cómo hago que esto funcione?" sino "¿qué debía ser cierto para que esto no pudiera fallar, y por qué no era cierto?". La respuesta a esa pregunta es la solución. Todo lo demás es posponer el costo.
