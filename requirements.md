# Especificación de Requisitos - InfoportOneAdmon

## Índice

1. [Introducción](#1-introducción)
2. [Requisitos Funcionales](#2-requisitos-funcionales)
   - 2.1. [Gestión de Organizaciones](#21-gestión-de-organizaciones)
   - 2.2. [Gestión de Aplicaciones](#22-gestión-de-aplicaciones)
   - 2.3. [Gestión de Roles y Módulos](#23-gestión-de-roles-y-módulos)
   - 2.4. [Arquitectura de Eventos](#24-arquitectura-de-eventos)
   - 2.5. [Integración con Keycloak](#25-integración-con-keycloak)
   - 2.6. [Consolidación de Usuarios](#26-consolidación-de-usuarios)
3. [Requisitos No Funcionales](#3-requisitos-no-funcionales)
   - 3.1. [Rendimiento](#31-rendimiento)
   - 3.2. [Seguridad](#32-seguridad)
   - 3.3. [Disponibilidad y Escalabilidad](#33-disponibilidad-y-escalabilidad)
   - 3.4. [Mantenibilidad](#34-mantenibilidad)
   - 3.5. [Usabilidad](#35-usabilidad)
   - 3.6. [Interoperabilidad](#36-interoperabilidad)

---

## 1. Introducción

### 1.1. Propósito
Este documento define los requisitos funcionales y no funcionales del sistema **InfoportOneAdmon**, plataforma centralizada para la gestión del portfolio de aplicaciones empresariales, control de acceso multi-organización e integración con Keycloak.

### 1.2. Alcance
Los requisitos cubren todos los módulos del sistema: gestión de organizaciones, aplicaciones, roles, módulos, arquitectura de eventos, integración con Keycloak y consolidación de usuarios multi-organización.

### 1.3. Convenciones
- **RF-XXX**: Requisito Funcional
- **RNF-XXX**: Requisito No Funcional
- **Prioridad**: Alta (crítico), Media (importante), Baja (deseable)

---

## 2. Requisitos Funcionales

### 2.1. Gestión de Organizaciones

| ID | Descripción | Prioridad | Criterios de Aceptación |
|----|-------------|-----------|-------------------------|
| **RF-001** | El sistema deberá permitir crear organizaciones clientes con información básica (nombre, CIF, dirección, contacto). | Alta | - Formulario de alta con validación de campos obligatorios<br/>- Generación automática de SecurityCompanyId único<br/>- Persistencia en base de datos PostgreSQL |
| **RF-002** | El sistema deberá permitir editar la información de organizaciones existentes. | Alta | - Solo administradores pueden editar<br/>- Validación de cambios<br/>- Auditoría de modificaciones con timestamp y usuario |
| **RF-003** | El sistema deberá permitir desactivar organizaciones (soft delete). | Alta | - Cambio de estado a `IsDeleted=true`<br/>- Publicación de evento OrganizationEvent con flag IsDeleted<br/>- Mantenimiento del histórico |
| **RF-004** | El sistema deberá permitir agrupar organizaciones en Grupos de Organizaciones. | Media | - Creación de grupos con nombre y descripción<br/>- Asignación de organizaciones a un grupo (relación 1:N)<br/>- Un grupo sin organizaciones se elimina automáticamente |
| **RF-005** | El sistema deberá publicar eventos OrganizationEvent al broker cuando se cree, actualice o elimine una organización. | Alta | - Evento con payload completo de la organización<br/>- Incluye GroupId si pertenece a un grupo<br/>- Hash SHA-256 para prevenir duplicados<br/>- Publicación al tópico `infoportone.events.organization` |
| **RF-006** | El sistema deberá listar todas las organizaciones con filtros y paginación. | Media | - Filtros: nombre, estado (activa/inactiva), grupo<br/>- Paginación configurable (10, 25, 50 items)<br/>- Ordenación por múltiples columnas |
| **RF-007** | El sistema deberá mostrar el detalle completo de una organización incluyendo aplicaciones y módulos contratados. | Media | - Vista detallada con información completa<br/>- Lista de aplicaciones con acceso<br/>- Módulos contratados por aplicación |

---

### 2.2. Gestión de Aplicaciones

| ID | Descripción | Prioridad | Criterios de Aceptación |
|----|-------------|-----------|-------------------------|
| **RF-008** | El sistema deberá permitir registrar aplicaciones satélite del portfolio con información técnica (nombre, descripción, prefijo de aplicación, ApplicationId, credenciales OAuth2). | Alta | - Generación de ClientId y ClientSecret para Keycloak<br/>- Configuración de RedirectURIs<br/>- Asignación de prefijo único para la aplicación (ej: STP para Sintraport)<br/>- Almacenamiento seguro de credenciales |
| **RF-008a** | El sistema deberá soportar dos tipos de credenciales OAuth2: CODE (public clients como Angular SPAs) y ClientCredentials (confidential clients como APIs backend). | Alta | - Public clients registrados solo con client_id (sin secret)<br/>- Confidential clients con client_id y client_secret hasheado con bcrypt<br/>- Public clients usan PKCE (S256) para seguridad sin secretos<br/>- Confidential clients almacenan secret hasheado, nunca en texto plano |
| **RF-008b** | El sistema deberá permitir a una aplicación tener múltiples credenciales OAuth2 simultáneamente (frontend + backend). | Media | - Tabla APPLICATION_SECURITY separada de APPLICATION<br/>- Múltiples registros de credenciales por ApplicationId<br/>- Cada credencial con su propio ciclo de vida (IsActive)<br/>- Soporte para rotación de secretos sin afectar otras credenciales |
| **RF-009** | El sistema deberá permitir definir roles de seguridad por cada aplicación usando el prefijo de la aplicación. | Alta | - CRUD completo de roles<br/>- Vinculación a aplicación específica<br/>- Nombres de rol usando prefijo de aplicación (ej: STP_AsignadorTransporte para Sintraport)<br/>- Nombres de rol únicos dentro de la aplicación |
| **RF-009a** | El sistema deberá validar que los roles y módulos sigan la nomenclatura estándar basada en el prefijo de la aplicación. | Media | - Roles usan RolePrefix directamente (ej: CRM_Vendedor)<br/>- Módulos usan M + RolePrefix (ej: MCRM_Facturacion)<br/>- Validación automática al crear/editar roles y módulos<br/>- Rechazo de nombres que no siguen el patrón |
| **RF-010** | El sistema deberá permitir definir módulos funcionales por cada aplicación usando la nomenclatura M + prefijo de aplicación. | Alta | - CRUD completo de módulos<br/>- Descripción y metadata de cada módulo<br/>- Vinculación a aplicación específica<br/>- Nombres de módulo usando M + prefijo de aplicación (ej: MSTP_Trafico para Sintraport) |
| **RF-011** | El sistema deberá permitir configurar qué organizaciones tienen acceso a qué módulos de cada aplicación. | Alta | - Matriz de permisos organización-módulo<br/>- Configuración masiva y por organización<br/>- Validación de acceso antes de asignar |
| **RF-012** | El sistema deberá registrar automáticamente cada aplicación como Client OAuth2 en Keycloak. | Alta | - Creación de client en Keycloak via Admin API<br/>- Configuración de Protocol Mappers para claim `c_ids`<br/>- Flow: Authorization Code + PKCE |
| **RF-013** | El sistema deberá publicar eventos ApplicationEvent cuando se registre, actualice o elimine una aplicación. | Alta | - Payload con datos de aplicación, roles y módulos<br/>- Incluye organizaciones con acceso a cada módulo<br/>- Hash SHA-256 para prevención de duplicados<br/>- Publicación al tópico `infoportone.events.application` |
| **RF-014** | El sistema deberá permitir visualizar el catálogo completo de aplicaciones del portfolio. | Media | - Lista con información resumida<br/>- Filtros por estado, nombre<br/>- Indicadores visuales de estado |

---

### 2.3. Gestión de Roles y Módulos

| ID | Descripción | Prioridad | Criterios de Aceptación |
|----|-------------|-----------|-------------------------|
| **RF-015** | El sistema deberá mantener un catálogo maestro de roles por aplicación. | Alta | - Roles únicos por aplicación<br/>- Descripción de permisos asociados<br/>- No se permite duplicación de nombres |
| **RF-016** | El sistema deberá incluir los roles en el payload de ApplicationEvent junto con la aplicación. | Alta | - Lista completa de roles en cada evento de aplicación<br/>- Sincronización atómica roles-aplicación<br/>- Sin eventos separados de roles |
| **RF-017** | El sistema deberá permitir definir módulos con metadata descriptiva (nombre, descripción, funcionalidad). | Media | - Formulario de alta/edición de módulos<br/>- Validación de campos<br/>- Asociación obligatoria a aplicación |
| **RF-018** | El sistema deberá incluir en el OrganizationEvent la lista de aplicaciones y módulos accesibles para cada organización. | Alta | - Por cada aplicación: ApplicationId (Id de Application), DatabaseName y lista de Ids de módulos accesibles<br/>- Sincronización completa en cada evento de organización<br/>- Permite a las apps satélite conocer qué puede hacer cada organización |

---

### 2.4. Arquitectura de Eventos

| ID | Descripción | Prioridad | Criterios de Aceptación |
|----|-------------|-----------|-------------------------|
| **RF-019** | El sistema deberá publicar eventos al broker ActiveMQ Artemis usando el patrón "State Transfer Event". | Alta | - Eventos contienen estado completo de la entidad<br/>- No deltas ni notificaciones simples<br/>- Payload como array para operaciones masivas |
| **RF-020** | El sistema deberá mantener 3 tópicos de eventos: organization, application, user. | Alta | - `infoportone.events.organization`<br/>- `infoportone.events.application`<br/>- `infoportone.events.user`<br/>- No existen otros tópicos |
| **RF-021** | El sistema deberá calcular hash SHA-256 del payload de cada evento para prevenir publicación de duplicados. | Alta | - Hash calculado sobre payload serializado<br/>- Excluye EventId, EventTimestamp, TraceId<br/>- Almacenamiento en tabla EventHashControl<br/>- Solo publica si hash es diferente al anterior |
| **RF-022** | El sistema deberá incluir metadatos de trazabilidad en cada evento (EventId, TraceId, Timestamp, OriginApplicationId). | Media | - EventId: UUID v4 único<br/>- TraceId: para correlación<br/>- Timestamp: ISO 8601<br/>- OriginApplicationId: identificador del emisor |
| **RF-023** | El sistema deberá permitir republicar eventos completos para sincronización inicial de aplicaciones satélite. | Media | - Funcionalidad administrativa para enviar snapshot completo<br/>- Por entidad: todas las organizaciones, aplicaciones, etc.<br/>- Logs de operaciones de sincronización |
| **RF-024** | El sistema deberá garantizar mensajería persistente en ActiveMQ Artemis. | Alta | - Configuración de persistencia en broker<br/>- Durabilidad de suscripciones<br/>- Entrega garantizada (at-least-once) |

---

### 2.5. Integración con Keycloak

| ID | Descripción | Prioridad | Criterios de Aceptación |
|----|-------------|-----------|-------------------------|
| **RF-025** | El sistema deberá interactuar con Keycloak exclusivamente mediante Admin API REST. | Alta | - Autenticación con service account<br/>- Solo InfoportOneAdmon accede a Admin API<br/>- Aplicaciones satélite solo usan flujo OAuth2 |
| **RF-026** | El sistema deberá crear automáticamente clients OAuth2 en Keycloak al registrar una aplicación. | Alta | - POST a `/admin/realms/InfoportOne/clients`<br/>- Configuración: clientId, secret, redirectUris, pkce enabled<br/>- Manejo de errores y rollback |
| **RF-027** | El sistema deberá configurar Protocol Mappers en Keycloak para incluir el claim personalizado `c_ids`. | Alta | - Mapper tipo "User Attribute"<br/>- Claim name: `c_ids`<br/>- Incluido en Access Token y ID Token<br/>- Tipo: JSON Array |
| **RF-028** | El sistema deberá operar sobre un único realm: InfoportOne. | Alta | - Configuración centralizada del realm<br/>- SSO habilitado entre aplicaciones<br/>- No multi-realm |
| **RF-029** | El sistema deberá sincronizar usuarios en Keycloak mediante operaciones CREATE y UPDATE via Admin API. | Alta | - GET `/users?email={email}` para buscar<br/>- POST `/users` si no existe<br/>- PUT `/users/{id}` si existe<br/>- Actualización de atributo `c_ids` como **atributo multivalor** (array de strings)<br/>- Sincronización de roles consolidados |

---

### 2.6. Consolidación de Usuarios

| ID | Descripción | Prioridad | Criterios de Aceptación |
|----|-------------|-----------|-------------------------|
| **RF-030** | El Background Worker deberá suscribirse al tópico `infoportone.events.user` para consumir eventos de usuario. | Alta | - Suscripción durable<br/>- Procesamiento idempotente<br/>- ACK solo tras sincronización exitosa con Keycloak |
| **RF-031** | El Background Worker deberá detectar usuarios duplicados por email (identificador único global). | Alta | - Búsqueda en BD por email<br/>- Identificación de múltiples SecurityCompanyIds<br/>- Ventana de consolidación configurable |
| **RF-032** | El Background Worker deberá consolidar múltiples organizaciones de un usuario en el claim `c_ids` y consolidar todos sus roles de las distintas aplicaciones. | Alta | - Query a BD para obtener todos los SecurityCompanyIds del email<br/>- Construcción de array completo [id1, id2, id3...]<br/>- Consolidación de roles de todas las aplicaciones usando prefijos de aplicación<br/>- Validación de que organizaciones existen y están activas |
| **RF-033** | El Background Worker deberá sincronizar directamente con Keycloak sin publicar eventos consolidados adicionales. | Alta | - Patrón Aggregator puro: consume → consolida → actúa<br/>- NO publica eventos de vuelta al broker<br/>- Evita ciclos infinitos de eventos |
| **RF-034** | El Background Worker deberá implementar retry con backoff exponencial ante fallos de Keycloak. | Media | - Política de reintentos configurable (ej: 3 intentos)<br/>- Backoff: 1s, 2s, 4s...<br/>- Envío a DLQ tras fallos definitivos |
| **RF-035** | El sistema deberá mantener caché de consolidación de usuarios para optimizar procesamiento. | Media | - Tabla `UserConsolidationCache` con email, c_ids consolidados, fecha<br/>- Actualización tras cada consolidación<br/>- Reducción de queries a BD |
| **RF-036** | El sistema deberá eliminar automáticamente grupos de organizaciones que queden sin miembros. | Baja | - Job periódico que detecta grupos huérfanos (sin organizaciones)<br/>- Soft delete de grupos vacíos<br/>- Notificación a apps satélite mediante ausencia de GroupId en eventos |
| **RF-037** | El sistema deberá almacenar en caché los roles consolidados de usuarios de todas las aplicaciones. | Media | - Campo ConsolidatedRoles en tabla UserConsolidationCache<br/>- Incluye roles de todas las aplicaciones con prefijos únicos<br/>- Actualización tras cada consolidación de usuario<br/>- Sincronización de roles consolidados con Keycloak |

---

## 3. Requisitos No Funcionales

### 3.1. Rendimiento

| ID | Descripción | Prioridad | Criterios de Aceptación |
|----|-------------|-----------|-------------------------|
| **RNF-001** | El sistema deberá responder a peticiones de consulta (GET) en menos de 200ms en el percentil 95. | Alta | - Medición con herramientas de APM<br/>- Bajo carga normal (100 usuarios concurrentes)<br/>- Incluye tiempo de BD |
| **RNF-002** | El sistema deberá procesar operaciones de escritura (POST/PUT) en menos de 500ms en el percentil 95. | Alta | - Incluye persistencia en BD y publicación de evento<br/>- Sin incluir propagación del evento a consumidores<br/>- Medición bajo carga normal |
| **RNF-003** | El Background Worker deberá procesar al menos 100 eventos de usuario por segundo. | Media | - Throughput sostenido<br/>- Incluye consolidación y sync con Keycloak<br/>- Sin degradación de latencia |
| **RNF-004** | El sistema deberá soportar picos de 500 eventos publicados por minuto sin pérdida de mensajes. | Media | - Configuración de buffer en ActiveMQ Artemis<br/>- Persistencia garantizada<br/>- Monitorización de cola |
| **RNF-005** | Las consultas a base de datos deberán optimizarse mediante índices adecuados. | Alta | - Índices en claves foráneas<br/>- Índices en campos de búsqueda frecuente (email, SecurityCompanyId)<br/>- Análisis de planes de ejecución |
| **RNF-006** | El sistema deberá implementar paginación en todas las listas con más de 25 elementos. | Media | - Paginación del lado del servidor<br/>- Control de tamaño de página<br/>- Metadata de paginación en respuestas |

---

### 3.2. Seguridad

| ID | Descripción | Prioridad | Criterios de Aceptación |
|----|-------------|-----------|-------------------------|
| **RNF-007** | El sistema deberá autenticar todas las peticiones HTTP mediante tokens JWT válidos. | Alta | - Validación de firma JWT<br/>- Verificación de expiración<br/>- Rechazo de tokens inválidos con HTTP 401 |
| **RNF-008** | El sistema deberá implementar autorización basada en roles para operaciones administrativas. | Alta | - Solo roles autorizados pueden crear/editar/eliminar<br/>- Validación en cada endpoint<br/>- Logs de intentos no autorizados |
| **RNF-009** | El sistema deberá proteger credenciales sensibles mediante cifrado. | Alta | - Secrets de Keycloak cifrados en BD<br/>- Variables de entorno para credenciales<br/>- No exponer secrets en logs ni respuestas API |
| **RNF-009a** | El sistema deberá gestionar secretos de forma diferenciada según el tipo de cliente OAuth2. | Alta | - Public clients (Angular SPAs): NO almacenan secretos, usan PKCE dinámico<br/>- Confidential clients (APIs backend): Secrets hasheados con bcrypt en BD<br/>- Docker Secrets para secretos de confidential clients en producción<br/>- dotnet user-secrets para desarrollo local de backends<br/>- Secretos solo visibles en texto plano en momento de creación |
| **RNF-010** | El sistema deberá utilizar HTTPS para todas las comunicaciones externas. | Alta | - Certificados TLS válidos<br/>- Redirección HTTP → HTTPS<br/>- HSTS headers configurados |
| **RNF-011** | El sistema deberá prevenir SQL Injection mediante prepared statements. | Alta | - Entity Framework Core con queries parametrizadas<br/>- Sin concatenación de SQL<br/>- Validación de entrada |
| **RNF-012** | El sistema deberá implementar validación de entrada en todos los endpoints. | Alta | - FluentValidation para DTOs<br/>- Validación de tipos, longitudes, formatos<br/>- Rechazo de entrada inválida con HTTP 400 |
| **RNF-013** | El sistema deberá implementar rate limiting para prevenir abuso de APIs. | Media | - Límite configurable por IP/usuario<br/>- Ventana temporal (ej: 100 req/min)<br/>- Respuesta HTTP 429 al exceder límite |
| **RNF-014** | El sistema deberá registrar auditoría de todas las operaciones de escritura. | Alta | - Tabla de auditoría con: usuario, operación, timestamp, entidad, cambios<br/>- Inmutabilidad de logs<br/>- Retención mínima 1 año |

---

### 3.3. Disponibilidad y Escalabilidad

| ID | Descripción | Prioridad | Criterios de Aceptación |
|----|-------------|-----------|-------------------------|
| **RNF-015** | El sistema deberá alcanzar una disponibilidad del 99.5% (downtime < 3.65 horas/mes). | Alta | - Medición con uptime monitoring<br/>- Excluye mantenimientos programados<br/>- SLA definido |
| **RNF-016** | El sistema deberá soportar despliegue en múltiples instancias (horizontal scaling). | Alta | - Arquitectura stateless<br/>- Sesiones en tokens JWT<br/>- Load balancer compatible |
| **RNF-017** | El sistema deberá permitir escalado horizontal del Background Worker. | Media | - Múltiples consumidores del mismo tópico<br/>- Distribución de carga mediante particiones o grupos de consumidores<br/>- Sin procesamiento duplicado |
| **RNF-018** | El sistema deberá implementar health checks para monitorización. | Alta | - Endpoint `/health` con estado de BD, Artemis, Keycloak<br/>- Respuesta en menos de 2 segundos<br/>- Integración con orchestrators (Kubernetes) |
| **RNF-019** | El sistema deberá soportar despliegue mediante contenedores Docker. | Alta | - Dockerfile optimizado<br/>- Imagen base oficial .NET<br/>- Variables de entorno para configuración |
| **RNF-020** | El sistema deberá implementar graceful shutdown para evitar pérdida de datos. | Media | - Finalización ordenada de procesamiento de eventos<br/>- Cierre de conexiones a BD<br/>- Timeout configurable (ej: 30s) |

---

### 3.4. Mantenibilidad

| ID | Descripción | Prioridad | Criterios de Aceptación |
|----|-------------|-----------|-------------------------|
| **RNF-021** | El sistema deberá seguir la arquitectura Helix6 (N-Capas + Clean Architecture). | Alta | - Separación clara de capas: Presentation, Application, Domain, Infrastructure<br/>- Dependencias unidireccionales hacia el núcleo<br/>- Inversión de dependencias mediante interfaces |
| **RNF-022** | El sistema deberá implementar logging estructurado con niveles adecuados. | Alta | - Serilog con sinks a consola y archivo<br/>- Niveles: Debug, Info, Warning, Error, Fatal<br/>- Contexto enriquecido (correlationId, usuario, operación) |
| **RNF-023** | El sistema deberá documentar todas las APIs mediante OpenAPI/Swagger. | Media | - Generación automática de documentación<br/>- Ejemplos de request/response<br/>- Descripciones de parámetros |
| **RNF-024** | El código deberá mantener una cobertura de tests unitarios superior al 70%. | Media | - Tests con xUnit/NUnit<br/>- Mocking de dependencias<br/>- Medición con herramientas de coverage |
| **RNF-025** | El sistema deberá seguir convenciones de código .NET estándar. | Media | - Análisis estático con Roslyn Analyzers<br/>- Estilo consistente (naming, indentación)<br/>- Sin warnings del compilador |
| **RNF-026** | El sistema deberá versionar cambios en el esquema de base de datos mediante migraciones. | Alta | - Entity Framework Core Migrations<br/>- Scripts SQL generados y versionados<br/>- Rollback disponible |

---

### 3.5. Usabilidad

| ID | Descripción | Prioridad | Criterios de Aceptación |
|----|-------------|-----------|-------------------------|
| **RNF-027** | La interfaz administrativa deberá ser responsive y compatible con resoluciones desktop. | Media | - Diseño adaptable a 1920x1080, 1366x768<br/>- Framework Angular Material o similar<br/>- Navegación intuitiva |
| **RNF-028** | El sistema deberá proporcionar mensajes de error claros y accionables. | Media | - Descripción del error en lenguaje natural<br/>- Sugerencias de solución cuando sea posible<br/>- Sin mensajes técnicos expuestos al usuario final |
| **RNF-029** | El sistema deberá confirmar operaciones destructivas (eliminaciones). | Media | - Modal de confirmación antes de eliminar<br/>- Descripción del impacto de la acción<br/>- Botón de cancelar visible |
| **RNF-030** | El sistema deberá proporcionar feedback visual durante operaciones asíncronas. | Baja | - Spinners/loading indicators<br/>- Mensajes de éxito/error tras completar<br/>- Barra de progreso cuando sea posible |

---

### 3.6. Interoperabilidad

| ID | Descripción | Prioridad | Criterios de Aceptación |
|----|-------------|-----------|-------------------------|
| **RNF-031** | El sistema deberá exponer APIs REST que cumplan con los principios RESTful. | Alta | - Uso correcto de verbos HTTP (GET, POST, PUT, DELETE)<br/>- URIs semánticas y consistentes<br/>- Códigos de estado HTTP apropiados |
| **RNF-032** | El sistema deberá serializar todos los eventos en formato JSON. | Alta | - Schema JSON bien definido<br/>- System.Text.Json o Newtonsoft.Json<br/>- Compatibilidad con consumidores heterogéneos |
| **RNF-033** | El sistema deberá ser compatible con ActiveMQ Artemis 2.31 o superior. | Alta | - Cliente Apache.NMS.ActiveMQ<br/>- Protocolo AMQP o OpenWire<br/>- Pruebas de integración |
| **RNF-034** | El sistema deberá ser compatible con Keycloak 23 o superior. | Alta | - Admin API REST v23+<br/>- OAuth2 / OpenID Connect estándar<br/>- Compatibilidad hacia atrás dentro de versión mayor |
| **RNF-035** | El sistema deberá soportar PostgreSQL 15 o superior como base de datos. | Alta | - Uso de características de PG 15<br/>- Migración compatible con versiones superiores<br/>- No dependencias de extensiones no estándar |

---

## Matriz de Trazabilidad

| Módulo/Componente | Requisitos Funcionales | Requisitos No Funcionales |
|-------------------|------------------------|---------------------------|
| **Gestión de Organizaciones** | RF-001 a RF-007 | RNF-001, RNF-002, RNF-005, RNF-007, RNF-008, RNF-014 |
| **Gestión de Aplicaciones** | RF-008 a RF-014 | RNF-001, RNF-002, RNF-005, RNF-007, RNF-008, RNF-009, RNF-014 |
| **Gestión de Roles y Módulos** | RF-015 a RF-018 | RNF-001, RNF-005, RNF-007, RNF-008 |
| **Arquitectura de Eventos** | RF-019 a RF-024 | RNF-003, RNF-004, RNF-017, RNF-024, RNF-032, RNF-033 |
| **Integración con Keycloak** | RF-025 a RF-029 | RNF-009, RNF-010, RNF-034 |
| **Consolidación de Usuarios** | RF-030 a RF-035 | RNF-003, RNF-005, RNF-020, RNF-024 |
| **Infraestructura General** | - | RNF-015 a RNF-020, RNF-035 |
| **Calidad de Código** | - | RNF-021 a RNF-026 |
| **Interfaz de Usuario** | - | RNF-027 a RNF-030 |
| **APIs y Comunicación** | - | RNF-031, RNF-032 |

---

## Notas de Implementación

### Priorización
- **Fase 1 (MVP)**: Todos los requisitos de prioridad ALTA
- **Fase 2**: Requisitos de prioridad MEDIA
- **Fase 3**: Requisitos de prioridad BAJA

### Dependencias Críticas
- PostgreSQL 15+ instalado y configurado
- ActiveMQ Artemis 2.31+ desplegado
- Keycloak 23+ con realm InfoportOne configurado
- .NET 8 SDK para desarrollo

### Validación
Cada requisito será validado mediante:
- **Requisitos Funcionales**: Tests de integración y pruebas manuales
- **Requisitos No Funcionales**: Métricas automatizadas y herramientas de monitorización
