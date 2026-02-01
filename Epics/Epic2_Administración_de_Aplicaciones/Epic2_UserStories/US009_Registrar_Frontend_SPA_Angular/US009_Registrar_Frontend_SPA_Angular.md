#### US-009: Registrar aplicación frontend (SPA Angular)

**Épica:** Administración de Aplicaciones del Ecosistema
**Rol:** ApplicationManager
**Prioridad:** Alta | **Estimación:** 5 Story Points

**Historia:**
```
Como ApplicationManager del portfolio de aplicaciones,
quiero registrar una nueva aplicación frontend (Angular SPA) como cliente público OAuth2 sin almacenar secretos,
para que los usuarios puedan autenticarse de forma segura usando PKCE sin exponer credenciales en el navegador.
```

**Criterios de aceptación:**
- Formulario con Nombre, Descripción, Prefijo, RedirectURIs
- Generar `client_id`, registrar en `APPLICATION` y `APPLICATION_SECURITY` con CredentialType: CODE
- Registrar client en Keycloak como public client con PKCE (S256) y configurar Protocol Mappers para `c_ids`
- Publicar `ApplicationEvent`

**Dependencias:** US-001

**Notas técnicas:**
- `ClientSecretHash` NULL para public clients
- `client_id` patrón `{prefijo}-app-frontend`
