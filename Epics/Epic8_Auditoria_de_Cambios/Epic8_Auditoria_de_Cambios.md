# Épica 8: Auditoría de Cambios Críticos

## Objetivo de Negocio
Proveer un sistema centralizado de auditoría selectiva que registre únicamente los cambios críticos en entidades clave (Organization, Module, OrganizationModule/MODULE_ACCESS, OrganizationGroup, User/roles, Application), para mejorar la trazabilidad, el cumplimiento y la capacidad de investigación ante incidentes.

## Valor que aporta
- Mejora la trazabilidad y la capacidad de investigación de cambios críticos.
- Facilita el cumplimiento normativo y las auditorías internas.
- Reduce el tiempo de resolución de incidentes y la carga de soporte.
- Minimiza el almacenamiento innecesario al evitar payloads completos (no JSON old/new).
- Permite correlacionar operaciones distribuidas mediante `CorrelationId`.

## Criterios de aceptación de la épica
- Creación de la tabla `AUDIT_LOG` y migración EF Core asociada.
- Implementación y registro en DI de `IAuditLogService` y `AuditEntry` DTO.
- Integración de hooks mínimos en servicios críticos (p.ej. OrganizationModuleService y flujos de activación/desactivación).
- Tests unitarios e integración que validen persistencia de entradas de auditoría y la semántica de `UserId` NULL para acciones del sistema.
- Índices implementados para consultas eficientes por `EntityType`+`EntityId` y por `Timestamp`.
- Documentación en el repositorio que describa el diseño y uso básico de la auditoría.
