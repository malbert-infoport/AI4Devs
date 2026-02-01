=============================================================
**TICKET ID:** TASK-020-FE  
**EPIC:** Configuración de Módulos y Permisos de Acceso  
**USER STORY:** US-020 - Visualizar matriz de permisos organización-módulo  
**COMPONENT:** Frontend  
**PRIORITY:** Media  
**ESTIMATION:** 8 horas  
=============================================================

**TÍTULO:**
Implementar matriz consolidada de permisos organización-módulo

**DESCRIPCIÓN:**
Crear vista de matriz que cruza organizaciones (filas) con módulos (columnas), con toggles editables, filtros y exportación a Excel (SheetJS). Usar virtual scrolling para escalabilidad.

**CRITERIOS DE ACEPTACIÓN TÉCNICOS:**
- [ ] Componente `PermissionsMatrixComponent` creado como Standalone
- [ ] Matriz pivoteada con virtual scrolling
- [ ] Exportación a Excel implementada
- [ ] Celdas editables con guardado automático
- [ ] Tests unitarios >80%

**ARCHIVOS A CREAR:**
- `src/app/modules/admin/pages/permissions-matrix/permissions-matrix.component.ts`
- Templates, estilos y tests
