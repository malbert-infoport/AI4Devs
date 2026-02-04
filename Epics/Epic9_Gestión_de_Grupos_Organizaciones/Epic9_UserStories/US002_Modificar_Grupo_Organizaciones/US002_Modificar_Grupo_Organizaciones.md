# US002 - Modificar Grupo de Organizaciones

Resumen: Formulario y endpoint para editar `OrganizationGroup` (Name, Description). `Update` Helix6 debe usar configuración `GroupBasic` (sin colecciones). Auditoría visible en modo read-only.

Definición de hecho:
- UI: formulario edición con validaciones y control de permisos (OrganizationManager).
- Backend: endpoint `Update` Helix6 disponible y protecciones para `SecurityCompanyId` inmutable.
