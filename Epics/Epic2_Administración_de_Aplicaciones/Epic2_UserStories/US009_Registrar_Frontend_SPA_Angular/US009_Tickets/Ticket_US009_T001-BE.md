#### TASK-009-BE: Implementar entidades Application y ApplicationSecurity con CRUD

=============================================================
**TICKET ID:** TASK-009-BE  
**EPIC:** Administración de Aplicaciones del Ecosistema  
**USER STORY:** US-009 - Registrar aplicación frontend (SPA)  
**COMPONENT:** Backend  
**PRIORITY:** Alta  
**ESTIMATION:** 8 horas  
=============================================================

**TÍTULO:**
Implementar entidades Application y ApplicationSecurity con registro de clients OAuth2

**DESCRIPCIÓN:**
Crear la infraestructura backend para gestionar el catálogo de aplicaciones del ecosistema: entidad `Application`, entidad `ApplicationSecurity` (1:N), soporte CODE (PKCE) y ClientCredentials, generación de `client_id`, hashing bcrypt de secrets, RolePrefix inmutable.

**CRITERIOS TÉCNICOS**: ver `tickets_epica2.md` TASK-009-BE (índice y guía de implementación incluida).

**Archivos y pasos**: crear entidades, DbContext, servicios `ApplicationService` y `ApplicationSecurityService`, endpoints, DI, tests y migraciones.
