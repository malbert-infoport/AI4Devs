#### TASK-009-EV-PUB: Publicar ApplicationEvent al crear/modificar aplicaciones

=============================================================
**TICKET ID:** TASK-009-EV-PUB  
**EPIC:** Administración de Aplicaciones del Ecosistema  
**USER STORY:** US-009 - Registrar aplicación frontend (SPA)  
**COMPONENT:** Backend - Event Publishing  
**PRIORITY:** Alta  
**ESTIMATION:** 3 horas  
=============================================================

**TÍTULO:**
Publicar ApplicationEvent al crear/modificar aplicaciones

**DESCRIPCIÓN:**
Implementar publicación de `ApplicationEvent` (State Transfer) en `PostActions` de `ApplicationService` usando `IMessagePublisher` e `IntegrationEvents`. Persistir en `IntegrationEvents` antes de enviar y asegurar resiliencia. Ver `tickets_epica2.md` TASK-009-EV-PUB para checklist y guías de tests con Testcontainers.
