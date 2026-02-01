=============================================================
**TICKET ID:** TASK-018-FE  
**EPIC:** Configuración de Módulos y Permisos de Acceso  
**USER STORY:** US-018 - Configurar acceso masivo de módulos  
**COMPONENT:** Frontend  
**PRIORITY:** Media  
**ESTIMATION:** 6 horas  
=============================================================

**TÍTULO:**
Implementar UI de configuración masiva de módulos a múltiples organizaciones

**DESCRIPCIÓN:**
Crear interfaz de usuario para asignar módulos a múltiples organizaciones de forma masiva: selector múltiple de organizaciones, selector de aplicación, checklist de módulos y preview antes de confirmar. Consumirá el endpoint `POST /api/module-access/bulk-assign`.

**CRITERIOS DE ACEPTACIÓN TÉCNICOS:**
- [ ] Componente `BulkModuleAssignComponent` creado como Standalone
- [ ] Multi-selector de organizaciones funcional
- [ ] Selector de aplicación que carga módulos
- [ ] Checklist de módulos con select-all
- [ ] Preview con resumen y indicador de progreso
- [ ] Tests unitarios >80%

**ARCHIVOS A CREAR:**
- `src/app/modules/admin/pages/bulk-module-assign/bulk-module-assign.component.ts`
- Templates, estilos y tests
