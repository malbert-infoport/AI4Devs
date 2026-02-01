=============================================================
**TICKET ID:** TASK-016-FE  
**EPIC:** Configuración de Módulos y Permisos de Acceso  
**USER STORY:** US-016 - Definir módulos funcionales de una aplicación  
**COMPONENT:** Frontend  
**PRIORITY:** Alta  
**ESTIMATION:** 6 horas  
=============================================================

**TÍTULO:**
Implementar grid de módulos con modal de creación/edición

**DESCRIPCIÓN:**
Crear la interfaz de usuario para gestionar módulos funcionales de una aplicación usando `ClGrid` y `ClModal`. El grid estará en el detalle de aplicación e incluirá creación, edición y eliminación con validación de nomenclatura `M{RolePrefix}_...`.

**CRITERIOS DE ACEPTACIÓN TÉCNICOS:**
- [ ] `ModuleGridComponent` y `ModuleDialogComponent` como Standalone
- [ ] Validación de nomenclatura en formulario
- [ ] No permitir eliminar último módulo activo
- [ ] Integración con cliente NSwag y tests unitarios >80%

**ARCHIVOS A CREAR:**
- `src/app/modules/admin/components/module-grid/module-grid.component.ts`
- `src/app/modules/admin/components/module-dialog/module-dialog.component.ts`
- Templates, estilos y tests
