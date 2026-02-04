# TASK-002-BE: Backend Insert para OrganizationGroup (Helix6)

=============================================================
**TICKET ID:** TASK-002-BE  
**EPIC:** Gestión de Grupos de Organizaciones  
**USER STORY:** US-001 - Crear Grupo de Organizaciones  
**COMPONENT:** Backend - Helix6  
**PRIORITY:** Alta  
**ESTIMATION:** 6 horas  
=============================================================

## TÍTULO
Exponer endpoint Helix6 `Insert` para `OrganizationGroup` y definir `HelixEntities` load configuration `GroupBasic`.

## DESCRIPCIÓN
- Crear ViewModel y servicio `OrganizationGroupService` si no existe.
- Definir `HelixEntities.xml` LoadConfiguration: `GroupBasic` (campos básicos: Name, Description, Audit*). No incluir `Organizations` en `GroupBasic`.
- Validar permisos: solo `OrganizationManager` y `SystemAdmin` pueden insertar.

CRITERIOS TÉCNICOS
- [ ] Endpoint `Insert` disponible y acepta payload con `GroupBasic`.
- [ ] Validaciones server-side (Name obligatorio).
- [ ] Tests unitarios y de integración.

ARCHIVOS A MODIFICAR/CREAR
- `backend/Helix/HelixEntities.xml` — añadir `GroupBasic` config
- `backend/Services/OrganizationGroupService.cs` — lógica de creación
