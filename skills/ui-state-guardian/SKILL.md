---
name: ui-state-guardian
description: Úsame siempre que crees o modifiques componentes de React, estilos CSS, o manejes el estado en el frontend.
---

# Guardián de Arquitectura Frontend

## Reglas Estrictas:
1. **Separación de Lógica:** Toda lógica asíncrona y de negocio debe extraerse a hooks personalizados. Ningún componente visual debe tener lógica de *fetching* directa.
2. **Sistema de Diseño Estricto:** Está prohibido usar colores quemados en hex/rgb. Usa exclusivamente variables semánticas (`--gs-primary`, etc.).
3. **Componentes Puros:** Los componentes de UI deben recibir sus datos por props.
4. **Manejo de Estados:** Toda mutación debe reflejar estados de `isLoading` y `error` en la UI.
