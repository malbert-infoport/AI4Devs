## Índice

1. [Descripción general del producto](#1-descripción-general-del-producto)
2. [Arquitectura del sistema](#2-arquitectura-del-sistema)
3. [Modelo de datos](#3-modelo-de-datos)
4. [Especificación de la API](#4-especificación-de-la-api)
5. [Historias de usuario](#5-historias-de-usuario)
6. [Tickets de trabajo](#6-tickets-de-trabajo)
7. [Pull requests](#7-pull-requests)

---

## 1. Descripción general del producto

## Prompt 1.1: Definición inicial del producto

**Rol:** Product Owner especialista en aplicaciones multiorganización, con una gestión centralizada de las organizaciones con acceso a cada aplicación mediante oauth2.

**Objetivo:** Realizar una descripción general del proyecto en formato .md, lo más detallada posible, para la gestión de organizaciones con toda la funcionalidad que debe cubrir para permitir crear organizaciones cuyos usuarios puedan acceder a las distintas aplicaciones del ecosistema. Esta documentación deberá cubrir:
- Una descripción breve del proyecto de organizaciones
- Funcionalidades principales
- Diagrama del sistema explicado con diagrama mermaid adjunto
- Descripción de todos los casos de uso que cubran la funcionalidad completa del proyecto junto con su diagrama mermaid asociado
- Modelo de datos que cubra entidades, atributos (nombre y tipo) y relaciones para todos los casos de uso

**Requisitos previos:**
- El proyecto de organizaciones está integrado con un identity server Keycloak en su última versión y accederá a las APIs REST de Keycloak para gestionar el alta de organizaciones, usuarios, etc.
- La interacción con Keycloak mediante APIs solo se realizará desde el proyecto de organizaciones, el resto de aplicaciones del ecosistema solo utilizarán el flujo de autenticación code PKCE
- Se define un realm único, InfoportOne, que permite SSO entre aplicaciones
- Gestión de aplicaciones y sus roles desde el proyecto de organizaciones
- Integración con la última versión de Keycloak para sincronizar datos relevantes que viajarán en el bearer token (como SecurityCompanyId)
- Las aplicaciones tendrán un ApplicationId entero
- Integración mediante broker de eventos tipo ActiveMQ Artemis
- Base de datos PostgreSQL y tecnología .NET 8 y Angular 20
- Despliegue mediante contenedores en la nube o on premise
- Premisas de optimización de costes (transacciones a BD, accesos a disco, número de contenedores, etc.)

---

## Prompt 1.2: Corrección del modelo de gestión de usuarios

**Rol:** Product Owner especialista en aplicaciones multiorganización, con una gestión centralizada de las organizaciones con acceso a cada aplicación mediante oauth2.

**Objetivo:** Volver a generar la documentación teniendo en cuenta que el proyecto de organizaciones NO gestiona los usuarios, son las aplicaciones quienes lo hacen y las que determinan cada rol que permisos de acceso efectivos tiene la propia aplicación. Desde el proyecto de organizaciones solo se gestionarán qué roles tiene cada aplicación para que la propia aplicación dé de alta usuarios con sus roles asociados mediante el proyecto de organizaciones.

---

## Prompt 1.3: Refinamiento de funcionalidades y cambios de naming

**Rol:** Product Owner especialista en aplicaciones multiorganización, con una gestión centralizada de las organizaciones con acceso a cada aplicación mediante oauth2.

**Objetivo:** Revisar la documentación completa ya generada para:
- Añadir una descripción a las funcionalidades principales, al menos al nivel superior indicando el sentido de la misma
- Sustituir RabbitMQ por ActiveMQ Artemis en todos los diagramas y referencias
- Cambiar toda referencia a SGOR como nombre de proyecto por InfoportOneAdmon
- Enfocarse en el "qué" no en el "cómo" (no ejemplos JSON para claims ni patrón de suscripción a roles)
- Los flujos deben diseñarse como diagramas de flujo en UML con Mermaid
- Aclarar que este proyecto está pensado para que UNA organización propietaria del ecosistema cree y gestione las organizaciones clientes desde InfoportOneAdmon (NO auto-registro)

---

## Prompt 1.4: Definición de Stakeholders

**Rol:** Product Owner especialista en aplicaciones multiorganización, con una gestión centralizada de las organizaciones con acceso a cada aplicación mediante oauth2.

**Objetivo:** En base al contexto de este hilo, definir en formato .md un nuevo punto para el informe con los Stakeholders: Identificar a todas las partes interesadas, incluyendo usuarios, compradores, fabricantes, asistencia al cliente, marketing y ventas, socios externos, instancias reguladoras, minoristas, entre otros.

---

## Prompt 1.5: Completar especificaciones del producto

**Rol:** Product Owner especialista en aplicaciones multiorganización, con una gestión centralizada de las organizaciones con acceso a cada aplicación mediante oauth2.

**Objetivo:** Añadir en base al contexto del proyecto los siguientes puntos:
- **Componentes Principales y Sitemaps**: Detalla la estructura y organización del producto, incluyendo sus componentes principales y cómo se relacionan entre sí
- **Diseño y Experiencia del Usuario**: Incluye especificaciones sobre el diseño del producto y la experiencia del usuario, asegurando que el producto sea usable y estéticamente agradable
- **Requisitos Técnicos**: Detalla los aspectos técnicos necesarios para el desarrollo del producto, incluyendo hardware, software, interactividad, personalización y normativas
- **Planificación del Proyecto**: Proporciona información sobre plazos, hitos y dependencias, crucial para la planificación y gestión efectiva del proyecto. Esta debe estar acotada a un plazo de 30 horas que son más o menos las horas dedicadas a realizar este proyecto mediante IA. Esto debe ser tenido en cuenta para determinar el PMV de este proyecto
- **Criterios de aceptación**: Define los estándares y condiciones bajo los cuales el producto será aceptado tras su finalización

---

## Prompt 1.6: Grupos de organizaciones y sincronización por eventos

**Rol:** Product Owner especialista en aplicaciones multiorganización, con una gestión centralizada de las organizaciones con acceso a cada aplicación mediante oauth2.

**Objetivo:** Analizar la documentación del producto y aplicar los siguientes cambios:
- Las organizaciones deben poder agruparse en grupos de organizaciones para que desde las aplicaciones se puedan realizar funcionalidades entre las organizaciones de un mismo grupo. Esto debe ser mantenible y generar eventos que lo comuniquen a los servicios
- Las aplicaciones NO deben conectarse vía API a InfoportOne para sincronizar datos al arrancar. En su lugar, debe haber una funcionalidad que permita enviar por eventos (por ejemplo, el listado completo de aplicaciones) a la cola a la que esté suscrita la aplicación destinataria. Este será el método de sincronización de datos o de inicialización de datos para una aplicación nueva

---

## Prompt 1.7: Definición de estructura de eventos State Transfer

**Rol:** Product Owner especialista en aplicaciones multiorganización, con una gestión centralizada de las organizaciones con acceso a cada aplicación mediante oauth2.

**Objetivo:** Redefinir los eventos para que NO usen sufijos como `added`, `created`, `updated`, `deleted`. La aplicación satélite receptora no tiene por qué estar en el mismo estado que InfoportOne. Se deben definir eventos generales para cada entidad:
- Tipo `OrganizationEvent` con propiedades: tipo de evento, fecha de creación, flag `IsDeleted` (indica si ha sido borrado en origen) y las propiedades de la Organización
- El resto de eventos seguirían una estructura similar (patrón "State Transfer Event")
- Incluir en la documentación la definición completa de los eventos

---

## 2. Arquitectura del Sistema

### **2.1. Diagrama de arquitectura:**

## Prompt 2.1.1: Corrección de responsabilidades del Background Worker

**Rol:** Arquitecto de Software especialista en arquitecturas event-driven, patrones de integración y sistemas distribuidos.

**Objetivo:** Corregir la documentación del sistema para reflejar correctamente las responsabilidades del Background Worker de InfoportOneAdmon:

**Problema detectado:**
- En el punto 2.1.2 (Diagrama de Contenedores) y posiblemente en otros lugares de la documentación, se muestra al Background Worker de InfoportOneAdmon publicando eventos consolidados al broker ActiveMQ Artemis
- Este comportamiento es incorrecto y genera confusión sobre las responsabilidades del componente

**Corrección requerida:**
- El Background Worker de InfoportOneAdmon debe actuar únicamente como **consumidor** de eventos (suscrito al tópico `infoportone.events.user`)
- Su única responsabilidad tras la consolidación de usuarios multi-organización es **sincronizar directamente con Keycloak** mediante su Admin API REST
- NO debe publicar eventos consolidados de vuelta al broker
- El flujo correcto es: Apps Satélite → Publican UserEvent → Background Worker consume → Consolida datos → Sincroniza con Keycloak (sin publicar eventos adicionales)

**Resultado esperado:**
- Actualizar todos los diagramas y descripciones donde aparezca el Background Worker
- Eliminar cualquier referencia a publicación de eventos consolidados por parte del Background Worker
- Clarificar que el patrón utilizado es **Aggregator** puro: consume N eventos, agrega/consolida información, y ejecuta acción (sync con Keycloak) sin generar nuevos eventos
- Documentar que esto evita ciclos infinitos de eventos y simplifica la arquitectura

## Prompt 2.1.2: Propuesta de diagramas jerárquicos de arquitectura

**Rol:** Arquitecto de Software especialista en documentación de arquitectura, visualización de sistemas complejos y modelo C4.

**Objetivo:** Proponer una reestructuración de la documentación de arquitectura mediante la creación de múltiples diagramas jerárquicos que simplifiquen la visualización y comprensión del sistema.

**Problema detectado:**
- El diagrama de arquitectura actual es demasiado grande y complejo, dificultando su comprensión
- Toda la información arquitectónica está concentrada en un único diagrama, sobrecargando la visualización
- No hay una progresión clara desde una visión de alto nivel hacia los detalles de implementación

**Propuesta requerida:**
- Diseñar una estructura de múltiples diagramas siguiendo un enfoque jerárquico (similar al modelo C4)
- Incluir un diagrama de **visión superior** (contexto del sistema) que muestre las interacciones de alto nivel
- Crear diagramas de **mayor nivel de detalle** para cada subsistema o aspecto arquitectónico importante
- Cada diagrama debe tener un propósito claro y complementar a los demás
- Sugerencias de tipos de diagrama: Contexto, Contenedores, Flujos de Secuencia, Arquitectura de Eventos, etc.

**Resultado esperado:**
- Propuesta estructurada de al menos 3-5 diagramas que cubran diferentes niveles de abstracción
- Descripción clara del propósito y alcance de cada diagrama propuesto
- Orden lógico de presentación (de lo general a lo específico)
- Mejora significativa en la legibilidad y comprensión de la arquitectura del sistema
- Facilitar la navegación progresiva desde conceptos generales hasta detalles técnicos

## Prompt 2.1.3: Clarificación de arquitectura de procesos y flujo de eventos

**Rol:** Arquitecto de Software especialista en arquitecturas event-driven, patrones de publicación/suscripción y sistemas distribuidos.

**Objetivo:** Actualizar la documentación para reflejar correctamente la arquitectura real de procesos publicadores y suscriptores de eventos del sistema.

**Corrección arquitectónica requerida:**

**Procesos del sistema:**
- Solo existirán **dos tipos de procesos** como emisores y suscriptores de eventos: **Aplicaciones Satélite** e **InfoportOneAdmon**
- Eliminar referencias a componentes intermedios o servicios separados que no existan en la implementación real

**Aplicaciones Satélite:**
- **Background Worker integrado**: Proceso en background suscrito a eventos de `organization` y `application`
- **Backend API**: Cuando se da de alta un usuario, publica evento `UserEvent` al tópico `infoportone.events.user`
- NO tienen componentes separados, es un único proceso con worker integrado

**InfoportOneAdmon:**
- **Background Worker integrado**: Proceso en background suscrito a eventos de `user`, consolida usuarios multi-organización y sincroniza con Keycloak
- **API REST**: Gestiona organizaciones y aplicaciones, publica eventos `OrganizationEvent` y `ApplicationEvent` a sus respectivos tópicos
- NO hay servicios separados de consolidación o sincronización

**Resultado esperado:**
- Actualizar todos los diagramas de arquitectura para mostrar únicamente estos dos tipos de procesos
- Eliminar referencias a componentes que no existen (servicios de consolidación separados, workers independientes, etc.)
- Clarificar que cada proceso tiene su Background Worker integrado (IHostedService en .NET)
- Actualizar descripciones de flujos de eventos para reflejar esta arquitectura simplificada
- Documentar que esta arquitectura reduce la complejidad operacional y el número de contenedores desplegados

### **2.2. Descripción de componentes principales:**

## Prompt 2.2.1: Gestión de usuarios vía eventos

**Rol:** Product Owner / Arquitecto Software experto en integraciones event-driven y gestión centralizada de organizaciones.

**Objetivo:** Incluir en la documentación la gestión de usuarios por parte de las aplicaciones satélite mediante eventos:
- Las aplicaciones publican `UserEvent` al broker cuando crean, actualizan o eliminan usuarios
- InfoportOne se suscribe a `infoportone.events.user` y aplica los cambios en Keycloak usando su Admin API
- El `Payload` será una lista de objetos `USER` y cada `USER` debe contener `SecurityCompanyId` (un usuario pertenece a una única organización)
- Actualizar los diagramas y flujos para reflejar este proceso

**Requisitos previos:**
- Las aplicaciones publican `UserEvent` con `Payload` como lista de usuarios
- InfoportOne tiene credenciales para Keycloak Admin API y procesa los eventos de forma idempotente
- La arquitectura de mensajería utilizada es ActiveMQ Artemis

---

## Prompt 2.2.2: Usuarios multi-organización y sistema de módulos

**Rol:** Product Owner especialista en aplicaciones multiorganización, con una gestión centralizada de las organizaciones con acceso a cada aplicación mediante oauth2.

**Objetivo:** Analizar la documentación del producto y aplicar los siguientes cambios arquitectónicos importantes:

**Cambio 1: Usuarios Multi-Organización**
- Los usuarios ahora pueden pertenecer a MÚLTIPLES organizaciones (no solo a una)
- En el bearer token debe viajar una lista con los identificadores de todas las organizaciones a las que pertenece el usuario

**Cambio 2: Nuevo Claim Personalizado**
- NO utilizar la entidad Organization de Keycloak ya que no soporta usuarios en múltiples organizaciones
- Definir un claim personalizado llamado `c_ids` (company ids) que contendrá la lista de identificadores de organizaciones del usuario
- Este claim debe configurarse en Keycloak y viajar en los tokens JWT

**Cambio 3: Nueva Entidad Módulo**
- Aparece una nueva entidad dependiente de la aplicación llamada Módulo
- Los módulos permiten definir agrupaciones funcionales dentro de cada aplicación
- Para cada aplicación se pueden definir N módulos
- Para cada organización se puede configurar qué módulos de cada aplicación tiene contratados (relación N:M entre Módulo y Organización)

**Cambio 4: Actualización del ApplicationEvent**
- El evento ApplicationEvent ahora debe incluir:
  - Los datos de la aplicación (como antes)
  - La lista de módulos definidos para esa aplicación
  - Para cada módulo: los identificadores de las organizaciones que tienen acceso al mismo

Actualizar toda la documentación para reflejar estos cambios: modelo de datos, eventos, casos de uso, diagramas, arquitectura de seguridad, y cualquier otra sección afectada.

---

## Prompt 2.2.3: Simplificación y optimización de eventos

**Rol:** Arquitecto de Software especialista en arquitecturas event-driven y sistemas multi-organización.

**Objetivo:** Simplificar y optimizar el modelo de eventos del sistema:

**Corrección 1: Consolidación del OrganizationEvent**
- Eliminar el evento `OrganizationGroupEvent` como evento independiente
- El `OrganizationEvent` debe incluir una propiedad opcional `GroupId` que indica el grupo al que pertenece la organización
- La entidad `OrganizationGroup` NO debe tener las propiedades `IsDeleted` ni `Active`
- Las aplicaciones satélite determinarán automáticamente si mantener o eliminar un grupo basándose en si tienen organizaciones que pertenezcan a él al procesar los eventos de organizaciones

**Corrección 2: Consolidación del RoleEvent dentro de ApplicationEvent**
- Eliminar el evento `RoleEvent` como evento independiente y el tópico `infoportone.events.role`
- El `ApplicationEvent` debe incluir la lista de roles (al igual que incluye los módulos) para indicar todos los roles vinculados a dicha aplicación
- Esto simplifica el modelo de eventos y garantiza que roles y módulos siempre estén sincronizados con su aplicación

**Corrección 3: Simplificación del UserEvent**
- Eliminar la propiedad `CompanyIds` del payload del `UserEvent`
- Mantener únicamente `OriginCompanyId` que indica desde qué organización se crea/actualiza el usuario
- La vinculación de un usuario a múltiples organizaciones se gestiona automáticamente desde InfoportOne al detectar por el `Email` (identificador único global) que el usuario ya existe en otra organización
- InfoportOne es responsable de fusionar y mantener actualizado el claim `c_ids` con todas las organizaciones del usuario

**Resultado esperado:**
- Reducción de tópicos de eventos: solo `organization`, `application` y `user`
- Menor complejidad en las aplicaciones satélite al procesar eventos
- Responsabilidad clara: InfoportOne gestiona la lógica de multi-organización de usuarios
- Modelo de datos más limpio y consistente

---

## Prompt 2.2.4: Corrección de consolidación de roles y sistema de prefijos de aplicación

**Rol:** Product Owner especialista en aplicaciones multiorganización, con una gestión centralizada de las organizaciones con acceso a cada aplicación mediante oauth2.

**Objetivo:** Revisar toda la documentación generada en el workspace porque se ha detectado un error de análisis que requiere corrección. Aplicar las siguientes premisas:

**Premisa 1: Estructura del evento infoportone.events.user**
- El evento `infoportone.events.user` debe incluir, además del identificador de la organización y de la aplicación que lo envía (`OriginApplicationId`), la lista de roles que la aplicación satélite le ha asignado a tal usuario
- Cada aplicación satélite publica los roles que ella misma gestiona para ese usuario en su contexto

**Premisa 2: Consolidación de usuarios multi-organización y multi-aplicación**
- Desde InfoportOneAdmon, el Background Worker se suscribe al evento de usuario
- Antes de realizar la sincronización con Keycloak, comprueba si dicho usuario (en base a su email) ya existe
- Si ya existe, debe encargarse de:
  - Consolidar las organizaciones a las que dicho usuario está vinculado (claim `c_ids`)
  - Consolidar los roles de las distintas aplicaciones a las que pertenece el usuario
- Esta consolidación garantiza que un usuario que trabaja en múltiples organizaciones y usa múltiples aplicaciones tenga toda su información integrada en Keycloak

**Premisa 3: Sistema de prefijos para aplicaciones**
- En el mantenimiento de aplicaciones existirá un campo `RolePrefix` único para cada aplicación (ejemplo: Sintraport → "STP")
- Este prefijo se usará como nomenclatura estándar para:
  - **Módulos**: Se añade una "M" al prefijo (ejemplo: "MSTP_Trafico" sería un módulo de Sintraport)
  - **Roles**: Se usa solo el prefijo (ejemplo: "STP_AsignadorTransporte" sería un rol de Sintraport)
- Esto evita conflictos de nombres entre roles de diferentes aplicaciones y permite identificar fácilmente a qué aplicación pertenece cada rol o módulo

**Archivos a revisar y corregir:**
- `readme.md`: Actualizar modelo de datos, eventos, Background Worker, diagramas de arquitectura
- `requirements.md`: Requisitos funcionales relacionados con aplicaciones, roles, módulos y consolidación de usuarios
- `useCases.md`: Casos de uso afectados por estos cambios
- Cualquier otro archivo que contenga información sobre estos aspectos

**Resultado esperado:**
- Documentación completa y coherente que refleje correctamente:
  - El evento UserEvent incluye roles asignados por cada aplicación
  - El Background Worker consolida tanto organizaciones como roles antes de sincronizar con Keycloak
  - Sistema de prefijos documentado en el modelo de datos y en todas las secciones relevantes
- Actualización de diagramas de secuencia y arquitectura para mostrar la consolidación de roles
- Modelo de datos actualizado con el campo `RolePrefix` en la entidad Application

---

## Prompt 2.2.5: Corrección de diseño de eventos - Permisos de módulos en OrganizationEvent

**Rol:** Arquitecto de Software especialista en arquitecturas event-driven, diseño de eventos y sistemas multi-organización.

**Objetivo:** Corregir un error de diseño en la arquitectura de eventos del sistema que afecta a la cohesión y eficiencia.

**Problema detectado:**
- El `ApplicationEvent` incluye actualmente `AccessibleByCompanies` dentro de cada módulo
- Esto viola el principio de cohesión: la información de "qué organizaciones tienen acceso" no es parte del estado de la aplicación, es parte del estado de cada organización
- Para modificar permisos de UNA organización, se requiere republicar eventos de MÚLTIPLES aplicaciones
- Las apps satélite deben procesar TODOS los ApplicationEvents y filtrar por SecurityCompanyId para saber qué puede hacer cada organización

**Corrección arquitectónica requerida:**

**ApplicationEvent debe contener solo el CATÁLOGO:**
- Lista de módulos disponibles (sin información de permisos)
- Lista de roles disponibles
- Información técnica de la aplicación (ClientId, RolePrefix, etc.)
- NO debe incluir `AccessibleByCompanies` ni información de permisos

**OrganizationEvent debe contener los PERMISOS:**
- Añadir una propiedad `Apps` (array) al payload de `OrganizationEvent`
- Cada elemento de `Apps` debe contener:
  - `AppId` (int): Identificador de la aplicación
  - `DatabaseName` (string): Nombre de la base de datos específica para esa organización y aplicación
  - `AccessibleModules` (int[]): IDs de los módulos a los que tiene acceso esta organización
- Esto coloca toda la información de permisos de una organización en SU propio evento

**Ventajas del nuevo diseño:**
- ✅ Cohesión perfecta: Toda la información de una organización está en su evento
- ✅ Eficiencia: Cambiar permisos de una org = 1 solo OrganizationEvent (no N ApplicationEvents)
- ✅ Simplicidad: Apps satélite procesan solo eventos de organizaciones relevantes
- ✅ State Transfer correcto: Cada evento describe el estado completo de la entidad

**Archivos a actualizar:**
- `readme.md`: Estructura de eventos ApplicationEvent y OrganizationEvent
- `requirements.md`: RF-018 (debe reflejar que módulos accesibles van en OrganizationEvent)
- `useCases.md`: Caso de uso RF-018

**Resultado esperado:**
- ApplicationEvent es un catálogo puro de la aplicación (módulos y roles disponibles)
- OrganizationEvent incluye array Apps con permisos específicos de esa organización
- Documentación coherente con separación clara de responsabilidades
- Mejor eficiencia en procesamiento de eventos por las aplicaciones satélite

### **2.3. Descripción de alto nivel del proyecto y estructura de ficheros**

## Prompt 2.3.1

## Prompt 2.3.2

## Prompt 2.3.3

### **2.4. Infraestructura y despliegue**

## Prompt 2.4.1

## Prompt 2.4.2

## Prompt 2.4.3

### **2.5. Seguridad**

## Prompt 2.5.1: Optimización de eventos y prevención de duplicados mediante hashing

**Rol:** Arquitecto de Software especialista en arquitecturas event-driven, optimización de sistemas distribuidos y prevención de eventos duplicados.

**Objetivo:** Aplicar las siguientes correcciones y optimizaciones al modelo de eventos del sistema:

**Corrección 1: Renombrado de Propiedad en UserEvent**
- Cambiar la propiedad `Rols` por `Roles` en el payload del `UserEvent`
- Actualizar todos los ejemplos JSON y documentación que hagan referencia a esta propiedad

**Corrección 2: Añadir Información de Base de Datos por Aplicación en OrganizationEvent**
- Añadir una nueva propiedad `Apps` (lista) al payload de `OrganizationEvent`
- Cada elemento de `Apps` debe contener:
  - `AppId` (int): Identificador de la aplicación
  - `DatabaseName` (string): Nombre de la base de datos específica para esa organización y aplicación
- Esto permite a las aplicaciones satélite conocer el nombre de la base de datos donde deben almacenar los datos de cada organización

**Corrección 3: Sistema de Prevención de Eventos Duplicados mediante Hashing**
- Implementar un mecanismo de detección de cambios reales antes de publicar eventos
- **Para OrganizationEvent**: Almacenar por `SecurityCompanyId` el hash del último evento enviado. Solo publicar si el hash del nuevo evento es diferente
- **Para ApplicationEvent**: Almacenar por `AppId` el hash del último evento enviado. Solo publicar si el hash del nuevo evento es diferente
- **Para UserEvent**: Almacenar por `UserId` el hash del último evento enviado. Solo publicar si el hash del nuevo evento es diferente
- El hash debe calcularse sobre el payload completo serializado del evento (excluyendo `EventId`, `EventTimestamp` y `TraceId`)
- Este mecanismo aplica tanto a eventos emitidos desde InfoportOneAdmon como desde las aplicaciones satélite
- Documentar claramente este comportamiento en la sección de eventos, incluyendo:
  - Cómo se calcula el hash (algoritmo recomendado: SHA-256)
  - Dónde se almacenan los hashes (tabla de control en la base de datos del emisor)
  - Ventajas: reducción de tráfico en ActiveMQ Artemis, menor procesamiento en consumidores, evita cambios en cascada sin contenido real

**Resultado esperado:**
- Propiedad `Roles` consistente en UserEvent
- OrganizationEvent con información de bases de datos por aplicación
- Sistema robusto de prevención de eventos duplicados que optimiza el uso del broker y reduce la carga en las aplicaciones satélite
- Documentación clara del mecanismo de hashing y detección de cambios

## Prompt 2.5.2

## Prompt 2.5.3

### **2.6. Tests**

## Prompt 2.6.1

## Prompt 2.6.2

## Prompt 2.6.3

---

## 3. Modelo de Datos

## Prompt 3.1: Corrección del modelo de datos para alineación con arquitectura Helix6

**Rol:** Arquitecto de datos especialista en arquitectura Helix6, normalización de bases de datos y mejores prácticas de diseño de esquemas relacionales.

**Objetivo:** Corregir completamente el modelo de datos de InfoportOneAdmon para alinearlo con la arquitectura Helix6 e incorporar mejoras arquitectónicas identificadas durante el análisis del sistema.

**Cambios requeridos:**

**Cambio 1: Alineación con Helix6 Framework**
- Todas las claves primarias deben ser `Id` (autonumérico) en lugar de nombres personalizados como `GroupId`, `SecurityCompanyId`, `AppId`, `ModuleId`, etc.
- `SecurityCompanyId` pasa a ser un índice único de negocio en la tabla `ORGANIZATION`, no la PK física
- Todos los campos de auditoría deben seguir el estándar Helix6:
  - `AuditCreationUser` (usuario que creó)
  - `AuditCreationDate` (fecha de creación)
  - `AuditModificationUser` (usuario que modificó)
  - `AuditModificationDate` (fecha de modificación)
  - `AuditDeletionDate` (soft delete - fecha de eliminación lógica)
- Eliminar campos personalizados de auditoría como `CreatedAt`, `UpdatedAt`, `CreatedBy`, `UpdatedBy`, `GrantedBy`

**Cambio 2: Tabla UserConsolidationCache**
- Añadir la tabla `USER_CONSOLIDATION_CACHE` que faltaba en el modelo de datos
- Esta tabla optimiza el proceso de consolidación de usuarios multi-organización
- Campos requeridos:
  - `Id` (PK, autonumérico)
  - `Email` (índice único, clave de búsqueda)
  - `ConsolidatedCompanyIds` (JSON array de SecurityCompanyIds)
  - `ConsolidatedRoles` (JSON array de roles consolidados de todas las aplicaciones)
  - `LastConsolidationDate` (timestamp de última consolidación)
  - `LastEventHash` (SHA-256 hash del último evento procesado)

**Cambio 3: Tabla ApplicationSecurity**
- Separar las credenciales OAuth2 de la tabla `APPLICATION` en una nueva tabla `APPLICATION_SECURITY`
- Una aplicación puede tener múltiples credenciales (frontend CODE + backend ClientCredentials)
- Campos requeridos:
  - `Id` (PK, autonumérico)
  - `ApplicationId` (FK a Application.Id)
  - `CredentialType` (CODE o ClientCredentials)
  - `ClientId` (índice único)
  - `ClientSecretHash` (NULL para CODE, hash bcrypt para ClientCredentials)
  - `RedirectUris` (JSON, solo para CODE)
  - `Scope` (scopes OAuth2)
  - `IsActive` (bool, credencial activa/inactiva)
  - Campos de auditoría Helix6
- Eliminar de `APPLICATION`: `ClientId`, `IsPublicClient`, `ClientSecretHash`, `RedirectUris`, `SecretRotatedAt`

**Cambio 4: Eliminación de campos redundantes y corrección de AUDIT_LOG**
- **AUDIT_LOG**: 
  - Eliminar campo `UserId` porque es redundante con los campos de auditoría Helix6 de cada entidad modificada
  - Eliminar campos `IpAddress` y `UserAgent` que son redundantes y no aportan valor en un sistema de auditoría de estado
  - AÑADIR campos de auditoría Helix6 (`AuditCreationUser`, `AuditCreationDate`, `AuditModificationUser`, `AuditModificationDate`, `AuditDeletionDate`) porque AUDIT_LOG es una entidad más del sistema y debe seguir el mismo estándar
  - Los campos de auditoría de AUDIT_LOG son meta-auditoría (quién creó el log), el usuario que hizo el cambio en la entidad está en esa entidad
- **MODULE_ACCESS**: Eliminar campos `GrantedAt` (redundante con `AuditCreationDate`) y `ExpiresAt` (la lógica de expiración se maneja con soft delete mediante `AuditDeletionDate`).

**Cambio 5: Ajuste de Foreign Keys**
- `ORGANIZATION.GroupId` debe referenciar `ORGANIZATION_GROUP.Id` (no GroupId)
- `MODULE.AppId` debe renombrarse a `MODULE.ApplicationId` y referenciar `APPLICATION.Id`
- `MODULE_ACCESS.SecurityCompanyId` debe renombrarse a `MODULE_ACCESS.OrganizationId` y referenciar `ORGANIZATION.Id`
- `APP_ROLE_DEFINITION.AppId` debe renombrarse a `APP_ROLE_DEFINITION.ApplicationId` y referenciar `APPLICATION.Id`

**Archivos a actualizar:**
- `readme.md`: Diagrama mermaid (sección 3.1), descripción de entidades (sección 3.2), índices, restricciones
- Actualizar todas las referencias en el documento que mencionen los campos antiguos
- Revisar `requirements.md` y `useCases.md` para referencias a campos modificados
- Añadir explicación de las ventajas de estos cambios en las "Notas sobre el Diseño"

**Resultado esperado:**
- Modelo de datos 100% alineado con Helix6 Framework
- Tabla UserConsolidationCache documentada
- Separación clara de credenciales OAuth2 en tabla dedicada
- Eliminación de redundancias (SecretRotatedAt ya no necesario con tabla separada)
- Nomenclatura consistente de Foreign Keys
- Documentación completa con ventajas de cada decisión arquitectónica

## Prompt 3.2

## Prompt 3.3

---

### 4. Especificación de la API

## Prompt 4.1

## Prompt 4.2

## Prompt 4.3

---

### 5. Historias de Usuario

## Prompt 5.1: Definición de requisitos funcionales y no funcionales

**Rol:** Product Manager especialista en ingeniería de requisitos, análisis de producto y definición de especificaciones técnicas para sistemas empresariales complejos.

**Objetivo:** Crear un documento completo de requisitos funcionales y no funcionales (requirements.md) que establezca las especificaciones detalladas del producto InfoportOneAdmon siguiendo las mejores prácticas de ingeniería de software.

**Estructura requerida:**
- Requisitos **funcionales** (RF-XXX): Definen QUÉ debe hacer el sistema, organizados por módulo/componente
- Requisitos **no funcionales** (RNF-XXX): Definen CÓMO debe comportarse el sistema (rendimiento, seguridad, escalabilidad, etc.)
- Cada requisito debe incluir: ID único, descripción clara, prioridad (Alta/Media/Baja), módulo asociado, criterios de aceptación verificables

**Componentes a cubrir:**
- Módulo de Gestión de Organizaciones
- Módulo de Gestión de Aplicaciones
- Módulo de Roles y Módulos
- Arquitectura de Eventos (ActiveMQ Artemis)
- Integración con Keycloak
- Background Worker
- Seguridad y Autenticación
- Requisitos transversales (rendimiento, disponibilidad, mantenibilidad, etc.)

**Buenas prácticas a aplicar:**
- Requisitos **SMART**: Específicos, Medibles, Alcanzables, Relevantes, Temporales
- Redacción en modo imperativo: "El sistema debe/deberá..."
- Evitar ambigüedades y términos vagos
- Incluir criterios de aceptación cuantificables cuando sea posible
- Trazabilidad con casos de uso y componentes arquitectónicos
- Fraccionar la generación por componentes para mantener claridad y manejabilidad

**Resultado esperado:**
- Archivo `requirements.md` estructurado y profesional
- Numeración clara y consistente (RF-001, RF-002... / RNF-001, RNF-002...)
- Organización lógica por secciones/módulos
- Priorización clara de requisitos
- Base sólida para desarrollo, pruebas y validación del producto

## Prompt 5.2

**Rol:** Experto en producto y análisis funcional de sistemas empresariales multi-organización.

**Objetivo:** Crear un nuevo fichero `useCases.md` que documente todos los casos de uso del sistema InfoportOneAdmon, agrupados por requerimiento, utilizando como fuente la documentación existente en `readme.md` y `requirements.md`.

**Instrucciones:**
- Analiza exhaustivamente los requisitos funcionales y no funcionales de `requirements.md` y la descripción de producto en `readme.md`.
- Para cada requerimiento funcional (RF-XXX), define uno o varios casos de uso detallados, agrupándolos bajo el identificador del requerimiento correspondiente.
- Para los casos de uso más relevantes o complejos, incluye diagramas UML en formato mermaid (casos de uso, secuencia, actividad, etc.) que ilustren el flujo principal y las interacciones clave.
- Estructura el fichero `useCases.md` de forma clara y modular, con índice, agrupación por requerimiento y enlaces internos.
- Asegura que cada caso de uso incluya: nombre, objetivo, actores, precondiciones, flujo principal, flujos alternativos y criterios de éxito.
- El resultado debe ser profesional, trazable y alineado con las mejores prácticas de documentación de casos de uso.

**Resultado esperado:**
- Un fichero `useCases.md` completo, organizado y visual, que sirva como referencia para desarrollo, validación y pruebas del sistema.

## Prompt 5.3: Generación de Historias de Usuario agrupadas por Épicas

**Rol:** Product Owner senior especialista en metodologías ágiles, definición de User Stories y gestión de product backlog para sistemas empresariales complejos.

**Objetivo:** Crear un conjunto completo y profesional de historias de usuario (User Stories) para el sistema InfoportOneAdmon, organizadas en épicas coherentes, siguiendo los estándares de excelencia de la industria y las mejores prácticas de desarrollo ágil.

**Contexto del proyecto:**
Analizar exhaustivamente toda la documentación existente del proyecto (readme.md, requirements.md, useCases.md) para comprender el alcance funcional completo del sistema InfoportOneAdmon: plataforma administrativa centralizada para gestión de portfolio de aplicaciones empresariales, control de acceso multi-organización, integración con Keycloak y arquitectura orientada a eventos.

**Estructura requerida:**

**1. Organización en Épicas:**
- Agrupar las User Stories en épicas de alto nivel que representen capacidades de negocio completas
- Cada épica debe tener: nombre descriptivo, objetivo de negocio, valor que aporta, criterios de aceptación de la épica
- Épicas sugeridas (adaptar según análisis): 
  - Gestión del Portfolio de Organizaciones Clientes
  - Administración de Aplicaciones del Ecosistema
  - Configuración de Módulos y Permisos de Acceso
  - Gobierno de Roles y Seguridad
  - Sincronización y Consolidación de Usuarios Multi-Organización
  - Integración con Keycloak e Identity Management
  - Arquitectura de Eventos y Sincronización

**2. Características de las User Stories:**

**a) Descripción informal y storytelling:**
- Redacción en lenguaje natural, accesible, no técnico
- Contar una historia desde la perspectiva del usuario, no listar funcionalidades
- Incluir contexto emocional y motivacional cuando sea posible
- Ejemplo: En lugar de "CRUD de organizaciones", escribir "Como administrador del ecosistema, quiero dar de alta una nueva organización cliente en pocos pasos para comenzar su onboarding rápidamente y sin errores"

**b) Enfoque en el usuario (Avatar/Buyer Persona):**
- Definir claramente los tipos de usuarios del sistema:
  - **Administrador de la Organización Propietaria**: Responsable de onboarding y gestión de clientes
  - **Gestor de Seguridad**: Administra roles, permisos y accesos
  - **Administrador de Aplicaciones**: Configura el portfolio de aplicaciones
  - **Auditor/Compliance Officer**: Revisa trazabilidad y cumplimiento
  - **Usuario Final de Organización Cliente**: Beneficiario indirecto del sistema
- Vincular cada User Story a uno de estos avatares específicos
- Describir brevemente el contexto y necesidad del avatar cuando aporte valor

**c) Estructura clásica obligatoria:**
Cada User Story debe seguir rigurosamente el formato:
```
Como un [tipo de usuario específico],
quiero [acción/capacidad que desea realizar],
para [beneficio/valor que obtiene].
```

**d) Componentes adicionales de cada User Story:**
- **ID único**: US-XXX (numeración secuencial)
- **Épica asociada**: Referencia a la épica padre
- **Título descriptivo**: Resumen de 5-10 palabras
- **Descripción**: Formato "Como... quiero... para..."
- **Contexto adicional** (opcional): Situación o escenario que desencadena la necesidad
- **Criterios de aceptación**: Lista de condiciones verificables que deben cumplirse (formato Given/When/Then cuando aplique)
- **Definición de hecho (DoD)**: Qué significa que la historia está completada
- **Prioridad**: Alta/Media/Baja (según valor de negocio e impacto)
- **Estimación**: Story Points (escala Fibonacci: 1, 2, 3, 5, 8, 13, 21) o T-Shirt sizes (XS, S, M, L, XL)
- **Dependencias**: Referencias a otras User Stories que deben completarse antes
- **Notas técnicas** (si son críticas): Consideraciones técnicas que el equipo debe conocer
- **Conversaciones pendientes**: Preguntas o aclaraciones que requieren diálogo con stakeholders

**e) Priorización:**
- Aplicar criterio de priorización basado en:
  - **Valor de negocio**: Impacto en los objetivos del producto
  - **Riesgo técnico**: Complejidad e incertidumbre
  - **Dependencias**: Funcionalidades que bloquean otras
  - **Urgencia**: Necesidad temporal del mercado o cliente
- Sugerir un orden lógico de implementación por épica
- Identificar el **MVP (Producto Mínimo Viable)** con las User Stories críticas para un primer lanzamiento funcional

**f) Estimación:**
- Asignar estimación de esfuerzo relativo (Story Points en escala Fibonacci o T-Shirt sizes)
- Considerar: complejidad técnica, incertidumbre, esfuerzo de desarrollo, esfuerzo de testing
- Identificar User Stories épicas (>13 puntos) que deberían dividirse en historias más pequeñas

**g) Conversación y confirmación:**
- Para User Stories complejas o ambiguas, incluir sección de "Preguntas para el equipo" que fomenten el diálogo
- Incluir "Criterios de demostración" que describan cómo se validará la historia en la Sprint Review

