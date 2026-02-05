#### US-032: Configurar Protocol Mapper de c_ids

**Épica:** Integración con Keycloak e Identity Management
**Avatar:** Sistema InfoportOneAdmon
**Prioridad:** Alta | **Estimación:** 5 Story Points

**Historia:**
```
Como el sistema InfoportOneAdmon,
quiero configurar automáticamente el Protocol Mapper que inyecta el claim personalizado c_ids en los tokens JWT,
para que las aplicaciones satélite reciban la lista de organizaciones del usuario sin configuración manual en Keycloak.
```

**Criterios de aceptación:**
- Crear Protocol Mapper tipo "User Attribute" con User Attribute `c_ids`, Token Claim Name `c_ids`, Claim JSON Type JSON
- Añadir al access token y id token

**Dependencias:** US-031

**Notas técnicas:**
- Validar que el mapper quede configurado y los tokens incluyan `c_ids`
