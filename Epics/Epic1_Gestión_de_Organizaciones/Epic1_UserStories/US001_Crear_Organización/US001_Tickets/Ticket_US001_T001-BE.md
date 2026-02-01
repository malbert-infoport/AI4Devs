#### TASK-001-BE: Implementar entidad Organization con CRUD completo en Helix6

=============================================================
**TICKET ID:** TASK-001-BE  
**EPIC:** Gestión del Portfolio de Organizaciones Clientes  
**USER STORY:** US-001 - Crear nueva organización cliente  
**COMPONENT:** Backend  
**PRIORITY:** Alta  
**ESTIMATION:** 6 horas  
=============================================================

**TÍTULO:**
Implementar entidad Organization con CRUD completo en Helix6

**DESCRIPCIÓN:**
Crear la infraestructura backend completa para gestionar Organizaciones Clientes siguiendo el patrón Helix6 Framework. Esto incluye:
- Entidad `Organization` en DataModel con todos los campos de negocio y auditoría
- ViewModel `OrganizationView` para la capa de presentación
- Servicio `OrganizationService` con lógica de negocio y validaciones
- Endpoints RESTful generados automáticamente con EndpointHelper
- Migración de Entity Framework Core
- Tests unitarios de servicio y tests de integración de endpoints

La funcionalidad debe cumplir con los criterios de aceptación de la User Story US-001:
- Validar que nombre, CIF y email de contacto sean obligatorios
- Generar `SecurityCompanyId` único automáticamente mediante secuencia de PostgreSQL
- Validar unicidad de CIF (no permitir duplicados)

**CRÍTICO:** NO publicar OrganizationEvent en PostActions (los eventos se publican solo cuando se asignan módulos, ver TASK-001-BE-EXT).

**CRÍTICO:** NO registrar en AUDIT_LOG la creación de organización (no es un cambio crítico según matriz de auditoría). Solo se auditan cambios críticos: asignación de módulos, baja/alta, cambio de grupo.

Los campos de auditoría de Helix6 (AuditCreationUser, AuditCreationDate, etc.) se gestionan automáticamente por el framework.

**GUÍA Y PASOS**
(Ver contenido completo en `tickets_epica1.md` -> TASK-001-BE)