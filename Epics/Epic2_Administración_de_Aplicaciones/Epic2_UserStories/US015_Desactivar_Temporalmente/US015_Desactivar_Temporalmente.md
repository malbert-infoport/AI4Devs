#### US-015: Desactivar aplicación temporalmente

**Épica:** Administración de Aplicaciones del Ecosistema
**Rol:** SecurityManager
**Prioridad:** Media | **Estimación:** 2 Story Points

**Historia:**
```
Como SecurityManager,
quiero desactivar temporalmente una aplicación sin eliminarla,
para bloquear autenticaciones durante mantenimientos programados o incidencias de seguridad.
```

**Criterios de aceptación:**
- Campo `Active` en `APPLICATION` controla estado
- Al desactivar: establecer `AuditDeletionDate`, publicar `ApplicationEvent` con `IsDeleted:true`, deshabilitar clients en Keycloak
- Reactivación invierte el proceso

**Dependencias:** US-009
