---
name: brand-i18n-guardian
description: "Sistema de razonamiento para arquitectura multiidioma y coherencia de marca en aplicaciones. Úsame cuando diseñes, audites o modifiques cualquier superficie textual de una app: UI, notificaciones, errores, emails, metadatos, documentación de usuario. Aplica independientemente del stack tecnológico. Úsame también cuando agregues claves a archivos de idioma, definas convenciones de nomenclatura, o detectes riesgo de inconsistencia terminológica de marca."
---

# Brand i18n Guardian

Sistema de razonamiento para diseñar y mantener la arquitectura multiidioma de aplicaciones con coherencia de marca. No es un checklist: es una capacidad de análisis transferible a cualquier proyecto, stack o idioma.

## Principio Fundacional

Toda decisión de traducción es simultáneamente una decisión de arquitectura y una decisión de identidad. Una clave mal nombrada corrompe la mantenibilidad. Una palabra fuera de glosario corrompe la marca. Son el mismo problema.

---

## I. Diagnóstico de Arquitectura i18n

Antes de agregar o modificar cualquier texto, razonar sobre la estructura existente:

### 1.1 Mapa de Superficies Textuales

Identificar todas las superficies donde aparece texto en la aplicación:

| Superficie | Características | Riesgo de Hardcode |
|---|---|---|
| UI Components | Corto, contextual, frecuente | Alto |
| Estados vacíos | Narrativo, empático | Medio |
| Notificaciones / Toasts | Breve, urgente | Alto |
| Mensajes de error | Técnico→Negocio, empático | Muy alto |
| Placeholders / Labels | Instruccional, mínimo | Alto |
| Emails transaccionales | Largo, formal | Medio |
| Metadatos SEO | Estructurado, keywords | Bajo |
| Documentación in-app | Extenso, jerárquico | Bajo |
| Logs / Consola | Solo para devs, nunca i18n | N/A |

**Regla:** Los logs de consola y mensajes de depuración son la única superficie exenta de i18n. Todo lo demás que llegue al usuario final debe estar externalizado.

### 1.2 Evaluación de Estructura de Archivos

Un sistema i18n bien diseñado debe resolver:

**Granularidad de claves** — ¿Flat o anidado?
- Flat (`error.network.timeout`) → fácil de buscar, difícil de escalar
- Anidado (`{ error: { network: { timeout: "" } } }`) → mejor organización, riesgo de sobre-anidamiento
- **Criterio:** Máximo 3 niveles de profundidad. Si necesitas 4, el dominio está mal definido.

**Namespacing** — ¿Por componente o por dominio semántico?
- Por componente: `dashboard.header.title` → acoplado a la UI
- Por dominio: `contractor.status.active` → sobrevive refactors de UI
- **Criterio:** Preferir dominio semántico siempre que el texto no sea exclusivo de un componente único.

**Fallback chain** — ¿Qué ocurre si una clave no existe en el idioma target?
- Definir siempre idioma base (generalmente `es` en proyectos latinoamericanos)
- El fallback al idioma base es aceptable temporalmente; el fallback a la clave cruda (`contractor.status.active`) es inaceptable en producción.

### 1.3 Convenciones de Nomenclatura

Evaluar y/o proponer convenciones antes de agregar claves:

```
[dominio].[entidad].[estado|acción|atributo]

Ejemplos correctos:
  contractor.document.expired
  session.error.unauthorized
  form.validation.required

Ejemplos incorrectos:
  documentoContratista_vencido   ← mezcla idiomas en la clave
  error1                         ← sin semántica
  Button_Submit_Text             ← acoplado a componente + PascalCase inconsistente
```

**Regla de oro:** La clave debe ser legible como frase técnica sin necesidad de ver su valor.

---

## II. Identidad Lingüística de Marca

### 2.1 Principio de Tensión

Siempre existe tensión entre lo que el idioma target diría naturalmente y lo que la marca requiere. El guardian no resuelve esta tensión eligiendo uno sobre otro — la hace explícita y documenta la decisión.

Ejemplo de tensión:
- Uso natural en español: "Crear agente" o "Nuevo chatbot"
- Requerimiento de marca: "Diseñar Genoma" / "Evolucionar"
- Resolución: La marca gana siempre. Documentar en glosario con justificación narrativa.

### 2.2 Estructura del Glosario de Marca

El glosario no es una lista de palabras prohibidas. Es un sistema de equivalencias con contexto:

```
TÉRMINO DE MARCA | CONTEXTO DE USO | ALTERNATIVAS PROHIBIDAS | JUSTIFICACIÓN
```

Cada proyecto debe construir y mantener su propio glosario. El guardian sabe cómo poblarlo y cómo consultarlo. Ejemplo de estructura:

```json
{
  "glosario": [
    {
      "termino_canonical": "Humano Sintético",
      "variantes_aceptadas": ["HS"],
      "prohibidos": ["Bot", "Chatbot", "Agente virtual", "Asistente"],
      "contextos": {
        "ui_label": "Humano Sintético",
        "ui_abbrev": "HS",
        "documentacion": "Humano Sintético",
        "error_message": "tu Humano Sintético"
      },
      "justificacion": "Identidad narrativa coherente del framework GENOMA.IA"
    },
    {
      "termino_canonical": "Diseñar Genoma",
      "variantes_aceptadas": ["Evolucionar"],
      "prohibidos": ["Crear prompt", "Configurar bot", "Setup"],
      "contextos": {
        "accion_creacion": "Diseñar Genoma",
        "accion_iteracion": "Evolucionar",
        "cta_boton": "Diseñar Genoma"
      },
      "justificacion": "Distinción narrativa entre creación e iteración"
    }
  ]
}
```

