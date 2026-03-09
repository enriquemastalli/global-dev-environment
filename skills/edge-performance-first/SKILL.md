---
name: edge-performance-first
description: Úsame siempre que escribas código para el backend, interactúes con la base de datos, APIs externas o manejes archivos.
---

# Mentalidad Cloudflare Workers (Edge Performance)

Este backend corre en V8 Isolates. La memoria es limitada y la latencia debe ser cero.

## Reglas Estrictas:
1. **Protección de Memoria:** Nunca cargues archivos enteros en memoria. Usa Streams (`ReadableStream`, `WritableStream`) para procesar datos por fragmentos.
2. **Prioridad de Caché:** Verifica siempre si el dato existe en el namespace KV antes de consultar D1 o APIs externas.
3. **Dependencias Ligeras:** Usa las Web APIs nativas (ej. `crypto.subtle`) en lugar de librerías externas de npm cuando sea posible.
