# US004 - Ver Detalle Grupo de Organizaciones

Resumen: Ficha de detalle con pestañas: General (datos básicos), Organizaciones (lista read-only) y Auditoría (read-only). `GetById` Helix6 deberá usar `GroupBasicWithOrganizationsReadOnly`.

Requisitos:
- `GetById` devuelve grupo con `Organizations` (solo lectura) y `AuditLog`.
- UI mostrará pestañas y permitirá navegación desde listado.

Definición de hecho:
- BE: `GetById` Helix6 disponible y documentada.
- FE: detalle con pestañas implementado y listado de organizations read-only.
