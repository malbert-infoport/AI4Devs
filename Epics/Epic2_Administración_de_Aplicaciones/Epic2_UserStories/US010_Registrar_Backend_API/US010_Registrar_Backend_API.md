#### US-010: Registrar aplicación backend (API)

**Épica:** Administración de Aplicaciones del Ecosistema
**Rol:** ApplicationManager
**Prioridad:** Alta | **Estimación:** 5 Story Points

**Historia:**
```
Como ApplicationManager del portfolio de aplicaciones,
quiero registrar una nueva aplicación backend (API) como cliente confidencial OAuth2 con secret seguro,
para que pueda autenticarse en Keycloak y obtener tokens para comunicarse con otros servicios del ecosistema.
```

**Criterios de aceptación:**
- Generar `client_id` y `client_secret` seguro
- Hashear el secret con bcrypt antes de almacenar
- Registrar client en Keycloak como confidential client
- Mostrar secret en modal una sola vez

**Dependencias:** US-001

**Notas técnicas:**
- Bcrypt factor 12
- Secret mínimo 32 caracteres
