---
name: ui-state-guardian
description: "Sistema de razonamiento para diseñar arquitectura de componentes React, gestión de estado y sistemas de diseño en el frontend. Úsame siempre que crees o modifiques componentes React, definas dónde vive el estado, diseñes hooks, apliques estilos, o evalúes si una decisión de arquitectura frontend introduce acoplamiento, duplicación o estados imposibles en la UI."
---

# UI State Guardian

Sistema de razonamiento para diseñar frontends React que sean predecibles, mantenibles y coherentes visualmente. No es una lista de reglas de estilo — es un modelo mental sobre cómo fluyen los datos, dónde vive la lógica, y por qué esas decisiones determinan si un componente puede evolucionar sin romper lo que lo rodea.

## Principio Fundacional

Un componente React es una función de su estado hacia una representación visual. Cuanto más puro sea ese mapeo — cuanto menos dependa el componente de cómo se obtuvo su estado — más predecible, testeable y reutilizable es.

La mayoría de los problemas de arquitectura frontend no son bugs — son decisiones sobre dónde vive la lógica que se tomaron sin un modelo claro. El resultado es componentes que saben demasiado, estado que vive en el lugar equivocado, y UIs que no reflejan fielmente lo que el sistema está haciendo.

---

## I. La Jerarquía de Responsabilidades

### 1.1 Tres Capas, Tres Contratos

Una arquitectura frontend bien diseñada tiene tres capas con responsabilidades distintas y contratos claros entre ellas:

```
┌─────────────────────────────────────────────────────────┐
│  CAPA DE DATOS                                          │
│  Hooks personalizados                                   │
│  - Fetching, mutaciones, caché                          │
│  - Lógica de negocio y transformaciones                 │
│  - Manejo de estados async (loading, error, success)    │
│  - NO sabe cómo se renderiza nada                       │
└───────────────────────┬─────────────────────────────────┘
                        │ props tipadas
┌───────────────────────▼─────────────────────────────────┐
│  CAPA DE COMPOSICIÓN                                    │
│  Componentes contenedores                               │
│  - Conectan hooks con componentes visuales              │
│  - Deciden qué renderizar según el estado               │
│  - NO tienen lógica de fetching directa                 │
│  - NO tienen lógica de presentación                     │
└───────────────────────┬─────────────────────────────────┘
                        │ props tipadas
┌───────────────────────▼─────────────────────────────────┐
│  CAPA VISUAL                                            │
│  Componentes puros de UI                                │
│  - Reciben datos por props, emiten eventos por callbacks│
│  - Sin efectos secundarios, sin fetch, sin estado global│
│  - Reutilizables en cualquier contexto                  │
│  - Testeables sin mocks de red                          │
└─────────────────────────────────────────────────────────┘
```

**El contrato fundamental:** cada capa solo conoce la interfaz de la capa inmediatamente adyacente. Un componente visual no sabe si sus datos vienen de una API, de localStorage o de un test.

### 1.2 El Diagnóstico de Responsabilidad Incorrecta

Señales de que la lógica está en el lugar equivocado:

| Síntoma | Causa | Consecuencia |
|---|---|---|
| `fetch` o `axios` dentro de un componente | Lógica de datos en capa visual | No reutilizable, no testeable aisladamente |
| `useEffect` con lógica de negocio en componente | Lógica de datos en capa visual | Efectos difíciles de rastrear y componer |
| Estado derivado recalculado en cada render | Transformación en capa visual | Performance innecesariamente degradada |
| Mismo fetch en dos componentes distintos | Sin capa de datos compartida | Inconsistencia de datos y requests duplicados |
| Componente que recibe 10+ props | Composición incorrecta | Acoplamiento excesivo, difícil de cambiar |

---

## II. Hooks como Unidades de Lógica Reutilizable

### 2.1 El Hook como Contrato de Datos

Un hook personalizado no es solo "lógica extraída de un componente" — es la interfaz pública de un caso de uso. Su nombre debe reflejar el qué del negocio, no el cómo técnico.

