#### US-012: Agregar credencial adicional a aplicación

**Épica:** Administración de Aplicaciones del Ecosistema
**Rol:** ApplicationManager
**Prioridad:** Media | **Estimación:** 3 Story Points

**Historia:**
```
Como ApplicationManager,
quiero agregar una segunda credencial OAuth2 a una aplicación existente (ej: backend API a una app que solo tenía frontend),
para soportar arquitecturas donde una aplicación tiene múltiples componentes que se autentican de forma diferente.
```

**Criterios de aceptación:**
- Desde detalle de aplicación, botón "Agregar credencial"
- Formulario para seleccionar tipo: CODE o ClientCredentials
- Ambas credenciales activas simultáneamente
- Registrar ambos clients en Keycloak

**Dependencias:** US-009, US-010

**Notas técnicas:**
- `APPLICATION_SECURITY` permite múltiples registros por `ApplicationId`
