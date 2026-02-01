#### US-018: Configurar acceso masivo de módulos

**Épica:** Configuración de Módulos y Permisos de Acceso
**Rol:** ApplicationManager
**Prioridad:** Media | **Estimación:** 5 Story Points

**Historia:**
```
Como ApplicationManager que debe configurar accesos para múltiples clientes,
quiero asignar un conjunto de módulos a múltiples organizaciones de una sola vez,
para ahorrar tiempo cuando tengo que activar el mismo paquete de funcionalidades para varias organizaciones.
```

**Criterios de aceptación:**
- Vista de configuración masiva con selector múltiple de organizaciones, selector de aplicación y checklist de módulos
- Crear registros en batch en `MODULE_ACCESS`
- Publicar `OrganizationEvent` por cada organización afectada
- Indicador de progreso

**Dependencias:** US-016, US-017

**Notas técnicas:**
- Usar transacciones para atomicidad
- Evitar duplicados
