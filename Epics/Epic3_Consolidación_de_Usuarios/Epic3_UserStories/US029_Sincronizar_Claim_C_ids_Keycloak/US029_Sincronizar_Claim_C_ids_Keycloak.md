#### US-029: Sincronizar claim c_ids con Keycloak

**Épica:** Sincronización y Consolidación de Usuarios Multi-Organización
**Rol:** Sistema (Background Worker)
**Prioridad:** Alta | **Estimación:** 5 Story Points

**Historia:**
```
Como el Background Worker,
quiero sincronizar directamente con Keycloak el usuario consolidado (c_ids + roles) mediante Admin API,
para que su próximo login genere un token JWT con toda su información multi-organización sin publicar eventos adicionales.
```

**Criterios de aceptación:**
- Usar Keycloak Admin API: GET /users?email=, POST /users, PUT /users/{id}
- Enviar `c_ids` como atributo multivalor
- Asignar/actualizar roles en Keycloak
- Retry con backoff ante fallos

**Dependencias:** US-027, US-028

**Notas técnicas:**
- Usar Keycloak.AuthServices.Sdk
- Timeout 10s para llamadas a Keycloak
