#### ORG-001: Crear y editar organización cliente

**Épica:** Gestión del Portfolio de Organizaciones Clientes
**Rol:** OrganizationManager
**Prioridad:** Alta | **Estimación:** 5 Story Points

**Historia:**
```
Como OrganizationManager responsable del onboarding de clientes,
quiero crear y editar una organización cliente completando un formulario simple con sus datos básicos (nombre, CIF, dirección, contacto),
para gestionar su incorporación al ecosistema y mantener sus datos actualizados sin errores que afecten al acceso a las aplicaciones.
```

**Contexto adicional:**

El onboarding rápido y sin errores reduce el tiempo de activación y la carga de soporte; es crítico validar datos al crear o editar una organización, asignar un `SecurityCompanyId` seguro y evitar la publicación de eventos hasta que se asignen permisos y módulos.

**Criterios de aceptación:**

- La organización se persiste en la base de datos y recibe un `SecurityCompanyId` generado por la secuencia PostgreSQL.
- No se publica ningún `OrganizationEvent` al crear o editar la organización salvo cuando se asignan módulos.
- Validaciones frontend y backend previenen datos inválidos y el backend devuelve HTTP 400 en caso de validación.
- No se permite crear organizaciones con `CIF` duplicado.
- La API devuelve HTTP 201/200 con la entidad organización actualizada con los identificadores nuevos asignados.
- Se incluyen tests unitarios e integración que cubran creación, edición, validaciones y ausencia de publicación de eventos cuando no correspondan.

**Requisitos no funcionales:**

- Rendimiento: la operación de creación/edición debe responder en menos de 2 segundos en condiciones normales de carga.
- Consistencia/Concurrencia: `SecurityCompanyId` se debe generar mediante secuencia PostgreSQL para evitar colisiones en entornos concurrentes.
- Seguridad: sólo usuarios con rol `OrganizationManager` (o roles con permisos adecuados) pueden crear/editar organizaciones.
- Fiabilidad: la operación debe ser atómica; ante fallo no debe quedar estado parcial en la base de datos.
- Escalabilidad: el diseño debe soportar picos de altas creaciones/ediciones (batchs) sin degradar la generación de identificadores.
- Accesibilidad: la UI del formulario debe cumplir WCAG 2.1 AA para los campos básicos.

**Definición de hecho (DoD):**
- Código implementado y revisado
- Tests unitarios e integración
- Validaciones de frontend y backend funcionando
- Organización creada/actualizada sin publicar evento cuando no procede

**Dependencias:** Ninguna

**Notas técnicas:**
- Usar EF Core, `SecurityCompanyId` por secuencia PostgreSQL
- NO publicar `OrganizationEvent` al crear o editar salvo cuando se asignen módulos