**h) Evolución iterativa:**
- Identificar User Stories que pueden evolucionar en futuras iteraciones
- Sugerir versiones incrementales (v1, v2) cuando una funcionalidad pueda entregarse progresivamente
- Ejemplo: "US-025 v1: Filtros básicos de organizaciones" → "US-025 v2: Filtros avanzados con guardado de preferencias"

**3. Formato de salida:**
Crear un documento markdown estructurado con:
- Índice navegable
- Sección de definición de avatares/buyer personas
- Una sección por épica con:
  - Descripción de la épica
  - Tabla resumen de User Stories de la épica
  - Detalle completo de cada User Story
- Roadmap visual (diagrama mermaid) mostrando dependencias entre épicas e hitos
- Backlog priorizado con las primeras 20-30 User Stories para Sprint Planning

**4. Estándares profesionales a aplicar:**
- Principio **INVEST**: Independent, Negotiable, Valuable, Estimable, Small, Testable
- Evitar User Stories técnicas (refactorizaciones, migraciones) a menos que aporten valor visible
- Mantener granularidad adecuada: historias completables en 1-3 días por desarrollador
- Balancear historias funcionales con historias no funcionales (seguridad, rendimiento, UX)
- Incluir "Spike Stories" para investigaciones técnicas cuando haya incertidumbre alta

