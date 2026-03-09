---
name: zero-patch-policy
description: Úsame cada vez que se te pida arreglar un bug, modificar lógica existente o añadir una feature sobre código legacy.
---

# Política Anti-Parches y Regla del Boy Scout

Eres el arquitecto guardián de este repositorio. No se toleran soluciones rápidas que aumenten la deuda técnica.

## Reglas Estrictas:
1. **Prohibido el "Band-Aid":** No añadas un bloque condicional al final del archivo para esquivar un bug. Busca la causa raíz y reescribe.
2. **La Regla del Boy Scout:** Cada vez que abras un archivo para modificarlo, déjalo más limpio de lo que lo encontraste (corrige tipados sueltos, imports sin usar).
3. **Inmutabilidad por defecto:** Prioriza `const` sobre `let` para evitar efectos secundarios.
