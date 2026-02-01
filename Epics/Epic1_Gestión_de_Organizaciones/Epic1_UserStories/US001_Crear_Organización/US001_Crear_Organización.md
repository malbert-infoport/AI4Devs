#### US-001: Crear nueva organización cliente

**Épica:** Gestión del Portfolio de Organizaciones Clientes
**Rol:** OrganizationManager
**Prioridad:** Alta | **Estimación:** 5 Story Points

**Historia:**
```
Como OrganizationManager responsable del onboarding de clientes,
quiero dar de alta una nueva organización cliente completando un formulario simple con sus datos básicos (nombre, CIF, dirección, contacto),
para iniciar su proceso de incorporación al ecosistema en pocos minutos y sin cometer errores que retrasen su acceso a las aplicaciones.
```

**Contexto adicional:**
El OrganizationManager acaba de cerrar un contrato con una nueva empresa de logística que necesita acceder al ecosistema de aplicaciones. El cliente espera comenzar a usar las herramientas en 48 horas. El proceso consta de dos fases: primero el OrganizationManager da de alta los datos básicos de la organización (sin publicar evento todavía), y luego un ApplicationManager asigna las aplicaciones y módulos contratados, momento en el cual se publica el primer OrganizationEvent para sincronización con aplicaciones satélite.

**Criterios de aceptación:**

(Pestaña Datos de Organización y Pestaña Módulos y Permisos - ver original para detalles de validaciones, generación de `SecurityCompanyId`, no publicación de evento al crear, navegación automática a pestaña módulos, etc.)

**Definición de hecho (DoD):**
- Código implementado y revisado
- Tests unitarios e integración
- Validaciones de frontend y backend funcionando
- Organización creada sin publicar evento

**Dependencias:** Ninguna

**Notas técnicas:**
- Usar EF Core, `SecurityCompanyId` por secuencia PostgreSQL
- NO publicar `OrganizationEvent` al crear
