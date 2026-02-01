=============================================================
**TICKET ID:** TASK-015-BE  
**EPIC:** Administración de Aplicaciones del Ecosistema  
**USER STORY:** US-015 - Desactivar aplicación temporalmente  
**COMPONENT:** Backend  
**PRIORITY:** Media  
**ESTIMATION:** 2 horas  
=============================================================

**TÍTULO:**
Implementar desactivación de aplicación con soft delete y sincronización a Keycloak

**DESCRIPCIÓN:**
El endpoint `DeleteUndeleteLogicById` ya está generado automáticamente por Helix6 y realiza soft delete estableciendo `AuditDeletionDate`. Este ticket añade lógica específica en `PostActions` para aplicaciones:
1. Deshabilitar todos los clients asociados en Keycloak cuando se desactiva
2. Reactivar clients en Keycloak cuando se reactiva
3. Publicar `ApplicationEvent` con `IsDeleted: true/false`

**CONTEXTO TÉCNICO:**
- **Endpoint automático**: POST `/applications/DeleteUndeleteLogicById` ya existe (generado por Helix6)
- **Soft delete**: Helix6 gestiona automáticamente el AuditDeletionDate
- **Keycloak**: Deshabilitar/reactivar clients en el hook PostActions
- **Evento**: ApplicationEvent con IsDeleted para sincronizar apps satélite

**CRITERIOS DE ACEPTACIÓN TÉCNICOS:**
- [ ] PostActions implementado en ApplicationService
- [ ] Deshabilitación de clients en Keycloak al borrar (delete=true)
- [ ] Reactivación de clients en Keycloak al restaurar (delete=false)
- [ ] Publicación de ApplicationEvent con IsDeleted correcto
- [ ] Tests unitarios e integración
