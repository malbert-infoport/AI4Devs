#### US-034: Implementar SSO entre aplicaciones

**Épica:** Integración con Keycloak e Identity Management
**Rol:** EndUser
**Prioridad:** Media | **Estimación:** 5 Story Points

**Historia:**
```
Como EndUser que trabaja con múltiples aplicaciones del ecosistema (CRM, ERP, BI),
quiero hacer login una sola vez y acceder a todas las aplicaciones sin volver a introducir credenciales,
para ahorrar tiempo y tener una experiencia fluida sin interrupciones por autenticaciones repetidas.
```

**Criterios de aceptación:**
- Flujo de SSO demostrado entre al menos 2 aplicaciones
- Logout centralizado que cierra sesión en Keycloak

**Dependencias:** US-031

**Definición de hecho:**
- SSO funcional y pruebas de flujo
