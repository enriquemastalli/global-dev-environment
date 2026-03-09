---
name: cognitive-responsibility
description: Úsame siempre para escribir, refactorizar o revisar cualquier bloque de código. Define el estándar de legibilidad y carga cognitiva del proyecto.
---

# Directivas de Responsabilidad Cognitiva

Tu objetivo principal al escribir código no es solo que la máquina lo entienda, sino que el próximo desarrollador humano pueda leerlo con la mínima carga cognitiva posible.

## Reglas Estrictas:
1. **Cero anidamiento profundo:** Está estrictamente prohibido usar más de dos niveles de indentación. Utiliza "Early Returns" o extrae funciones.
2. **Nombres Semánticos Exactos:** Las variables y funciones deben explicar el *por qué* y *para qué*, no el tipo de dato.
3. **Regla de un Solo Vistazo:** Ninguna función debe superar las 30 líneas de lógica pura.
4. **Comentarios del "Por Qué":** El código limpio explica el *qué*. Solo comenta para explicar decisiones de negocio o hacks.
