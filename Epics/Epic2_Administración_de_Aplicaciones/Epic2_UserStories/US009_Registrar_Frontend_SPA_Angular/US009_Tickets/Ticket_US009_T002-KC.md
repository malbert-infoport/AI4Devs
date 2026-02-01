#### TASK-009-KC: Integrar con Keycloak Admin API para crear public clients con PKCE

=============================================================
**TICKET ID:** TASK-009-KC  
**EPIC:** Administración de Aplicaciones del Ecosistema  
**USER STORY:** US-009 - Registrar aplicación frontend (SPA)  
**COMPONENT:** Backend - Keycloak Integration  
**PRIORITY:** Alta  
**ESTIMATION:** 6 horas  
=============================================================

**TÍTULO:**
Integrar con Keycloak Admin API para crear public clients con PKCE

**DESCRIPCIÓN:**
Implementar `KeycloakAdminService` para crear/actualizar public clients con PKCE S256 y confidential clients para ClientCredentials, añadir protocol mapper `c_ids`, manejar idempotencia y reintentos. Ver `tickets_epica2.md` TASK-009-KC para pasos y tests con Testcontainers.
