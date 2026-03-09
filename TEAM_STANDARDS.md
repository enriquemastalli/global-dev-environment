# Team Development Standards

Guía para todo el equipo. Define cómo es el **Entorno Global de Desarrollo** y qué esperar.

**Este entorno es universal. Aplica a CUALQUIER proyecto del equipo, sin importar tecnología.**

---

## 1. Para Nuevos Desarrolladores

Cuando trabajas en un proyecto DOSA:

```
1. Clonas el repo (tiene AGENTS.md)
2. Abres el proyecto
3. Sistema detecta automáticamente:
   - Tipo de proyecto
   - Contexto de desarrollo
4. Se cargan los 9 skills relevantes automáticamente
5. Se notifica: "Cargué X, Y, Z skills para esta tarea"
6. Comienzas a trabajar con estándares senior integrados
```

**Beneficio:** No necesitas pensar en qué skill cargar. Se hace automáticamente.

---

## 2. AGENTS.md — Obligatorio

**Cada proyecto DEBE tener `AGENTS.md`.**

Si no lo tiene:

```
Sistema automáticamente:
1. Detecta que falta
2. Lo crea desde template
3. Notifica al dev: "Creé AGENTS.md con estructura base"
4. Dev personaliza según proyecto
```

**Qué contiene AGENTS.md:**

- Ruta base del proyecto
- Reglas específicas del equipo
- Referencias a los 9 skills
- Configuración de BD, APIs, deployment
- Estándares particulares del proyecto

---

## 3. Comportamiento Esperado — Consistente Global

### Debugging

**Orden SIEMPRE:**

1. ¿Validación frontend?
2. ¿Request se envía?
3. ¿Qué datos exactos?
4. ¿Qué responde servidor?
5. ¿Frontend muestra detalles?

**NO hay asumir. SIEMPRE verificar datos reales.**

### Error Handling

Errores SIEMPRE con contexto:

```json
{
  "error": "Datos inválidos",
  "details": {
    "campo": ["Mensaje específico del error"]
  }
}
```

UI muestra detalles específicos, no mensajes genéricos.

### Code Quality

- ✅ Causa raíz, nunca band-aids
- ✅ Código más limpio que antes
- ✅ Cero parches temporales
- ✅ Regla del Boy Scout

### Pre-Acción Checklist

Antes de cualquier cambio:

- Datos reales verificados
- Causa raíz clara
- Contexto propagado
- Fix permanente
- Código más limpio

---

## 4. Los 9 Skills Disponibles Globalmente

Todos los desarrolladores tienen acceso a estos skills:

| Skill                           | Para Qué                     | Cuándo                          |
| ------------------------------- | ---------------------------- | ------------------------------- |
| **zero-patch-policy**           | Código limpio, causa raíz    | Arreglar bugs, modificar legacy |
| **cognitive-responsibility**    | Legibilidad, carga cognitiva | Escribir/refactorizar código    |
| **strict-typescript-contract**  | Tipado fullstack             | Crear tipos, cruzar datos B/F   |
| **edge-performance-first**      | Performance en Workers       | Escribir backend/DB/APIs        |
| **saas-security-enforcer**      | Seguridad multi-tenant       | Endpoints, JWT, webhooks        |
| **ui-state-guardian**           | Arquitectura frontend        | Componentes React, CSS, estado  |
| **brand-i18n-guardian**         | Marca y traducciones         | Textos UI, errores, i18n        |
| **ai-genome-protocol**          | Prompts y genoma IA          | Modificar prompts, XML          |
| **senior-development-protocol** | Debugging, estándares senior | SIEMPRE, toda sesión            |

**Carga Inteligente:**

- Se cargan automáticamente según el contexto
- Se notifica cuáles se cargaron
- NO necesitas pedirlo

---

## 5. Ejemplos Reales

### Ejemplo 1: Crear API Endpoint

```
Dev: "Voy a crear POST /api/contractors"

Sistema detecta: Backend + D1 + validación
Carga automáticamente:
├─ senior-development-protocol (siempre)
├─ edge-performance-first (queries D1)
├─ saas-security-enforcer (JWT, multi-tenant)
├─ strict-typescript-contract (tipos)
└─ zero-patch-policy + cognitive-responsibility (código)

Dev escribe el endpoint con:
✓ Validación Zod con details
✓ Queries D1 seguras (.first<T | null>)
✓ Error handling robusto
✓ Código limpio
✓ Checklist pre-commit automático
```

### Ejemplo 2: Bug en Formulario Frontend

```
Dev: "El formulario de flota no valida año correctamente"

Sistema detecta: Frontend + React + validación
Carga automáticamente:
├─ senior-development-protocol (siempre)
├─ ui-state-guardian (componentes React)
├─ brand-i18n-guardian (mensajes de error)
├─ strict-typescript-contract (tipos)
└─ zero-patch-policy + cognitive-responsibility (código)

Dev sigue protocolo:
1. Verifica datos reales (Network tab)
2. Causa raíz: .max(new Date().getFullYear()) evaluado en build-time
3. Fix: cambiar a .refine()
4. Test: año 2019 ahora funciona
5. Commit: "fix: validación dinámica de año en schema"
```

