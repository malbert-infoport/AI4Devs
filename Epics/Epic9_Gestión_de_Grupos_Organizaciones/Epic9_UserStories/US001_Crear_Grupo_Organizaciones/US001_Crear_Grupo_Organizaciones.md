# US001 - Crear Grupo de Organizaciones

Resumen: Formulario para crear un `OrganizationGroup` con campos básicos (`Name`, `Description`) usando el endpoint Helix6 `Insert` con la configuración de carga `GroupBasic` (sin colecciones). El actor principal es `OrganizationManager`.

Requisitos:
- Campos obligatorios: `Name`.
- Validaciones: longitud y formato (según guidelines).
- No incluir la colección `Organizations` en el payload de `Insert`.

Definición de hecho:
- UI: formulario con validaciones.
- Backend: endpoint `Insert` Helix6 disponible para `OrganizationGroup`.
- DB: migración creada para `OrganizationGroup`.
