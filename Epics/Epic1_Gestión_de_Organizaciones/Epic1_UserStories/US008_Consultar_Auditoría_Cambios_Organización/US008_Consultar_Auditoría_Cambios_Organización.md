#### US-008: Consultar auditoría de cambios en organización

**Épica:** Gestión del Portfolio de Organizaciones Clientes
**Rol:** ComplianceOfficer
**Prioridad:** Media | **Estimación:** 5 Story Points

**Historia:**
```
Como ComplianceOfficer,
quiero consultar el historial completo de cambios realizados en una organización específica,
para demostrar en auditorías externas que solo usuarios autorizados modificaron datos críticos y verificar trazabilidad completa.
```

**Criterios de aceptación:**
- Vista de auditoría accesible desde detalle de org
- Listado inverso de SOLO cambios críticos desde `AUDIT_LOG`
- Filtros: rango de fechas, usuario, tipo de acción
- Exportar a CSV

**Dependencias:** US-001, US-002

**Notas técnicas:**
- `AUDIT_LOG` es append-only
- Filtrar solo Actions críticos