### Ejemplo 3: Refactorizar Componente Legacy

```
Dev: "Este componente tiene 200 líneas, quiero limpiarlo"

Sistema detecta: Refactorización de código
Carga automáticamente:
├─ senior-development-protocol
├─ zero-patch-policy (causa raíz, no parches)
├─ cognitive-responsibility (max 30 líneas por función)
├─ ui-state-guardian (separar lógica)
└─ strict-typescript-contract (tipos correctos)

Dev sigue protocolo:
1. Identifica la causa raíz de complejidad
2. Extrae funciones (no agrega banditas)
3. Cada función < 30 líneas
4. Código final más limpio que antes
5. Tests pasan
6. Commit: "refactor: simplificar componente X con hooks"
```

---

## 6. Qué NO Esperes

### ❌ Errores Genéricos

```
// Nunca verás:
"Error al procesar solicitud"

// Siempre verás:
"Marca requerida · Placa requerida"
(detalles específicos del error)
```

### ❌ Parches Temporales

```
// Nunca verás:
if (edge_case) { return hardcoded_workaround; }

// Siempre verás:
// Causa raíz identificada y resuelta permanentemente
```

### ❌ Código Complejo

```
// Nunca verás:
function processData() {
  if (x) {
    if (y) {
      if (z) {
        // 50 líneas de lógica anidada
      }
    }
  }
}

// Siempre verás:
// Early returns, funciones < 30 líneas, max 2 niveles de indentación
```

---

## 7. Flujo de Trabajo Garantizado

### Para Todo Cambio de Código

```
1. Leer AGENTS.md (entender contexto del proyecto)
2. Cargar skills automáticamente (sistema lo hace)
3. Aplicar checklist pre-acción (mental):
   - Datos reales verificados
   - Causa raíz clara
   - Contexto propagado
4. Implementar fix/feature:
   - Seguir protocolo senior
   - Code quality robusta
   - Tests si es necesario
5. Commit:
   - Mensaje claro con prefijo (fix:, feat:, refactor:)
   - Referencia el porqué, no el qué
6. Push:
   - A rama propia (no master)
   - PR para revisión
7. Merge:
   - Una vez aprobado
   - Auto-deploy (GitHub Actions)

Resultado: Código consistente, predecible, senior.
```

---

## 8. Soporte y Debugging

Si algo no funciona:

```
1. Revisar AGENTS.md del proyecto
2. Leer DEVELOPMENT_STANDARDS.md (estándares globales)
3. Leer BEHAVIORAL_STANDARDS.md (comportamiento esperado)
4. Revisar config.json (~/.opencode/) para carga inteligente

Si el problema persiste:
→ Contactar al equipo
→ Incluir: proyecto, error, contexto, datos reales
```

---

## 9. Valores del Equipo

### Verificación Antes de Acción

```
❌ "Asumo que..."
✅ "Verifiqué que..."
```

### Causa Raíz, No Síntomas

```
❌ "Voy a agregar un if para esquivar esto"
✅ "La causa raíz es X, voy a resolver aquí"
```

### Código Limpio Siempre

```
❌ "Hago funcionar rápido, después limpio"
✅ "Esto quedará más limpio que antes"
```

### Contexto Completo

```
❌ "Error al procesar solicitud"
✅ "Marca requerida · Placa requerida"
```

### Consistencia Global

```
❌ "En mi proyecto usamos X, en el otro Y"
✅ "Los 9 skills + protocolo senior en TODO lado"
```

---

## 10. Para Líderes Técnicos

**Qué esperar de este ambiente:**

- ✅ **Debugging predecible:** Científico, verificable, sin asumir
- ✅ **Code quality consistente:** Causa raíz, cero parches
- ✅ **Error handling robusto:** Contexto completo siempre
- ✅ **Onboarding simplificado:** Nuevos devs saben qué esperar
- ✅ **Reducción de deuda técnica:** Por definición
- ✅ **Escalabilidad:** El mismo protocolo en 100 proyectos

**Lo que NO esperes:**

- ❌ Parches rápidos que crean deuda
- ❌ Errores genéricos que no dicen qué falló
- ❌ Código complejo sin refactor
- ❌ Debugging aleatorio sin método
- ❌ Inconsistencias entre desarrolladores

---

## Conclusión

**Este entorno garantiza:**

Que sin importar quién trabajaje, en qué proyecto, en qué momento, el comportamiento sea:

✅ **Consistente** — Mismo protocolo siempre  
✅ **Senior** — Estándares de 20+ años integrados  
✅ **Verificable** — Datos reales, no asumir  
✅ **Robusto** — Error handling completo  
✅ **Limpio** — Código mejor que antes  
✅ **Escalable** — Funciona en 1 o 100 proyectos