**5. Casos especiales a considerar:**
- **Integraciones**: User Stories que involucren Keycloak, ActiveMQ Artemis
- **Background Workers**: Historias de consolidación de usuarios multi-organización
- **Eventos**: Historias de sincronización y publicación/consumo de eventos
- **Seguridad**: Historias de autenticación OAuth2, PKCE, gestión de secretos
- **Auditoría**: Historias de trazabilidad y compliance

**Ejemplos de buenas User Stories para referencia:**

**Ejemplo 1 - Story simple:**
```
ID: US-001
Épica: Gestión del Portfolio de Organizaciones Clientes
Título: Crear nueva organización cliente
Prioridad: Alta | Estimación: 5 Story Points

Como Administrador de la Organización Propietaria,
quiero dar de alta una nueva organización cliente completando un formulario con sus datos básicos (nombre, CIF, contacto),
para iniciar su proceso de onboarding en el ecosistema y permitir que sus usuarios accedan a las aplicaciones contratadas.

Criterios de aceptación:
- El formulario valida que nombre, CIF y email de contacto sean obligatorios
- El sistema genera automáticamente un SecurityCompanyId único e inmutable
- Se muestra confirmación visual del registro exitoso
- Se publica un OrganizationEvent al broker ActiveMQ Artemis
- El registro queda visible en el listado de organizaciones
- Se registra en auditoría quién y cuándo creó la organización

Definición de hecho:
- Código revisado y aprobado
- Tests unitarios y de integración pasando
- Evento publicado correctamente verificado
- Documentación de API actualizada

Dependencias: Ninguna (historia fundacional)
```

**Ejemplo 2 - Story con conversación:**
```
ID: US-015
Épica: Sincronización y Consolidación de Usuarios Multi-Organización
Título: Consolidar usuarios duplicados por email
Prioridad: Alta | Estimación: 8 Story Points

Como el Background Worker del sistema,
quiero detectar automáticamente cuando un usuario existe en múltiples organizaciones (por email duplicado),
para consolidar todas sus organizaciones en el claim c_ids del token JWT y permitirle acceder a datos de todas ellas con un solo login.

Criterios de aceptación:
- Given: Dos organizaciones publican UserEvent con el mismo email
- When: El Background Worker procesa el segundo evento
- Then: Detecta el email duplicado, consulta la BD y construye array c_ids con ambos SecurityCompanyId
- And: Sincroniza el claim consolidado con Keycloak via Admin API
- And: El token JWT del usuario contiene c_ids: [12345, 67890]

Preguntas para el equipo:
- ¿Cómo manejamos el caso de emails duplicados con diferente capitalización (juan@example.com vs Juan@Example.com)?
- ¿Qué hacemos si una organización marca al usuario como inactivo pero en otra está activo?

Notas técnicas:
- Usar tabla UserConsolidationCache para optimizar detección de duplicados
- El claim c_ids debe ser atributo multivalor en Keycloak

Dependencias: US-012 (Alta de usuarios desde apps satélite)
```

**Resultado esperado:**
- Documento `userStories.md` completo, profesional y accionable
- Organización clara en épicas con roadmap visual
- Historias bien escritas, priorizadas y estimadas
- Backlog listo para Sprint Planning
- Fomento de conversación entre equipo de producto y técnico
- Base sólida para desarrollo iterativo e incremental del sistema InfoportOneAdmon

---

## 6. Tickets de Trabajo

## Prompt 6.1-BE: Generación de Tickets Técnicos de Backend y Eventos

**Rol:** Tech Lead Backend especialista en .NET 8, Helix6 Framework, Entity Framework Core, arquitecturas event-driven con ActiveMQ Artemis e integración con Keycloak.

**Objetivo:** Generar tickets técnicos detallados y profesionales para la implementación de funcionalidades Backend y sistema de eventos (publicación/suscripción) a partir de las User Stories definidas en `userStories.md`. Cada ticket debe seguir las arquitecturas estándar documentadas y ser completamente accionable por cualquier desarrollador del equipo.

**Contexto del proyecto:**
Analizar exhaustivamente:
- **User Stories**: `userStories.md` - Historias de usuario con criterios de aceptación
- **Arquitectura Backend**: `Helix6_Backend_Architecture.md` - Framework Helix6, patrón Repository/Service, Entity Framework Core 9.0, PostgreSQL
- **Arquitectura de Eventos**: `ActiveMQ_Events.md` - IPVInterchangeShared, EventBase, IMessagePublisher, IEventProcessor, Testcontainers

**Instrucciones detalladas:**

### 1. Análisis de User Stories

Para cada User Story en `userStories.md`:
1. Identificar si requiere componentes Backend (entidades, servicios, endpoints)
2. Identificar si requiere publicación de eventos (OrganizationEvent, ApplicationEvent, UserEvent)
3. Identificar si requiere suscripción a eventos (procesadores, consolidación)
4. Determinar el orden lógico de implementación (backend primero, eventos después)

### 2. Tipos de Tickets Backend a Generar

#### Ticket Tipo A: Backend CRUD Completo (Entidad + Servicio + Endpoints)

Este tipo de ticket cubre la implementación completa de una entidad de negocio con operaciones CRUD siguiendo el patrón Helix6.

**Plantilla de Ticket Backend CRUD:**

