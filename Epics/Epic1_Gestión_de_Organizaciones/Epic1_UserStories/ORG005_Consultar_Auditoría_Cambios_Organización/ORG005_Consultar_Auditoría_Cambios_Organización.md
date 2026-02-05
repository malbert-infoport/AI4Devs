# ORG005 - Consultar Auditoría de Cambios en Organización

**ID:** ORG005
**EPIC:** Gestión del Portfolio de Organizaciones Clientes
**DESCRIPCIÓN (resumen):**
La funcionalidad permite a usuarios autorizados consultar el historial de cambios de una organización (auditoría): quién hizo qué, cuándo y datos anteriores/actuales. Incluye filtros, detalle por evento y exportación básica.

**OBJETIVOS**
- Proveer una vista paginada y filtrable del registro de auditoría para una organización.
- Mostrar campo `ChangedBy`, `ChangedAt`, `ActionType`, `Entity`, `PropertyChanges` (antes/después) y `CorrelationId`.
- Permitir inspección detalle y exportación CSV de un subconjunto de eventos.

**PRIORIDAD:** Media
**ESTIMACIÓN:** 1 día (frontend) + 1 día (backend)

**ACTORES:** Administrador de cliente, Operador con permiso de auditoría.

**DEPENDE DE:** Endpoint backend para obtener auditoría por `organizationId` (ej: `Audit/GetByOrganizationId` o `Organization/GetAudit`).

**CRITERIOS DE ACEPTACIÓN (AC)**
- AC1: Un usuario con permiso `Organization audit query` puede ver la pestaña "Auditoría" en la ficha de organización.
- AC2: La vista muestra eventos con paginación, orden por fecha descendente y filtros por tipo de acción y rango de fechas.
- AC3: Al abrir un evento, se muestra un modal con lista de `PropertyChanges` (campo, valor anterior, valor nuevo) y `CorrelationId`.
- AC4: Es posible exportar a CSV los resultados filtrados.
- AC5: Peticiones incluyen `X-Correlation-Id` y manejan `ProblemDetails` friendly en errores.

**NOTAS TÉCNICAS**
- Seguir `Helix6_Frontend_Architecture.md` y usar `ClGrid` para la lista principal y `ClModal` para detalle.
- Usar `inject()` para dependencias; usar NSwag client generado para consumir endpoint (ej: `AuditClient` o `OrganizationClient.GetAudit`).
- Validar permiso `Organization audit query` usando `AccessService`.
- Tests unitarios y E2E mínimos recomendados.

**SIGUIENTES PASOS**
- Crear ticket frontend y backend con contrato exacto de API.
- Coordinar con backend si el endpoint de auditoría no existe o requiere ajuste.

***
