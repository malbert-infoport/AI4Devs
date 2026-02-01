#### US-005: Ver detalle completo de organización

**Épica:** Gestión del Portfolio de Organizaciones Clientes
**Rol:** OrganizationManager
**Prioridad:** Media | **Estimación:** 3 Story Points

**Historia:**
```
Como OrganizationManager,
quiero ver toda la información detallada de una organización incluyendo aplicaciones y módulos contratados,
para tener una visión completa de qué servicios tiene activos el cliente y poder responder consultas comerciales.
```

**Criterios de aceptación:**
- Vista con 3 pestañas: Datos de Organización, Módulos y Permisos, Auditoría
- Mostrar metadata Helix6, SecurityCompanyId readonly, estado visual
- Pestaña Auditoría muestra SOLO cambios críticos desde `AUDIT_LOG`

**Dependencias:** US-001

**Notas técnicas:**
- Rendimiento: Datos <200ms, Módulos <500ms
