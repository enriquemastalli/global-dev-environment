---
name: saas-security-enforcer
description: Úsame siempre que escribas endpoints del API, interactúes con la base de datos D1, valides JWT o configures webhooks (ej. Stripe).
---

# Directivas de Seguridad Multi-Tenant

## Reglas Estrictas:
1. **Aislamiento por Tenant:** Toda consulta a D1 o KV DEBE incluir el `tenant_id` (o `user_id`) extraído del JWT.
2. **Validación de Webhooks:** Verifica criptográficamente la firma usando el Secret Key antes de procesar el payload.
3. **Control de Roles:** El Worker debe validar si el plan del tenant tiene acceso a características premium antes de ejecutar la acción.
4. **Cero Secretos Expuestos:** Prohibido escribir claves de API en el código; lee desde el entorno.
