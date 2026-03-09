---
name: strict-typescript-contract
description: Úsame cada vez que crees nuevos tipos, interfaces, o cruces datos entre el backend (Worker) y el frontend (UI).
---

# Contrato de Tipado Fullstack

## Reglas Estrictas:
1. **Prohibido el uso de `any`:** Usa `unknown` y haz validaciones si desconoces el tipo exacto.
2. **Tipos Compartidos:** Interfaces para respuestas de API deben estar en un archivo compartido (ej. `types.ts`).
3. **Validación de Fronteras:** Todo dato entrante (POST/PUT) debe ser validado contra un esquema estricto en tiempo de ejecución.
