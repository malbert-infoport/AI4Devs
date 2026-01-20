> Detalla en esta sección los prompts principales utilizados durante la creación del proyecto, que justifiquen el uso de asistentes de código en todas las fases del ciclo de vida del desarrollo. Esperamos un máximo de 3 por sección, principalmente los de creación inicial o  los de corrección o adición de funcionalidades que consideres más relevantes.
Puedes añadir adicionalmente la conversación completa como link o archivo adjunto si así lo consideras


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

### 3. Modelo de Datos

## Prompt 3.1

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

## Prompt 5.3

---

### 6. Tickets de Trabajo

## Prompt 6.1

## Prompt 6.2

## Prompt 6.3

---

### 7. Pull Requests

## Prompt 7.1

## Prompt 7.2

## Prompt 7.3
