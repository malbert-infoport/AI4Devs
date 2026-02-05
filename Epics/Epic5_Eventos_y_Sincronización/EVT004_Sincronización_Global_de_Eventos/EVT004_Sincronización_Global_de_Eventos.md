```markdown
# EVT004 — Sincronización Global de Eventos

## Resumen
Funcionalidad administrativa que permite publicar el estado completo (último estado) de todas las `Organization` o `Application` al tópico correspondiente, forzando una sincronización global hacia las aplicaciones satélite. Se expondrá una API backend para iniciar la sincronización (desde grid/front se lanzará la llamada).

## Objetivo
- Permitir a un admin lanzar una sincronización masiva que publique `OrganizationEvent` o `ApplicationEvent` para todos los registros (o un subconjunto) en su último estado.

## Criterios de Aceptación
- [ ] API backend definida y documentada.
- [ ] Worker que publica eventos en batches con control de paginación y idempotencia.
- [ ] Front-end podrá invocar el API para iniciar la sincronización (se definirá API front después).

```
