#### US-031: Registrar aplicación automáticamente en Keycloak

**Épica:** Integración con Keycloak e Identity Management
**Avatar:** Sistema InfoportOneAdmon
**Prioridad:** Alta | **Estimación:** 5 Story Points

**Historia:**
```
Como el sistema InfoportOneAdmon,
quiero registrar automáticamente cada aplicación nueva en Keycloak como client OAuth2 al darla de alta,
para que los administradores no tengan que acceder manualmente a la consola de Keycloak.
```

**Criterios de aceptación:**
- Invocar Keycloak Admin API para crear client con configuración adecuada
- Rollback si falla la creación en Keycloak

**Notas técnicas:**
- Autenticación con service account, manejar errores robustamente
