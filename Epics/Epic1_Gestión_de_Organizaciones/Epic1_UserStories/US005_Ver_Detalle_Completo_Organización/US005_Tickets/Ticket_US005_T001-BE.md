=============================================================
**TICKET ID:** TASK-001-BE
**EPIC:** Gestión del Portfolio de Organizaciones Clientes
**USER STORY:** US-005 - Ver detalle completo de organización
**COMPONENT:** Backend - Helix6 / Servicios
**PRIORITY:** Alta
**ESTIMATION:** 6 horas
=============================================================

## TÍTULO
Exponer `GetById` Helix6 para devolver detalle completo de `Organization` con carga configurada

## DESCRIPCIÓN
El backend debe exponer y/o asegurar el endpoint genérico generado por Helix6 `GetById` que devuelva la entidad `Organization` con la configuración de carga requerida por la UI de edición/visualización.

La carga debe incluir las siguientes secciones (tapas/pestañas) en el objeto devuelto:
- **General**: datos principales de la organización (Id, SecurityCompanyId, Name, Cif, ContactEmail, ContactPhone, GroupId, etc.).
- **Aplicaciones y Módulos**: colección de `Applications` y, dentro de cada `Application`, sus `Modules` asociados. Estos elementos deben estar en modo escritura (es decir, enviados en la misma estructura que el editor espera para poder guardar cambios desde la ficha de edición).
- **Auditoría**: lista o sección con campos de auditoría y `AuditLog` relevantes (creación, actualizaciones, eliminación). Esta pestaña debe ser de solo lectura: los campos de auditoría deben viajar en el DTO pero el contrato debe indicar que no son editables.

Requisitos específicos:
- Asegurar que `HelixEntities.xml` (o la configuración de generación de Helix6) incluya una `LoadConfiguration` para `Organization` que cargue:
  - `Applications` (write-enabled)
  - `Modules` asociados a cada `Application` (write-enabled)
  - `AuditLog` o información de auditoría (read-only)
- El endpoint expuesto por Helix6 (`GetById`) debe aceptar `id` como parámetro y opcionalmente `configurationName` si se emplea múltiples configuraciones. Ejemplo de uso desde FE: `GET /api/Organization/GetById?id=123` (o la variante que use `configurationName`).
- Añadir validaciones de permisos: solo usuarios con permisos de lectura podrán invocar; la edición seguirá controlándose por roles (SecurityManager, etc.) en endpoints de escritura.
- El resultado debe mapear a un DTO de vista (ViewModel) que contenga las tres pestañas/colecciones claramente diferenciadas.

PRUEBAS Y CRITERIOS DE ACEPTACIÓN
- [ ] `GetById` devuelve `Organization` con `Applications[]` y `Modules[]` embebidos y poblados.
- [ ] Campos de auditoría y `AuditLog` están presentes pero marcados/read-only en el contrato (documentado).
- [ ] Endpoint funciona con `configurationName` alternativo si aplica.
- [ ] Pruebas unitarias que validen mapping entre entidad y ViewModel para `GetById`.
- [ ] Tests de integración que ejecuten `GetById` contra un entorno de prueba y validen payload.
- [ ] Documentación en el ticket indicando qué `LoadConfiguration` fue añadida en `HelixEntities.xml`.

ARCHIVOS A MODIFICAR/CREAR
- `backend/Helix/HelixEntities.xml` — añadir/ajustar `LoadConfiguration` para `Organization`.
- `backend/Services/OrganizationService.cs` (o el servicio generado) — asegurar mapping y permisos.
- `backend/Controllers/OrganizationController.cs` — si aplica, comprobar que se delega al endpoint Helix6 generado.
- `tests/Integration/Organization/GetByIdTests.cs` — pruebas de integración.

NOTAS IMPLEMENTACIÓN
- Preferir usar la lógica generada por Helix6 (endpoints generados) para mantener coherencia con otros módulos.
- Si la generación no cubre exactamente la estructura esperada para la UI, crear un adaptador que transforme el ViewModel generado agregando la sección `Audit` en read-only.
- Asegurar que no se exponga información sensible en la sección de auditoría; incluir solo metadatos necesarios (usuario, fecha, acción, comentario).

DEFINITION OF DONE
- `GetById` Helix6 disponible y devuelve el DTO con `General`, `Applications+Modules` (write-enabled), y `Audit` (read-only).
- Pruebas unitarias e integración implementadas y pasan.
- Documentación de `HelixEntities.xml` y cambios en PR.

=============================================================
