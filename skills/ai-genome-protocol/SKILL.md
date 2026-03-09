---
name: ai-genome-protocol
description: Úsame siempre que modifiques los prompts del sistema (Arquitecto, Evolucionador), manejes la API de Gemini o analices/escribas archivos XML. Prototipo para mantener el system prompt de agentes conversacionales.
---

# Protocolo del Genoma y Guardarraíles de IA

## Reglas Estrictas:
1. **Inmutabilidad del Esquema XML:** Respeta estrictamente la estructura canónica (`core/genoma-universal-v3.1.xml`). Prohibido inventar etiquetas nuevas.
2. **Parseo Seguro:** Antes de guardar un nuevo genoma, el Worker debe validar que el string resultante sea un XML válido y bien formado.
3. **Defensa contra Prompt Injection:** Sanitiza los inputs no confiables antes de enviarlos a la API de Gemini.