```
=============================================================
TICKET ID: TASK-XXX-BE
EPIC: [Nombre de la Épica]
USER STORY: US-XXX - [Título de la User Story]
COMPONENT: Backend
PRIORITY: [Alta/Media/Baja]
ESTIMATION: [4-8 horas]
=============================================================

TÍTULO:
Implementar entidad [NombreEntidad] con CRUD completo en Helix6

DESCRIPCIÓN:
Crear la infraestructura backend completa para gestionar [descripción funcional de la entidad] siguiendo el patrón Helix6 Framework. Esto incluye:
- Entidad de base de datos con Entity Framework Core
- ViewModel para la capa de presentación
- Servicio que hereda de BaseService con lógica de negocio
- Repositorio personalizado si requiere queries específicas
- Endpoints RESTful generados automáticamente con EndpointHelper
- Tests unitarios de servicio y tests de integración de endpoints

La funcionalidad debe cumplir con los criterios de aceptación de la User Story US-XXX: [copiar criterios relevantes]

CONTEXTO TÉCNICO:
- **Framework**: Helix6 Framework sobre .NET 8
- **Base de datos**: PostgreSQL con Entity Framework Core 9.0
- **Patrón arquitectónico**: Repository/Service pattern
- **Auditoría**: Todos los cambios deben registrarse con campos Helix6 (AuditCreationUser, AuditCreationDate, AuditModificationUser, AuditModificationDate, AuditDeletionDate)
- **Soft Delete**: Usar AuditDeletionDate para eliminación lógica
- **Validaciones**: Implementar en ValidateView del servicio
- **Transacciones**: Manejadas automáticamente por BaseService

CRITERIOS DE ACEPTACIÓN TÉCNICOS:
- [ ] Entidad [NombreEntidad] creada en DataModel implementando IEntityBase
- [ ] ViewModel [NombreEntidad]View creada en Entities implementando IViewBase
- [ ] Servicio [NombreEntidad]Service creado heredando de BaseService<TView, TEntity, TMetadata>
- [ ] Métodos ValidateView, PreviousActions y PostActions implementados según lógica de negocio
- [ ] Endpoints generados con EndpointHelper o creados manualmente si requieren lógica específica
- [ ] Migración de Entity Framework Core generada y aplicada
- [ ] Inyección de dependencias configurada en DependencyInjection.cs
- [ ] Tests unitarios del servicio con cobertura >80%
- [ ] Tests de integración de endpoints (GET, POST, PUT, DELETE)
- [ ] Documentación Swagger actualizada con comentarios XML
- [ ] Sin warnings de compilación ni vulnerabilidades

GUÍA DE IMPLEMENTACIÓN:

**Paso 1: Crear la Entidad en DataModel**

Archivo: `InfoportOneAdmon.DataModel/Entities/[NombreEntidad].cs`

```csharp
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Helix6.Base.Domain.BaseInterfaces;

namespace InfoportOneAdmon.DataModel.Entities
{
    /// <summary>
    /// Representa [descripción funcional de la entidad]
    /// </summary>
    [Table("NOMBRE_TABLA")]
    public class [NombreEntidad] : IEntityBase
    {
        /// <summary>
        /// Identificador único (PK autonumérica)
        /// </summary>
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int Id { get; set; }
        
        /// <summary>
        /// [Descripción del campo de negocio]
        /// </summary>
        [Required]
        [StringLength(200)]
        public string Name { get; set; }
        
        /// <summary>
        /// [Descripción de otro campo]
        /// </summary>
        [StringLength(500)]
        public string Description { get; set; }
        
        // Foreign Keys (si aplica)
        /// <summary>
        /// FK a la entidad relacionada
        /// </summary>
        public int? RelatedEntityId { get; set; }
        
        [ForeignKey(nameof(RelatedEntityId))]
        public virtual RelatedEntity RelatedEntity { get; set; }
        
        // Campos de auditoría Helix6 (OBLIGATORIOS)
        public int? AuditCreationUser { get; set; }
        public DateTime? AuditCreationDate { get; set; }
        public int? AuditModificationUser { get; set; }
        public DateTime? AuditModificationDate { get; set; }
        public DateTime? AuditDeletionDate { get; set; }
    }
}
```

**Paso 2: Crear el ViewModel en Entities**

Archivo: `InfoportOneAdmon.Entities/Views/[NombreEntidad]View.cs`

```csharp
using System.ComponentModel.DataAnnotations;
using Helix6.Base.Application.BaseInterfaces;

namespace InfoportOneAdmon.Entities.Views
{
    /// <summary>
    /// ViewModel para [descripción funcional]
    /// </summary>
    public class [NombreEntidad]View : IViewBase
    {
        public int Id { get; set; }
        
        [Required(ErrorMessage = "El nombre es obligatorio")]
        [StringLength(200, ErrorMessage = "El nombre no puede exceder 200 caracteres")]
        public string Name { get; set; }
        
        [StringLength(500, ErrorMessage = "La descripción no puede exceder 500 caracteres")]
        public string Description { get; set; }
        
        public int? RelatedEntityId { get; set; }
        public string RelatedEntityName { get; set; } // Para visualización
        
        // Campos de auditoría (para lectura)
        public int? AuditCreationUser { get; set; }
        public DateTime? AuditCreationDate { get; set; }
        public int? AuditModificationUser { get; set; }
        public DateTime? AuditModificationDate { get; set; }
        public DateTime? AuditDeletionDate { get; set; }
    }
}
```

**Paso 3: Crear el Servicio**

Archivo: `InfoportOneAdmon.Services/Services/[NombreEntidad]Service.cs`

```csharp
using Helix6.Base.Application.Services;
using Helix6.Base.Domain.Repositories;
using InfoportOneAdmon.DataModel.Entities;
using InfoportOneAdmon.Entities.Views;
using Microsoft.Extensions.Logging;

namespace InfoportOneAdmon.Services.Services
{
    /// <summary>
    /// Servicio para gestión de [descripción funcional]
    /// </summary>
    public class [NombreEntidad]Service : BaseService<[NombreEntidad]View, [NombreEntidad], BaseMetadata>
    {
        public [NombreEntidad]Service(
            ILogger<[NombreEntidad]Service> logger,
            IRepository<[NombreEntidad]> repository)
            : base(logger, repository)
        {
        }

        /// <summary>
        /// Validaciones de negocio antes de guardar
        /// </summary>
        protected override async Task<bool> ValidateView([NombreEntidad]View view, CancellationToken cancellationToken)
        {
            // Validación 1: Nombre único
            var exists = await Repository.ExistsAsync(
                e => e.Name == view.Name && e.Id != view.Id && e.AuditDeletionDate == null,
                cancellationToken);
            
            if (exists)
            {
                AddError($"Ya existe un registro con el nombre '{view.Name}'");
                return false;
            }
            
            // Validación 2: FK válida (si aplica)
            if (view.RelatedEntityId.HasValue)
            {
                // Inyectar IRepository<RelatedEntity> en constructor si necesario
                // var relatedExists = await _relatedRepository.ExistsAsync(...)
            }
            
            return true;
        }

        /// <summary>
        /// Acciones previas a guardar (mapeos adicionales, cálculos, etc.)
        /// </summary>
        protected override async Task PreviousActions([NombreEntidad]View view, [NombreEntidad] entity, CancellationToken cancellationToken)
        {
            // Ejemplo: normalizar datos
            entity.Name = entity.Name?.Trim();
            
            await base.PreviousActions(view, entity, cancellationToken);
        }

        /// <summary>
        /// Acciones posteriores a guardar (publicar eventos, notificaciones, etc.)
        /// </summary>
        protected override async Task PostActions([NombreEntidad]View view, [NombreEntidad] entity, CancellationToken cancellationToken)
        {
            // NOTA: Si esta entidad debe publicar eventos, se implementará aquí
            // Ver Ticket Tipo B para detalles de publicación de eventos
            
            await base.PostActions(view, entity, cancellationToken);
        }
    }
}
```

**Paso 4: Generar Endpoints**

Archivo: `InfoportOneAdmon.Api/Endpoints/[NombreEntidad]Endpoints.cs`

```csharp
using Helix6.Base.Api.Endpoints;
using InfoportOneAdmon.Entities.Views;
using InfoportOneAdmon.Services.Services;

namespace InfoportOneAdmon.Api.Endpoints
{
    /// <summary>
    /// Endpoints RESTful para [descripción funcional]
    /// </summary>
    public static class [NombreEntidad]Endpoints
    {
        public static void Map[NombreEntidad]Endpoints(this IEndpointRouteBuilder app)
        {
            // Genera automáticamente: GET, GET/{id}, POST, PUT/{id}, DELETE/{id}
            EndpointHelper.MapCrudEndpoints<[NombreEntidad]Service, [NombreEntidad]View>(
                app,
                "[nombreentidad]", // route base
                "[NombreEntidad]"); // tag para Swagger
        }
    }
}
```

Registrar en `Program.cs`:
```csharp
app.Map[NombreEntidad]Endpoints();
```

**Si se requieren endpoints personalizados:**
```csharp
public static void Map[NombreEntidad]Endpoints(this IEndpointRouteBuilder app)
{
    var group = app.MapGroup("[nombreentidad]")
        .WithTags("[NombreEntidad]")
        .RequireAuthorization();

    // Endpoints CRUD estándar
    EndpointHelper.MapCrudEndpoints<[NombreEntidad]Service, [NombreEntidad]View>(
        app, "[nombreentidad]", "[NombreEntidad]");

    // Endpoint personalizado
    group.MapGet("/search/{query}", async (
        [FromServices] [NombreEntidad]Service service,
        [FromRoute] string query,
        CancellationToken ct) =>
    {
        // Lógica personalizada
        var results = await service.SearchAsync(query, ct);
        return Results.Ok(results);
    })
    .WithName("Search[NombreEntidad]")
    .Produces<IEnumerable<[NombreEntidad]View>>();
}
```

**Paso 5: Configurar Inyección de Dependencias**

Archivo: `InfoportOneAdmon.Services/DependencyInjection.cs`

```csharp
public static IServiceCollection AddApplicationServices(this IServiceCollection services)
{
    // ... otros servicios ...
    
    services.AddScoped<[NombreEntidad]Service>();
    
    return services;
}
```

**Paso 6: Generar Migración de Entity Framework Core**

Ejecutar en terminal desde la carpeta del proyecto API:

```powershell
dotnet ef migrations add Add[NombreEntidad]Table --project ..\InfoportOneAdmon.DataModel --startup-project InfoportOneAdmon.Api
dotnet ef database update --project ..\InfoportOneAdmon.DataModel --startup-project InfoportOneAdmon.Api
```

Verificar que el archivo de migración generado es correcto (revisar campos, índices, FKs).

**Paso 7: Implementar Tests Unitarios del Servicio**

Archivo: `InfoportOneAdmon.Services.Tests/Services/[NombreEntidad]ServiceTests.cs`

```csharp
using Xunit;
using Moq;
using FluentAssertions;
using Microsoft.Extensions.Logging;
using Helix6.Base.Domain.Repositories;
using InfoportOneAdmon.Services.Services;
using InfoportOneAdmon.Entities.Views;
using InfoportOneAdmon.DataModel.Entities;

namespace InfoportOneAdmon.Services.Tests.Services
{
    public class [NombreEntidad]ServiceTests
    {
        private readonly Mock<ILogger<[NombreEntidad]Service>> _loggerMock;
        private readonly Mock<IRepository<[NombreEntidad]>> _repositoryMock;
        private readonly [NombreEntidad]Service _service;

        public [NombreEntidad]ServiceTests()
        {
            _loggerMock = new Mock<ILogger<[NombreEntidad]Service>>();
            _repositoryMock = new Mock<IRepository<[NombreEntidad]>>();
            _service = new [NombreEntidad]Service(_loggerMock.Object, _repositoryMock.Object);
        }

        [Fact]
        public async Task ValidateView_WithValidData_ReturnsTrue()
        {
            // Arrange
            var view = new [NombreEntidad]View
            {
                Name = "Test Name",
                Description = "Test Description"
            };
            
            _repositoryMock.Setup(r => r.ExistsAsync(It.IsAny<Expression<Func<[NombreEntidad], bool>>>(), It.IsAny<CancellationToken>()))
                .ReturnsAsync(false);

            // Act
            var result = await _service.ValidateView(view, CancellationToken.None);

            // Assert
            result.Should().BeTrue();
        }

        [Fact]
        public async Task ValidateView_WithDuplicateName_ReturnsFalse()
        {
            // Arrange
            var view = new [NombreEntidad]View
            {
                Name = "Duplicate Name"
            };
            
            _repositoryMock.Setup(r => r.ExistsAsync(It.IsAny<Expression<Func<[NombreEntidad], bool>>>(), It.IsAny<CancellationToken>()))
                .ReturnsAsync(true);

            // Act
            var result = await _service.ValidateView(view, CancellationToken.None);

            // Assert
            result.Should().BeFalse();
            _service.Errors.Should().Contain(e => e.Contains("Ya existe"));
        }
        
        // Más tests: PreviousActions, PostActions, mapeos, etc.
    }
}
```

**Paso 8: Implementar Tests de Integración de Endpoints**

Archivo: `InfoportOneAdmon.Api.Tests/Endpoints/[NombreEntidad]EndpointsTests.cs`

```csharp
using Xunit;
using FluentAssertions;
using Microsoft.AspNetCore.Mvc.Testing;
using System.Net.Http.Json;
using InfoportOneAdmon.Entities.Views;

namespace InfoportOneAdmon.Api.Tests.Endpoints
{
    public class [NombreEntidad]EndpointsTests : IClassFixture<WebApplicationFactory<Program>>
    {
        private readonly HttpClient _client;

        public [NombreEntidad]EndpointsTests(WebApplicationFactory<Program> factory)
        {
            _client = factory.CreateClient();
        }

        [Fact]
        public async Task GetAll_ReturnsSuccessStatusCode()
        {
            // Act
            var response = await _client.GetAsync("/[nombreentidad]");

            // Assert
            response.EnsureSuccessStatusCode();
            var items = await response.Content.ReadFromJsonAsync<IEnumerable<[NombreEntidad]View>>();
            items.Should().NotBeNull();
        }

        [Fact]
        public async Task Create_WithValidData_ReturnsCreated()
        {
            // Arrange
            var newItem = new [NombreEntidad]View
            {
                Name = "Test Item",
                Description = "Test Description"
            };

            // Act
            var response = await _client.PostAsJsonAsync("/[nombreentidad]", newItem);

            // Assert
            response.StatusCode.Should().Be(System.Net.HttpStatusCode.Created);
            var created = await response.Content.ReadFromJsonAsync<[NombreEntidad]View>();
            created.Id.Should().BeGreaterThan(0);
        }
        
        // Más tests: Update, Delete, validaciones, etc.
    }
}
```

ARCHIVOS A CREAR/MODIFICAR:
Backend:
- `InfoportOneAdmon.DataModel/Entities/[NombreEntidad].cs` - Entidad EF Core
- `InfoportOneAdmon.Entities/Views/[NombreEntidad]View.cs` - ViewModel
- `InfoportOneAdmon.Services/Services/[NombreEntidad]Service.cs` - Servicio con lógica de negocio
- `InfoportOneAdmon.Api/Endpoints/[NombreEntidad]Endpoints.cs` - Endpoints RESTful
- `InfoportOneAdmon.Services/DependencyInjection.cs` - Registro de servicio
- `InfoportOneAdmon.Api/Program.cs` - Mapeo de endpoints
- `InfoportOneAdmon.Services.Tests/Services/[NombreEntidad]ServiceTests.cs` - Tests unitarios
- `InfoportOneAdmon.Api.Tests/Endpoints/[NombreEntidad]EndpointsTests.cs` - Tests de integración
- `Migrations/XXXXXX_Add[NombreEntidad]Table.cs` - Migración EF Core (generada automáticamente)

DEPENDENCIAS:
- Ninguna para entidades fundacionales
- [TASK-XXX-BE] para entidades que dependen de otras (FKs)

DEFINITION OF DONE:
- [ ] Entidad creada con IEntityBase y campos de auditoría Helix6
- [ ] ViewModel creado con validaciones DataAnnotations
- [ ] Servicio implementado con ValidateView, PreviousActions, PostActions
- [ ] Endpoints generados/creados y documentados en Swagger
- [ ] Migración EF Core generada y aplicada sin errores
- [ ] DI configurada correctamente
- [ ] Tests unitarios del servicio con cobertura >80%
- [ ] Tests de integración de endpoints (CRUD completo)
- [ ] Code review aprobado
- [ ] Sin warnings ni vulnerabilidades
- [ ] Documentación XML en servicio y endpoints

RECURSOS:
- Arquitectura Backend: `Helix6_Backend_Architecture.md` - Secciones 2, 3, 4, 5
- User Story: `userStories.md#us-xxx`

=============================================================
```

#### Ticket Tipo B: Publicación de Eventos desde Backend

Este tipo de ticket cubre la implementación de publicación de eventos (OrganizationEvent, ApplicationEvent, UserEvent) desde el backend cuando ocurren cambios en las entidades.

**Plantilla de Ticket Publicación de Eventos:**

```
=============================================================
TICKET ID: TASK-XXX-EV-PUB
EPIC: [Nombre de la Épica]
USER STORY: US-XXX - [Título de la User Story]
COMPONENT: Events - Publisher
PRIORITY: Alta
ESTIMATION: [2-4 horas]
=============================================================

