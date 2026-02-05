#### US-033: Validar tokens JWT sin consultar Keycloak

**Épica:** Integración con Keycloak e Identity Management
**Avatar:** Aplicación Satélite (Backend API)
**Prioridad:** Media | **Estimación:** 3 Story Points

**Historia:**
```
Como una aplicación satélite backend,
quiero validar tokens JWT localmente verificando su firma criptográfica,
para no tener que consultar Keycloak en cada petición y evitar que sea un cuello de botella.
```

**Criterios de aceptación:**
- Obtener clave pública de Keycloak periódicamente
- Verificar firma RS256, `exp`, `iss`, `aud` y extraer claims (c_ids, email)
- Rechazar con 401 si inválido

**Definición de hecho:**
- Validación stateless implementada
- Rendimiento <10ms por validación

**Dependencias:** US-032
