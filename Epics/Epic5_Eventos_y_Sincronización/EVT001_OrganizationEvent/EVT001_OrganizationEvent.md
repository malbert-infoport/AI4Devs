```markdown
# EVT001 — OrganizationEvent

## Resumen
Definir el contrato de evento `OrganizationEvent` publicado por InfoportOneAdmon cuando una organización cambia (alta, baja, modificación). El evento seguirá el patrón State-Transfer: payload con el estado completo de la organización.

## Objetivo
- Garantizar que las aplicaciones satélite puedan consumir el estado completo de una organización y sincronizar su propia copia.

## Criterios de Aceptación
- [ ] Especificación del payload y topic `infoportone.events.organization` documentada.
- [ ] Ticket backend creado para producir eventos desde Services cuando cambian las organizaciones.
- [ ] Ejemplos de consumo y pruebas de integración proporcionadas.

```