TÍTULO:
Publicar [NombreEvento] al crear/modificar/eliminar [NombreEntidad]

DESCRIPCIÓN:
Implementar la publicación de eventos al broker ActiveMQ Artemis cuando se realizan operaciones CRUD sobre la entidad [NombreEntidad]. Los eventos deben seguir el patrón "State Transfer Event" documentado en `ActiveMQ_Events.md`, incluyendo el estado completo de la entidad y el flag IsDeleted para soft deletes.

Las aplicaciones satélite suscriptoras procesarán estos eventos para sincronizar sus bases de datos locales.

CONTEXTO TÉCNICO:
- **Broker**: ActiveMQ Artemis configurado en docker-compose
- **Librería**: IPVInterchangeShared para integración con Artemis
- **Patrón**: Event-driven State Transfer (no eventos granulares como "created", "updated")
- **Persistencia**: Los eventos se persisten en tabla IntegrationEvents de PostgreSQL antes de publicarse
- **Reintentos**: Configurados automáticamente con dead letter queue
- **Idempotencia**: Los suscriptores deben implementar procesamiento idempotente
- **Testing**: Usar Testcontainers para tests de integración con Artemis real

CRITERIOS DE ACEPTACIÓN TÉCNICOS:
- [ ] Clase de evento [NombreEvento] creada heredando de EventBase
- [ ] IMessagePublisher inyectado en [NombreEntidad]Service
- [ ] Publicación implementada en PostActions del servicio
- [ ] Evento incluye todas las propiedades de la entidad (state transfer completo)
- [ ] Flag IsDeleted indica si la entidad fue eliminada (AuditDeletionDate != null)
- [ ] Configuración de tópico añadida en appsettings.json
- [ ] Test de integración con Testcontainers verifica publicación correcta
- [ ] Test verifica persistencia en tabla IntegrationEvents
- [ ] Documentación del evento actualizada (estructura del payload)

GUÍA DE IMPLEMENTACIÓN:

**Paso 1: Crear la Clase del Evento**

Archivo: `InfoportOneAdmon.Events/[NombreEvento].cs`

```csharp
using IPVInterchangeShared.Broker.Events;

namespace InfoportOneAdmon.Events
{
    /// <summary>
    /// Evento publicado cuando cambia el estado de [descripción de la entidad]
    /// Patrón State Transfer: incluye el estado completo, no solo los cambios
    /// </summary>
    public class [NombreEvento] : EventBase
    {
        public [NombreEvento](string topic, string serviceName) : base(topic, serviceName)
        {
        }

        // Propiedades de negocio (estado completo de la entidad)
        
        /// <summary>
        /// Identificador de negocio único
        /// </summary>
        public int EntityId { get; set; }
        
        /// <summary>
        /// Nombre de [la entidad]
        /// </summary>
        public string Name { get; set; }
        
        /// <summary>
        /// Descripción de [la entidad]
        /// </summary>
        public string Description { get; set; }
        
        /// <summary>
        /// FK a entidad relacionada (si aplica)
        /// </summary>
        public int? RelatedEntityId { get; set; }
        
        // Flag crítico: indica si la entidad fue eliminada (soft delete)
        /// <summary>
        /// Indica si la entidad ha sido eliminada lógicamente en el sistema origen
        /// Los suscriptores deben procesar esto como soft delete local
        /// </summary>
        public bool IsDeleted { get; set; }
        
        // Campos de auditoría (opcionales pero recomendados para trazabilidad)
        public DateTime? AuditCreationDate { get; set; }
        public DateTime? AuditModificationDate { get; set; }
    }
}
```

**Paso 2: Inyectar IMessagePublisher en el Servicio**

Modificar: `InfoportOneAdmon.Services/Services/[NombreEntidad]Service.cs`

```csharp
using IPVInterchangeShared.Broker.Interfaces;
using InfoportOneAdmon.Events;
using Microsoft.Extensions.Configuration;

namespace InfoportOneAdmon.Services.Services
{
    public class [NombreEntidad]Service : BaseService<[NombreEntidad]View, [NombreEntidad], BaseMetadata>
    {
        private readonly IMessagePublisher _messagePublisher;
        private readonly IConfiguration _configuration;

        public [NombreEntidad]Service(
            ILogger<[NombreEntidad]Service> logger,
            IRepository<[NombreEntidad]> repository,
            IMessagePublisher messagePublisher,
            IConfiguration configuration)
            : base(logger, repository)
        {
            _messagePublisher = messagePublisher;
            _configuration = configuration;
        }

        // ... ValidateView, PreviousActions ...

        protected override async Task PostActions([NombreEntidad]View view, [NombreEntidad] entity, CancellationToken cancellationToken)
        {
            await base.PostActions(view, entity, cancellationToken);
            
            // Publicar evento al broker
            await PublishEntityEvent(entity, cancellationToken);
        }

        /// <summary>
        /// Publica el evento de estado de la entidad al broker ActiveMQ Artemis
        /// </summary>
        private async Task PublishEntityEvent([NombreEntidad] entity, CancellationToken cancellationToken)
        {
            var topic = _configuration["EventBroker:Topics:[NombreEvento]"] 
                        ?? "infoportone.events.[nombreentidad]";
            var serviceName = _configuration["EventBroker:ServiceName"] 
                              ?? "InfoportOneAdmon";

            var evento = new [NombreEvento](topic, serviceName)
            {
                EntityId = entity.Id,
                Name = entity.Name,
                Description = entity.Description,
                RelatedEntityId = entity.RelatedEntityId,
                
                // CRÍTICO: Flag IsDeleted indica soft delete
                IsDeleted = entity.AuditDeletionDate.HasValue,
                
                // Auditoría
                AuditCreationDate = entity.AuditCreationDate,
                AuditModificationDate = entity.AuditModificationDate
            };

            try
            {
                // PublishAsync persiste en IntegrationEvents y envía al broker
                await _messagePublisher.PublishAsync(topic, evento, cancellationToken);
                
                Logger.LogInformation(
                    "Evento {EventType} publicado para entidad {EntityId} (IsDeleted: {IsDeleted})",
                    nameof([NombreEvento]),
                    entity.Id,
                    evento.IsDeleted);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex, 
                    "Error al publicar evento {EventType} para entidad {EntityId}",
                    nameof([NombreEvento]),
                    entity.Id);
                
                // IMPORTANTE: No lanzar excepción, el evento se reintentará desde IntegrationEvents
                // La transacción de BD ya se completó correctamente
            }
        }
    }
}
```

**Paso 3: Configurar Tópico en appsettings.json**

Archivo: `InfoportOneAdmon.Api/appsettings.json`

```json
{
  "EventBroker": {
    "ServiceName": "InfoportOneAdmon",
    "Artemis": {
      "Host": "localhost",
      "Port": 61616,
      "User": "artemis",
      "Password": "artemis"
    },
    "Topics": {
      "[NombreEvento]": "infoportone.events.[nombreentidad]"
    },
    "Retry": {
      "MaxAttempts": 5,
      "InitialDelay": 1000,
      "MaxDelay": 60000
    }
  }
}
```

**Paso 4: Configurar AddArtemisBroker en Program.cs**

Si no está ya configurado, añadir en `InfoportOneAdmon.Api/Program.cs`:

```csharp
using IPVInterchangeShared.Broker.Artemis;

var builder = WebApplication.CreateBuilder(args);

// Configurar IPVInterchangeShared con Artemis
builder.Services.AddArtemisBroker(builder.Configuration, typeof(Program).Assembly);

// ... resto de configuración ...
```

**Paso 5: Implementar Test de Integración con Testcontainers**

Archivo: `InfoportOneAdmon.Services.Tests/Events/[NombreEvento]PublisherTests.cs`

```csharp
using Xunit;
using FluentAssertions;
using Testcontainers.PostgreSql;
using Testcontainers.Artemis; // Paquete: Testcontainers.Artemis
using Microsoft.Extensions.DependencyInjection;
using IPVInterchangeShared.Broker.Interfaces;
using InfoportOneAdmon.Services.Services;
using InfoportOneAdmon.Entities.Views;
using InfoportOneAdmon.Events;

namespace InfoportOneAdmon.Services.Tests.Events
{
    public class [NombreEvento]PublisherTests : IAsyncLifetime
    {
        private PostgreSqlContainer _postgresContainer;
        private ArtemisContainer _artemisContainer;
        private IServiceProvider _serviceProvider;

        public async Task InitializeAsync()
        {
            // Configurar contenedor PostgreSQL
            _postgresContainer = new PostgreSqlBuilder()
                .WithImage("postgres:16")
                .WithDatabase("infoportone_test")
                .Build();
            await _postgresContainer.StartAsync();

            // Configurar contenedor ActiveMQ Artemis
            _artemisContainer = new ArtemisBuilder()
                .WithImage("apache/activemq-artemis:latest")
                .Build();
            await _artemisContainer.StartAsync();

            // Configurar DI con contenedores reales
            var services = new ServiceCollection();
            services.AddLogging();
            
            // Configurar DbContext con PostgreSQL de Testcontainer
            services.AddDbContext<InfoportOneAdmonContext>(options =>
                options.UseNpgsql(_postgresContainer.GetConnectionString()));
            
            // Configurar Artemis con Testcontainer
            var config = new ConfigurationBuilder()
                .AddInMemoryCollection(new Dictionary<string, string>
                {
                    ["EventBroker:Artemis:Host"] = _artemisContainer.Hostname,
                    ["EventBroker:Artemis:Port"] = _artemisContainer.GetMappedPublicPort(61616).ToString(),
                    ["EventBroker:ServiceName"] = "TestService"
                })
                .Build();
            
            services.AddSingleton<IConfiguration>(config);
            services.AddArtemisBroker(config, typeof([NombreEvento]).Assembly);
            
            // Registrar servicio a testear
            services.AddScoped<[NombreEntidad]Service>();
            services.AddScoped(typeof(IRepository<>), typeof(Repository<>));
            
            _serviceProvider = services.BuildServiceProvider();
            
            // Aplicar migraciones
            using var scope = _serviceProvider.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<InfoportOneAdmonContext>();
            await context.Database.MigrateAsync();
        }

        [Fact]
        public async Task PostActions_WhenEntityCreated_PublishesEventSuccessfully()
        {
            // Arrange
            using var scope = _serviceProvider.CreateScope();
            var service = scope.ServiceProvider.GetRequiredService<[NombreEntidad]Service>();
            var context = scope.ServiceProvider.GetRequiredService<InfoportOneAdmonContext>();
            
            var view = new [NombreEntidad]View
            {
                Name = "Test Entity",
                Description = "Test Description"
            };

            // Act
            var result = await service.CreateAsync(view, CancellationToken.None);

            // Assert
            result.Should().NotBeNull();
            result.Id.Should().BeGreaterThan(0);
            
            // Verificar que el evento se persistió en IntegrationEvents
            var integrationEvent = await context.IntegrationEvents
                .Where(e => e.EventType == nameof([NombreEvento]))
                .OrderByDescending(e => e.CreatedAt)
                .FirstOrDefaultAsync();
            
            integrationEvent.Should().NotBeNull();
            integrationEvent.State.Should().Be("Published");
            
            // Deserializar payload y verificar
            var payload = JsonSerializer.Deserialize<[NombreEvento]>(integrationEvent.Payload);
            payload.EntityId.Should().Be(result.Id);
            payload.Name.Should().Be("Test Entity");
            payload.IsDeleted.Should().BeFalse();
        }

        [Fact]
        public async Task PostActions_WhenEntityDeleted_PublishesEventWithIsDeletedTrue()
        {
            // Arrange
            using var scope = _serviceProvider.CreateScope();
            var service = scope.ServiceProvider.GetRequiredService<[NombreEntidad]Service>();
            var context = scope.ServiceProvider.GetRequiredService<InfoportOneAdmonContext>();
            
            var view = new [NombreEntidad]View { Name = "To Delete" };
            var created = await service.CreateAsync(view, CancellationToken.None);

            // Act
            await service.DeleteAsync(created.Id, CancellationToken.None);

            // Assert
            var deleteEvent = await context.IntegrationEvents
                .Where(e => e.EventType == nameof([NombreEvento]))
                .OrderByDescending(e => e.CreatedAt)
                .FirstOrDefaultAsync();
            
            var payload = JsonSerializer.Deserialize<[NombreEvento]>(deleteEvent.Payload);
            payload.IsDeleted.Should().BeTrue();
        }

        public async Task DisposeAsync()
        {
            await _postgresContainer.DisposeAsync();
            await _artemisContainer.DisposeAsync();
        }
    }
}
```

**Paso 6: Documentar el Evento**

Crear archivo: `docs/events/[NombreEvento].md`

```markdown
# [NombreEvento]

## Descripción
Evento publicado cuando cambia el estado de [descripción de la entidad].

## Patrón
State Transfer Event - Incluye el estado completo de la entidad.

## Tópico
`infoportone.events.[nombreentidad]`

## Publisher
InfoportOneAdmon API

## Subscribers
- Aplicación Satélite A
- Aplicación Satélite B

## Estructura del Payload

```json
{
  "eventId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "eventTimestamp": "2026-01-31T10:30:00Z",
  "traceId": "trace-123",
  "topic": "infoportone.events.[nombreentidad]",
  "serviceName": "InfoportOneAdmon",
  "entityId": 12345,
  "name": "Nombre de la entidad",
  "description": "Descripción detallada",
  "relatedEntityId": 67890,
  "isDeleted": false,
  "auditCreationDate": "2026-01-01T08:00:00Z",
  "auditModificationDate": "2026-01-31T10:30:00Z"
}
```

## Propiedades

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| entityId | int | Sí | Identificador único de la entidad |
| name | string | Sí | Nombre de la entidad |
| description | string | No | Descripción detallada |
| isDeleted | bool | Sí | Indica si la entidad fue eliminada (soft delete) |

## Procesamiento Idempotente

Los suscriptores deben:
1. Verificar si `isDeleted == true` para aplicar soft delete local
2. Si `isDeleted == false`, hacer UPSERT (insert o update según exista)
3. Usar `entityId` como clave de idempotencia

## Ejemplo de Suscriptor

Ver `ActiveMQ_Events.md` sección "Implementar un Suscriptor (IEventProcessor)".
```

ARCHIVOS A CREAR/MODIFICAR:
- `InfoportOneAdmon.Events/[NombreEvento].cs` - Clase del evento
- `InfoportOneAdmon.Services/Services/[NombreEntidad]Service.cs` - Inyectar IMessagePublisher y publicar en PostActions
- `InfoportOneAdmon.Api/appsettings.json` - Configuración del tópico
- `InfoportOneAdmon.Services.Tests/Events/[NombreEvento]PublisherTests.cs` - Tests con Testcontainers
- `docs/events/[NombreEvento].md` - Documentación del evento

DEPENDENCIAS:
- [TASK-XXX-BE] - Debe existir el servicio de la entidad

DEFINITION OF DONE:
- [ ] Clase [NombreEvento] creada heredando de EventBase
- [ ] IMessagePublisher inyectado en servicio
- [ ] Evento publicado en PostActions del servicio
- [ ] Flag IsDeleted implementado correctamente
- [ ] Configuración en appsettings.json
- [ ] Test con Testcontainers verifica publicación
- [ ] Test verifica persistencia en IntegrationEvents
- [ ] Test verifica IsDeleted=true en soft delete
- [ ] Documentación del evento creada
- [ ] Code review aprobado

RECURSOS:
- Arquitectura de Eventos: `ActiveMQ_Events.md` - Secciones "Publicar un Evento", "Testing con Testcontainers"

