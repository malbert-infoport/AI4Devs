#### US-001v2: Asignar módulos tras crear organización

**Épica:** Gestión del Portfolio de Organizaciones Clientes
**Rol:** ApplicationManager
**Prioridad:** Alta | **Estimación:** 5 Story Points

**Historia:**
```
Como ApplicationManager,
quiero asignar aplicaciones y módulos a una organización recién creada desde la pestaña "Módulos y Permisos de Acceso",
para que al guardar los permisos se publique el primer OrganizationEvent y la organización quede sincronizada con las aplicaciones satélite.
```

**Criterios de aceptación:**
- Mostrar tabla de aplicaciones disponibles
- Insertar registros en `MODULE_ACCESS`
- Registrar `AuditLog` con Action="ModuleAssigned"
- Publicar primer `OrganizationEvent` con estructura `apps` y `IsDeleted:false`

**Definición de hecho:**
- Interfaz master-detail funcional
- Auditoría y publicación del evento al guardar módulos

**Dependencias:** US-001

**Notas técnicas:**
- Evento publicado desde `OrganizationModuleService.AssignModule` cuando `ModuleCount` pasa de 0 a >0