```ts
// Mal: nombre técnico que refleja implementación
function useFetch<T>(url: string) { ... }

// Bien: nombre de dominio que refleja el caso de uso
function useContractorDocuments(contractorId: string) {
  // Encapsula: qué endpoint, cómo se transforma, qué estados expone
}
```

### 2.2 La Interfaz Completa de un Hook de Datos

Un hook de datos siempre expone los cuatro estados posibles de una operación asíncrona — no solo el caso exitoso:

```ts
interface UseContractorDocumentsResult {
  // Estado de datos
  documents: ContractorDocument[]
  total: number

  // Estados de ciclo de vida — todos necesarios
  isLoading: boolean    // primera carga
  isFetching: boolean   // refetch en background (datos previos aún visibles)
  error: AppError | null

  // Acciones
  refetch: () => void
  uploadDocument: (file: File) => Promise<void>
  isUploading: boolean
  uploadError: AppError | null
}

function useContractorDocuments(contractorId: string): UseContractorDocumentsResult {
  const [documents, setDocuments] = useState<ContractorDocument[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [isFetching, setIsFetching] = useState(false)
  const [error, setError] = useState<AppError | null>(null)

  // ... implementación

  return { documents, total, isLoading, isFetching, error, refetch, uploadDocument, isUploading, uploadError }
}
```

**La distinción `isLoading` vs `isFetching`:** `isLoading` es true solo en la primera carga (sin datos previos). `isFetching` es true en cualquier request activo, incluyendo revalidaciones donde los datos anteriores siguen visibles. Confundirlos resulta en UIs que muestran skeleton screens cuando ya tienen datos.

### 2.3 Composición de Hooks

Los hooks se componen igual que las funciones. Un hook complejo debe construirse sobre hooks más simples con responsabilidades acotadas:

```ts
// Hook de infraestructura — solo sabe hacer fetching
function useApiRequest<T>(endpoint: string) { ... }

// Hook de dominio — combina fetching con lógica de negocio
function useContractorCompliance(contractorId: string) {
  const { data, isLoading, error } = useApiRequest<ContractorComplianceResponse>(
    `/contractors/${contractorId}/compliance`
  )

  // Lógica de negocio en la capa de datos, no en el componente
  const complianceStatus = useMemo(() => {
    if (!data) return null
    return calculateComplianceStatus(data.documents, data.requirements)
  }, [data])

  const pendingItems = useMemo(() =>
    data?.requirements.filter(r => !r.fulfilled) ?? [],
    [data]
  )

  return { complianceStatus, pendingItems, isLoading, error }
}
```

---

## III. Componentes: Pureza y Composición

### 3.1 El Espectro de Pureza

Los componentes no son puros o impuros — existen en un espectro según cuántas fuentes de datos conocen:

```
Más puro ←──────────────────────────────────────────→ Más acoplado

Button        ContractorCard    ContractorList    ContractorPage
(solo props)  (solo props)      (hook interno)    (múltiples hooks)

Testeable     Testeable         Requiere mocks    Requiere contexto
sin mocks     sin mocks         de red            completo
```

**Principio:** Los componentes deben ser tan puros como sea posible dado su nivel en la jerarquía. Un componente hoja (sin hijos que sean componentes de dominio) debería ser completamente puro.

### 3.2 Props como Contrato Visual

Las props de un componente son su API pública. Diseñarlas mal es diseñar un componente que solo funciona en un contexto.

```tsx
// Mal: props acopladas a la forma de la respuesta de API
interface ContractorCardProps {
  contractorData: ContractorApiResponse  // acoplado al schema de la API
}

// Bien: props que expresan lo que el componente necesita renderizar
interface ContractorCardProps {
  name: string
  status: ContractorStatus
  documentCount: number
  onViewDetails: (id: string) => void
  isSelected?: boolean
}
```

La diferencia: el primer diseño hace el componente inutilizable si el schema de la API cambia o si queremos usarlo con datos de otra fuente. El segundo es estable — puede recibir datos de cualquier origen que los tenga.

### 3.3 Límites de Complejidad de Props