=============================================================
```

#### Ticket Tipo C: Suscripción a Eventos desde Backend

Este tipo de ticket cubre la implementación de suscripción a eventos (consumo desde ActiveMQ Artemis) para sincronizar datos de InfoportOneAdmon en aplicaciones satélite.

**Plantilla de Ticket Suscripción a Eventos:**

```
=============================================================
TICKET ID: TASK-XXX-EV-SUB
EPIC: [Nombre de la Épica]
USER STORY: US-XXX - [Título de la User Story]
COMPONENT: Events - Subscriber
PRIORITY: Alta
ESTIMATION: [3-5 horas]
=============================================================

TÍTULO:
Suscribirse a [NombreEvento] para sincronizar [NombreEntidad] localmente

DESCRIPCIÓN:
Implementar un procesador de eventos (IEventProcessor) que se suscriba al tópico [nombre-topico] de ActiveMQ Artemis para mantener sincronizada la entidad [NombreEntidad] en la base de datos local de la aplicación satélite.

El procesador debe:
- Consumir eventos del tópico automáticamente
- Procesar el estado completo de la entidad (patrón State Transfer)
- Hacer UPSERT (insert o update) según el entityId exista o no
- Aplicar soft delete local si IsDeleted=true
- Implementar procesamiento idempotente (detectar eventos duplicados)
- Manejar errores con reintentos automáticos

CONTEXTO TÉCNICO:
- **Patrón**: Event-Driven Synchronization con State Transfer
- **Librería**: IPVInterchangeShared.Broker.Artemis
- **Registro automático**: AddArtemisBroker registra automáticamente todos los IEventProcessor del assembly
- **Idempotencia**: Detectar eventos ya procesados usando EventId o comparación de estado
- **Reintentos**: Configurados automáticamente por IPVInterchangeShared (max 5 intentos)
- **Dead Letter Queue**: Eventos fallidos tras reintentos van a DLQ automáticamente

CRITERIOS DE ACEPTACIÓN TÉCNICOS:
- [ ] Clase [NombreEntidad]Processor implementa IEventProcessor<[NombreEvento]>
- [ ] Método GetQueues() retorna el nombre de la cola suscrita
- [ ] Método ProcessAsync() implementa lógica UPSERT idempotente
- [ ] Soft delete aplicado correctamente cuando IsDeleted=true
- [ ] Logging de eventos procesados y errores
- [ ] Manejo de excepciones sin bloquear la cola
- [ ] Test de integración con Testcontainers verifica consumo correcto
- [ ] Test verifica idempotencia (procesar mismo evento 2 veces = mismo resultado)

GUÍA DE IMPLEMENTACIÓN:

**Paso 1: Crear el Procesador de Eventos**

Archivo: `[AplicacionSatelite].EventProcessors/[NombreEntidad]Processor.cs`

```csharp
using IPVInterchangeShared.Broker.Interfaces;
using InfoportOneAdmon.Events;
using Microsoft.Extensions.Logging;
using Microsoft.EntityFrameworkCore;

namespace [AplicacionSatelite].EventProcessors
{
    /// <summary>
    /// Procesa eventos de [NombreEntidad] desde InfoportOneAdmon
    /// para mantener sincronizada la base de datos local
    /// </summary>
    public class [NombreEntidad]Processor : IEventProcessor<[NombreEvento]>
    {
        private readonly ILogger<[NombreEntidad]Processor> _logger;
        private readonly [AplicacionSatelite]Context _context;

        public [NombreEntidad]Processor(
            ILogger<[NombreEntidad]Processor> logger,
            [AplicacionSatelite]Context context)
        {
            _logger = logger;
            _context = context;
        }

        /// <summary>
        /// Define las colas a las que este procesador se suscribe
        /// </summary>
        public List<string> GetQueues()
        {
            // IMPORTANTE: Debe coincidir con el tópico configurado en InfoportOneAdmon
            return new List<string> { "infoportone.events.[nombreentidad]" };
        }

        /// <summary>
        /// Procesa un evento recibido de la cola
        /// </summary>
        public async Task ProcessAsync([NombreEvento] eventToProcess, string queueName, CancellationToken ct)
        {
            _logger.LogInformation(
                "Procesando evento {EventType} - EntityId: {EntityId}, IsDeleted: {IsDeleted}, EventId: {EventId}",
                nameof([NombreEvento]),
                eventToProcess.EntityId,
                eventToProcess.IsDeleted,
                eventToProcess.EventId);

            try
            {
                // Buscar entidad existente en BD local
                var existingEntity = await _context.[NombreEntidades]
                    .FirstOrDefaultAsync(e => e.EntityId == eventToProcess.EntityId, ct);

                if (eventToProcess.IsDeleted)
                {
                    // Soft Delete: marcar como eliminada
                    if (existingEntity != null)
                    {
                        existingEntity.AuditDeletionDate = DateTime.UtcNow;
                        _logger.LogInformation(
                            "Entidad {EntityId} marcada como eliminada (soft delete)",
                            eventToProcess.EntityId);
                    }
                    else
                    {
                        _logger.LogWarning(
                            "Se recibió evento de eliminación para entidad {EntityId} que no existe localmente",
                            eventToProcess.EntityId);
                    }
                }
                else
                {
                    // UPSERT: Insert o Update
                    if (existingEntity == null)
                    {
                        // INSERT: Crear nueva entidad
                        existingEntity = new [NombreEntidad]
                        {
                            EntityId = eventToProcess.EntityId
                        };
                        _context.[NombreEntidades].Add(existingEntity);
                        
                        _logger.LogInformation(
                            "Nueva entidad {EntityId} creada desde evento",
                            eventToProcess.EntityId);
                    }
                    else
                    {
                        _logger.LogInformation(
                            "Actualizando entidad existente {EntityId}",
                            eventToProcess.EntityId);
                    }

                    // Actualizar propiedades (tanto para INSERT como UPDATE)
                    existingEntity.Name = eventToProcess.Name;
                    existingEntity.Description = eventToProcess.Description;
                    existingEntity.RelatedEntityId = eventToProcess.RelatedEntityId;
                    
                    // Si fue previamente eliminada, restaurar
                    existingEntity.AuditDeletionDate = null;
                    
                    // Actualizar auditoría
                    existingEntity.AuditModificationDate = DateTime.UtcNow;
                    existingEntity.AuditModificationUser = 0; // Usuario sistema
                }

                // Guardar cambios en BD
                await _context.SaveChangesAsync(ct);

                _logger.LogInformation(
                    "Evento {EventType} procesado exitosamente para EntityId {EntityId}",
                    nameof([NombreEvento]),
                    eventToProcess.EntityId);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex,
                    "Error al procesar evento {EventType} para EntityId {EntityId}",
                    nameof([NombreEvento]),
                    eventToProcess.EntityId);
                
                // IMPORTANTE: Lanzar excepción para que el framework active reintentos
                throw;
            }
        }
    }
}
```

**Paso 2: Registrar el Procesador en Program.cs**

Archivo: `[AplicacionSatelite].Api/Program.cs`

```csharp
using IPVInterchangeShared.Broker.Artemis;

var builder = WebApplication.CreateBuilder(args);

// Registrar IPVInterchangeShared con Artemis
// Esto registra automáticamente TODOS los IEventProcessor del assembly especificado
builder.Services.AddArtemisBroker(
    builder.Configuration,
    typeof([NombreEntidad]Processor).Assembly); // Assembly que contiene los procesadores

// ... resto de configuración ...
```

**Paso 3: Configurar appsettings.json**

Archivo: `[AplicacionSatelite].Api/appsettings.json`

```json
{
  "EventBroker": {
    "ServiceName": "[AplicacionSatelite]",
    "Artemis": {
      "Host": "localhost",
      "Port": 61616,
      "User": "artemis",
      "Password": "artemis"
    },
    "Queues": {
      "[NombreEntidad]": "infoportone.events.[nombreentidad]"
    },
    "Retry": {
      "MaxAttempts": 5,
      "InitialDelay": 1000,
      "MaxDelay": 60000
    },
    "DeadLetterQueue": {
      "Enabled": true,
      "QueueName": "DLQ.[AplicacionSatelite]"
    }
  }
}
```

**Paso 4: Crear Entidad Local en la Aplicación Satélite**

Archivo: `[AplicacionSatelite].DataModel/Entities/[NombreEntidad].cs`

```csharp
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Helix6.Base.Domain.BaseInterfaces;

namespace [AplicacionSatelite].DataModel.Entities
{
    /// <summary>
    /// Entidad sincronizada desde InfoportOneAdmon vía eventos
    /// </summary>
    [Table("NOMBRE_ENTIDAD")]
    public class [NombreEntidad] : IEntityBase
    {
        /// <summary>
        /// PK local (autonumérica)
        /// </summary>
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int Id { get; set; }
        
        /// <summary>
        /// Identificador de negocio desde InfoportOneAdmon (índice único)
        /// </summary>
        [Required]
        public int EntityId { get; set; }
        
        /// <summary>
        /// Nombre sincronizado desde el evento
        /// </summary>
        [Required]
        [StringLength(200)]
        public string Name { get; set; }
        
        /// <summary>
        /// Descripción sincronizada desde el evento
        /// </summary>
        [StringLength(500)]
        public string Description { get; set; }
        
        /// <summary>
        /// FK sincronizada desde el evento
        /// </summary>
        public int? RelatedEntityId { get; set; }
        
        // Campos de auditoría Helix6
        public int? AuditCreationUser { get; set; }
        public DateTime? AuditCreationDate { get; set; }
        public int? AuditModificationUser { get; set; }
        public DateTime? AuditModificationDate { get; set; }
        public DateTime? AuditDeletionDate { get; set; }
    }
}
```

**Configurar índice único en DbContext:**

```csharp
public class [AplicacionSatelite]Context : DbContext
{
    public DbSet<[NombreEntidad]> [NombreEntidades] { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // Índice único para EntityId (clave de negocio desde InfoportOneAdmon)
        modelBuilder.Entity<[NombreEntidad]>()
            .HasIndex(e => e.EntityId)
            .IsUnique();
        
        base.OnModelCreating(modelBuilder);
    }
}
```

**Paso 5: Generar Migración**

```powershell
dotnet ef migrations add Add[NombreEntidad]SyncTable --project ..\[AplicacionSatelite].DataModel --startup-project [AplicacionSatelite].Api
dotnet ef database update
```

**Paso 6: Implementar Test de Integración**

Archivo: `[AplicacionSatelite].EventProcessors.Tests/[NombreEntidad]ProcessorTests.cs`

```csharp
using Xunit;
using FluentAssertions;
using Testcontainers.PostgreSql;
using Testcontainers.Artemis;
using Microsoft.Extensions.DependencyInjection;
using IPVInterchangeShared.Broker.Interfaces;
using [AplicacionSatelite].EventProcessors;
using InfoportOneAdmon.Events;

namespace [AplicacionSatelite].EventProcessors.Tests
{
    public class [NombreEntidad]ProcessorTests : IAsyncLifetime
    {
        private PostgreSqlContainer _postgresContainer;
        private ArtemisContainer _artemisContainer;
        private IServiceProvider _serviceProvider;

        public async Task InitializeAsync()
        {
            _postgresContainer = new PostgreSqlBuilder()
                .WithImage("postgres:16")
                .Build();
            await _postgresContainer.StartAsync();

            _artemisContainer = new ArtemisBuilder()
                .WithImage("apache/activemq-artemis:latest")
                .Build();
            await _artemisContainer.StartAsync();

            var services = new ServiceCollection();
            services.AddLogging();
            
            services.AddDbContext<[AplicacionSatelite]Context>(options =>
                options.UseNpgsql(_postgresContainer.GetConnectionString()));
            
            var config = new ConfigurationBuilder()
                .AddInMemoryCollection(new Dictionary<string, string>
                {
                    ["EventBroker:Artemis:Host"] = _artemisContainer.Hostname,
                    ["EventBroker:Artemis:Port"] = _artemisContainer.GetMappedPublicPort(61616).ToString()
                })
                .Build();
            
            services.AddSingleton<IConfiguration>(config);
            services.AddArtemisBroker(config, typeof([NombreEntidad]Processor).Assembly);
            
            _serviceProvider = services.BuildServiceProvider();
            
            using var scope = _serviceProvider.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<[AplicacionSatelite]Context>();
            await context.Database.MigrateAsync();
        }

        [Fact]
        public async Task ProcessAsync_WithNewEntity_CreatesLocalEntity()
        {
            // Arrange
            using var scope = _serviceProvider.CreateScope();
            var processor = scope.ServiceProvider.GetRequiredService<[NombreEntidad]Processor>();
            var context = scope.ServiceProvider.GetRequiredService<[AplicacionSatelite]Context>();
            
            var evento = new [NombreEvento]("test.topic", "TestService")
            {
                EntityId = 12345,
                Name = "Test Entity",
                Description = "Test Description",
                IsDeleted = false
            };

            // Act
            await processor.ProcessAsync(evento, "test.queue", CancellationToken.None);

            // Assert
            var localEntity = await context.[NombreEntidades]
                .FirstOrDefaultAsync(e => e.EntityId == 12345);
            
            localEntity.Should().NotBeNull();
            localEntity.Name.Should().Be("Test Entity");
            localEntity.AuditDeletionDate.Should().BeNull();
        }

        [Fact]
        public async Task ProcessAsync_WithIsDeletedTrue_AppliesSoftDelete()
        {
            // Arrange
            using var scope = _serviceProvider.CreateScope();
            var processor = scope.ServiceProvider.GetRequiredService<[NombreEntidad]Processor>();
            var context = scope.ServiceProvider.GetRequiredService<[AplicacionSatelite]Context>();
            
            // Crear entidad local primero
            var localEntity = new [NombreEntidad]
            {
                EntityId = 12345,
                Name = "To Delete"
            };
            context.[NombreEntidades].Add(localEntity);
            await context.SaveChangesAsync();
            
            var evento = new [NombreEvento]("test.topic", "TestService")
            {
                EntityId = 12345,
                IsDeleted = true
            };

            // Act
            await processor.ProcessAsync(evento, "test.queue", CancellationToken.None);

            // Assert
            var deletedEntity = await context.[NombreEntidades]
                .FirstOrDefaultAsync(e => e.EntityId == 12345);
            
            deletedEntity.Should().NotBeNull();
            deletedEntity.AuditDeletionDate.Should().NotBeNull();
        }

        [Fact]
        public async Task ProcessAsync_WithDuplicateEvent_IsIdempotent()
        {
            // Arrange
            using var scope = _serviceProvider.CreateScope();
            var processor = scope.ServiceProvider.GetRequiredService<[NombreEntidad]Processor>();
            var context = scope.ServiceProvider.GetRequiredService<[AplicacionSatelite]Context>();
            
            var evento = new [NombreEvento]("test.topic", "TestService")
            {
                EntityId = 12345,
                Name = "Idempotent Test",
                IsDeleted = false
            };

            // Act
            await processor.ProcessAsync(evento, "test.queue", CancellationToken.None);
            await processor.ProcessAsync(evento, "test.queue", CancellationToken.None); // Mismo evento 2 veces

            // Assert
            var entities = await context.[NombreEntidades]
                .Where(e => e.EntityId == 12345)
                .ToListAsync();
            
            entities.Should().HaveCount(1); // Solo 1 entidad, no duplicada
        }

        public async Task DisposeAsync()
        {
            await _postgresContainer.DisposeAsync();
            await _artemisContainer.DisposeAsync();
        }
    }
}
```

ARCHIVOS A CREAR/MODIFICAR:
- `[AplicacionSatelite].EventProcessors/[NombreEntidad]Processor.cs` - Procesador del evento
- `[AplicacionSatelite].DataModel/Entities/[NombreEntidad].cs` - Entidad local sincronizada
- `[AplicacionSatelite].DataModel/[AplicacionSatelite]Context.cs` - Configurar índice único
- `[AplicacionSatelite].Api/Program.cs` - Registrar AddArtemisBroker
- `[AplicacionSatelite].Api/appsettings.json` - Configuración de broker
- `[AplicacionSatelite].EventProcessors.Tests/[NombreEntidad]ProcessorTests.cs` - Tests con Testcontainers
- `Migrations/XXXXXX_Add[NombreEntidad]SyncTable.cs` - Migración EF Core

