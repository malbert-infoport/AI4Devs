=============================================================
**TICKET ID:** TASK-017-FE  
**EPIC:** Configuración de Módulos y Permisos de Acceso  
**USER STORY:** US-017 - Asignar módulos de una aplicación a una organización  
**COMPONENT:** Frontend  
**PRIORITY:** Alta  
**ESTIMATION:** 7 horas  
=============================================================

**TÍTULO:**
Implementar UI de asignación de módulos a organización con checklist por aplicación

**DESCRIPCIÓN:**
Crear interfaz dentro del detalle de organización que muestre las aplicaciones disponibles y permita marcar/desmarcar módulos mediante checkboxes. Los cambios se guardan automáticamente al hacer toggle del checkbox.

**CRITERIOS DE ACEPTACIÓN TÉCNICOS:**
- [ ] `ModuleAccessComponent` creado como Standalone
- [ ] Accordion de aplicaciones con checklist de módulos
- [ ] Auto-save al toggle del checkbox
- [ ] Indicador de "Guardando..." durante peticiones
- [ ] Tests unitarios >80%

**ARCHIVOS A CREAR:**
- `src/app/modules/admin/components/module-access/module-access.component.ts`
- Templates, estilos y tests