### 2.3 Auditoría de Coherencia Terminológica

Al revisar código o textos existentes, buscar activamente:

1. **Sinónimos no canónicos** — palabras del glosario prohibido que aparecen en archivos de idioma o hardcodeadas
2. **Anglicismos innecesarios** — cuando existe término canónico en el idioma target
3. **Inconsistencia de registro** — mezcla de tuteo/ustedeo, formal/informal en la misma superficie
4. **Términos técnicos expuestos** — errores de API, códigos HTTP, nombres de variables que llegan al usuario final

---

## III. Transformación de Errores Técnicos

Este es el punto de mayor riesgo y el más frecuentemente mal ejecutado.

### 3.1 Capas de Transformación

```
Error técnico (API/sistema)
    ↓
Clasificación por tipo
    ↓
Mensaje de negocio (i18n key)
    ↓
Texto empático (valor de la key)
```

### 3.2 Taxonomía de Errores

| Tipo | Origen | Mensaje técnico típico | Traducción de negocio |
|---|---|---|---|
| Autenticación | 401/403 | `Unauthorized` | "Tu sesión expiró. Ingresá de nuevo." |
| Validación | 422 | `field 'email' is required` | "El correo es obligatorio para continuar." |
| Red | timeout/fetch fail | `Network request failed` | "Hay un problema de conexión. Verificá tu internet." |
| Servidor | 500 | `Internal server error` | "Algo salió mal en nuestro lado. Ya estamos revisándolo." |
| Recurso | 404 | `Entity not found` | "No encontramos lo que buscás. ¿Querés volver al inicio?" |
| Límite | 429 | `Rate limit exceeded` | "Recibimos muchas solicitudes. Esperá un momento e intentá de nuevo." |

### 3.3 Reglas de Transformación

1. **Nunca exponer:** Códigos HTTP, nombres de campos técnicos, stack traces, IDs internos
2. **Siempre incluir:** Qué pasó (sin culpar al usuario), qué puede hacer el usuario
3. **Cuando aplica:** Próximos pasos, timeouts esperados, contacto de soporte
4. **Tono:** Empático pero no condescendiente. Nunca: "¡Ups! Algo salió mal 😅"

---

## IV. Proceso de Auditoría

Cuando se revisa un sistema existente, seguir este orden:

### Fase 1: Inventario
```
1. Listar todos los archivos de idioma existentes
2. Mapear superficies textuales no cubiertas por i18n
3. Identificar claves huérfanas (definidas pero no usadas)
4. Identificar textos hardcodeados en código fuente
```

### Fase 2: Análisis Estructural
```
1. Evaluar profundidad de anidamiento (máx 3 niveles)
2. Detectar inconsistencias de nomenclatura
3. Verificar paridad entre archivos de idioma (¿todas las keys existen en todos los idiomas?)
4. Identificar claves con valores idénticos entre idiomas (posible falta de traducción)
```

### Fase 3: Auditoría de Marca
```
1. Buscar términos prohibidos del glosario en todos los archivos
2. Verificar consistencia de registro (formal/informal)
3. Revisar mensajes de error: ¿son técnicos o de negocio?
4. Verificar que CTAs y acciones usen verbos canónicos de marca
```

### Fase 4: Reporte

Formato de output de auditoría:

```
AUDITORÍA i18n — [nombre del proyecto]

COBERTURA: X% de superficies textuales externalizadas

PROBLEMAS CRÍTICOS (bloquean deploy):
- [archivo:línea] Texto hardcodeado: "..."
- [archivo.json] Clave faltante en idioma EN: "..."

PROBLEMAS DE MARCA:
- [archivo.json:clave] Término prohibido "Bot" → usar "Humano Sintético"
- [archivo.json:clave] Registro inconsistente con resto de la UI

PROBLEMAS ESTRUCTURALES:
- Anidamiento excesivo en: "error.form.validation.email.format.invalid"
- Clave huérfana: "dashboard.old_title" (no usada en código)

SUGERENCIAS:
- Separar namespace "error" en "error.auth" y "error.network"
- Agregar clave "common.loading" (duplicada en 6 componentes)
```

---

## V. Criterios de Decisión Frecuentes

**¿Externalizar o hardcodear?**
Hardcodear solo si: el texto nunca cambia, es exclusivo de desarrollo, y jamás llega al usuario. En la duda: externalizar.

**¿Nueva clave o reutilizar existente?**
Reutilizar si el texto es semánticamente idéntico en todos los contextos donde se usa. Si el texto puede divergir en el futuro según contexto, crear claves separadas aunque el valor sea igual hoy.

**¿Traducción literal o adaptación?**
Si el término tiene equivalente canónico en el glosario de marca: usar el canónico. Si no: adaptar culturalmente, no traducir literalmente. Una traducción literal que suene extraña en el idioma target es un error de marca.

**¿Un archivo por idioma o múltiples archivos con namespaces?**
Un archivo por idioma funciona hasta ~200 claves. Más allá: dividir por namespace con lazy loading. El criterio es mantenibilidad, no tamaño de archivo.

---

## Filosofía Operativa

> La internacionalización no es una feature técnica. Es la decisión de que tu marca suene coherente en cualquier idioma y en cualquier momento de la experiencia del usuario.

Cada clave de idioma es una promesa de marca. Un texto hardcodeado es una promesa rota esperando ser descubierta.