DEPENDENCIAS:
- Evento [NombreEvento] debe estar publicándose desde InfoportOneAdmon

DEFINITION OF DONE:
- [ ] Procesador implementa IEventProcessor<[NombreEvento]>
- [ ] GetQueues() retorna cola correcta
- [ ] ProcessAsync() implementa UPSERT idempotente
- [ ] Soft delete aplicado cuando IsDeleted=true
- [ ] Entidad local creada con índice único en EntityId
- [ ] Migración EF Core generada y aplicada
- [ ] AddArtemisBroker configurado en Program.cs
- [ ] appsettings.json configurado
- [ ] Test verifica creación de entidad desde evento
- [ ] Test verifica soft delete
- [ ] Test verifica idempotencia
- [ ] Code review aprobado

RECURSOS:
- Arquitectura de Eventos: `ActiveMQ_Events.md` - Sección "Implementar un Suscriptor (IEventProcessor)"

=============================================================
```

### 3. Instrucciones Finales

**Generar todos los tickets necesarios** para implementar las User Stories de `userStories.md`, siguiendo estas plantillas:
- **Tipo A**: Backend CRUD completo (entidades, servicios, endpoints)
- **Tipo B**: Publicación de eventos desde backend
- **Tipo C**: Suscripción a eventos en aplicaciones satélite

**Estructura del documento de salida:**
```markdown
# Tickets Técnicos Backend y Eventos

## Índice
[Generar índice por Épica y User Story]

---

## Épica 1: [Nombre]

### US-001: [Título de la User Story]

#### TASK-001-BE: [Título del ticket backend]
[Contenido completo siguiendo plantilla Tipo A]

#### TASK-001-EV-PUB: [Título del ticket publicación]
[Contenido completo siguiendo plantilla Tipo B]

---

### US-002: [Título de la User Story]
...
```

**Notas importantes:**
- Mantener trazabilidad: cada ticket debe referenciar su User Story origen
- Incluir estimaciones realistas (en horas)
- Priorizar según dependencias técnicas y valor de negocio
- Código de ejemplo debe ser funcional y seguir convenciones Helix6
- Tests deben usar Testcontainers para entornos reales

---

## Prompt 6.1-FE: Generación de Tickets Técnicos de Frontend

**Rol:** Tech Lead Frontend especialista en Angular 20, Standalone Components, @cl/common-library (ClGrid, ClModal, ClFormFields), NSwag, OAuth2 PKCE y gestión de permisos con AccessService.

**Objetivo:** Generar tickets técnicos detallados y profesionales para la implementación de funcionalidades Frontend a partir de las User Stories definidas en `userStories.md`. Cada ticket debe seguir la arquitectura estándar documentada en `Helix6_Frontend_Architecture.md` y ser completamente accionable por cualquier desarrollador del equipo.

**Contexto del proyecto:**
Analizar exhaustivamente:
- **User Stories**: `userStories.md` - Historias de usuario con criterios de aceptación
- **Arquitectura Frontend**: `Helix6_Frontend_Architecture.md` - Angular 20 Standalone, CommonLibrary, NSwag, permisos
- **Backend API**: Los endpoints generados por Helix6 Backend estarán disponibles vía Swagger

**Instrucciones detalladas:**

### 1. Análisis de User Stories

Para cada User Story en `userStories.md`:
1. Identificar si requiere componentes Frontend (grids, modals, formularios)
2. Identificar qué endpoints del backend consume (cliente NSwag)
3. Identificar permisos requeridos (AccessService)
4. Determinar componentes de CommonLibrary necesarios (ClGrid, ClModal, ClFormFields, etc.)

### 2. Tipos de Tickets Frontend a Generar

#### Ticket Tipo FE-A: Grid de Listado con Modal de Edición

Este tipo de ticket cubre la implementación de un grid de listado con operaciones CRUD usando ClGrid y ClModal.

**Plantilla de Ticket Frontend Grid:**

```
=============================================================
TICKET ID: TASK-XXX-FE
EPIC: [Nombre de la Épica]
USER STORY: US-XXX - [Título de la User Story]
COMPONENT: Frontend
PRIORITY: [Alta/Media/Baja]
ESTIMATION: [5-8 horas]
=============================================================

TÍTULO:
Implementar grid de [NombreEntidad] con modal de creación/edición

DESCRIPCIÓN:
Crear la interfaz de usuario para gestionar [descripción funcional de la entidad] usando los componentes de CommonLibrary (ClGrid, ClModal) y siguiendo los patrones de Angular 20 Standalone Components.

La funcionalidad debe incluir:
- Grid de listado con paginación, ordenación y filtrado
- Modal para crear/editar registros
- Validaciones de formulario reactivo
- Control de permisos (crear, editar, eliminar)
- Integración con cliente NSwag generado desde Swagger
- Traducciones i18n en español e inglés
- Tests unitarios de componentes

La funcionalidad debe cumplir con los criterios de aceptación de la User Story US-XXX: [copiar criterios relevantes]

CONTEXTO TÉCNICO:
- **Framework**: Angular 20 con Standalone Components
- **Librería UI**: @cl/common-library (ClGrid, ClModal, ClFormFields)
- **Cliente API**: NSwag generado automáticamente desde Swagger
- **Autenticación**: OAuth2 PKCE con Keycloak
- **Permisos**: AccessService con enums Access (Create, Read, Update, Delete)
- **Traducciones**: i18n con archivos JSON (es.json, en.json)
- **Forms**: Reactive Forms con validaciones

CRITERIOS DE ACEPTACIÓN TÉCNICOS:
- [ ] Componente grid [NombreEntidad]GridComponent creado como Standalone
- [ ] Componente modal [NombreEntidad]DialogComponent creado como Standalone
- [ ] ClGridConfig configurado con columnas, paginación, ordenación, filtrado
- [ ] ClModal integrado para creación/edición de registros
- [ ] Formulario reactivo con validaciones (required, maxLength, etc.)
- [ ] Cliente NSwag integrado para llamadas al backend
- [ ] Permisos implementados con AccessService
- [ ] Traducciones añadidas en es.json y en.json
- [ ] Estilos SCSS siguiendo guía de estilo del proyecto
- [ ] Tests unitarios con Jasmine/Karma (cobertura >80%)
- [ ] Sin errores de compilación ni warnings

GUÍA DE IMPLEMENTACIÓN:

**Paso 1: Generar Cliente NSwag desde Swagger**

Ejecutar script para generar cliente TypeScript desde el Swagger del backend:

```powershell
# Desde SintraportV4.Front/
npm run generate-api-client
```

Esto genera el cliente en `src/webServicesReferences/api/apiClients.ts` con todos los endpoints del backend.

**Paso 2: Crear Componente Grid**

Archivo: `src/app/modules/[modulo]/components/[nombre-entidad]-grid/[nombre-entidad]-grid.component.ts`

```typescript
import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ClGridComponent, ClGridConfig, ClPageableSettings, ClSortableSettings, ClFilterableSettings, ClGridEdition, GridDataResult } from '@cl/common-library/cl-grid';
import { ClModalService } from '@cl/common-library/cl-modal';
import { TranslateModule } from '@ngx-translate/core';
import { [NombreEntidad]Client, [NombreEntidad]View } from '@webServicesReferences/api/apiClients';
import { AccessService, Access } from '@services/access.service';
import { [NombreEntidad]DialogComponent } from '../[nombre-entidad]-dialog/[nombre-entidad]-dialog.component';

@Component({
  selector: 'app-[nombre-entidad]-grid',
  standalone: true,
  imports: [
    CommonModule,
    ClGridComponent,
    TranslateModule
  ],
  templateUrl: './[nombre-entidad]-grid.component.html',
  styleUrls: ['./[nombre-entidad]-grid.component.scss']
})
export class [NombreEntidad]GridComponent implements OnInit {
  // Inyección de dependencias con inject() (Angular 20)
  private readonly [nombreEntidad]Client = inject([NombreEntidad]Client);
  private readonly modalService = inject(ClModalService);
  private readonly accessService = inject(AccessService);

  // Configuración del grid
  gridConfig!: ClGridConfig<[NombreEntidad]View>;
  gridData: GridDataResult<[NombreEntidad]View> = { data: [], total: 0 };
  loading = false;

  // Permisos
  hasCreatePermission = false;
  hasUpdatePermission = false;
  hasDeletePermission = false;

  ngOnInit(): void {
    this.checkPermissions();
    this.configureGrid();
    this.loadData();
  }

  private checkPermissions(): void {
    const moduleName = '[ModuleName]'; // Ej: 'MSTP_Organizations'
    
    this.hasCreatePermission = this.accessService.hasAccess(moduleName, Access.Create);
    this.hasUpdatePermission = this.accessService.hasAccess(moduleName, Access.Update);
    this.hasDeletePermission = this.accessService.hasAccess(moduleName, Access.Delete);
  }

  private configureGrid(): void {
    this.gridConfig = new ClGridConfig<[NombreEntidad]View>({
      idGrid: '[nombreEntidad]GridConfig',
      serverSide: true,
      columns: [
        {
          field: 'id',
          title: 'ID',
          width: 80,
          hidden: true
        },
        {
          field: 'name',
          title: '[NombreEntidad].Name', // Clave de traducción
          width: 300,
          editor: {
            type: 'text',
            validators: [Validators.required, Validators.maxLength(200)]
          }
        },
        {
          field: 'description',
          title: '[NombreEntidad].Description',
          width: 400,
          editor: {
            type: 'text',
            validators: [Validators.maxLength(500)]
          }
        },
        {
          field: 'relatedEntityName',
          title: '[NombreEntidad].RelatedEntity',
          width: 200,
          editor: {
            type: 'lookup',
            lookupConfig: {
              // Configurar lookup si es necesario
              dataSource: [], // Cargar desde otro endpoint
              textField: 'name',
              valueField: 'id'
            }
          }
        },
        {
          field: 'auditCreationDate',
          title: 'Common.CreatedAt',
          width: 150,
          type: 'date',
          format: 'dd/MM/yyyy HH:mm',
          editable: false
        }
      ],
      pageable: new ClPageableSettings({
        pageSizes: [10, 20, 50, 100],
        initialPage: 1,
        pageSize: 20
      }),
      sortable: new ClSortableSettings({
        mode: 'multiple',
        allowUnsort: true
      }),
      filterable: new ClFilterableSettings({
        mode: 'menu'
      }),
      edition: new ClGridEdition({
        mode: 'row',
        allowAdding: this.hasCreatePermission,
        allowEditing: this.hasUpdatePermission,
        allowDeleting: this.hasDeletePermission
      }),
      rowActions: [
        {
          icon: 'edit',
          tooltip: 'Common.Edit',
          visible: () => this.hasUpdatePermission,
          action: (row: [NombreEntidad]View) => this.openEditDialog(row)
        },
        {
          icon: 'delete',
          tooltip: 'Common.Delete',
          visible: () => this.hasDeletePermission,
          action: (row: [NombreEntidad]View) => this.confirmDelete(row),
          confirmMessage: 'Common.ConfirmDelete'
        }
      ],
      toolbarActions: [
        {
          text: 'Common.Add',
          icon: 'add',
          visible: this.hasCreatePermission,
          action: () => this.openCreateDialog()
        },
        {
          text: 'Common.Refresh',
          icon: 'refresh',
          action: () => this.loadData()
        }
      ]
    });
  }

  async loadData(state?: any): Promise<void> {
    this.loading = true;
    
    try {
      // Preparar parámetros de paginación/filtrado/ordenación
      const skip = state?.skip ?? 0;
      const take = state?.take ?? 20;
      const filter = state?.filter; // ClGrid pasa filtros en formato Kendo
      const sort = state?.sort;

      // Llamar al cliente NSwag
      const response = await this.[nombreEntidad]Client.getAll(
        skip,
        take,
        this.buildFilterExpression(filter),
        this.buildSortExpression(sort)
      ).toPromise();

      this.gridData = {
        data: response?.items ?? [],
        total: response?.total ?? 0
      };
    } catch (error) {
      console.error('Error loading [NombreEntidad] data', error);
      // Mostrar notificación de error
    } finally {
      this.loading = false;
    }
  }

  openCreateDialog(): void {
    const dialogRef = this.modalService.open([NombreEntidad]DialogComponent, {
      title: '[NombreEntidad].CreateTitle',
      width: 600,
      data: { mode: 'create' }
    });

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        this.loadData(); // Recargar grid tras crear
      }
    });
  }

  openEditDialog(entity: [NombreEntidad]View): void {
    const dialogRef = this.modalService.open([NombreEntidad]DialogComponent, {
      title: '[NombreEntidad].EditTitle',
      width: 600,
      data: { mode: 'edit', entity }
    });

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        this.loadData(); // Recargar grid tras editar
      }
    });
  }

  async confirmDelete(entity: [NombreEntidad]View): Promise<void> {
    // ClGrid ya muestra confirmación si se configuró confirmMessage
    try {
      await this.[nombreEntidad]Client.delete(entity.id).toPromise();
      this.loadData(); // Recargar grid tras eliminar
      // Mostrar notificación de éxito
    } catch (error) {
      console.error('Error deleting [NombreEntidad]', error);
      // Mostrar notificación de error
    }
  }

  private buildFilterExpression(filter: any): string | undefined {
    // Convertir filtros de Kendo a expresión OData o SQL
    // Implementación según backend
    return undefined;
  }

  private buildSortExpression(sort: any): string | undefined {
    // Convertir ordenación de Kendo a expresión OData
    // Implementación según backend
    return undefined;
  }
}
```

**Paso 3: Crear Template del Grid**

Archivo: `src/app/modules/[modulo]/components/[nombre-entidad]-grid/[nombre-entidad]-grid.component.html`

```html
<div class="[nombre-entidad]-grid-container">
  <h2>{{ '[NombreEntidad].Title' | translate }}</h2>
  
  <cl-grid
    [config]="gridConfig"
    [data]="gridData"
    [loading]="loading"
    (dataStateChange)="loadData($event)">
  </cl-grid>
</div>
```

**Paso 4: Crear Componente Modal de Edición**

Archivo: `src/app/modules/[modulo]/components/[nombre-entidad]-dialog/[nombre-entidad]-dialog.component.ts`

```typescript
import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule } from '@angular/forms';
import { ClModalRef, MODAL_DATA } from '@cl/common-library/cl-modal';
import { ClFormFieldsModule } from '@cl/common-library/cl-form-fields';
import { TranslateModule } from '@ngx-translate/core';
import { [NombreEntidad]Client, [NombreEntidad]View } from '@webServicesReferences/api/apiClients';

@Component({
  selector: 'app-[nombre-entidad]-dialog',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    ClFormFieldsModule,
    TranslateModule
  ],
  templateUrl: './[nombre-entidad]-dialog.component.html',
  styleUrls: ['./[nombre-entidad]-dialog.component.scss']
})
export class [NombreEntidad]DialogComponent implements OnInit {
  private readonly fb = inject(FormBuilder);
  private readonly [nombreEntidad]Client = inject([NombreEntidad]Client);
  private readonly dialogRef = inject(ClModalRef);
  private readonly data = inject(MODAL_DATA);

  form!: FormGroup;
  mode: 'create' | 'edit' = 'create';
  entity?: [NombreEntidad]View;
  saving = false;

  ngOnInit(): void {
    this.mode = this.data.mode;
    this.entity = this.data.entity;
    
    this.buildForm();
    
    if (this.mode === 'edit' && this.entity) {
      this.form.patchValue(this.entity);
    }
  }

  private buildForm(): void {
    this.form = this.fb.group({
      id: [0],
      name: ['', [Validators.required, Validators.maxLength(200)]],
      description: ['', [Validators.maxLength(500)]],
      relatedEntityId: [null]
    });
  }

  async save(): Promise<void> {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }

    this.saving = true;

    try {
      const formValue: [NombreEntidad]View = this.form.value;

      if (this.mode === 'create') {
        await this.[nombreEntidad]Client.create(formValue).toPromise();
      } else {
        await this.[nombreEntidad]Client.update(formValue.id, formValue).toPromise();
      }

      this.dialogRef.close(true); // Cerrar modal con éxito
    } catch (error) {
      console.error('Error saving [NombreEntidad]', error);
      // Mostrar notificación de error
    } finally {
      this.saving = false;
    }
  }

  cancel(): void {
    this.dialogRef.close(false);
  }
}
```