Un componente que requiere más de 6-7 props es una señal de que o bien hace demasiado o bien necesita composición:

```tsx
// Señal de alerta: demasiadas props → el componente tiene múltiples responsabilidades
<ContractorCard
  name={...} status={...} documentCount={...}
  pendingDocuments={...} lastActivity={...}
  complianceScore={...} assignedClients={...}
  onEdit={...} onDelete={...} onViewDocuments={...}
/>

// Solución: composición
<ContractorCard name={...} status={...}>
  <ContractorMetrics documentCount={...} complianceScore={...} />
  <ContractorActions onEdit={...} onDelete={...} />
</ContractorCard>
```

---

## IV. Gestión de Estado

### 4.1 Los Cuatro Tipos de Estado

No todo estado es igual. Antes de decidir dónde vive el estado, identificar su tipo:

| Tipo | Definición | Dónde vive | Ejemplo |
|---|---|---|---|
| Estado de servidor | Datos que viven en el backend | Hook de datos + caché | Lista de contractors |
| Estado de UI local | Interacciones efímeras del componente | `useState` en el componente | Modal abierto/cerrado |
| Estado de UI global | Estado de UI compartido entre componentes | Context o store global | Tema, idioma, usuario actual |
| Estado de URL | Estado que debe persistir en navegación | Query params / router | Filtros, paginación, tab activo |

**El error más frecuente:** tratar estado de servidor como estado de UI global — poner datos de API en un store Redux cuando un hook con caché (React Query, SWR) es la respuesta correcta.

### 4.2 Colocar el Estado en el Nivel Correcto

El estado debe vivir en el componente más bajo de la jerarquía que necesite compartirlo:

```
              App
             /   \
          Header  Main
                  /  \
           Sidebar   ContractorList ← estado de selección vive aquí
                         /    \         (si Sidebar también lo necesita,
                    Card    Card        subir al nivel común: Main)
```

**Señales de estado mal ubicado:**
- Prop drilling de más de 2 niveles (el estado debería subir o ir a context)
- Estado global que solo usa un componente (debería bajar al componente)
- Estado duplicado en múltiples componentes (debería subir al ancestro común)

### 4.3 Estado Derivado vs Estado Almacenado

El estado derivado no se almacena — se calcula. Almacenar estado derivado crea la posibilidad de inconsistencia.

```tsx
// Mal: estado derivado almacenado — puede quedar desincronizado
const [documents, setDocuments] = useState<Document[]>([])
const [pendingCount, setPendingCount] = useState(0)  // derivado de documents

// Bien: estado derivado calculado — siempre consistente
const [documents, setDocuments] = useState<Document[]>([])
const pendingCount = useMemo(
  () => documents.filter(d => d.status === 'pending').length,
  [documents]
)
```

---

## V. Estados de Ciclo de Vida en la UI

### 5.1 Los Estados que la UI Debe Reflejar

Toda operación asíncrona tiene estados que el usuario necesita ver. Omitir cualquiera de ellos produce UIs que mienten sobre lo que el sistema está haciendo.

```
Idle → Loading → Success
                └→ Error → (retry) → Loading → ...
```

**En la UI, esto se traduce en:**

```tsx
function ContractorDocuments({ contractorId }: { contractorId: string }) {
  const { documents, isLoading, error, refetch } = useContractorDocuments(contractorId)

  // Estado de carga inicial — sin datos previos
  if (isLoading) return <DocumentListSkeleton />

  // Estado de error — con posibilidad de retry
  if (error) return (
    <ErrorState
      message={error.userMessage}
      onRetry={refetch}
    />
  )

  // Estado vacío — distinto de error y de carga
  if (documents.length === 0) return (
    <EmptyState
      title="Sin documentos"
      description="Este contratista aún no tiene documentos cargados."
    />
  )

  // Estado de datos
  return <DocumentList documents={documents} />
}
```

### 5.2 El Estado Vacío No Es un Error

Un error frecuente es renderizar el mismo componente para "sin datos" y para "lista de datos vacía". Son estados semánticamente distintos con UX distinta:

| Estado | Causa | UX correcta |
|---|---|---|
| Loading | Request en curso | Skeleton que refleja la forma del contenido |
| Error | Request fallido | Mensaje + acción de retry |
| Empty | Request exitoso, cero resultados | Explicación contextual + acción de creación |
| Partial | Algunos datos, request de más en curso | Datos existentes + indicador sutil de actualización |
| Success | Datos completos | Contenido |

### 5.3 Optimistic Updates

Las mutaciones que probablemente van a funcionar (>99% de los casos) deben reflejarse en la UI inmediatamente, con rollback si fallan:

```tsx
function useToggleContractorStatus(contractorId: string) {
  const [contractors, setContractors] = useContractorList()

  async function toggleStatus(currentStatus: ContractorStatus) {
    const optimisticStatus = currentStatus === 'active' ? 'suspended' : 'active'

    // Actualizar UI inmediatamente
    setContractors(prev =>
      prev.map(c => c.id === contractorId ? { ...c, status: optimisticStatus } : c)
    )

    try {
      await api.updateContractorStatus(contractorId, optimisticStatus)
    } catch (error) {
      // Rollback si falla
      setContractors(prev =>
        prev.map(c => c.id === contractorId ? { ...c, status: currentStatus } : c)
      )
      showErrorToast('No se pudo actualizar el estado')
    }
  }

  return { toggleStatus }
}
```

---

## VI. Sistema de Diseño y Variables Semánticas

### 6.1 Por Qué las Variables Semánticas, No los Colores

Un color hardcodeado (`#2563eb`) es un valor sin significado. Una variable semántica (`--color-action-primary`) es una intención. La diferencia es crítica cuando el sistema de diseño evoluciona:

```css
/* Mal: 47 archivos CSS con #2563eb — cambiar el color primario requiere buscar y reemplazar */
.button { background: #2563eb; }
.link { color: #2563eb; }
.badge { border: 1px solid #2563eb; }

/* Bien: 47 archivos CSS con --color-action-primary — cambiar el color es una línea en :root */
.button { background: var(--color-action-primary); }
.link { color: var(--color-action-primary); }
.badge { border: 1px solid var(--color-action-primary); }
```

### 6.2 Taxonomía de Variables Semánticas

Las variables deben organizarse por semántica, no por valor:

```css
:root {
  /* Primitivos — nunca usados directamente en componentes */
  --blue-500: #2563eb;
  --red-500: #dc2626;
  --gray-900: #111827;

  /* Semánticos — los únicos que usan los componentes */
  --color-action-primary: var(--blue-500);
  --color-action-danger: var(--red-500);
  --color-text-primary: var(--gray-900);
  --color-surface-default: white;

  /* Espaciado */
  --space-xs: 4px;
  --space-sm: 8px;
  --space-md: 16px;
  --space-lg: 24px;

  /* Tipografía */
  --font-size-body: 14px;
  --font-size-heading-sm: 18px;
  --font-weight-medium: 500;
}
```

**Regla:** Los primitivos existen para definir semánticos. Los componentes solo usan semánticos. Si se necesita un color nuevo en un componente, la pregunta es "¿qué variable semántica falta?" — no "¿qué hex uso?".

### 6.3 Tokens de Componente

Para componentes con estados visuales complejos, definir tokens específicos del componente que apuntan a los semánticos globales:

```css
/* Tokens del componente Button */
.button {
  --button-bg: var(--color-action-primary);
  --button-text: white;
  --button-border: transparent;
}

.button:hover {
  --button-bg: var(--color-action-primary-hover);
}

.button[data-variant="danger"] {
  --button-bg: var(--color-action-danger);
}

/* El estilo del componente usa solo sus propios tokens */
.button {
  background: var(--button-bg);
  color: var(--button-text);
  border: 1px solid var(--button-border);
}
```

Este patrón hace que cambiar el sistema de diseño no requiera tocar la implementación de cada componente — solo los tokens semánticos globales.

---

## VII. Proceso de Auditoría

