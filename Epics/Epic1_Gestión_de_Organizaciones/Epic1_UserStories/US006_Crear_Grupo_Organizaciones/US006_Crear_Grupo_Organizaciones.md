#### US-006: Crear grupo de organizaciones

**Épica:** Gestión del Portfolio de Organizaciones Clientes
**Rol:** ApplicationManager
**Prioridad:** Media | **Estimación:** 3 Story Points

**Historia:**
```
Como ApplicationManager que gestiona holdings empresariales,
quiero crear grupos lógicos de organizaciones (ej: "Holding Logístico Norte", "Consorcio Financiero"),
para que las aplicaciones satélite puedan implementar funcionalidades colaborativas entre organizaciones del mismo grupo.
```

**Criterios de aceptación:**
- Formulario creación grupo: Nombre (único), Descripción
- Validación unicidad del nombre
- Grupo disponible en dropdown inmediatamente

**Dependencias:** US-001

**Notas técnicas:**
- Los grupos no tienen eventos propios; se propagan mediante `GroupId` en `OrganizationEvent`