**Paso 5: Crear Template del Modal**

Archivo: `src/app/modules/[modulo]/components/[nombre-entidad]-dialog/[nombre-entidad]-dialog.component.html`

```html
<div class="[nombre-entidad]-dialog">
  <form [formGroup]="form" (ngSubmit)="save()">
    
    <cl-input
      formControlName="name"
      [label]="'[NombreEntidad].Name' | translate"
      [required]="true"
      [maxLength]="200">
    </cl-input>

    <cl-input
      formControlName="description"
      [label]="'[NombreEntidad].Description' | translate"
      [maxLength]="500"
      [multiline]="true"
      [rows]="4">
    </cl-input>

    <cl-look-up
      formControlName="relatedEntityId"
      [label]="'[NombreEntidad].RelatedEntity' | translate"
      [dataSource]="relatedEntitiesDataSource"
      textField="name"
      valueField="id">
    </cl-look-up>

    <div class="modal-actions">
      <button
        type="button"
        class="btn btn-secondary"
        (click)="cancel()"
        [disabled]="saving">
        {{ 'Common.Cancel' | translate }}
      </button>
      
      <button
        type="submit"
        class="btn btn-primary"
        [disabled]="form.invalid || saving">
        <span *ngIf="saving" class="spinner-border spinner-border-sm"></span>
        {{ (mode === 'create' ? 'Common.Create' : 'Common.Save') | translate }}
      </button>
    </div>
  </form>
</div>
```

**Paso 6: Añadir Traducciones**

Archivo: `src/assets/i18n/es.json`

```json
{
  "[NombreEntidad]": {
    "Title": "Gestión de [Nombre Plural]",
    "CreateTitle": "Crear [Nombre Singular]",
    "EditTitle": "Editar [Nombre Singular]",
    "Name": "Nombre",
    "Description": "Descripción",
    "RelatedEntity": "Entidad Relacionada"
  },
  "Common": {
    "Add": "Añadir",
    "Edit": "Editar",
    "Delete": "Eliminar",
    "Save": "Guardar",
    "Cancel": "Cancelar",
    "Create": "Crear",
    "Refresh": "Actualizar",
    "ConfirmDelete": "¿Está seguro de que desea eliminar este registro?",
    "CreatedAt": "Fecha de Creación"
  }
}
```

Archivo: `src/assets/i18n/en.json`

```json
{
  "[NombreEntidad]": {
    "Title": "[Plural Name] Management",
    "CreateTitle": "Create [Singular Name]",
    "EditTitle": "Edit [Singular Name]",
    "Name": "Name",
    "Description": "Description",
    "RelatedEntity": "Related Entity"
  },
  "Common": {
    "Add": "Add",
    "Edit": "Edit",
    "Delete": "Delete",
    "Save": "Save",
    "Cancel": "Cancel",
    "Create": "Create",
    "Refresh": "Refresh",
    "ConfirmDelete": "Are you sure you want to delete this record?",
    "CreatedAt": "Created At"
  }
}
```

**Paso 7: Configurar Ruta**

Archivo: `src/app/app.routes.ts`

```typescript
import { Routes } from '@angular/router';
import { AuthGuard } from '@guards/auth.guard';
import { [NombreEntidad]GridComponent } from '@modules/[modulo]/components/[nombre-entidad]-grid/[nombre-entidad]-grid.component';

export const routes: Routes = [
  // ... otras rutas ...
  {
    path: '[nombre-entidad]',
    component: [NombreEntidad]GridComponent,
    canActivate: [AuthGuard],
    data: {
      requiredModule: '[ModuleName]',
      requiredAccess: Access.Read
    }
  }
];
```

**Paso 8: Implementar Tests Unitarios**

Archivo: `src/app/modules/[modulo]/components/[nombre-entidad]-grid/[nombre-entidad]-grid.component.spec.ts`

```typescript
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { of } from 'rxjs';
import { [NombreEntidad]GridComponent } from './[nombre-entidad]-grid.component';
import { [NombreEntidad]Client } from '@webServicesReferences/api/apiClients';
import { AccessService } from '@services/access.service';
import { ClModalService } from '@cl/common-library/cl-modal';
import { TranslateModule } from '@ngx-translate/core';

describe('[NombreEntidad]GridComponent', () => {
  let component: [NombreEntidad]GridComponent;
  let fixture: ComponentFixture<[NombreEntidad]GridComponent>;
  let mockClient: jasmine.SpyObj<[NombreEntidad]Client>;
  let mockAccessService: jasmine.SpyObj<AccessService>;
  let mockModalService: jasmine.SpyObj<ClModalService>;

  beforeEach(async () => {
    mockClient = jasmine.createSpyObj('[NombreEntidad]Client', ['getAll', 'delete']);
    mockAccessService = jasmine.createSpyObj('AccessService', ['hasAccess']);
    mockModalService = jasmine.createSpyObj('ClModalService', ['open']);

    await TestBed.configureTestingModule({
      imports: [
        [NombreEntidad]GridComponent,
        TranslateModule.forRoot()
      ],
      providers: [
        { provide: [NombreEntidad]Client, useValue: mockClient },
        { provide: AccessService, useValue: mockAccessService },
        { provide: ClModalService, useValue: mockModalService }
      ]
    }).compileComponents();

    fixture = TestBed.createComponent([NombreEntidad]GridComponent);
    component = fixture.componentInstance;
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should load data on init', async () => {
    const mockData = {
      items: [{ id: 1, name: 'Test' }],
      total: 1
    };
    
    mockClient.getAll.and.returnValue(of(mockData));
    mockAccessService.hasAccess.and.returnValue(true);

    fixture.detectChanges();
    await fixture.whenStable();

    expect(component.gridData.data.length).toBe(1);
    expect(component.gridData.total).toBe(1);
  });

  it('should check permissions on init', () => {
    mockAccessService.hasAccess.and.returnValue(true);
    
    component.ngOnInit();

    expect(component.hasCreatePermission).toBeTrue();
    expect(component.hasUpdatePermission).toBeTrue();
    expect(component.hasDeletePermission).toBeTrue();
  });

  // Más tests: delete, open dialog, etc.
});
```

ARCHIVOS A CREAR/MODIFICAR:
Frontend:
- `src/app/modules/[modulo]/components/[nombre-entidad]-grid/[nombre-entidad]-grid.component.ts`
- `src/app/modules/[modulo]/components/[nombre-entidad]-grid/[nombre-entidad]-grid.component.html`
- `src/app/modules/[modulo]/components/[nombre-entidad]-grid/[nombre-entidad]-grid.component.scss`
- `src/app/modules/[modulo]/components/[nombre-entidad]-dialog/[nombre-entidad]-dialog.component.ts`
- `src/app/modules/[modulo]/components/[nombre-entidad]-dialog/[nombre-entidad]-dialog.component.html`
- `src/app/modules/[modulo]/components/[nombre-entidad]-dialog/[nombre-entidad]-dialog.component.scss`
- `src/app/app.routes.ts` - Añadir ruta
- `src/assets/i18n/es.json` - Traducciones español
- `src/assets/i18n/en.json` - Traducciones inglés
- `src/app/modules/[modulo]/components/[nombre-entidad]-grid/[nombre-entidad]-grid.component.spec.ts`
- `src/app/modules/[modulo]/components/[nombre-entidad]-dialog/[nombre-entidad]-dialog.component.spec.ts`

DEPENDENCIAS:
- [TASK-XXX-BE] - Backend con endpoints disponibles
- Cliente NSwag generado desde Swagger

DEFINITION OF DONE:
- [ ] Grid component creado como Standalone
- [ ] Dialog component creado como Standalone
- [ ] ClGridConfig configurado correctamente
- [ ] Formulario reactivo con validaciones
- [ ] Cliente NSwag integrado
- [ ] Permisos implementados con AccessService
- [ ] Traducciones en es.json y en.json
- [ ] Rutas configuradas con guards
- [ ] Tests unitarios con cobertura >80%
- [ ] Sin errores de compilación
- [ ] Code review aprobado

RECURSOS:
- Arquitectura Frontend: `Helix6_Frontend_Architecture.md` - Secciones sobre ClGrid, ClModal, Forms, Permisos

=============================================================
```

### 3. Instrucciones Finales

**Generar todos los tickets Frontend necesarios** para implementar las User Stories de `userStories.md`, siguiendo la plantilla Tipo FE-A y sus variantes según la complejidad de la UI.

**Estructura del documento de salida:**
```markdown
# Tickets Técnicos Frontend

## Índice
[Generar índice por Épica y User Story]

---

## Épica 1: [Nombre]

### US-001: [Título de la User Story]

#### TASK-001-FE: [Título del ticket frontend]
[Contenido completo siguiendo plantilla Tipo FE-A]

---
```

**Notas importantes:**
- Cada componente debe ser Standalone (Angular 20)
- Usar inject() para inyección de dependencias
- Componentes de CommonLibrary deben configurarse según documentación
- Tests unitarios con mocks de servicios
- Traducciones obligatorias en es.json y en.json

---

## Prompt 6.2: Generación de Tickets de Infraestructura y Setup

**Rol:** DevOps Engineer / Infrastructure Architect especialista en Docker, Kubernetes, PostgreSQL, ActiveMQ Artemis, Keycloak, CI/CD y configuración de entornos de desarrollo.

**Objetivo:** Generar tickets técnicos detallados para configurar toda la infraestructura necesaria del proyecto InfoportOneAdmon, incluyendo contenedores, bases de datos, brokers de mensajería, identity providers y pipelines de CI/CD.

**Contexto del proyecto:**
Este proyecto requiere múltiples componentes de infraestructura:
- **PostgreSQL** para persistencia de datos
- **ActiveMQ Artemis** para mensajería event-driven
- **Keycloak** para autenticación OAuth2 y gestión de usuarios
- **Docker Compose** para entorno de desarrollo local
- **Kubernetes** para despliegue en producción
- **CI/CD Pipelines** (Azure DevOps) para integración y despliegue continuo

**Instrucciones detalladas:**

Generar tickets individuales (NO agrupar en un solo ticket) para cada uno de estos componentes de infraestructura:

### Lista de Tickets de Infraestructura a Generar:

1. **INFRA-001**: Configurar Docker Compose con PostgreSQL, Artemis y Keycloak
2. **INFRA-002**: Configurar Keycloak Realm InfoportOne con Protocol Mappers
3. **INFRA-003**: Crear scripts de inicialización de base de datos PostgreSQL
4. **INFRA-004**: Configurar ActiveMQ Artemis (tópicos, colas, security, Jolokia)
5. **INFRA-005**: Setup de proyecto Helix6 Backend (.NET 8)
6. **INFRA-006**: Setup de proyecto Angular 20 Frontend con CommonLibrary
7. **INFRA-007**: Configurar pipeline CI/CD para Backend (.NET)
8. **INFRA-008**: Configurar pipeline CI/CD para Frontend (Angular)
9. **INFRA-009**: Crear manifiestos Kubernetes para despliegue en producción
10. **INFRA-010**: Configurar Secrets Management (Azure Key Vault / Kubernetes Secrets)

Cada ticket debe incluir:
- Scripts completos y funcionales (docker-compose.yml, Dockerfiles, appsettings.json, etc.)
- Comandos exactos para ejecutar
- Configuraciones de seguridad (credenciales, certificados)
- Instrucciones de validación (cómo verificar que funciona)
- Troubleshooting común

**Formato de cada ticket:**

```
=============================================================
TICKET ID: INFRA-XXX
COMPONENT: Infrastructure
PRIORITY: Alta
ESTIMATION: [2-4 horas]
=============================================================

TÍTULO:
[Descripción concisa de la tarea de infraestructura]

DESCRIPCIÓN:
[Explicación detallada de qué componente se configura, por qué es necesario y cómo se integra con el resto del sistema]

ARCHIVOS A CREAR/MODIFICAR:
- [Lista de archivos de configuración]

GUÍA DE IMPLEMENTACIÓN:
[Pasos detallados con scripts completos]

VALIDACIÓN:
[Cómo verificar que la configuración funciona correctamente]

TROUBLESHOOTING:
[Problemas comunes y soluciones]

DEFINITION OF DONE:
- [ ] Configuración implementada y probada localmente
- [ ] Documentación actualizada
- [ ] Scripts validados
- [ ] Credenciales gestionadas de forma segura
```

---

## Prompt 6.3: Generación de Tickets de Testing End-to-End y Documentación

**Rol:** QA Lead / Technical Writer especialista en testing E2E (Playwright/Cypress), testing de integración, documentación técnica y generación de diagramas.

**Objetivo:** Generar tickets técnicos para implementar tests end-to-end que validen flujos completos de usuario, tests de carga/rendimiento, tests de seguridad y documentación técnica exhaustiva del sistema.

**Contexto del proyecto:**
Una vez implementadas las funcionalidades Backend y Frontend, es necesario:
- **Tests E2E** que validen flujos de usuario completos (login, CRUD, eventos)
- **Tests de integración** entre componentes (backend ↔ eventos ↔ keycloak)
- **Tests de rendimiento** y carga del sistema
- **Tests de seguridad** (OAuth2, PKCE, permisos)
- **Documentación técnica** (Swagger, diagramas de secuencia, READMEs)

**Instrucciones detalladas:**

Generar tickets individuales para:

### Lista de Tickets de Testing y Documentación a Generar:

1. **TEST-001**: Configurar Playwright para tests E2E del Frontend
2. **TEST-002**: Implementar tests E2E de flujo de autenticación OAuth2 PKCE
3. **TEST-003**: Implementar tests E2E de CRUD de Organizaciones (completo con eventos)
4. **TEST-004**: Implementar tests E2E de gestión de Aplicaciones y Módulos
5. **TEST-005**: Tests de integración de eventos (publicación y consumo con Testcontainers)
6. **TEST-006**: Tests de carga con JMeter/K6 (endpoints críticos)
7. **TEST-007**: Tests de seguridad (SQL injection, XSS, autorización)
8. **TEST-008**: Documentar API con Swagger (descripciones, ejemplos, schemas)
9. **TEST-009**: Generar diagramas de secuencia para flujos críticos (mermaid)
10. **TEST-010**: Crear README completo de cada módulo con instrucciones de uso

Cada ticket debe incluir:
- Configuración de herramientas de testing
- Tests completos y ejecutables
- Scripts de ejecución automatizada
- Reportes de cobertura
- Documentación generada

**Formato de cada ticket:**

```
=============================================================
TICKET ID: TEST-XXX / DOC-XXX
COMPONENT: Testing / Documentation
PRIORITY: Media
ESTIMATION: [3-6 horas]
=============================================================

TÍTULO:
[Descripción concisa de la tarea de testing o documentación]

DESCRIPCIÓN:
[Explicación detallada de qué se testea o documenta y por qué es crítico]

ARCHIVOS A CREAR/MODIFICAR:
- [Lista de archivos de tests o documentación]

GUÍA DE IMPLEMENTACIÓN:
[Pasos detallados con ejemplos de tests o templates de documentación]

CRITERIOS DE ACEPTACIÓN:
- [ ] Tests implementados y pasando
- [ ] Cobertura de código >80%
- [ ] Reportes generados automáticamente
- [ ] Documentación publicada y accesible

DEFINITION OF DONE:
- [ ] Tests ejecutables en CI/CD
- [ ] Documentación revisada y aprobada
```

---

### 7. Pull Requests

## Prompt 7.1

## Prompt 7.2

## Prompt 7.3