### Fase 1: Distribución de Responsabilidades
```
1. ¿Hay componentes con fetch directo o useEffect de datos?
2. ¿Hay lógica de transformación o negocio en el render de un componente?
3. ¿Los hooks tienen nombres que expresan casos de uso del dominio?
```

### Fase 2: Estado
```
1. ¿Hay estado derivado almacenado en useState?
2. ¿Hay prop drilling de más de 2 niveles?
3. ¿El estado de servidor está en un store global en lugar de un hook con caché?
4. ¿El estado de URL (filtros, paginación) vive en useState local?
```

### Fase 3: Estados de Ciclo de Vida en UI
```
1. ¿Toda operación async refleja isLoading, error y success en la UI?
2. ¿El estado vacío está diferenciado del estado de error?
3. ¿La distinción isLoading vs isFetching está implementada correctamente?
```

### Fase 4: Sistema de Diseño
```
1. ¿Hay valores de color en hex, rgb o hsl hardcodeados en estilos?
2. ¿Hay valores de spacing o tipografía hardcodeados?
3. ¿Los componentes usan variables semánticas o primitivos directamente?
```

### Formato de reporte

```
AUDITORÍA FRONTEND — [archivo/componente]

ARQUITECTURA:
- [componente X] fetch directo en componente visual → extraer a hook useXxx
- [componente X] lógica de filtrado en render → mover a useMemo en hook
- [hook X] nombre técnico `useFetch` → renombrar a caso de uso `useContractorDocuments`

ESTADO:
- [línea X] Estado derivado `pendingCount` en useState → convertir a useMemo
- [componente X] Prop drilling de 3 niveles → evaluar Context o subir estado
- [componente X] +8 props → evaluar composición o segregación de responsabilidades

CICLO DE VIDA:
- [componente X] Sin estado de error en UI → agregar ErrorState con retry
- [componente X] Sin estado vacío → agregar EmptyState diferenciado
- [componente X] isLoading cubre refetch → separar isFetching para revalidaciones

SISTEMA DE DISEÑO:
- [archivo.css línea X] Color hardcodeado #2563eb → var(--color-action-primary)
- [archivo.css línea X] margin: 16px hardcodeado → var(--space-md)
```

---

## VIII. Tradeoffs y Cuándo Ceder

**Pureza vs pragmatismo en componentes pequeños**
Un componente de una sola página usado en un solo lugar puede tener su hook inline si extraerlo no agrega claridad. La pureza es un medio, no un fin. El criterio es si el componente podría ser reutilizado o testeado aisladamente con valor real.

**Context vs prop drilling en árboles pequeños**
Agregar Context tiene overhead de diseño. Para árboles de 2-3 niveles donde el estado es simple, prop drilling es más explícito y más fácil de rastrear. Context se justifica cuando el estado cruza más de 2 niveles o es usado por muchos componentes en distintas ramas.

**Optimistic updates vs consistencia**
No toda mutación merece optimistic update. Operaciones destructivas (eliminar, suspender), operaciones donde el backend puede rechazar por reglas de negocio complejas, o operaciones que el usuario esperaría confirmación antes de ver el efecto — estas son mejores con loading explícito.

**Skeleton vs spinner**
Skeleton screens son superiores cuando la forma del contenido es conocida y estable — reducen el layout shift y comunican más sobre qué está cargando. Spinners son aceptables para operaciones donde la forma del resultado es desconocida o muy variable.

**Criterio de decisión siempre:** ¿Si este componente fuera usado en un contexto diferente — otro proyecto, otro equipo, otro dataset — seguiría funcionando sin modificaciones? Si la respuesta es no, hay acoplamiento que vale la pena evaluar.

---

## Filosofía Operativa

> Un componente que sabe cómo se obtienen sus datos no puede ser reutilizado. Un componente que sabe solo cómo renderizar sus datos puede vivir en cualquier parte del sistema.

La arquitectura frontend no es sobre frameworks ni patrones — es sobre contratos. Contratos entre la capa de datos y la de composición, entre la de composición y la visual, entre el sistema de diseño y los componentes. Cuando esos contratos son explícitos y respetados, el frontend puede cambiar sin romper.
