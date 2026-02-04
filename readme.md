## Índice

0. [Ficha del proyecto](#0-ficha-del-proyecto)
1. [Descripción general del producto](#1-descripción-general-del-producto)
2. [Arquitectura del sistema](#2-arquitectura-del-sistema)
3. [Modelo de datos](#3-modelo-de-datos)
4. [Especificación de la API](#4-especificación-de-la-api)
5. [Historias de usuario](#5-historias-de-usuario)
6. [Tickets de trabajo](#6-tickets-de-trabajo)
7. [Pull requests](#7-pull-requests)

---

## 0. Ficha del proyecto

### **0.1. Tu nombre completo: Miguel Albert Villanova**

### **0.2. Nombre del proyecto: InfoportOneAdmon**

### **0.3. Descripción breve del proyecto:**

**InfoportOneAdmon** es la plataforma administrativa centralizada diseñada para la gestión integral del **portfolio de aplicaciones empresariales** de la Organización Propietaria. Actúa como el núcleo de gobierno y control de acceso del ecosistema, permitiendo a la Organización Propietaria determinar de forma centralizada qué organizaciones clientes tienen acceso a cada aplicación del portfolio, qué módulos funcionales pueden utilizar dentro de cada una, y qué roles de seguridad están disponibles para sus usuarios en el sistema.

A diferencia de modelos SaaS de auto-servicio, en este ecosistema **las organizaciones no se registran por sí mismas**. Es la Organización Propietaria quien, a través de InfoportOneAdmon, ejecuta el proceso completo de onboarding: da de alta las organizaciones clientes, las agrupa lógicamente, configura sus permisos de acceso a aplicaciones y módulos, y provisiona su identidad digital mediante integración con **Keycloak** para la gestión unificada de usuarios y autenticación.

**InfoportOneAdmon actúa como la Fuente de la Verdad para:**
- **Gestión del Portfolio de Aplicaciones**: Registro y configuración de las aplicaciones satélite del ecosistema, incluyendo credenciales OAuth2 y definición de módulos funcionales
- **Control de Acceso por Organización**: Determinación granular de qué organizaciones clientes tienen acceso a qué aplicaciones y a qué módulos específicos dentro de cada aplicación
- **Gestión de Inquilinos (Tenants)**: Control del ciclo de vida completo de las organizaciones clientes, desde el alta hasta la baja
- **Gestión de Grupos de Organizaciones**: Creación y mantenimiento de agrupaciones lógicas (holdings, consorcios) para facilitar la gestión colectiva
- **Catálogo Maestro de Roles**: Definición centralizada y consistente de los roles de seguridad disponibles en cada aplicación del portfolio
- **Gobierno de Identidad y Usuarios**: Orquestación con Keycloak para la gestión de usuarios multi-organización, autenticación SSO y tokens JWT con claims personalizados que habilitan el acceso segmentado por organización

El sistema utiliza una arquitectura orientada a eventos basada en **ActiveMQ Artemis** con patrón "State Transfer Event", garantizando desacoplamiento total entre InfoportOneAdmon y las aplicaciones satélite, permitiendo que cada aplicación mantenga su propia autonomía operacional mientras sincroniza automáticamente los datos maestros de organizaciones, roles y permisos.

### **0.4. URL del proyecto:**

> Puede ser pública o privada, en cuyo caso deberás compartir los accesos de manera segura. Puedes enviarlos a [alvaro@lidr.co](mailto:alvaro@lidr.co) usando algún servicio como [onetimesecret](https://onetimesecret.com/).

### 0.5. URL o archivo comprimido del repositorio

> Puedes tenerlo alojado en público o en privado, en cuyo caso deberás compartir los accesos de manera segura. Puedes enviarlos a [alvaro@lidr.co](mailto:alvaro@lidr.co) usando algún servicio como [onetimesecret](https://onetimesecret.com/). También puedes compartir por correo un archivo zip con el contenido


---

## 1. Descripción general del producto

### **1.1. Objetivo:**

#### **Propósito del Producto**

InfoportOneAdmon centraliza la complejidad administrativa del ecosistema de aplicaciones empresariales para que las aplicaciones de negocio (Sintraport, Translate, etc.) puedan centrarse exclusivamente en su lógica funcional y en la gestión de sus propios usuarios finales.

**Misión**: Centralizar la gestión del portfolio de aplicaciones, el onboarding de organizaciones clientes, la configuración de accesos granulares por aplicación y módulo, y el gobierno de identidad, liberando a las aplicaciones satélite de la complejidad de gestión multi-tenant y seguridad transversal.

#### **Valor que Aporta**

1. **Control Total del Ecosistema**: Permite a la Organización Propietaria mantener un control absoluto sobre quién accede al ecosistema, a qué aplicaciones, y con qué permisos, sin depender de auto-registros incontrolados.

2. **Simplificación de Aplicaciones Satélite**: Las aplicaciones del portfolio no necesitan implementar lógica compleja de multi-organización ni gestión de tenants. Solo deben validar tokens JWT y consumir eventos de sincronización.

3. **Seguridad Centralizada y Consistente**: Al orquestar Keycloak desde un único punto, se garantiza coherencia en la autenticación, autorización y claims personalizados en todo el ecosistema.

4. **Flexibilidad Comercial**: Permite modelos de negocio sofisticados donde no todas las organizaciones contratan todas las funcionalidades. El sistema de módulos habilita ventas granulares por funcionalidad.

5. **Escalabilidad mediante Desacoplamiento**: La arquitectura orientada a eventos (ActiveMQ Artemis) permite que el ecosistema crezca sin crear dependencias síncronas entre sistemas.

6. **Auditoría y Compliance**: Proporciona trazabilidad completa de todos los cambios administrativos (altas, bajas, modificaciones de acceso), esencial para cumplimiento normativo.

#### **Qué Soluciona**

- **Problema de Onboarding Manual**: Elimina procesos manuales y descentralizados de alta de clientes. Todo el provisioning se ejecuta desde una única interfaz.

- **Inconsistencia de Roles**: Sin un catálogo maestro, cada aplicación podría definir roles con nombres diferentes para conceptos similares. InfoportOneAdmon garantiza coherencia.

- **Complejidad de Multi-Organización**: Resuelve el desafío técnico de usuarios que trabajan para múltiples organizaciones mediante claims, algo que la feature nativa de Organizations de Keycloak no soporta.

- **Falta de Gobierno de Acceso**: Sin InfoportOneAdmon, cada aplicación tendría que gestionar individualmente qué organizaciones tienen acceso, creando inconsistencias y agujeros de seguridad.

- **Acoplamiento Técnico**: Evita que las aplicaciones satélite dependan síncronamente de un sistema central de configuración. Los eventos permiten que cada app opere autónomamente con su copia local de datos maestros.

#### **Para Quién**

**Usuario Principal**: **Administradores de la Organización Propietaria**
- Responsables del onboarding de nuevos clientes (organizaciones)
- Gestores de seguridad que configuran accesos a aplicaciones y módulos
- Administradores de identidad que orquestan usuarios y roles

**Beneficiarios Indirectos**:
- **Equipos de Desarrollo de Aplicaciones Satélite**: Consumen datos maestros de organizaciones y roles sin implementar lógica administrativa compleja
- **Usuarios Finales de las Organizaciones Clientes**: Experimentan SSO fluido y acceso coherente a todas las aplicaciones del ecosistema
- **Dirección Ejecutiva**: Obtiene visibilidad y control total sobre el portfolio de aplicaciones y la base de clientes

**Tipo de Ecosistema**: Diseñado para organizaciones que gestionan un **portfolio de aplicaciones B2B propias** donde los clientes son otras empresas (no consumidores finales) y donde la Organización Propietaria necesita control total sobre el acceso y la seguridad.

### **1.2. Características y funcionalidades principales:**

InfoportOneAdmon ofrece seis módulos funcionales principales que cubren todo el ciclo de vida administrativo del ecosistema de aplicaciones:

#### **1.2.1. Gestión de Organizaciones (Clientes)**

Módulo que permite gestionar el ciclo de vida completo de las empresas clientes del ecosistema.

**Capacidades principales:**
- ✅ **Onboarding de Clientes**: Alta de nueva organización en un único paso, generando automáticamente su `SecurityCompanyId` (identificador único inmutable)
- 🛠️ **Gestión de Configuración**: Modificación de datos corporativos (nombre, dirección, datos fiscales)
- 🔌 **Baja de Organizaciones**: Bloqueo inmediato de acceso de una organización a todo el ecosistema mediante `AuditDeletionDate`. Al dar de baja una organización, se propaga automáticamente la baja de todos sus usuarios en Keycloak
- 🔄 **Alta de Organizaciones**: Reversión de una baja estableciendo `AuditDeletionDate = null`, reactivando el acceso de la organización y sus usuarios
- 🧾 **Auditoría Selectiva**: Trazabilidad de cambios críticos en seguridad y permisos (asignación/remoción de módulos, activación/desactivación, cambios de grupo). No se auditan cambios en datos básicos (nombre, dirección, contacto)
- 📢 **Publicación de Eventos**: Cada cambio genera un `OrganizationEvent` que se publica en ActiveMQ Artemis para sincronización con aplicaciones satélite

**Objetivo**: Centralizar el alta administrativa y técnica de clientes en un solo paso, garantizando coherencia en todo el ecosistema.

#### **1.2.2. Gestión de Grupos de Organizaciones**

Permite agrupar organizaciones lógicamente para facilitar la administración colectiva (ej: holdings, consorcios, franquicias).

**Capacidades principales:**
- 🆕 **Creación de Grupos**: Definir nuevos grupos de organizaciones (ej: "Grupo Logístico Peninsular", "Holding Financiero Norte")
- 🔄 **Asociación de Miembros**: Asignar o modificar el `GroupId` de una organización para incluirla en un grupo
- 🗑️ **Gestión del Ciclo de Vida**: Modificar grupos. Las aplicaciones satélite eliminan automáticamente grupos sin organizaciones
- 📢 **Propagación de Cambios**: Los cambios en grupos se publican mediante `OrganizationEvent` (incluyen campos `GroupId` y `GroupName`)

**Nota importante**: Los grupos NO tienen eventos propios; se propagan como parte del evento de organización.

#### **1.2.3. Gestión del Portfolio de Aplicaciones**

Permite registrar y configurar las aplicaciones satélite que forman parte del ecosistema.

**Capacidades principales:**
- 🆕 **Registro de Aplicación Frontend (Angular SPA)**: Alta como public client con `client_id` únicamente, habilitando PKCE para autenticación segura sin secretos
- 🔐 **Registro de Aplicación Backend (API)**: Alta como confidential client con generación de `client_id` y `client_secret`, con gestión segura de credenciales
- 🏷️ **Prefijo de Aplicación**: Cada aplicación tiene un prefijo único (ej: "STP" para Sintraport, "CRM" para CRM) que se utiliza para nomenclatura de roles y módulos. Los módulos usan "M" + prefijo (ej: MSTP_Trafico), los roles usan solo el prefijo (ej: STP_AsignadorTransporte)
- 🔄 **Gestión de Credenciales**: Administración segura de credenciales para confidential clients (backends). Las aplicaciones pueden tener una credencial CODE PKCE para acceso web y múltiples credenciales ClientCredentials para accesos externos
- 🔌 **Baja de Aplicaciones**: Dar de baja aplicaciones mediante `AuditDeletionDate`, revocando automáticamente sus credenciales en Keycloak
- 🧩 **Definición de Módulos**: Cada aplicación debe tener al menos un módulo. Los módulos representan agrupaciones funcionales vendibles por separado
- 📘 **Catálogo de Roles**: Definir qué roles existen dentro de cada aplicación (ej: "Tráfico", "Mensajería", "Administrador")
- ✨ **Sincronización de Datos**: Funcionalidad para enviar catálogos completos publicando eventos cuyo `Payload` contiene listas de objetos

**Nota sobre seguridad**: Las aplicaciones Angular (public clients) utilizan Authorization Code Flow with PKCE (S256) y no requieren almacenar secretos. Solo las APIs backend (confidential clients) requieren `client_secret`.

**Objetivo**: Mantener el inventario completo del portfolio de aplicaciones y sus capacidades (módulos y roles).

#### **1.2.4. Gestión de Módulos por Aplicación**

Define agrupaciones funcionales (módulos) dentro de cada aplicación y configura qué organizaciones tienen acceso a cada módulo.

**Capacidades principales:**
- 🧩 **Definición de Módulos**: Crear módulos para una aplicación siguiendo la nomenclatura "M" + RolePrefix (ej: si RolePrefix="STP", módulos como "MSTP_Trafico", "MSTP_Almacen", "MSTP_Facturacion")
- ⚙️ **Configuración de Acceso**: Asignar qué organizaciones tienen acceso a qué módulos (relación N:M)
- 📢 **Propagación de Cambios**: Los cambios se publican en eventos `ApplicationEvent` (catálogo de módulos) y `OrganizationEvent` (permisos de acceso)
- 📊 **Visibilidad de Contratación**: Permite a las aplicaciones saber exactamente qué funcionalidades están habilitadas para cada organización

**Regla de negocio**: Toda aplicación debe tener como mínimo un módulo. Los módulos son obligatorios.

**Objetivo**: Habilitar un modelo de negocio flexible donde no todas las organizaciones contratan todas las funcionalidades de una aplicación.

#### **1.2.5. Gestión de Definiciones de Roles (Catálogo)**

Define qué roles existen dentro de cada aplicación del ecosistema. Los roles se sincronizan como parte del `ApplicationEvent`.

**Capacidades principales:**
- 📘 **Definición de Roles**: Definir roles para una aplicación siguiendo la nomenclatura RolePrefix + nombre (ej: si RolePrefix="STP", roles como "STP_AsignadorTransporte", "STP_Supervisor", "STP_Operador")
- 🔌 **Baja de Roles**: Dar de baja roles mediante `AuditDeletionDate`. Los roles dados de baja no se pueden asignar a nuevos usuarios, pero los usuarios existentes pueden mantenerlos
- 🔄 **Sincronización**: Los roles se publican automáticamente con el `ApplicationEvent` (junto con módulos)
- 📋 **Catálogo Único**: Asegura que todos los sistemas usen nombres consistentes para los mismos conceptos de rol
- 🏷️ **Prefijos Únicos**: El uso de prefijos de aplicación evita conflictos cuando un usuario tiene roles en múltiples aplicaciones

**Principio clave**: InfoportOneAdmon define los roles (catálogo), las aplicaciones satélite los asignan a usuarios.

**Objetivo**: Garantizar coherencia en los nombres de roles y flexibilidad en su asignación por las aplicaciones.

#### **1.2.6. Integración Transparente con Keycloak**

Abstrae la complejidad de Keycloak. Los administradores no necesitan acceder directamente a su consola.

**Capacidades principales:**
- 🔄 **Sincronización de Usuarios**: Consumo de eventos `UserEvent` publicados por aplicaciones satélite para crear/actualizar usuarios en Keycloak
- 🧩 **Claims Personalizados**: Configuración automática del claim `c_ids` (company ids) con la lista de `SecurityCompanyId` de todas las organizaciones del usuario. Se define como **atributo multivalor** en Keycloak
- 🔑 **Mapeo de Protocol Mappers**: Configuración automática para incluir claims personalizados en tokens JWT
- 👥 **Gestión Multi-Organización**: Detección automática de usuarios existentes por email y fusión de organizaciones en el claim `c_ids`
- 🏢 **Single Realm**: Utiliza un único realm (InfoportOne) para todo el ecosistema, habilitando SSO real
- 🔐 **PKCE para SPAs**: Configuración automática de clientes públicos con PKCE (Proof Key for Code Exchange) para aplicaciones Angular, eliminando la necesidad de secretos en el cliente

**Nota importante**: No se utiliza la feature nativa de Organizations de Keycloak porque no soporta usuarios en múltiples organizaciones.

**Objetivo**: Proporcionar gobierno de identidad centralizado sin que los administradores necesiten conocer Keycloak.

#### **1.2.7. Arquitectura Orientada a Eventos (ActiveMQ Artemis)**

Mecanismo de comunicación asíncrona basado en el patrón **"State Transfer Event"** con especialización para usuarios multi-organización.

**Capacidades principales:**
- 📣 **Publicación de Eventos de Estado**: En lugar de notificar acciones (ej. "se creó X"), se notifica el estado final de la entidad
- 🔄 **Sincronización Robusta**: Los consumidores aplican lógica "upsert" (si existe actualiza, si no crea) o eliminan si `IsDeleted=true`
- 📋 **Tópicos por Entidad**: 
  - `infoportone.events.organization`: Organizaciones y grupos
  - `infoportone.events.application`: Aplicaciones, módulos y roles
  - `infoportone.events.user`: Usuarios publicados por apps satélite (consolidados por InfoportOneAdmon)
- 📦 **Payload como Lista**: Cada evento transporta un array de objetos, permitiendo sincronizaciones masivas
- 🔒 **Prevención de Duplicados**: Sistema de hash SHA-256 que evita publicar eventos idénticos consecutivos, reduciendo tráfico innecesario
- 🆔 **Trazabilidad**: Cada evento incluye `EventId` (UUID), `TraceId` (correlación), `OriginApplicationId` (emisor)
- 🧩 **Patrón Aggregator Integrado**: El Background Worker de InfoportOneAdmon consolida usuarios multi-organización y sincroniza directamente con Keycloak

**Flujo de Sincronización de Usuarios Multi-Organización:**

```mermaid
sequenceDiagram
    participant App1 as App Satélite 1<br/>(CRM Backend)
    participant App2 as App Satélite 2<br/>(ERP Backend)
    participant Topic1 as Tópico<br/>user
    participant BGWorker as InfoportOneAdmon<br/>Background Worker
    participant DB as Base de Datos<br/>InfoportOneAdmon
    participant KC as Keycloak

    Note over App1,App2: Creación de usuario en múltiples apps

    App1->>Topic1: UserEvent<br/>{email: "juan@example.com"<br/>companyId: 12345<br/>roles: ["CRM_Vendedor"]}
    App2->>Topic1: UserEvent<br/>{email: "juan@example.com"<br/>companyId: 67890<br/>roles: ["ERP_Contable"]}

    Topic1->>BGWorker: Consume eventos
    
    Note over BGWorker: Detecta email duplicado
    
    BGWorker->>DB: Consulta: ¿Más organizaciones<br/>y roles para juan@example.com?
    DB-->>BGWorker: Retorna c_ids: [12345, 67890, 11111]<br/>roles: ["CRM_Vendedor", "ERP_Contable", "BI_Analista"]
    
    Note over BGWorker: Consolida c_ids Y roles<br/>de todas las aplicaciones
    
    BGWorker->>KC: Busca usuario por email
    
    alt Usuario existe
        BGWorker->>KC: UPDATE user attributes<br/>c_ids: [12345, 67890, 11111]<br/>roles: ["CRM_Vendedor", "ERP_Contable", "BI_Analista"]
    else Usuario nuevo
        BGWorker->>KC: CREATE user<br/>con c_ids y roles consolidados
    end
    
    KC-->>BGWorker: OK
    BGWorker->>Topic1: ACK (confirma procesamiento)
```

**Ventajas de la arquitectura integrada**:
1. **Apps satélite simplificadas**: Solo publican eventos con su `companyId` local y sus roles específicos desde su backend
2. **Consistencia garantizada**: InfoportOneAdmon es fuente de verdad para relaciones usuario-organización y consolidación de roles
3. **Keycloak siempre sincronizado**: El claim `c_ids` refleja todas las organizaciones reales del usuario y los roles consolidados de todas las aplicaciones
4. **Evita conflictos de roles**: El uso de prefijos de aplicación en los roles (ej: CRM_Vendedor, ERP_Contable) garantiza unicidad
5. **Menor latencia**: Sincronización directa sin pasos intermedios
6. **Arquitectura simplificada**: Un solo proceso (InfoportOneAdmon) con Background Worker integrado

**Objetivo**: Garantizar desacoplamiento total entre InfoportOneAdmon y las aplicaciones satélite, permitiendo autonomía operacional mientras se mantiene consistencia en la identidad multi-organización.

### **1.3. Diseño y experiencia de usuario:**

> Proporciona imágenes y/o videotutorial mostrando la experiencia del usuario desde que aterriza en la aplicación, pasando por todas las funcionalidades principales.0

### **1.3.1. Modelo de Datos de Eventos (Event Schema)**

InfoportOneAdmon utiliza un modelo estandarizado para todos los eventos publicados en ActiveMQ Artemis, garantizando consistencia y facilidad de integración para las aplicaciones satélite.

#### **Estructura Base de Evento (Envelope)**

Todos los eventos comparten una estructura común (envelope) que contiene metadatos de trazabilidad y el payload específico:

```json
{
  "EventId": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
  "EventType": "USER_SYNC",
  "EventTimestamp": "2026-01-15T14:35:22.123Z",
  "TraceId": "trace-abc-123-xyz",
  "OriginApplicationId": "infoportone-admon",
  "SchemaVersion": "1.0",
  "Payload": [
    { /* objetos específicos del evento */ }
  ]
}
```

**Campos del Envelope:**
- `EventId` (UUID): Identificador único del evento, permite deduplicación
- `EventType` (string): Tipo de evento (`ORGANIZATION`, `APPLICATION`, `USER`, `USER_SYNC`)
- `EventTimestamp` (ISO 8601): Marca temporal de publicación en UTC
- `TraceId` (string): Identificador de correlación para debugging distribuido
- `OriginApplicationId` (string): Aplicación que publicó el evento
- `SchemaVersion` (string): Versión del esquema del payload (versionado evolutivo)
- `Payload` (array): Lista de objetos del tipo correspondiente

#### **Evento de Usuario (Apps Satélite → InfoportOneAdmon)**

**Tópico**: `infoportone.events.user`

**Publicado por**: Aplicaciones satélite cuando crean/modifican/eliminan usuarios

**Estructura del Payload**:
```json
{
  "EventId": "uuid-123",
  "EventType": "USER",
  "EventTimestamp": "2026-01-15T14:35:22Z",
  "TraceId": "trace-crm-001",
  "OriginApplicationId": "crm-app-backend",
  "SchemaVersion": "1.0",
  "Payload": [
    {
      "Email": "juan.perez@example.com",
      "FirstName": "Juan",
      "LastName": "Pérez",
      "SecurityCompanyId": 12345,
      "IsDeleted": false,
      "Roles": ["Sales", "Manager"],
      "Attributes": {
        "Department": "Ventas",
        "Phone": "+34 600 123 456",
        "EmployeeId": "EMP-001"
      },
      "CreatedBy": "admin@crm.com",
      "CreatedDate": "2026-01-15T14:30:00Z"
    }
  ]
}
```

**Campos del objeto USER:**
- `Email` (string, required): Email del usuario (único, clave de búsqueda)
- `FirstName` (string, required): Nombre
- `LastName` (string, required): Apellidos
- `SecurityCompanyId` (int, required): ID de la organización a la que pertenece en esta app
- `IsDeleted` (bool): Flag de soft delete (true = eliminar de Keycloak)
- `Roles` (string[]): Roles asignados en la aplicación origen
- `Attributes` (object): Atributos personalizados adicionales
- `CreatedBy` (string): Usuario que creó el registro
- `CreatedDate` (ISO 8601): Fecha de creación

**Nota importante sobre consolidación**: 
- En esta fase, el evento contiene **solo una organización** (`SecurityCompanyId`). La consolidación multi-organización la realiza el Background Worker de InfoportOneAdmon
- El Background Worker sincroniza directamente con Keycloak mediante Admin API, configurando el atributo `c_ids` como **atributo multivalor** (array de strings en la API de Keycloak) que contiene el array completo de todas las organizaciones del usuario
- No se publica un evento adicional tras la consolidación

#### **Evento de Organización**

**Tópico**: `infoportone.events.organization`

**Publicado por**: InfoportOneAdmon (módulo de Organizaciones)

**Consumido por**: Todas las aplicaciones satélite

**Estructura del Payload**:
```json
{
  "EventId": "uuid-789",
  "EventType": "ORGANIZATION",
  "EventTimestamp": "2026-01-15T15:00:00Z",
  "TraceId": "trace-admin-001",
  "OriginApplicationId": "infoportone-admon",
  "SchemaVersion": "1.0",
  "Payload": [
    {
      "SecurityCompanyId": 12345,
      "Name": "ACME Corporation",
      "TaxId": "A12345678",
      "Address": "Calle Mayor 123",
      "City": "Madrid",
      "Country": "España",
      "IsDeleted": false,
      "GroupId": 100,
      "GroupName": "Holding Empresarial",
      "Apps": [
        {
          "AppId": 5,
          "DatabaseName": "org_12345_crm",
          "AccessibleModules": [10, 11]
        },
        {
          "AppId": 8,
          "DatabaseName": "org_12345_erp",
          "AccessibleModules": [25, 26, 27]
        }
      ],
      "CreatedDate": "2025-06-01T10:00:00Z",
      "ModifiedDate": "2026-01-15T15:00:00Z"
    }
  ]
}
```

**Campos del objeto ORGANIZATION:**
- `SecurityCompanyId` (int, required): Identificador único de la organización
- `Name` (string, required): Nombre de la organización
- `TaxId` (string): Identificador fiscal
- `Address`, `City`, `Country` (string): Datos de ubicación
- `IsDeleted` (bool): Flag de soft delete
- `GroupId` (int, optional): ID del grupo al que pertenece
- `GroupName` (string, optional): Nombre del grupo
- `Apps` (array): **Lista de aplicaciones con acceso y configuración específica de esta organización**
  - `AppId` (int): ID de la aplicación
  - `DatabaseName` (string): Nombre de la base de datos específica para esta org y app
  - `AccessibleModules` (int[]): IDs de los módulos a los que tiene acceso esta organización
- `CreatedDate`, `ModifiedDate` (ISO 8601): Fechas de auditoría

**Ventajas de este diseño:**
- ✅ **Cohesión perfecta**: Toda la información de permisos de una organización está en su propio evento
- ✅ **Eficiencia**: Cambiar acceso a módulos de una org = 1 solo OrganizationEvent (no N ApplicationEvents)
- ✅ **Simplicidad**: Apps satélite procesan solo eventos de organizaciones relevantes
- ✅ **Onboarding natural**: Alta de organización incluye directamente qué puede usar

#### **Evento de Aplicación (Catálogo de Módulos y Roles)**

**Tópico**: `infoportone.events.application`

**Propósito**: Define QUÉ ES la aplicación (su catálogo de módulos y roles disponibles). NO incluye información de permisos por organización, eso va en OrganizationEvent.

**Estructura del Payload**:
```json
{
  "EventId": "uuid-999",
  "EventType": "APPLICATION",
  "EventTimestamp": "2026-01-15T16:00:00Z",
  "TraceId": "trace-admin-002",
  "OriginApplicationId": "infoportone-admon",
  "SchemaVersion": "1.0",
  "Payload": [
    {
      "ApplicationId": 5,
      "Name": "CRM Application",
      "RolePrefix": "CRM",
      "ClientId": "crm-app-backend",
      "Modules": [
        {
          "ApplicationModuleId": 10,
          "Name": "MCRM_Sales",
          "Description": "Gestión de ventas"
        },
        {
          "ApplicationModuleId": 11,
          "Name": "MCRM_Reporting",
          "Description": "Reportes avanzados"
        }
      ],
      "Roles": [
        {
          "RoleId": 20,
          "Name": "CRM_Sales",
          "Description": "Vendedor"
        },
        {
          "RoleId": 21,
          "Name": "CRM_Manager",
          "Description": "Gerente"
        }
      ]
    }
  ]
}
```

**Campos del objeto APPLICATION:**
- `ApplicationId` (int): Identificador único de la aplicación
- `Name` (string): Nombre de la aplicación
- `RolePrefix` (string): Prefijo para nomenclatura de roles y módulos
- `ClientId` (string): OAuth2 client_id
- `Modules` (array): Catálogo de módulos disponibles (sin permisos)
- `Roles` (array): Catálogo de roles disponibles

**Nota importante**: Este evento define el CATÁLOGO de la aplicación. Los permisos de acceso por organización se definen en el `OrganizationEvent`.

#### **Patrones de Procesamiento de Eventos**

**Para consumidores (Apps Satélite y Workers):**

```csharp
// Pseudocódigo de consumo idempotente
public async Task ProcessEvent(EventEnvelope envelope)
{
    foreach (var item in envelope.Payload)
    {
        if (item.IsDeleted)
        {
            await DeleteLocalEntity(item);
        }
        else
        {
            // Upsert: Update si existe, Insert si no
            await UpsertLocalEntity(item);
        }
    }
}
```

**Validación de esquema:**
```csharp
public bool ValidateEventSchema(EventEnvelope envelope)
{
    // Validar que SchemaVersion es compatible
    if (!IsSupportedVersion(envelope.SchemaVersion))
        return false;
    
    // Validar campos requeridos según tipo de evento
    if (envelope.EventType == "USER_SYNC")
    {
        foreach (var user in envelope.Payload)
        {
            if (string.IsNullOrEmpty(user.Email)) return false;
            if (user.CompanyIds == null || user.CompanyIds.Length == 0) return false;
        }
    }
    
    return true;
}
```

#### **Versionado de Esquemas**

El sistema soporta evolución de esquemas mediante el campo `SchemaVersion`:

- **v1.0**: Versión inicial
- **v1.1**: Podría agregar campos opcionales sin romper compatibilidad
- **v2.0**: Cambios que rompen compatibilidad (requieren actualización de consumidores)

**Estrategia de migración:**
1. Publicar eventos con ambas versiones durante período de transición
2. Consumidores implementan lógica para soportar múltiples versiones
3. Deprecación gradual de versiones antiguas con notificaciones

### **1.4. Instrucciones de instalación:**

InfoportOneAdmon está construido sobre el framework Helix6 para .NET 8. A continuación se detallan los pasos para instalar y poner en marcha el proyecto en un entorno de desarrollo local.

#### **1.4.1. Requisitos Previos**

**Software necesario**:
- **.NET 8 SDK** (8.0 o superior)
- **Visual Studio 2022** (17.8+) o **Visual Studio Code** con extensión C#
- **PostgreSQL 15+**
- **Node.js 20+** y **npm** (para el frontend Angular)
- **Docker Desktop** (opcional, para ejecutar ActiveMQ Artemis y Keycloak localmente)
- **Git** para control de versiones

**Puertos requeridos** (configurables):
- `5000`: API Backend (HTTP)
- `5001`: API Backend (HTTPS)
- `4200`: Angular Frontend (desarrollo)
- `61616`: ActiveMQ Artemis (AMQP)
- `8080`: Keycloak

#### **1.4.2. Instalación del Backend (InfoportOneAdmon.Api)**

**Paso 1: Clonar el repositorio**
```powershell
git clone https://github.com/organizacion/InfoportOneAdmon.git
cd InfoportOneAdmon
```

**Paso 2: Restaurar dependencias NuGet**
```powershell
cd InfoportOneAdmon.Api
dotnet restore
```

**Dependencias principales de Helix6**:
- `Helix6.Base` (9.0.2) - Framework base
- `Helix6.Base.Domain` (9.0.2) - Dominio y contratos
- `Helix6.Base.Utils` (9.0.2) - Utilidades
- `Microsoft.EntityFrameworkCore` (9.0.2)
- `Mapster` (7.4.0)
- `Serilog.AspNetCore` (9.0.2)

**Paso 3: Configurar la cadena de conexión**

Editar `appsettings.Development.json`:
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Database=InfoportOneAdmon;Username=postgres;Password=***;",
    "ConnectionStringType": "PostgreSQL"
  },
  "ApplicationContext": {
    "ApplicationName": "InfoportOneAdmon",
    "DBMSType": "PostgreSQL",
    "RolPrefixes": ["InfoportOne_"]
  },
  "Keycloak": {
    "AdminApiUrl": "http://localhost:8080/admin/realms/InfoportOne",
    "Realm": "InfoportOne",
    "ClientId": "infoportone-admin",
    "ClientSecret": "***"
  },
  "ActiveMQ": {
    "BrokerUri": "tcp://localhost:61616",
    "Username": "artemis",
    "Password": "artemis",
    "Topics": {
      "Organization": "infoportone.events.organization",
      "Application": "infoportone.events.application",
      "User": "infoportone.events.user"
    }
  }
}
```

> **Gestión de secretos en desarrollo**: Para desarrollo local, utilizar `dotnet user-secrets` en lugar de almacenar secretos en archivos:
> ```powershell
> dotnet user-secrets init
> dotnet user-secrets set "Keycloak:ClientSecret" "tu-secret-aqui"
> dotnet user-secrets set "ActiveMQ:Password" "tu-password-aqui"
> ```

**Paso 4: Crear y migrar la base de datos**

El proyecto utiliza **Entity Framework Core Code First**. Para crear la base de datos y aplicar las migraciones:

```powershell
# Instalar herramientas de EF Core (si no están instaladas)
dotnet tool install --global dotnet-ef

# Crear la migración inicial (si no existe)
dotnet ef migrations add InitialCreate --project InfoportOneAdmon.Data --startup-project InfoportOneAdmon.Api

# Aplicar migraciones a la base de datos
dotnet ef database update --project InfoportOneAdmon.Data --startup-project InfoportOneAdmon.Api
```

**Estructura de tablas creadas** (principales):
- `Organization`: Entidades de organizaciones clientes
- `OrganizationGroup`: Agrupaciones de organizaciones
- `Application`: Aplicaciones satélite registradas
- `ApplicationModule`: Módulos funcionales por aplicación
- `OrganizationApplicationModule`: Relación N:M entre módulos y organizaciones
- `ApplicationRole`: Catálogo de roles
- `AuditLog`: Auditoría selectiva de cambios críticos (sin campos JSON)
- `EventHash`: Control de eventos duplicados

> **Nota Helix6 - Auditoría Dual**: 
> - **Auditoría Base (Helix6)**: Todas las entidades heredan de `IEntityBase` e incluyen automáticamente campos de auditoría (`AuditCreationUser`, `AuditModificationUser`, `AuditCreationDate`, `AuditModificationDate`, `AuditDeletionDate`) que registran TODOS los cambios. Ver detalles en [Helix6_Backend_Architecture.md - Sección 2.5](Helix6_Backend_Architecture.md#25-proyectodatamodel-capa-de-modelo-de-datos).
> - **Auditoría Selectiva (AUDITLOG)**: Tabla adicional que registra SOLO cambios críticos en seguridad y permisos con contexto de acción específico. No duplica la funcionalidad de Helix6, sino que complementa con trazabilidad de acciones de negocio críticas.

**Paso 5: Poblar datos semilla (seed data)**

El proyecto puede incluir un seeder inicial. Ejecutar:

```powershell
dotnet run --project InfoportOneAdmon.Api --seed
```

O ejecutar scripts SQL manualmente:
```sql
-- Insertar organización propietaria
INSERT INTO Organization (Name, TaxId, SecurityCompanyId)
VALUES ('Organización Propietaria', 'A12345678', 1);

-- Insertar aplicación de ejemplo
INSERT INTO Application (Name, ClientId, ClientType)
VALUES ('CRM App', 'crm-app-frontend', 'Public');
```

**Paso 6: Ejecutar el backend**

```powershell
dotnet run --project InfoportOneAdmon.Api
```

La API estará disponible en:
- HTTP: `http://localhost:5000`
- HTTPS: `https://localhost:5001`
- Swagger UI: `https://localhost:5001/swagger`

> **Configuración de Serilog**: Los logs se escriben en `logs/log-{Date}.txt` y en consola. Configuración detallada en `appsettings.json` sección `Serilog`. Ver [Helix6_Backend_Architecture.md - Sección 7](Helix6_Backend_Architecture.md#7-bootstrapping-y-programcs) para detalles del bootstrapping.

#### **1.4.3. Instalación del Frontend (Angular)**

**Paso 1: Instalar dependencias**
```powershell
cd InfoportOneAdmon.Frontend
npm install
```

**Dependencias principales**:
- `@angular/core`: 20.x
- `@angular/router`: 20.x
- `@angular/common/http`: 20.x
- `oidc-client-ts`: Autenticación OAuth2/OIDC

**Paso 2: Configurar el entorno**

Editar `src/environments/environment.development.ts`:
```typescript
export const environment = {
  production: false,
  apiUrl: 'https://localhost:5001/api',
  keycloak: {
    issuer: 'http://localhost:8080/realms/InfoportOne',
    clientId: 'infoportone-admin-frontend',
    redirectUri: 'http://localhost:4200/callback',
    scope: 'openid profile email',
    responseType: 'code',
    pkce: true
  }
};
```

**Paso 3: Ejecutar el frontend**
```powershell
npm start
```

El frontend estará disponible en: `http://localhost:4200`

#### **1.4.4. Instalación de ActiveMQ Artemis (Message Broker)**

**Opción 1: Docker (Recomendado para desarrollo)**

```powershell
docker run -d --name artemis `
  -p 61616:61616 `
  -p 8161:8161 `
  -e ARTEMIS_USERNAME=artemis `
  -e ARTEMIS_PASSWORD=artemis `
  apache/activemq-artemis:latest
```

Consola web: `http://localhost:8161` (usuario: `artemis`, password: `artemis`)

**Opción 2: Instalación local**

1. Descargar desde https://activemq.apache.org/components/artemis/
2. Extraer y ejecutar:
```powershell
cd apache-artemis-2.31.0\bin
.\artemis create mybroker
cd ..\mybroker\bin
.\artemis run
```

**Configuración de tópicos**:
Los tópicos se crean automáticamente cuando InfoportOneAdmon publica el primer evento. No requiere configuración previa.

#### **1.4.5. Instalación de Keycloak (Identity Provider)**

**Opción 1: Docker (Recomendado para desarrollo)**

```powershell
docker run -d --name keycloak `
  -p 8080:8080 `
  -e KEYCLOAK_ADMIN=admin `
  -e KEYCLOAK_ADMIN_PASSWORD=admin `
  quay.io/keycloak/keycloak:23.0 `
  start-dev
```

Consola de administración: `http://localhost:8080` (usuario: `admin`, password: `admin`)

**Opción 2: Instalación local**

1. Descargar desde https://www.keycloak.org/downloads
2. Ejecutar:
```powershell
cd keycloak-23.0.0\bin
.\kc.bat start-dev
```

**Configuración inicial de Keycloak**:

1. **Crear el realm `InfoportOne`**:
   - Login en consola de administración
   - Crear nuevo realm: `InfoportOne`

2. **Registrar el cliente de InfoportOneAdmon**:
   ```json
   {
     "clientId": "infoportone-admin-frontend",
     "enabled": true,
     "publicClient": true,
     "redirectUris": ["http://localhost:4200/*"],
     "webOrigins": ["http://localhost:4200"],
     "standardFlowEnabled": true,
     "pkceCodeChallengeMethod": "S256"
   }
   ```

3. **Configurar Protocol Mapper para `c_ids`**:
   - Crear mapper de tipo "User Attribute"
   - Nombre: `company-ids-mapper`
   - User Attribute: `c_ids`
   - Token Claim Name: `c_ids`
   - Claim JSON Type: Array
   - **Multivalued**: ON (✅ importante: habilita manejo de array de organizaciones)
   - Add to ID token: ON
   - Add to access token: ON

> **Nota técnica**: El atributo `c_ids` se define en Keycloak como **atributo multivalor**. Al sincronizar usuarios mediante la Admin API, debe enviarse como un array de strings. Esto permite almacenar múltiples SecurityCompanyIds para usuarios que pertenecen a varias organizaciones.

> **Implementación de claims en Helix6**: El framework proporciona `KeyCloakUserClaimsMapping` que maneja automáticamente la lectura del claim `c_ids` y otros claims de Keycloak. Ver [Helix6_Backend_Architecture.md - Sección 10.5](Helix6_Backend_Architecture.md#105-mapeo-de-claims-según-identity-server).

#### **1.4.6. Verificación de la Instalación**

**Test 1: API Backend**
```powershell
curl https://localhost:5001/api/health
# Respuesta esperada: {"status": "Healthy"}
```

**Test 2: Swagger**
- Abrir navegador: `https://localhost:5001/swagger`
- Verificar que aparecen todos los endpoints generados

**Test 3: Keycloak**
- Login en `http://localhost:8080`
- Verificar realm `InfoportOne`

**Test 4: ActiveMQ Artemis**
- Abrir `http://localhost:8161`
- Verificar broker activo

**Test 5: Frontend Angular**
- Abrir `http://localhost:4200`
- Verificar redirección a Keycloak para login

**Test 6: Flujo completo (End-to-End)**
1. Login en el frontend Angular
2. Crear una organización nueva
3. Verificar en la base de datos que se creó el registro
4. Verificar en Artemis que se publicó el evento `OrganizationEvent`
5. Verificar en la tabla `EventHash` el hash del evento

#### **1.4.7. Troubleshooting Común**

**Problema**: Error de conexión a PostgreSQL
```
Npgsql.NpgsqlException: Connection refused...
```
**Solución**: Verificar que PostgreSQL está ejecutándose y que el puerto 5432 está abierto. Revisar credenciales y permisos de usuario.

**Problema**: Error de autenticación con Keycloak
```
IDX10501: Signature validation failed. Unable to match key...
```
**Solución**: Limpiar caché de claves públicas y reiniciar la API. Verificar que el `issuer` en `appsettings.json` coincide exactamente con el de Keycloak.

**Problema**: Eventos no se publican en Artemis
```
System.NullReferenceException at EventPublisher.Publish()
```
**Solución**: Verificar que ActiveMQ Artemis está ejecutándose y que las credenciales en `appsettings.json` son correctas.

**Problema**: Endpoints no aparecen en Swagger
**Solución**: Regenerar código con Helix Generator:
```powershell
cd InfoportOneAdmon.HelixGenerator
dotnet run
```

> **Documentación completa de arquitectura**: Para comprender el flujo de datos, ciclo de vida de peticiones y patrones implementados, consultar [Helix6_Backend_Architecture.md](Helix6_Backend_Architecture.md).

---

## 2. Arquitectura del Sistema

### **2.1. Diagramas de arquitectura:**

La arquitectura de InfoportOneAdmon se presenta en múltiples niveles de detalle, desde una vista general del contexto hasta flujos específicos de casos de uso críticos.

---

#### **2.1.1. Diagrama de Contexto del Sistema**

**Descripción**: Vista de alto nivel que muestra InfoportOneAdmon como caja negra y sus interacciones con actores externos y sistemas de terceros. Este diagrama responde a la pregunta: *¿Qué hace el sistema y con quién interactúa?*

```mermaid
graph TB
    Admin[👤 Administradores<br/>Organización Propietaria]
    EndUsers[👥 Usuarios Finales<br/>Organizaciones Clientes]
    
    InfoportOne[🎯 InfoportOneAdmon<br/>Plataforma de Gobierno<br/>del Ecosistema]
    
    Keycloak[🔐 Keycloak<br/>Identity Provider]
    Artemis[📨 ActiveMQ Artemis<br/>Message Broker]
    SatelliteApps[📱 Aplicaciones Satélite<br/>CRM, ERP, BI, etc.]
    
    Admin -->|Gestiona organizaciones,<br/>aplicaciones, roles y módulos| InfoportOne
    
    InfoportOne -->|Sincroniza usuarios<br/>y configuración OAuth2| Keycloak
    InfoportOne -->|Publica eventos de<br/>organizaciones y aplicaciones| Artemis
    
    Artemis -->|Sincroniza datos maestros<br/>Orgs, Roles, Módulos| SatelliteApps
    
    SatelliteApps -->|Publica eventos<br/>de usuarios| Artemis
    Artemis -->|Eventos de usuarios<br/>para consolidación| InfoportOne
    
    EndUsers -->|Autenticación SSO| Keycloak
    Keycloak -->|Token JWT con c_ids| EndUsers
    EndUsers -->|Accede con token| SatelliteApps
    
    style InfoportOne fill:#4A90E2,color:#fff
    style Keycloak fill:#90C695,color:#fff
    style Artemis fill:#E89B3C,color:#fff
    style SatelliteApps fill:#9B72AA,color:#fff
    style Admin fill:#FFE5B4
    style EndUsers fill:#FFE5B4
```

**Elementos clave**:
- **Administradores**: Personal de la Organización Propietaria que gestiona el ecosistema
- **InfoportOneAdmon**: Sistema central de gobierno y configuración
- **Keycloak**: Proveedor de identidad centralizado (OAuth2/OIDC)
- **ActiveMQ Artemis**: Bus de mensajería para comunicación asíncrona
- **Aplicaciones Satélite**: Apps de negocio que consumen datos maestros y autentican usuarios
- **Usuarios Finales**: Empleados de las organizaciones clientes que usan las aplicaciones

---

#### **2.1.2. Diagrama de Contenedores (Componentes Principales)**

**Descripción**: Descompone InfoportOneAdmon en sus contenedores/servicios principales, mostrando la arquitectura física del sistema. Este diagrama responde: *¿Qué componentes conforman el sistema y cómo se comunican?*

```mermaid
graph TB
    subgraph "Capa de Presentación"
        FrontendUI[🖥️ Frontend Angular 20<br/>Interfaz Administrativa<br/>Public Client - PKCE]
    end
    
    subgraph "InfoportOneAdmon - Proceso Único"
        API[🔌 API REST .NET 8<br/>Framework Helix6<br/>Endpoints CRUD + Event Publisher]
        
        BGWorker[⚙️ Background Worker<br/>Consolidación de usuarios<br/>+ Sincronización Keycloak]
        
        DB[(💾 PostgreSQL<br/>Base de Datos Core<br/>Fuente de la Verdad)]
    end
    
    subgraph "Infraestructura Externa"
        Artemis[📨 ActiveMQ Artemis<br/>4 Tópicos principales<br/>Mensajería persistente]
        
        Keycloak[🔐 Keycloak<br/>Realm: InfoportOne<br/>Admin API REST]
    end
    
    subgraph "Aplicaciones Satélite"
        SatAppBE[🔌 Backend API<br/>Event Publisher<br/>+ Background Worker]
        SatAppFE[🖥️ Frontend<br/>Angular]
        SatCache[(⚡ Caché Local<br/>Orgs, Roles, Módulos)]
    end
    
    Admin[👤 Administrador] -->|HTTPS| FrontendUI
    FrontendUI -->|REST API<br/>JWT Bearer| API
    
    API -->|EF Core| DB
    API -->|Publica eventos<br/>org, app| Artemis
    
    Artemis -->|Topic: user| BGWorker
    BGWorker -->|Consulta Orgs| DB
    BGWorker -->|Keycloak Admin API<br/>CREATE/UPDATE users| Keycloak
    
    Artemis -->|Topics: org, app| SatAppBE
    SatAppBE -->|Actualiza| SatCache
    SatAppBE -->|Publica eventos<br/>user| Artemis
    
    API -.->|Registra Clients OAuth2| Keycloak
    SatAppFE -->|Consume API| SatAppBE
    
    style API fill:#4A90E2,color:#fff
    style BGWorker fill:#5DADE2,color:#fff
    style DB fill:#9B59B6,color:#fff
    style Artemis fill:#E74C3C,color:#fff
    style Keycloak fill:#2ECC71,color:#fff
    style FrontendUI fill:#3498DB,color:#fff
    style SatAppBE fill:#95A5A6,color:#fff
    style SatAppFE fill:#7F8C8D,color:#fff
    style SatCache fill:#BDC3C7,color:#fff
```

**Responsabilidades por componente**:

**InfoportOneAdmon**:
- **Frontend Angular**: Interfaz administrativa para gestión de orgs, apps, roles y módulos
- **API REST**: Lógica de negocio, validaciones, persistencia, publicación de eventos de organizaciones y aplicaciones
- **Background Worker**: Proceso en background que actúa como consumidor de eventos de usuarios, los consolida y sincroniza directamente con Keycloak (patrón Aggregator - NO publica eventos adicionales)
- **Base de Datos Core**: Fuente de verdad para organizaciones, aplicaciones, roles, módulos y auditoría

**Aplicaciones Satélite**:
- **Backend API**: Lógica de negocio específica, publica eventos de usuario cuando se dan de alta
- **Background Worker**: Proceso en background suscrito a eventos de organizaciones y aplicaciones
- **Frontend**: Interfaz de usuario de la aplicación (Angular)
- **Caché Local**: Almacenamiento local de organizaciones, roles y módulos sincronizados

**Infraestructura**:
- **ActiveMQ Artemis**: Bus de mensajería que garantiza entrega eventual y desacoplamiento total
- **Keycloak**: IdP centralizado, genera tokens JWT con claim c_ids, implementa SSO

---

#### **2.1.3. Flujo de Sincronización de Usuarios Multi-Organización**

**Descripción**: Flujo detallado del caso de uso más complejo del sistema: cómo se consolidan usuarios que pertenecen a múltiples organizaciones, se consolidan sus roles de distintas aplicaciones y se sincronizan con Keycloak para generar el claim `c_ids` y asignar roles consolidados. Este es el diferenciador clave del sistema.

```mermaid
sequenceDiagram
    participant CRM as 📱 CRM Backend<br/>(Sat App)
    participant ERP as 📱 ERP Backend<br/>(Sat App)
    participant BI as 📱 BI Backend<br/>(Sat App)
    participant TopicUser as 📨 Topic: user
    participant BGWorker as ⚙️ InfoportOneAdmon<br/>Background Worker
    participant DB as 💾 Base de Datos
    participant KC as 🔐 Keycloak

    Note over CRM,BI: Fase 1: Apps satélite publican eventos de usuarios desde su backend
    
    CRM->>TopicUser: UserEvent<br/>{email: "juan@example.com"<br/>companyId: 12345<br/>roles: ["CRM_Vendedor", "CRM_Manager"]}
    ERP->>TopicUser: UserEvent<br/>{email: "juan@example.com"<br/>companyId: 67890<br/>roles: ["ERP_Contable"]}
    BI->>TopicUser: UserEvent<br/>{email: "juan@example.com"<br/>companyId: 11111<br/>roles: ["BI_Analista"]}
    
    Note over TopicUser,BGWorker: Fase 2: Background Worker consolida usuarios multi-organización y roles
    
    TopicUser->>BGWorker: Consume eventos (3 mensajes)
    BGWorker->>BGWorker: Detecta email duplicado<br/>"juan@example.com"
    
    BGWorker->>DB: SELECT SecurityCompanyId, Roles<br/>WHERE Email = 'juan@example.com'
    DB-->>BGWorker: c_ids: [12345, 67890, 11111]<br/>roles: ["CRM_Vendedor", "CRM_Manager",<br/>"ERP_Contable", "BI_Analista"]
    
    BGWorker->>DB: SELECT * FROM Organization<br/>WHERE SecurityCompanyId IN (12345, 67890, 11111)
    DB-->>BGWorker: Valida que todas existen y están dadas de alta<br/>(AuditDeletionDate IS NULL)
    
    BGWorker->>BGWorker: Construye c_ids completo<br/>y roles consolidados con prefijos
    
    Note over BGWorker,KC: Fase 3: Sincronización directa con Keycloak
    
    BGWorker->>BGWorker: Valida datos del usuario
    
    Worker->>KC: GET /users?email=juan@example.com
    
    alt Usuario NO existe en Keycloak
        KC-->>BGWorker: 404 Not Found
        BGWorker->>KC: POST /users<br/>{email, firstName, lastName,<br/>attributes: {c_ids: [12345, 67890, 11111]}<br/>roles: ["CRM_Vendedor", "CRM_Manager",<br/>"ERP_Contable", "BI_Analista"]}
        KC-->>BGWorker: 201 Created
    else Usuario YA existe
        KC-->>BGWorker: 200 OK + User data
        BGWorker->>BGWorker: Fusiona c_ids actuales con nuevos<br/>y consolida roles de todas las apps<br/>Elimina duplicados
        BGWorker->>KC: PUT /users/{id}<br/>{attributes: {c_ids: [12345, 67890, 11111]}<br/>roles: ["CRM_Vendedor", "CRM_Manager",<br/>"ERP_Contable", "BI_Analista"]}
        KC-->>BGWorker: 204 No Content
    end
    
    BGWorker->>TopicUser: ACK (confirma procesamiento exitoso)
    
    Note over KC: Keycloak tiene usuario con c_ids completo<br/>y roles consolidados de todas las aplicaciones<br/>Listo para generar tokens JWT
```

**Fases del proceso**:
1. **Publicación desde backend**: Cada app satélite publica eventos de usuario desde su backend cuando se da de alta un usuario, con su `companyId` local y los roles que asigna a ese usuario (usando prefijos de aplicación)
2. **Consolidación en background**: El Background Worker de InfoportOneAdmon consume eventos, detecta duplicados por email y consulta la BD para construir la lista completa de organizaciones y consolidar todos los roles del usuario de las distintas aplicaciones
3. **Sincronización directa**: El mismo Background Worker sincroniza inmediatamente con Keycloak usando Admin API, actualizando el claim `c_ids` y asignando todos los roles consolidados con prefijos únicos

**Ventajas del patrón**:
- Apps satélite solo publican eventos simples con sus roles locales, sin conocer multi-organización ni roles de otras apps
- InfoportOneAdmon mantiene la fuente de verdad de relaciones usuario-organización y consolidación de roles
- El uso de prefijos de aplicación evita conflictos de nombres de roles entre aplicaciones
- Background Worker integrado simplifica la arquitectura (no hay componentes separados)
- Keycloak siempre tiene el claim `c_ids` actualizado y los roles consolidados de todas las aplicaciones
- Tolerante a fallos: eventos persistentes garantizan eventual consistency

---

#### **2.1.4. Arquitectura de Eventos (Tópicos y Patrones)**

**Descripción**: Vista centrada en ActiveMQ Artemis que muestra todos los tópicos, sus publishers, consumers y el patrón de consolidación. Ilustra el desacoplamiento total entre componentes.

```mermaid
graph LR
    subgraph "Publishers"
        IOAPI[🔌 InfoportOneAdmon<br/>API]
        CRM[📱 CRM Backend]
        ERP[📱 ERP Backend]
        BI[📱 BI Backend]
    end
    
    subgraph "ActiveMQ Artemis - Message Broker"
        T1[📣 infoportone.events<br/>.organization<br/><br/>Schema: OrganizationEvent<br/>Payload: Organization]
        T2[📣 infoportone.events<br/>.application<br/><br/>Schema: ApplicationEvent<br/>Payload: Application]
        T3[📣 infoportone.events<br/>.user<br/><br/>Schema: UserEvent<br/>Payload: User]
    end
    
    subgraph "Consumers"
        SatBG[📱 Apps Satélite<br/>Background Workers<br/>CRM, ERP, BI]
        IOBG[⚙️ InfoportOneAdmon<br/>Background Worker]
    end
    
    IOAPI -->|Publica cambios<br/>en Orgs| T1
    IOAPI -->|Publica cambios en Apps<br/>Módulos, Roles| T2
    
    CRM -->|Publica usuarios<br/>locales| T3
    ERP -->|Publica usuarios<br/>locales| T3
    BI -->|Publica usuarios<br/>locales| T3
    
    T1 -->|Sincroniza caché<br/>local| SatBG
    T2 -->|Sincroniza caché<br/>local| SatBG
    
    T3 -->|Consolida y sincroniza<br/>con Keycloak| IOBG
    
    style T1 fill:#48C9B0,color:#fff
    style T2 fill:#5DADE2,color:#fff
    style T3 fill:#F39C12,color:#fff
    style IOAPI fill:#3498DB,color:#fff
    style IOBG fill:#9B59B6,color:#fff
    style SatBG fill:#95A5A6,color:#fff
```

**Características clave**:
- **Patrón State Transfer Event**: Los eventos contienen el estado completo de la entidad, no solo notificaciones de cambio
- **Payload como Array**: Permite sincronizaciones masivas (ej: catálogo completo de aplicaciones con sus módulos y roles)
- **Segregación de tópicos**: Cada entidad tiene su tópico, facilitando suscripciones selectivas
- **Solo 3 tópicos activos**: `organization`, `application`, `user` (integración directa con Keycloak desde Background Worker)
- **Mensajería persistente**: ActiveMQ garantiza durabilidad y entrega eventual
- **Background Workers integrados**: 
  - **InfoportOneAdmon**: Worker suscrito a `user`, consolida y sincroniza directamente con Keycloak
  - **Apps Satélite**: Workers suscritos a `organization` y `application`, publican `user` desde su backend

**Patrón de Consumo Idempotente** (implementado por todos los consumers):
```
foreach (item in event.Payload):
    if (item.IsDeleted):
        DELETE FROM local_cache WHERE id = item.Id
    else:
        UPSERT INTO local_cache VALUES (item)
```

---

#### **2.1.5. Flujo de Autenticación y Autorización**

**Descripción**: Secuencia completa de autenticación de un usuario final, desde el login inicial hasta la validación del token JWT con el claim `c_ids` en una aplicación satélite. Muestra cómo funciona el SSO y la seguridad multi-organización.

```mermaid
sequenceDiagram
    participant User as 👤 Usuario Final
    participant Browser as 🌐 Navegador
    participant AppFE as 📱 App Satélite (Angular)
    participant KC as 🔐 Keycloak
    participant AppBE as 🔌 API Backend App

    Note over User,AppBE: Fase 1: Autenticación inicial (Authorization Code + PKCE)
    
    User->>Browser: Accede a https://crm.empresa.com
    Browser->>AppFE: GET /
    AppFE-->>Browser: index.html + app.js
    
    AppFE->>AppFE: Genera code_verifier (random)<br/>Calcula code_challenge = SHA256(verifier)
    
    AppFE->>Browser: Redirige a Keycloak
    Browser->>KC: GET /auth?client_id=crm-app<br/>&redirect_uri=https://crm.empresa.com/callback<br/>&response_type=code<br/>&code_challenge={hash}<br/>&code_challenge_method=S256
    
    KC-->>Browser: Formulario de login
    User->>Browser: Ingresa credenciales
    Browser->>KC: POST /auth (usuario + contraseña)
    
    KC->>KC: Valida credenciales<br/>Genera authorization_code
    
    KC-->>Browser: Redirige a https://crm.empresa.com/callback?code=ABC123
    Browser->>AppFE: GET /callback?code=ABC123
    
    Note over AppFE,KC: Fase 2: Intercambio de código por token
    
    AppFE->>KC: POST /token<br/>{grant_type: authorization_code<br/>code: ABC123<br/>code_verifier: {original}<br/>client_id: crm-app}
    
    KC->>KC: Valida code_verifier<br/>SHA256(verifier) == code_challenge
    
    KC->>KC: Consulta atributos del usuario<br/>Lee c_ids: [12345, 67890, 11111]
    
    KC->>KC: Genera JWT Token<br/>Incluye claims:<br/>- sub: user-id<br/>- email: juan@example.com<br/>- c_ids: [12345, 67890, 11111]<br/>Firma con RS256
    
    KC-->>AppFE: 200 OK<br/>{access_token: "eyJhbG...",<br/>refresh_token: "...",<br/>expires_in: 3600}
    
    AppFE->>AppFE: Almacena tokens en sessionStorage
    
    Note over AppFE,AppBE: Fase 3: Uso del token en llamadas API
    
    User->>AppFE: Solicita datos (ej: lista de clientes)
    AppFE->>AppBE: GET /api/customers<br/>Header: Authorization: Bearer eyJhbG...
    
    AppBE->>AppBE: Valida firma del token (RS256)<br/>Verifica exp, iss, aud
    
    AppBE->>AppBE: Extrae claim c_ids<br/>[12345, 67890, 11111]
    
    AppBE->>AppBE: Filtra query SQL:<br/>SELECT * FROM Customers<br/>WHERE SecurityCompanyId IN (12345, 67890, 11111)
    
    AppBE-->>AppFE: 200 OK + JSON data
    AppFE-->>User: Muestra datos en UI
    
    Note over User,AppBE: Fase 4: Renovación de token (opcional)
    
    AppFE->>AppFE: Token expira (detectado)
    AppFE->>KC: POST /token<br/>{grant_type: refresh_token<br/>refresh_token: "..."<br/>client_id: crm-app}
    
    KC->>KC: Valida refresh_token<br/>Genera nuevo access_token
    
    KC-->>AppFE: 200 OK<br/>{access_token: "nuevo...",<br/>refresh_token: "nuevo...",<br/>expires_in: 3600}
```

**Puntos clave de seguridad**:
1. **PKCE (Proof Key for Code Exchange)**: Protege contra ataques de intercepción de código en SPAs
2. **No hay secretos en el cliente**: El frontend Angular nunca almacena `client_secret`
3. **Validación stateless**: El backend valida tokens localmente sin llamar a Keycloak
4. **Claim c_ids multi-organización**: Permite acceso a datos de múltiples organizaciones con un solo token
5. **Tokens de corta duración**: Access tokens expiran en 1 hora, mitigando riesgo de robo
6. **Refresh tokens seguros**: Permiten renovación sin re-autenticación

**Beneficios del SSO**:
- Usuario se autentica una sola vez
- Puede acceder a CRM, ERP, BI sin volver a ingresar credenciales
- Logout centralizado: cerrar sesión en Keycloak cierra todas las apps

#### **Patrón Arquitectónico**

El sistema implementa una **arquitectura híbrida** que combina:

1. **Event-Driven Architecture (EDA)**: Comunicación asíncrona mediante eventos de estado publicados en ActiveMQ Artemis
2. **Microservicios Ligeros**: Módulos internos independientes (Organizaciones, Aplicaciones, Roles, Módulos)
3. **Orchestration Pattern**: Servicio de orquestación que abstrae la complejidad de Keycloak Admin API
4. **CQRS Ligero**: Separación implícita entre escritura (InfoportOneAdmon) y lectura (cachés locales de apps)

#### **Justificación de la Arquitectura**

**¿Por qué Event-Driven con State Transfer?**

1. **Desacoplamiento Total**: Las aplicaciones satélite nunca invocan directamente a InfoportOneAdmon. Pueden operar autónomamente incluso si InfoportOneAdmon está en mantenimiento.

2. **Escalabilidad Horizontal**: Nuevas aplicaciones se añaden al ecosistema simplemente suscribiéndose a los tópicos de eventos, sin modificar InfoportOneAdmon.

3. **Resiliencia**: Si una aplicación está caída durante una actualización administrativa, procesará los cambios cuando se reconecte (mensajería persistente).

4. **Idempotencia Natural**: El patrón "State Transfer" (enviar estado final, no acciones) hace que los consumidores sean más simples y robustos mediante lógica upsert.

5. **Prevención de Cascadas**: El sistema de hash SHA-256 evita publicar eventos duplicados, previniendo actualizaciones circulares infinitas.

**¿Por qué Single Realm en Keycloak?**

- Habilita **SSO real** entre todas las aplicaciones del ecosistema
- Simplifica la administración de usuarios (un único lugar)
- Permite users multi-organización mediante claims personalizados (`c_ids`)

**¿Por qué NO usar Organizations de Keycloak?**

La feature nativa de Organizations de Keycloak **no soporta usuarios en múltiples organizaciones**, requisito fundamental para consultores, auditores y usuarios que trabajan para varias empresas clientes.

#### **Beneficios Principales**

| Beneficio | Descripción | Impacto |
|-----------|-------------|---------|
| **Autonomía de Apps** | Cada app opera con su caché local sin depender de InfoportOneAdmon en tiempo real | Alta disponibilidad del ecosistema |
| **Bajo Acoplamiento** | Comunicación exclusiva por eventos asíncronos | Facilita evolución independiente de componentes |
| **Seguridad Stateless** | Validación de tokens JWT sin consultar servicios centrales | Rendimiento óptimo en autenticación |
| **Escalabilidad Lineal** | Añadir apps no aumenta complejidad de InfoportOneAdmon | Crecimiento sostenible del ecosistema |
| **Trazabilidad Completa** | EventId, TraceId y auditoría en DB | Compliance y debugging facilitados |
| **Tolerancia a Fallos** | Mensajería persistente garantiza entrega eventual | No se pierden cambios administrativos |

#### **Sacrificios y Déficits**

| Sacrificio | Descripción | Mitigación |
|------------|-------------|------------|
| **Consistencia Eventual** | Los cambios en InfoportOneAdmon no se reflejan instantáneamente en apps | Aceptable para datos maestros que cambian poco frecuentemente |
| **Complejidad Operacional** | Requiere gestión de ActiveMQ Artemis y monitorización de colas | Automatización de despliegue y alertas de lag en consumidores |
| **Sincronización Inicial** | Las apps nuevas necesitan poblar su caché en el primer arranque | Proceso de sincronización bajo demanda disparado desde InfoportOneAdmon |
| **Duplicación de Datos** | Cada app mantiene copia de organizaciones, roles y módulos | Trade-off aceptado para ganar autonomía y rendimiento |
| **Debugging Distribuido** | Rastrear un flujo requiere correlación por TraceId entre sistemas | Logging estructurado y herramientas de observabilidad (APM) |

#### **Tecnologías Utilizadas**

- **Backend**: .NET 8 / ASP.NET Core (API REST) sobre **Framework Helix6**
- **Frontend**: Angular 20 (Interfaz administrativa y aplicaciones satélite). Algunas aplicaciones legacy pueden estar en otras tecnologías.
- **Message Broker**: Apache ActiveMQ Artemis
- **Identity Provider**: Keycloak (OAuth2 / OpenID Connect)
- **Base de Datos**: PostgreSQL
- **ORM**: Entity Framework Core 9.0.2 (escrituras) + Dapper 2.1.66 (lecturas optimizadas)
- **Mapeo de Objetos**: Mapster 7.4.0
- **Logging**: Serilog 9.0.2 con sinks a archivo y consola
- **Serialización**: JSON para eventos (System.Text.Json)
- **Prevención de Duplicados**: SHA-256 hashing

> **Framework Base Helix6**: Proporciona la infraestructura técnica completa (repositorios base, servicios genéricos, generación automática de endpoints, sistema de seguridad, validaciones, auditoría automática) permitiendo que InfoportOneAdmon se enfoque exclusivamente en su lógica de negocio específica. Ver documentación completa en [Helix6_Backend_Architecture.md](Helix6_Backend_Architecture.md).

> Usa el formato que consideres más adecuado para representar los componentes principales de la aplicación y las tecnologías utilizadas. Explica si sigue algún patrón predefinido, justifica por qué se ha elegido esta arquitectura, y destaca los beneficios principales que aportan al proyecto y justifican su uso, así como sacrificios o déficits que implica.


### **2.2. Descripción de componentes principales:**

El sistema InfoportOneAdmon se compone de módulos internos de aplicación y sistemas de infraestructura crítica, desacoplados mediante una arquitectura orientada a eventos.

> **Nota sobre el Framework Base**: Los componentes backend de InfoportOneAdmon están implementados sobre el **Framework Helix6**, una arquitectura en N-Capas para Web APIs con .NET 8 que implementa patrones de Clean Architecture y DDD. Helix6 proporciona la infraestructura base (repositorios, servicios, endpoints, seguridad) permitiendo que InfoportOneAdmon se enfoque exclusivamente en su lógica de negocio específica. Para detalles completos sobre la arquitectura base, consultar [Helix6_Backend_Architecture.md](Helix6_Backend_Architecture.md).

#### **2.2.1. Módulo de Organizaciones**

**Responsabilidad**: Gestionar el ciclo de vida completo de los clientes (alta, modificación, baja).

**Tecnología**: 
- ASP.NET Core 8 (Web API) sobre **Framework Helix6**
- Entity Framework Core (ORM)
- FluentValidation (validación de modelos)

**Implementación Helix6**:
- Entidad `Organization` en capa DataModel
- `OrganizationService` hereda de `BaseService<OrganizationView, Organization, OrganizationViewMetadata>`
- `OrganizationRepository` hereda de `BaseRepository<Organization>`
- Endpoints generados automáticamente mediante Helix Generator
- Auditoría automática gestionada por el framework (campos `AuditCreationUser`, `AuditModificationUser`, `AuditDeletionDate`)

**Funcionalidades principales**:
- CRUD de organizaciones con generación automática de `SecurityCompanyId`
- Gestión de grupos de organizaciones (asignación de `GroupId`)
- Baja lógica de organizaciones mediante `AuditDeletionDate` (bloquea acceso inmediato, propaga baja a usuarios en Keycloak)
- Auditoría selectiva de cambios críticos en tabla `AUDITLOG` (sin almacenar JSON de valores anteriores/nuevos)

**Interacciones**:
- Escribe en la **Base de Datos Core**
- Utiliza el **Servicio de Orquestación** para sincronizar con Keycloak
- Publica eventos `OrganizationEvent` a **ActiveMQ Artemis**

#### **2.2.2. Módulo de Aplicaciones**

**Responsabilidad**: Registrar nuevas aplicaciones satélite y gestionar sus credenciales OAuth2.

**Tecnología**:
- ASP.NET Core 8 (Web API)
- Gestión segura de secretos mediante dotnet user-secrets (desarrollo) y variables de entorno/Docker Secrets (producción)
- Entity Framework Core

**Funcionalidades principales**:
- Alta de aplicaciones frontend (Angular SPAs) como public clients con `client_id` únicamente
- Alta de aplicaciones backend como confidential clients con generación de `client_id` y `client_secret`
- Definición de módulos funcionales por aplicación
- Configuración de acceso a módulos por organización (relación N:M)
- Rotación de credenciales OAuth2 para confidential clients

**Interacciones**:
- Escribe en la **Base de Datos Core**
- Utiliza el **Servicio de Orquestación** para registrar clientes en Keycloak
- Publica eventos `ApplicationEvent` (catálogo de módulos y roles) y `OrganizationEvent` (permisos de acceso) a **ActiveMQ Artemis**

#### **2.2.3. Módulo de Catálogo de Roles**

**Responsabilidad**: Definir y almacenar las plantillas de roles disponibles en cada aplicación.

**Tecnología**:
- ASP.NET Core 8 (Web API)
- Entity Framework Core

**Funcionalidades principales**:
- CRUD de definiciones de roles (`ApplicationRole`)
- Baja lógica de roles mediante `AuditDeletionDate`
- Validación de unicidad de nombres de rol por aplicación

**Interacciones**:
- Escribe en la **Base de Datos Core**
- Los roles se sincronizan como parte del **ApplicationEvent** (no tienen evento propio)

**Nota importante**: InfoportOneAdmon define los roles (catálogo), las aplicaciones satélite los asignan a usuarios.

#### **2.2.4. Módulo de Módulos**

**Responsabilidad**: Gestionar los módulos funcionales de cada aplicación y configurar qué organizaciones tienen acceso a cada módulo.

**Tecnología**:
- ASP.NET Core 8 (Web API)
- Entity Framework Core

**Funcionalidades principales**:
- CRUD de módulos por aplicación
- Configuración de acceso por organización (tabla `OrganizationApplicationModule`)
- Validación de regla de negocio: toda aplicación debe tener al menos un módulo

**Interacciones**:
- Escribe en la **Base de Datos Core**
- Publica cambios de permisos mediante **OrganizationEvent** que incluye los módulos accesibles por cada aplicación

#### **2.2.5. Background Worker de InfoportOneAdmon**

**Responsabilidad**: Proceso en background integrado en InfoportOneAdmon que consolida eventos de usuarios multi-organización y sincroniza directamente con Keycloak.

**Tipo de componente**: Hosted Service / Background Service (.NET IHostedService)

**Tecnología**:
- ASP.NET Core 8 (IHostedService)
- Keycloak.AuthServices.Sdk (cliente Admin API)
- Apache.NMS.ActiveMQ (consumidor de eventos)
- Entity Framework Core (consulta de organizaciones)
- Patrón Aggregator (EIP - Enterprise Integration Pattern)

**Funcionalidades principales**:
- **Consumo de eventos de usuario**: Suscripción durable al tópico `infoportone.events.user`
- **Detección de usuarios duplicados**: Búsqueda por email en eventos previos y en base de datos
- **Consolidación de organizaciones**: Agregación de todos los `SecurityCompanyId` asociados al email
- **Consolidación de roles multi-aplicación**: Agregación de todos los roles asignados al usuario desde las distintas aplicaciones, utilizando el prefijo de aplicación para evitar conflictos (ej: CRM_Vendedor, ERP_Contable)
- **Validación de organizaciones**: Verificación de que las organizaciones existen y están dadas de alta (AuditDeletionDate IS NULL)
- **Sincronización directa con Keycloak**: CREATE/UPDATE de usuarios mediante Admin API
- **Gestión del claim c_ids**: Configuración automática del claim multi-organización
- **Gestión de roles consolidados**: Asignación de todos los roles del usuario desde todas las aplicaciones en Keycloak
- **Registro de clientes OAuth2**: Alta de aplicaciones satélite en Keycloak
- **Configuración de Protocol Mappers**: Inyección automática del claim `c_ids` en tokens JWT
- **Retry inteligente**: Política de reintentos con backoff exponencial
- **Telemetría**: Logging estructurado de todas las operaciones

**Flujo de procesamiento integrado**:
1. Consume evento de usuario desde tópico `user`
2. Valida estructura del evento (schema validation)
3. Detecta si el email ya existe en eventos previos (ventana de consolidación)
4. Consulta base de datos para obtener:
   - Lista completa de organizaciones del usuario (para c_ids)
   - Lista completa de roles del usuario desde todas las aplicaciones
5. Construye c_ids completo = [companyId_evento + companyIds_adicionales_BD]
6. Consolida roles de todas las aplicaciones:
   - Obtiene roles del evento actual (incluyen OriginApplicationId y prefijo de aplicación)
   - Consulta roles previos del usuario desde otras aplicaciones en BD
   - Construye array de roles consolidados con prefijos únicos por aplicación
7. Invoca Keycloak Admin API directamente:
   - GET /users?email={email}
   - POST /users (si no existe) o PUT /users/{id} (si existe)
   - Actualiza atributo `c_ids` (multivalor) con array completo de SecurityCompanyIds
   - Asigna/actualiza roles consolidados del usuario en Keycloak
   - **Importante**: `c_ids` debe enviarse como array de strings al API de Keycloak (atributo multivalor)
8. Confirma procesamiento (ACK) o envía a DLQ si falla tras reintentos

**Interacciones**:
- Consume eventos desde tópico **`infoportone.events.user`** (publicados por apps satélite)
- Consulta **Base de Datos Core** para detectar organizaciones adicionales y roles
- Invoca **Keycloak Admin API** (REST) directamente para CREATE/UPDATE de usuarios:
  - Atributo `c_ids`: Definido como **atributo multivalor**, se envía como array de strings con todos los SecurityCompanyIds
  - Roles: Se asignan consolidados de todas las aplicaciones
- Utiliza tabla auxiliar `UserCache` para optimizar detección de duplicados

**Tabla auxiliar: UserCache**
```sql
CREATE TABLE UserCache (
  Email NVARCHAR(255) PRIMARY KEY,
  ConsolidatedCompanyIds NVARCHAR(MAX), -- JSON array de c_ids
  ConsolidatedRoles NVARCHAR(MAX), -- JSON array de roles consolidados de todas las apps
  LastConsolidationDate DATETIME2,
  LastEventHash NVARCHAR(64)
);
```

**Gestión de errores**:
- Retry con backoff exponencial para fallos transitorios de Keycloak
- Dead Letter Queue (DLQ) para mensajes con errores de validación
- Alertas cuando se detectan organizaciones inválidas o eliminadas
- Circuit breaker para proteger Keycloak de sobrecarga

**Ventajas de la integración**:
- **Arquitectura simplificada**: Un solo proceso para InfoportOneAdmon
- **Menor latencia**: Sincronización directa sin pasos intermedios
- **Menos componentes**: Reduce complejidad operacional
- **Fuente de verdad única**: La base de datos de InfoportOneAdmon es autoritativa para relaciones usuario-organización

**🔑 Patrón Arquitectónico - Aggregator Puro**:
- El Background Worker implementa el patrón **Aggregator** de Enterprise Integration Patterns (EIP)
- **NO publica eventos consolidados** de vuelta al broker ActiveMQ Artemis
- Consume N eventos → Consolida información → Ejecuta acción final (sync con Keycloak)
- Esto evita ciclos infinitos de eventos y mantiene la arquitectura simple y predecible
- La sincronización con Keycloak es la acción terminal del proceso de consolidación

#### **2.2.6. Publicador de Eventos (Event Publisher)**

**Responsabilidad**: Componente que gestiona la publicación de eventos al message broker.

**Tecnología**:
- Apache.NMS.ActiveMQ (cliente .NET para Artemis)
- System.Text.Json (serialización)
- SHA-256 para hash de eventos

**Funcionalidades principales**:
- Serialización de eventos a JSON
- Cálculo de hash SHA-256 del `Payload` para prevención de duplicados
- Consulta/actualización de tabla `EventHash`
- Publicación a tópicos específicos en ActiveMQ Artemis
- Gestión de `EventId` (UUID v4) y `TraceId`

**Lógica de prevención de duplicados**:
1. Calcula hash del `Payload` (excluye `EventId`, `EventTimestamp`, `TraceId`)
2. Consulta `EventHash` por `EntityType` y `EntityId`
3. Si el hash coincide con `LastEventHash`, **NO publica** el evento
4. Si difiere, publica y actualiza `EventHash` con nuevo hash y timestamp

#### **2.2.6. Base de Datos Core**

**Responsabilidad**: Persistencia de la fuente de la verdad para organizaciones, aplicaciones, roles y auditoría.

**Tecnología**:
- PostgreSQL 15
- Entity Framework Core 8 (Code First)

**Entidades principales**:
- `Organization`: Clientes del ecosistema
- `OrganizationGroup`: Agrupaciones lógicas de organizaciones
- `Application`: Aplicaciones satélite registradas
- `ApplicationModule`: Módulos funcionales por aplicación
- `OrganizationApplicationModule`: Relación N:M entre módulos y organizaciones
- `ApplicationRole`: Catálogo de roles por aplicación
- `AuditLog`: Registro inmutable de cambios CRÍTICOS (6 acciones en Epic1: ModuleAssigned, ModuleRemoved, OrganizationDeactivatedManual, OrganizationAutoDeactivated, OrganizationReactivatedManual, GroupChanged). Campos: Id, Action, EntityType, EntityId, UserId (nullable), Timestamp, CorrelationId. Sin almacenar JSON de valores anteriores/nuevos
- `EventHash`: Control de duplicados con hash SHA-256

**Restricciones clave**:
- `SecurityCompanyId`: Unique, Auto-increment
- `Email` en usuarios: Unique (índice único)
- Foreign keys con cascada configurada según entidad

#### **2.2.7. ActiveMQ Artemis (Message Broker)**

**Responsabilidad**: Bus de mensajería empresarial que garantiza la entrega asíncrona y coherencia de datos.

**Tecnología**:
- Apache ActiveMQ Artemis 2.31+
- Protocolo AMQP 1.0 / Core Protocol
- Persistencia en disco (Journal)

**Tópicos configurados**:
- `infoportone.events.organization`: Eventos de organizaciones (incluye grupos)
- `infoportone.events.application`: Eventos de aplicaciones (incluye módulos y roles)
- `infoportone.events.user`: Eventos de usuarios publicados por apps satélite

**Segregación de responsabilidades por tópico**:
- **`infoportone.events.organization`**: 
  - Publisher: InfoportOneAdmon API
  - Consumers: Background Workers de Apps Satélite
- **`infoportone.events.application`**: 
  - Publisher: InfoportOneAdmon API
  - Consumers: Background Workers de Apps Satélite
- **`infoportone.events.user`**: 
  - Publishers: Backends de Apps Satélite
  - Consumer: Background Worker de InfoportOneAdmon

**Características**:
- **Mensajería persistente**: Los mensajes sobreviven a reinicios del broker
- **Durabilidad de suscripciones**: Los consumidores offline reciben mensajes al reconectarse
- **Dead Letter Queue (DLQ)**: Mensajes fallidos tras reintentos se mueven a DLQ
- **Monitorización**: JMX y consola web para observabilidad

#### **2.2.8. Keycloak (Identity Provider)**

**Responsabilidad**: Servidor de identidad centralizado para autenticación y autorización.

**Tecnología**:
- Keycloak 23+ (Red Hat SSO)
- OAuth 2.0 / OpenID Connect (OIDC)
- PostgreSQL (base de datos de Keycloak)

**Configuración**:
- **Realm único**: `InfoportOne` (todo el ecosistema)
- **Clients**: Uno por cada aplicación satélite (confidential clients)
- **Protocol Mappers**: Mapper personalizado para claim `c_ids`
- **Users**: Usuarios finales de todas las organizaciones

**Claim personalizado `c_ids`**:
```json
{
  "c_ids": [12345, 67890, 11111]
}
```
Este array contiene los `SecurityCompanyId` de todas las organizaciones a las que pertenece el usuario.

**Razón de NO usar Organizations de Keycloak**: La feature nativa no soporta usuarios en múltiples organizaciones simultáneamente.

#### **2.2.9. Aplicaciones Satélite (Consumidores y Productores)**

**Responsabilidad**: Aplicaciones de negocio del ecosistema (CRM, ERP, BI, etc.) que consumen eventos para sincronizar datos maestros y publican eventos de usuarios.

**Arquitectura de cada App Satélite**:
- **Frontend** (Angular 20 u otras tecnologías)
- **Backend API** (variable: .NET 8, Java, Node.js, Python, etc.)
- **Background Worker** (proceso en background para consumir eventos)
- **Caché Local** (Redis, In-Memory, SQL local)

**Tecnología Frontend**:
- **Angular 20**: Tecnología principal para SPAs del ecosistema
- Aplicaciones legacy ocasionales en otras tecnologías
- Autenticación mediante Authorization Code Flow with PKCE (sin almacenar secretos)

**Tecnología Backend** (variable según aplicación):
- .NET 8, Java, Node.js, Python, etc.
- Cliente AMQP/ActiveMQ según plataforma
- Caché local (Redis, In-Memory, SQL local)

**Funcionalidades del Background Worker**:
- Suscripción durable a tópicos `organization` y `application`
- Deserialización de eventos con `Payload` como lista
- Procesamiento idempotente: para cada objeto en `Payload`, aplicar upsert o delete según `IsDeleted`
- Mantenimiento de caché local de organizaciones, roles y módulos

**Funcionalidades del Backend API**:
- Lógica de negocio específica de la aplicación
- Validación de tokens JWT (verifica firma y claim `c_ids`)
- **Publicación de eventos de usuario**: Cuando se da de alta un usuario, publica `UserEvent` al tópico `infoportone.events.user`
- Filtrado automático de datos por `SecurityCompanyId` según claim `c_ids`

**Principio clave**: Las apps **NUNCA** invocan directamente a InfoportOneAdmon. La comunicación es exclusivamente por eventos.

#### **Tabla Resumen de Componentes**

| Componente | Rol | Tecnología Principal | Interacciones Clave |
|------------|-----|---------------------|---------------------|
| **Módulo Organizaciones** | Gestión de clientes | ASP.NET Core 8 | DB, Keycloak Orch, Artemis |
| **Módulo Aplicaciones** | Gestión de portfolio | ASP.NET Core 8 | DB, Keycloak Orch, Artemis |
| **Módulo Roles** | Catálogo de roles | ASP.NET Core 8 | DB (sincroniza con AppEvent) |
| **Módulo Módulos** | Configuración modular | ASP.NET Core 8 | DB, Artemis (via AppEvent) |
| **Background Worker (InfoportOne)** | Consolidación usuarios + Sync Keycloak | IHostedService .NET 8 | DB, Artemis (consumer), Keycloak API |
| **Event Publisher** | Publicación eventos | Apache.NMS | Artemis, EventHashControl |
| **Base de Datos Core** | Fuente de la verdad | PostgreSQL | Todos los módulos |
| **ActiveMQ Artemis** | Message broker | Artemis 2.31+ | InfoportOne API, Apps Satélite |
| **Keycloak** | Identity Provider | Keycloak 23+ | Background Worker, Apps (OAuth2) |
| **Apps Satélite - Backend** | Lógica negocio + Publisher usuarios | Variable (.NET, Java, etc.) | Artemis (pub), Keycloak (OAuth2) |
| **Apps Satélite - BG Worker** | Consumer de org/app events | Variable | Artemis (consumer), Caché local |

### **2.3. Descripción de alto nivel del proyecto y estructura de ficheros**

InfoportOneAdmon sigue la **arquitectura Helix6**, una implementación de N-Capas con Clean Architecture para proyectos Web API en .NET 8. La estructura se organiza en capas claramente separadas con dependencias unidireccionales hacia el núcleo.

#### **Estructura de Proyectos**

```
InfoportOneAdmon/
├── InfoportOneAdmon.Api/              # Capa de Presentación (Punto de entrada)
│   ├── Endpoints/
│   │   ├── Base/Generator/            # Endpoints generados automáticamente
│   │   │   ├── OrganizationEndpoints.cs
│   │   │   ├── ApplicationEndpoints.cs
│   │   │   └── ...
│   │   ├── GenericEndpoints.cs        # Mapeo centralizado de endpoints
│   │   └── Endpoints.cs               # Endpoints personalizados/manuales
│   ├── Extensions/
│   │   ├── DependencyInjection.cs     # Auto-registro de servicios/repositorios
│   │   └── AuthConfiguration.cs       # Configuración JWT y autenticación
│   ├── Security/
│   │   └── KeyCloakUserClaimsMapping.cs  # Mapeo de claims de Keycloak
│   ├── Program.cs                     # Bootstrapping de la aplicación
│   ├── appsettings.json               # Configuración principal
│   └── HelixEntities.xml              # Configuración de generación de código
│
├── InfoportOneAdmon.Services/         # Capa de Lógica de Negocio
│   ├── OrganizationService.cs         # Servicios de dominio
│   ├── ApplicationService.cs
│   ├── ApplicationModuleService.cs
│   ├── ApplicationRoleService.cs
│   ├── KeycloakOrchestrationService.cs # Orquestación de Keycloak
│   ├── EventPublisherService.cs       # Publicación de eventos
│   ├── EventConsumerService.cs        # Consumo de eventos
│   └── ServiceConsts.cs               # Constantes de validación
│
├── InfoportOneAdmon.Entities/         # Capa de DTOs/Views
│   ├── Views/
│   │   ├── OrganizationView.cs        # Views generadas (partial classes)
│   │   ├── ApplicationView.cs
│   │   └── ...
│   └── Views/Metadata/
│       ├── OrganizationViewMetadata.cs # Metadatos de validación
│       ├── ApplicationViewMetadata.cs
│       └── ...
│
├── InfoportOneAdmon.Data/             # Capa de Acceso a Datos
│   ├── DataModel/
│   │   └── EntityModel.cs             # DbContext de Entity Framework
│   └── Repository/
│       ├── Interfaces/
│       │   ├── IOrganizationRepository.cs
│       │   └── ...
│       ├── OrganizationRepository.cs  # Implementaciones concretas
│       └── ...
│
├── InfoportOneAdmon.DataModel/        # Capa de Modelo de Datos
│   ├── Organization.cs                # Entidades que mapean a BD
│   ├── OrganizationGroup.cs
│   ├── Application.cs
│   ├── ApplicationModule.cs
│   ├── OrganizationApplicationModule.cs
│   ├── ApplicationRole.cs
│   ├── ApplicationSecurity.cs
│   ├── AuditLog.cs
│   ├── EventHash.cs
│   └── UserCache.cs
│
├── Helix6.Base/                       # Framework Base (librería compartida)
│   ├── Repository/                    # Repositorios base genéricos
│   ├── Service/                       # Servicios base genéricos
│   ├── Endpoints/                     # Helpers de generación de endpoints
│   ├── Middleware/                    # Middleware personalizado
│   ├── Security/                      # Componentes de seguridad
│   └── Extensions/                    # Métodos de extensión
│
├── Helix6.Base.Domain/                # Dominio Base (contratos e interfaces)
│   ├── BaseInterfaces/
│   │   ├── IEntityBase.cs
│   │   └── IViewBase.cs
│   ├── Configuration/
│   │   ├── AppSettings.cs
│   │   └── ApplicationContext.cs
│   ├── Security/
│   │   ├── IUserContext.cs
│   │   └── IUserPermissions.cs
│   └── HelixEnums.cs
│
└── Helix6.Base.Utils/                 # Utilidades compartidas
    ├── FileHelper.cs
    └── MailHelper.cs
```

#### **Principios Arquitectónicos Helix6**

**Separación de Responsabilidades (Separation of Concerns)**:
- **Api**: Exposición HTTP, autenticación, inyección de dependencias, configuración
- **Services**: Lógica de negocio, validaciones, orquestación, mapeo Entity↔View
- **Entities**: Contratos de transferencia de datos (DTOs/Views)
- **Data**: Implementación de repositorios, transacciones, patrón Unit of Work
- **DataModel**: Representación fiel de tablas de base de datos
- **Base/Domain**: Infraestructura reutilizable y agnóstica del dominio

**Flujo de Dependencias** (Dependency Rule):
```
Api → Services → Data → DataModel
  ↓       ↓        ↓        ↓
  └───────┴────────┴────────→ Base/Domain
```
Las capas externas dependen de las internas. Las capas base no tienen dependencias de negocio.

**Patrón Repository + Unit of Work**:
- Cada entidad tiene un repositorio que hereda de `BaseRepository<TEntity>`
- `EntityModel` (DbContext) actúa como Unit of Work
- Dual-ORM: Entity Framework para escrituras, Dapper para lecturas optimizadas

**Patrón Service con Hooks Extensibles**:
- Servicios heredan de `BaseService<TView, TEntity, TMetadata>`
- Pipeline estándar: `ValidateView` → `PreviousActions` → `MapViewToEntity` → Repositorio → `PostActions` → `MapEntityToView`
- Hooks virtuales permiten inyectar lógica personalizada sin romper el flujo

**Generación Automática de Código**:
- `HelixEntities.xml` define qué entidades exponer y qué endpoints generar
- Helix Generator produce Views, ViewMetadata y Endpoints automáticamente
- Elimina código boilerplate, enfoca desarrollo en lógica de negocio

#### **Personalización para InfoportOneAdmon**

Además de la estructura base de Helix6, InfoportOneAdmon añade:

**Componentes Específicos**:
- `KeycloakOrchestrationService`: Abstracción de Keycloak Admin API
- `EventPublisherService`: Sistema de publicación de eventos con hash SHA-256
- `EventConsumerService`: Consumo de eventos desde ActiveMQ Artemis
- `EventHashControl` (tabla): Prevención de eventos duplicados

**Configuración Personalizada**:
```json
{
  "ActiveMQ": {
    "BrokerUri": "tcp://artemis.infoportone.com:61616",
    "Topics": {
      "Organization": "infoportone.events.organization",
      "Application": "infoportone.events.application",
      "User": "infoportone.events.user"
    }
  },
  "Keycloak": {
    "AdminApiUrl": "https://keycloak.infoportone.com/admin/realms/InfoportOne",
    "Realm": "InfoportOne"
  }
}
```

**Extensiones del Modelo de Datos**:
- Todas las entidades incluyen auditoría automática (Helix6)
- `EventHashControl` para gestión de duplicados (específico de InfoportOne)
- Soft Delete mediante `AuditDeletionDate` (Helix6)

> **Documentación Técnica Completa**: Para entender en profundidad la arquitectura base, patrones implementados, ciclo de vida de peticiones y convenciones de código, consultar [Helix6_Backend_Architecture.md](Helix6_Backend_Architecture.md).

### **2.4. Infraestructura y despliegue**

> Detalla la infraestructura del proyecto, incluyendo un diagrama en el formato que creas conveniente, y explica el proceso de despliegue que se sigue

### **2.5. Seguridad**

InfoportOneAdmon implementa múltiples capas de seguridad que garantizan la protección de datos, autenticación robusta, autorización granular y trazabilidad completa. A continuación se describen las prácticas de seguridad principales implementadas en el proyecto:

#### **2.5.1. Autenticación y Autorización mediante OAuth 2.0 / OpenID Connect**

**Descripción**: Todo el ecosistema utiliza Keycloak como Identity Provider centralizado, implementando los estándares OAuth 2.0 y OpenID Connect.

**Implementación**:
- **Single Sign-On (SSO)**: Un único realm (`InfoportOne`) permite a los usuarios autenticarse una sola vez para acceder a todas las aplicaciones del ecosistema
- **Public Clients (SPAs)**: Las aplicaciones Angular se registran como clientes públicos sin `client_secret`
- **Confidential Clients (Backend APIs)**: Las APIs backend se registran como clientes confidenciales con `client_id` y `client_secret`
- **Authorization Code Flow with PKCE**: Flujo estándar para Single Page Applications (Angular) que no requiere almacenar secretos en el cliente
- **Authorization Code Flow**: Flujo tradicional para aplicaciones con backend seguro
- **Refresh Tokens**: Tokens de larga duración para renovar access tokens sin re-autenticación

**Ejemplo de configuración de cliente público (SPA Angular) en Keycloak**:
```json
{
  "clientId": "crm-app-frontend",
  "enabled": true,
  "publicClient": true,
  "redirectUris": ["https://crm.infoportone.com/*"],
  "webOrigins": ["https://crm.infoportone.com"],
  "standardFlowEnabled": true,
  "implicitFlowEnabled": false,
  "directAccessGrantsEnabled": false,
  "pkceCodeChallengeMethod": "S256"
}
```

**Ejemplo de configuración de cliente confidencial (Backend API) en Keycloak**:
```json
{
  "clientId": "crm-api-backend",
  "enabled": true,
  "publicClient": false,
  "clientAuthenticatorType": "client-secret",
  "secret": "********************",
  "serviceAccountsEnabled": true,
  "directAccessGrantsEnabled": false
}
```

#### **2.5.2. Tokens JWT con Claims Personalizados (c_ids)**

**Descripción**: Los tokens JWT incluyen un claim personalizado `c_ids` que contiene la lista de `SecurityCompanyId` de todas las organizaciones a las que pertenece el usuario.

**Implementación**:
- **Protocol Mapper personalizado** en Keycloak que inyecta el array `c_ids` en el token
- El claim se genera dinámicamente consultando las relaciones usuario-organización
- Las aplicaciones satélite validan el claim para verificar acceso a recursos específicos de una organización

**Ejemplo de token JWT decodificado**:
```json
{
  "sub": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
  "email": "juan.perez@consultora.com",
  "name": "Juan Pérez",
  "c_ids": [12345, 67890, 11111],
  "iss": "https://keycloak.infoportone.com/realms/InfoportOne",
  "aud": "crm-app-prod",
  "exp": 1736345678,
  "iat": 1736342078
}
```

**Validación en aplicaciones satélite** (ejemplo en C#):
```csharp
// Extraer claim c_ids del token
var companyIds = User.Claims
    .FirstOrDefault(c => c.Type == "c_ids")
    ?.Value;

// Verificar si el usuario tiene acceso a la organización solicitada
if (!companyIds.Contains(requestedCompanyId))
{
    return Forbid(); // 403 Forbidden
}
```

#### **2.5.3. Validación Stateless de Tokens (Sin Llamadas a Keycloak)**

**Descripción**: Las aplicaciones satélite validan tokens JWT localmente mediante verificación criptográfica, sin necesidad de consultar a Keycloak en cada petición.

**Implementación**:
- **Firma Digital**: Los tokens están firmados con RS256 (RSA + SHA-256)
- **Clave Pública**: Las aplicaciones obtienen la clave pública de Keycloak una sola vez y la cachean
- **Validación Local**: Verifica firma, expiración (`exp`), emisor (`iss`) y audiencia (`aud`)

**Beneficios**:
- **Rendimiento**: No hay latencia de red en cada validación
- **Escalabilidad**: Keycloak no se convierte en cuello de botella
- **Disponibilidad**: Las apps pueden validar tokens incluso si Keycloak está temporalmente inaccesible

**Ejemplo de validación** (pseudocódigo):
```csharp
var tokenHandler = new JwtSecurityTokenHandler();
var validationParameters = new TokenValidationParameters
{
    ValidateIssuerSigningKey = true,
    IssuerSigningKey = GetKeycloakPublicKey(), // Cacheada
    ValidateIssuer = true,
    ValidIssuer = "https://keycloak.infoportone.com/realms/InfoportOne",
    ValidateAudience = true,
    ValidAudience = "crm-app-prod",
    ValidateLifetime = true,
    ClockSkew = TimeSpan.FromMinutes(5)
};

var principal = tokenHandler.ValidateToken(token, validationParameters, out _);
```

> **Implementación en Helix6**: El framework proporciona `KeyCloakUserClaimsMapping` que abstrae el mapeo de claims desde la estructura compleja de KeyCloak (`realm_access`, `resource_access`). Ver detalles en [Helix6_Backend_Architecture.md - Sección 10.5](Helix6_Backend_Architecture.md#105-mapeo-de-claims-según-identity-server).

#### **2.5.4. Segregación de Datos por Organización (Multi-Tenancy)**

**Descripción**: Todas las consultas a base de datos en aplicaciones satélite deben filtrar por `SecurityCompanyId` para garantizar aislamiento de datos entre organizaciones.

**Implementación**:
- **Filtro Global en Entity Framework**: Middleware que añade automáticamente `WHERE SecurityCompanyId IN (c_ids)` a todas las queries
- **Row-Level Security (RLS)**: En PostgreSQL, se pueden implementar políticas de seguridad a nivel de fila
- **Validación en API**: Verificar que el `SecurityCompanyId` solicitado está en el claim `c_ids` del usuario

**Ejemplo de filtro global** (C# + Entity Framework):
```csharp
protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    // Obtener c_ids del contexto HTTP
    var companyIds = _httpContext.User.FindFirst("c_ids")?.Value;
    
    // Aplicar filtro global a todas las entidades con SecurityCompanyId
    modelBuilder.Entity<Customer>()
        .HasQueryFilter(e => companyIds.Contains(e.SecurityCompanyId));
    
    modelBuilder.Entity<Invoice>()
        .HasQueryFilter(e => companyIds.Contains(e.SecurityCompanyId));
}
```

#### **2.5.5. Gestión Segura de Secretos**

**Descripción**: Los secretos sensibles (`client_secret` de APIs backend, cadenas de conexión, claves de cifrado) nunca se almacenan en código fuente ni en archivos de configuración.

**Alcance**: Esta gestión aplica **exclusivamente a confidential clients** (APIs backend, servicios del servidor). Las aplicaciones Angular (public clients) utilizan PKCE y **no requieren almacenar secretos**.

**Implementación por Entorno**:
- **Desarrollo Local**: `dotnet user-secrets` para APIs backend - evita commits accidentales y aísla secretos del código
- **Producción (Docker Swarm)**: 
  - **Docker Secrets** (nativo de Swarm): Para datos ultra-sensibles como `client_secret` de Keycloak, passwords de BD
  - **Variables de Entorno**: Para configuraciones menos críticas inyectadas por pipelines CI/CD según entorno (dev/staging/prod)
- **Rotación de Credenciales**: Proceso manual/semiautomático para rotar `client_secret` de APIs backend cada 90 días
- **Principio de Mínimo Privilegio**: Cada aplicación solo tiene acceso a sus propios secretos
- **PKCE para SPAs**: Las aplicaciones Angular no almacenan secretos; usan code verifier/challenge dinámico por sesión

**Ejemplo de uso de Docker Secrets en Swarm** (docker-compose.yml):
```yaml
services:
  infoportoneadmon-api:
    image: infoportone/admon:latest
    secrets:
      - keycloak_client_secret
      - db_password
    environment:
      - Keycloak__ClientId=infoportone-admin
      - Keycloak__ClientSecret_File=/run/secrets/keycloak_client_secret
      - ConnectionStrings__DefaultConnection_File=/run/secrets/db_password

secrets:
  keycloak_client_secret:
    external: true  # Creado previamente: docker secret create keycloak_client_secret secret.txt
  db_password:
    external: true

KeyVaultSecret secret = await client.GetSecretAsync("CrmApp-ClientSecret");
string clientSecret = secret.Value;
```

#### **2.5.6. Auditoría Selectiva de Cambios Críticos**

**Descripción**: Los cambios CRÍTICOS en organizaciones relacionados con seguridad y permisos se registran en una tabla de auditoría inmutable simplificada.

**Filosofía de Auditoría Dual**:
- **Auditoría Base (Helix6)**: El framework gestiona automáticamente campos de auditoría en TODAS las entidades (`AuditCreationUser`, `AuditModificationUser`, `AuditCreationDate`, `AuditModificationDate`, `AuditDeletionDate`) registrando todos los cambios
- **Auditoría Selectiva (AUDITLOG)**: Tabla adicional que registra SOLO 6 acciones críticas con contexto de acción específico (Epic1, expandible en otras épicas)

**Acciones Críticas Auditadas (Epic1)**:
1. `ModuleAssigned` - Asignación de módulo/aplicación a organización
2. `ModuleRemoved` - Remoción de módulo/aplicación de organización
3. `OrganizationDeactivatedManual` - Baja manual por SecurityManager
4. `OrganizationAutoDeactivated` - Baja automática por sistema
5. `OrganizationReactivatedManual` - Alta manual por SecurityManager
6. `GroupChanged` - Cambio de grupo de la organización

**NO se auditan selectivamente**: Cambios en datos básicos (nombre, dirección, email, teléfono, CIF) - estos solo tienen auditoría base de Helix6.

**Implementación**:
- **Tabla `AUDITLOG`**: Estructura simplificada sin JSON de valores anteriores/nuevos
- **Campos**: `Id`, `Action`, `EntityType`, `EntityId`, `UserId` (nullable para acciones del sistema), `Timestamp`, `CorrelationId`
- **IAuditLogService**: Servicio dedicado para registro de acciones críticas

> **Implementación en Helix6**: El framework automáticamente inyecta el `UserId` desde `IUserContext` en las operaciones de escritura. El `DbContext` sobreescribe `SaveChanges` para poblar los campos de auditoría base antes de persistir. Ver [Helix6_Backend_Architecture.md - Sección 2.6](Helix6_Backend_Architecture.md#26-proyectodata-capa-de-acceso-a-datos) para detalles de la implementación del DbContext.

**Ejemplo de registro de auditoría selectiva**:
```json
{
  "id": 98765,
  "action": "ModuleAssigned",
  "entityType": "Organization",
  "entityId": 12345,
  "userId": 42,
  "timestamp": "2026-01-08T14:35:22Z",
  "correlationId": "batch-2026-01-08-001"
}
```

**Uso en compliance**:
- Responder a auditorías regulatorias (GDPR, ISO 27001)
- Investigar incidentes de seguridad relacionados con permisos
- Demostrar trazabilidad de cambios críticos en seguridad y accesos

#### **2.5.7. Protección contra Inyección SQL y XSS**

**Descripción**: Implementación de defensas contra las vulnerabilidades más comunes (OWASP Top 10).

**Implementación**:
- **Prepared Statements**: Entity Framework Core usa queries parametrizadas por defecto, previniendo SQL Injection
- **Validación de Entrada**: FluentValidation para validar datos de entrada en todas las APIs
- **Encoding de Salida**: En frontend, sanitización automática de HTML (Angular escapa por defecto con DomSanitizer)
- **Content Security Policy (CSP)**: Headers HTTP que previenen XSS

**Ejemplo de validación** (FluentValidation):
```csharp
public class CreateOrganizationValidator : AbstractValidator<CreateOrganizationDto>
{
    public CreateOrganizationValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty()
            .MaximumLength(200)
            .Matches("^[a-zA-Z0-9 .,&()-]+$"); // Solo caracteres seguros
        
        RuleFor(x => x.TaxId)
            .NotEmpty()
            .Matches(@"^[A-Z]\d{8}$"); // Formato específico
    }
}
```

#### **2.5.8. Comunicación Segura (TLS/SSL)**

**Descripción**: Todas las comunicaciones entre componentes utilizan canales cifrados.

**Implementación**:
- **HTTPS obligatorio**: Certificados TLS 1.3 en todas las APIs y frontends
- **mTLS para ActiveMQ Artemis**: Autenticación mutua entre InfoportOneAdmon y el broker
- **Certificados Gestionados**: Let's Encrypt o certificados corporativos con renovación automática

**Configuración de Artemis con TLS**:
```xml
<acceptor name="artemis-ssl">
  tcp://0.0.0.0:61617?sslEnabled=true;
  keyStorePath=/path/to/broker.ks;
  keyStorePassword=***;
  trustStorePath=/path/to/client.ts;
  trustStorePassword=***;
  needClientAuth=true
</acceptor>
```

#### **2.5.9. Control de Acceso Basado en Roles (RBAC) en InfoportOneAdmon**

**Descripción**: La propia interfaz de InfoportOneAdmon implementa RBAC para distinguir entre diferentes tipos de administradores.

**Roles definidos**:
- **SuperAdmin**: Acceso total (gestión de organizaciones, apps, roles, módulos)
- **OrgManager**: Solo gestión de organizaciones y grupos
- **AppManager**: Solo gestión de aplicaciones y módulos
- **Auditor**: Solo lectura de auditorías y logs (sin modificación)

**Implementación**:
```csharp
[Authorize(Roles = "SuperAdmin")]
[HttpPost("api/organization")]
public async Task<IActionResult> CreateOrganization(...)

[Authorize(Roles = "SuperAdmin,Auditor")]
[HttpGet("api/audit-log")]
public async Task<IActionResult> GetAuditLogs(...)
```

#### **2.5.10. Prevención de Duplicados mediante Hash (Integridad de Eventos)**

**Descripción**: El sistema de hash SHA-256 no solo optimiza tráfico, también garantiza que los eventos publicados representan cambios reales y no manipulaciones.

**Implementación**:
- Cada evento tiene un hash calculado sobre su `Payload` (excluye metadatos variables)
- Si el hash no cambia, se previene la publicación
- Protege contra ataques de replay o publicación maliciosa de eventos idénticos

**Seguridad adicional**:
```csharp
public string ComputeEventHash(object payload)
{
    var json = JsonSerializer.Serialize(payload, new JsonSerializerOptions 
    { 
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull,
        WriteIndented = false // Formato consistente
    });
    
    using var sha256 = SHA256.Create();
    var hashBytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(json));
    return Convert.ToBase64String(hashBytes);
}
```

#### **Tabla Resumen de Prácticas de Seguridad**

| Práctica | Capa | Tecnología/Estándar | Beneficio Principal |
|----------|------|---------------------|---------------------|
| OAuth 2.0 / OIDC | Autenticación | Keycloak | SSO y estándar de industria |
| PKCE para SPAs | Autenticación | Code + PKCE (S256) | Seguridad sin secretos en cliente |
| Claims personalizados (c_ids) | Autorización | JWT | Multi-organización flexible |
| Validación stateless | Rendimiento | RS256 + JWT | Escalabilidad sin bottleneck |
| Segregación por tenant | Datos | EF Core Filters | Aislamiento de organizaciones |
| Gestión de secretos | Infraestructura | Docker Secrets + user-secrets | Sin secretos en código (solo backends) |
| Auditoría inmutable | Compliance | AuditLog table | Trazabilidad completa |
| Prepared Statements | Datos | EF Core | Prevención SQL Injection |
| TLS/mTLS | Red | TLS 1.3 | Cifrado end-to-end |
| RBAC | Acceso | ASP.NET Core | Principio mínimo privilegio |
| Hash de eventos | Integridad | SHA-256 | Prevención de duplicados/replay |

> Enumera y describe las prácticas de seguridad principales que se han implementado en el proyecto, añadiendo ejemplos si procede

### **2.6. Tests**

> Describe brevemente algunos de los tests realizados

---

## 3. Modelo de Datos

### **3.1. Diagrama del modelo de datos:**

El modelo de datos de InfoportOneAdmon representa la fuente de la verdad para organizaciones, aplicaciones, módulos, roles y auditoría. A continuación se presenta el diagrama completo con todas las relaciones, claves y restricciones:

```mermaid
erDiagram
    ORGANIZATIONGROUP ||--|{ ORGANIZATION : "agrupa a"
    ORGANIZATION ||--|{ ORGANIZATION_APPLICATIONMODULE : "tiene acceso a"
    APPLICATION ||--|{ APPLICATIONMODULE : "contiene"
    APPLICATION ||--|{ APPLICATIONROLE : "define roles"
    APPLICATION ||--|{ APPLICATIONSECURITY : "tiene credenciales"
    APPLICATIONMODULE ||--|{ ORGANIZATION_APPLICATIONMODULE : "asigna acceso"
    ORGANIZATION ||--o{ AUDITLOG : "genera auditoría"
    APPLICATION ||--o{ AUDITLOG : "genera auditoría"
    APPLICATIONMODULE ||--o{ AUDITLOG : "genera auditoría"
    
    ORGANIZATIONGROUP {
        int Id PK "AUTO_INCREMENT, Identificador único del grupo"
        string GroupName UK "NOT NULL, Nombre del grupo (ej: Holding Norte)"
        string Description "Descripción del grupo"
        string AuditCreationUser "Usuario que creó el grupo"
        datetime AuditCreationDate "NOT NULL, Fecha de creación"
        string AuditModificationUser "Usuario que modificó"
        datetime AuditModificationDate "Fecha última actualización"
        datetime AuditDeletionDate "Soft delete - fecha de eliminación lógica"
    }
    
    ORGANIZATION {
        int Id PK "AUTO_INCREMENT, Identificador único autogenerado por Helix6"
        int SecurityCompanyId UK "NOT NULL, Identificador de negocio inmutable"
        int GroupId FK "NULL, Referencia a OrganizationGroup.Id"
        string Name UK "NOT NULL, Nombre de la organización"
        string TaxId UK "NOT NULL, NIF/CIF fiscal"
        string Address "Dirección postal"
        string City "Ciudad"
        string PostalCode "Código postal"
        string Country "País"
        string ContactEmail "Email de contacto"
        string ContactPhone "Teléfono de contacto"
        string AuditCreationUser "Usuario que creó el registro"
        datetime AuditCreationDate "NOT NULL, Fecha de creación"
        string AuditModificationUser "Usuario que modificó"
        datetime AuditModificationDate "Fecha última actualización"
        datetime AuditDeletionDate "Soft delete - fecha de eliminación lógica"
    }
    
    APPLICATION {
        int Id PK "AUTO_INCREMENT, Identificador único de la aplicación"
        string AppName UK "NOT NULL, Nombre de la aplicación (ej: CRM, ERP)"
        string Description "Descripción de la aplicación"
        string RolePrefix UK "NOT NULL, Prefijo para roles y módulos (ej: STP)"
        string AuditCreationUser "Usuario que creó el registro"
        datetime AuditCreationDate "NOT NULL, Fecha de creación"
        string AuditModificationUser "Usuario que modificó"
        datetime AuditModificationDate "Fecha última actualización"
        datetime AuditDeletionDate "Soft delete - fecha de eliminación lógica"
    }
    
    APPLICATIONSECURITY {
        int Id PK "AUTO_INCREMENT, Identificador único de credencial"
        int ApplicationId FK "NOT NULL, Referencia a Application.Id"
        string CredentialType "NOT NULL, Tipo: CODE o ClientCredentials"
        string ClientId UK "NOT NULL, OAuth2 client_id generado"
        string ClientSecretHash "NULL para CODE, Hash bcrypt para ClientCredentials"
        string RedirectUris "JSON array de URIs (solo CODE)"
        string Scope "Scopes OAuth2 permitidos"
        string AuditCreationUser "Usuario que creó la credencial"
        datetime AuditCreationDate "NOT NULL, Fecha de creación"
        string AuditModificationUser "Usuario que modificó"
        datetime AuditModificationDate "Fecha última actualización"
        datetime AuditDeletionDate "Soft delete - fecha de eliminación lógica"
    }
    
    APPLICATIONMODULE {
        int Id PK "AUTO_INCREMENT, Identificador único del módulo"
        int ApplicationId FK "NOT NULL, Referencia a Application.Id"
        string ModuleName "NOT NULL, Nombre del módulo (ej: Módulo Facturación)"
        string Description "Descripción del módulo"
        int DisplayOrder "Orden de visualización"
        string AuditCreationUser "Usuario que creó el módulo"
        datetime AuditCreationDate "NOT NULL, Fecha de creación"
        string AuditModificationUser "Usuario que modificó"
        datetime AuditModificationDate "Fecha última actualización"
        datetime AuditDeletionDate "Soft delete - fecha de eliminación lógica"
    }
    
    ORGANIZATION_APPLICATIONMODULE {
        int Id PK "AUTO_INCREMENT, Identificador único"
        int ApplicationModuleId FK "NOT NULL, Referencia a ApplicationModule.Id"
        int OrganizationId FK "NOT NULL, Referencia a Organization.Id"
        string AuditCreationUser "Usuario que concedió el acceso"
        datetime AuditCreationDate "NOT NULL, Fecha de creación"
        string AuditModificationUser "Usuario que modificó"
        datetime AuditModificationDate "Fecha última actualización"
        datetime AuditDeletionDate "Soft delete - fecha de eliminación lógica"
    }
    
    APPLICATIONROLE {
        int Id PK "AUTO_INCREMENT, Identificador único del rol"
        int ApplicationId FK "NOT NULL, Referencia a Application.Id"
        string RoleName "NOT NULL, Nombre del rol (ej: Vendedor, Gerente)"
        string Description "Descripción del rol"
        string AuditCreationUser "Usuario que creó el rol"
        datetime AuditCreationDate "NOT NULL, Fecha de creación"
        string AuditModificationUser "Usuario que modificó"
        datetime AuditModificationDate "Fecha última actualización"
        datetime AuditDeletionDate "Soft delete - fecha de eliminación lógica"
    }
    
    USERCACHE {
        int Id PK "AUTO_INCREMENT, Identificador único"
        string Email UK "NOT NULL, Email del usuario (clave de búsqueda)"
        string ConsolidatedCompanyIds "NOT NULL, JSON array de SecurityCompanyIds"
        string ConsolidatedRoles "NOT NULL, JSON array de roles consolidados"
        datetime LastConsolidationDate "NOT NULL, Última consolidación"
        string LastEventHash "Hash SHA-256 del último evento procesado"
    }
    
    AUDITLOG {
        bigint Id PK "AUTO_INCREMENT, Identificador único del log"
        string EntityType "NOT NULL, Tipo de entidad"
        string EntityId "NOT NULL, ID de la entidad afectada"
        string Action "NOT NULL, Acción: INSERT, UPDATE, DELETE"
        datetime Timestamp "NOT NULL, Momento exacto del cambio"
        string OldValue "JSON con estado anterior (NULL en INSERT)"
        string NewValue "JSON con estado posterior (NULL en DELETE)"
        string AuditCreationUser "Usuario que creó el log"
        datetime AuditCreationDate "NOT NULL, Fecha de creación"
        string AuditModificationUser "Usuario que modificó"
        datetime AuditModificationDate "Fecha última actualización"
        datetime AuditDeletionDate "Soft delete - fecha de eliminación lógica"
    }
    
    EVENTHASH {
        string EntityType PK "NOT NULL, Tipo de entidad"
        string EntityId PK "NOT NULL, ID de la entidad"
        string LastEventHash "NOT NULL, Hash SHA-256 del último evento"
        datetime LastEventTimestamp "NOT NULL, Timestamp del último evento"
    }
```

#### **Descripción de Relaciones**

| Relación | Cardinalidad | Descripción | Comportamiento Cascada |
|----------|--------------|-------------|------------------------|
| OrganizationGroup → Organization | 1:N | Un grupo agrupa múltiples organizaciones | ON DELETE SET NULL |
| Application → ApplicationModule | 1:N | Una aplicación contiene múltiples módulos | ON DELETE CASCADE |
| Application → ApplicationRole | 1:N | Una aplicación define múltiples roles | ON DELETE CASCADE |
| Application → ApplicationSecurity | 1:N | Una aplicación tiene múltiples credenciales OAuth2 | ON DELETE CASCADE |
| ApplicationModule → OrganizationApplicationModule | 1:N | Un módulo puede asignarse a múltiples organizaciones | ON DELETE CASCADE |
| Organization → OrganizationApplicationModule | 1:N | Una organización puede tener acceso a múltiples módulos | ON DELETE CASCADE |
| Organization → AuditLog | 1:N | Una organización genera múltiples registros de auditoría | ON DELETE NO ACTION |
| Application → AuditLog | 1:N | Una aplicación genera múltiples registros de auditoría | ON DELETE NO ACTION |

#### **Índices Principales**

Para optimizar las consultas más frecuentes, se definen los siguientes índices:

```sql
-- Índices únicos (restricciones de negocio)
CREATE UNIQUE INDEX UX_Org_SecurityCompanyId ON ORGANIZATION(SecurityCompanyId);
CREATE UNIQUE INDEX UX_Org_Name ON ORGANIZATION(Name);
CREATE UNIQUE INDEX UX_Org_TaxId ON ORGANIZATION(TaxId);
CREATE UNIQUE INDEX UX_App_AppName ON APPLICATION(AppName);
CREATE UNIQUE INDEX UX_App_RolePrefix ON APPLICATION(RolePrefix);
CREATE UNIQUE INDEX UX_AppSec_ClientId ON APPLICATIONSECURITY(ClientId);
CREATE UNIQUE INDEX UX_OrgGroup_GroupName ON ORGANIZATIONGROUP(GroupName);
CREATE UNIQUE INDEX UX_UserCache_Email ON USERCACHE(Email);

-- Índices compuestos para módulos (evitar duplicados)
CREATE UNIQUE INDEX UX_AppMod_ApplicationId_ModuleName ON APPLICATIONMODULE(ApplicationId, ModuleName);
CREATE UNIQUE INDEX UX_AppRole_ApplicationId_RoleName ON APPLICATIONROLE(ApplicationId, RoleName);
CREATE UNIQUE INDEX UX_OrgAppMod_AppModuleId_OrgId ON ORGANIZATION_APPLICATIONMODULE(ApplicationModuleId, OrganizationId);

-- Índices de búsqueda frecuente
CREATE INDEX IX_Org_GroupId ON ORGANIZATION(GroupId);
CREATE INDEX IX_AppMod_ApplicationId ON APPLICATIONMODULE(ApplicationId);
CREATE INDEX IX_OrgAppMod_OrganizationId ON ORGANIZATION_APPLICATIONMODULE(OrganizationId);
CREATE INDEX IX_AppSec_ApplicationId ON APPLICATIONSECURITY(ApplicationId);
CREATE INDEX IX_AuditLog_EntityType_EntityId ON AUDITLOG(EntityType, EntityId);
CREATE INDEX IX_AuditLog_Timestamp ON AUDITLOG(Timestamp DESC);
CREATE INDEX IX_EventHash_EntityType_EntityId ON EVENTHASH(EntityType, EntityId);
```

#### **Reglas de Integridad y Restricciones**

1. **Organización debe tener nombre, TaxId y SecurityCompanyId únicos**: Previene duplicación de clientes
2. **SecurityCompanyId es índice único**: Es el identificador de negocio, mientras que Id es la PK técnica de Helix6
3. **Aplicación debe tener al menos un módulo**: Validado a nivel de negocio (no FK)
4. **ModuleAccess es relación N:M con restricción única**: Una organización no puede tener el mismo módulo asignado dos veces
5. **AuditLog es append-only**: No permite UPDATE ni DELETE (tabla inmutable)
6. **EventHashControl tiene clave compuesta**: (EntityType, EntityId) para prevención de duplicados
7. **ApplicationSecurity.ClientSecretHash nunca almacena texto plano**: Siempre se hashea con bcrypt antes de insertar
8. **Soft Delete con AuditDeletionDate**: Todas las entidades Helix6 soportan eliminación lógica mediante el campo AuditDeletionDate. Dar de baja una entidad establece este campo, dar de alta lo pone a NULL

#### **Notas sobre el Diseño**

**¿Por qué todas las PKs son Id autonumérico?**
- Sigue el estándar de **Helix6 Framework** que utiliza `Id` como PK técnica en todas las entidades
- `SecurityCompanyId` pasa a ser un índice único de negocio, no la PK física
- Esto facilita la generación automática de repositorios y endpoints en Helix6

**¿Por qué tabla separada ApplicationSecurity?**
- Una aplicación puede tener una credencial CODE PKCE para acceso web y múltiples credenciales ClientCredentials para accesos externos
- Soporta diferentes tipos de flujo OAuth2: CODE (Angular SPAs) vs ClientCredentials (APIs backend)
- Cada credencial puede tener su propio ciclo de vida independiente
- Dar de baja una credencial mediante AuditDeletionDate la revoca automáticamente en Keycloak

**¿Por qué campos de auditoría Helix6?**
- **AuditCreationUser / AuditCreationDate**: Trazabilidad de quién y cuándo creó el registro
- **AuditModificationUser / AuditModificationDate**: Trazabilidad de modificaciones
- **AuditDeletionDate**: Soft delete - permite "eliminar" sin borrar físicamente el registro
- El framework Helix6 gestiona automáticamente estos campos en todas las operaciones CUD

**¿Por qué UserConsolidationCache?**
- Optimiza el proceso de consolidación de usuarios multi-organización
- Evita consultas costosas a la BD en cada evento de usuario recibido
- Almacena el hash del último evento procesado para detección de duplicados
- Contiene los datos consolidados (organizaciones y roles) listos para sincronizar con Keycloak

**¿Por qué OrganizationGroup no tiene campo de baja lógica?**
- Los grupos se mantienen implícitamente por las aplicaciones satélite basándose en el `GroupId` de las organizaciones
- Si un grupo queda sin organizaciones, las apps lo eliminan automáticamente de su caché local
- Simplifica la gestión al no requerir operaciones explícitas de alta/baja de grupos
- InfoportOneAdmon puede eliminar grupos huérfanos mediante un job periódico

**¿Por qué EventHashControl tiene clave compuesta?**
- Permite búsqueda rápida del último hash por entidad específica
- Ejemplo: (EntityType='Organization', EntityId='12345') → último hash conocido
- Evita escaneos de tabla completa en cada publicación de evento

**¿Por qué AuditLog usa EntityId como string y no int?**
- Flexibilidad para auditar diferentes tipos de entidades con diferentes tipos de ID
- Permite auditar usuarios (ID UUID de Keycloak) sin cambiar el esquema

> Recomendamos usar mermaid para el modelo de datos, y utilizar todos los parámetros que permite la sintaxis para dar el máximo detalle, por ejemplo las claves primarias y foráneas.


### **3.2. Descripción de entidades principales:**

A continuación se describen en detalle las 9 entidades principales del modelo de datos de InfoportOneAdmon, incluyendo todos sus atributos, tipos, restricciones, relaciones y reglas de negocio.

> **Nota sobre Helix6**: Todas las entidades siguen el estándar del Framework Helix6, con `Id` como PK autonumérica y campos de auditoría automáticos (`AuditCreationUser`, `AuditCreationDate`, `AuditModificationUser`, `AuditModificationDate`, `AuditDeletionDate`).

---

#### **3.2.1. ORGANIZATIONGROUP**

**Propósito**: Representa agrupaciones lógicas de organizaciones como holdings, consorcios, franquicias o grupos empresariales.

**Tabla de Atributos**:

| Nombre Campo | Tipo | Restricciones | Descripción |
|--------------|------|---------------|-------------|
| **Id** | INT | PK, AUTO_INCREMENT, NOT NULL | Identificador único técnico del grupo (PK Helix6). |
| **GroupName** | VARCHAR(200) | UNIQUE, NOT NULL | Nombre del grupo (ej: "Holding Norte", "Consorcio Logístico"). Debe ser único en toda la base de datos. |
| **Description** | VARCHAR(500) | NULL | Descripción opcional del grupo y su propósito. |
| **AuditCreationUser** | VARCHAR(255) | NULL | Email del usuario que creó el grupo. |
| **AuditCreationDate** | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Fecha y hora de creación del grupo. |
| **AuditModificationUser** | VARCHAR(255) | NULL | Email del usuario que modificó el grupo. |
| **AuditModificationDate** | DATETIME | NULL, ON UPDATE CURRENT_TIMESTAMP | Fecha y hora de la última modificación. |
| **AuditDeletionDate** | DATETIME | NULL | Fecha de eliminación lógica (soft delete). NULL = activo. |

**Relaciones**:
- **1:N con Organization**: Un grupo puede contener múltiples organizaciones. Relación opcional (una organización puede no pertenecer a ningún grupo).

**Restricciones de Negocio**:
- El nombre del grupo debe ser único (índice `UX_OrganizationGroup_GroupName`)
- No requiere baja lógica explícita porque los grupos se mantienen implícitamente basándose en las organizaciones que contienen
- Un grupo sin organizaciones puede ser eliminado automáticamente por jobs de limpieza
- Soft delete mediante `AuditDeletionDate` permite recuperar grupos eliminados

**Índices**:
```sql
PK: Id
UK: GroupName
```

**Nota de Diseño**: Los grupos NO tienen eventos propios; se propagan mediante el campo `GroupId` en los `OrganizationEvent`.

---

#### **3.2.2. ORGANIZATION**

**Propósito**: Representa a las organizaciones clientes del ecosistema. Es la entidad central para la multi-tenancy y segregación de datos.

**Tabla de Atributos**:

| Nombre Campo | Tipo | Restricciones | Descripción |
|--------------|------|---------------|-------------|
| **Id** | INT | PK, AUTO_INCREMENT, NOT NULL | Identificador único técnico (PK Helix6). |
| **SecurityCompanyId** | INT | UNIQUE, NOT NULL, AUTO_INCREMENT | Identificador de negocio inmutable. Es el pilar de la seguridad multi-tenant. Se incluye en el claim `c_ids` de los tokens JWT. |
| **GroupId** | INT | FK → OrganizationGroup.Id, NULL | Referencia opcional al grupo al que pertenece. NULL si no pertenece a ningún grupo. |
| **Name** | VARCHAR(200) | UNIQUE, NOT NULL | Nombre comercial de la organización. Debe ser único. |
| **TaxId** | VARCHAR(50) | UNIQUE, NOT NULL | Identificador fiscal (NIF/CIF/RFC). Debe ser único. |
| **Address** | VARCHAR(300) | NULL | Dirección postal completa. |
| **City** | VARCHAR(100) | NULL | Ciudad. |
| **PostalCode** | VARCHAR(20) | NULL | Código postal. |
| **Country** | VARCHAR(100) | NULL | País. |
| **ContactEmail** | VARCHAR(255) | NULL | Email de contacto administrativo. |
| **ContactPhone** | VARCHAR(50) | NULL | Teléfono de contacto. |
| **AuditCreationUser** | VARCHAR(255) | NULL | Email del administrador que creó la organización. |
| **AuditCreationDate** | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Fecha de creación (onboarding). |
| **AuditModificationUser** | VARCHAR(255) | NULL | Email del administrador que realizó la última modificación. |
| **AuditModificationDate** | DATETIME | NULL, ON UPDATE CURRENT_TIMESTAMP | Fecha de última modificación. |
| **AuditDeletionDate** | DATETIME | NULL | Fecha de eliminación lógica (soft delete). |

**Relaciones**:
- **N:1 con OrganizationGroup** (opcional): Una organización puede pertenecer a un grupo. FK: `GroupId`. ON DELETE SET NULL.
- **1:N con ModuleAccess**: Una organización puede tener acceso a múltiples módulos de diferentes aplicaciones.
- **1:N con AuditLog**: Una organización genera múltiples registros de auditoría a lo largo de su ciclo de vida.

**Restricciones de Negocio**:
- `SecurityCompanyId` debe ser único (índice `UX_Organization_SecurityCompanyId`)
- `Name` debe ser único (índice `UX_Organization_Name`)
- `TaxId` debe ser único (índice `UX_Organization_TaxId`)
- `SecurityCompanyId` es inmutable; una vez creado, nunca cambia
- Cuando `AuditDeletionDate != NULL`, la organización está dada de baja y las aplicaciones satélite deben denegar acceso a todos sus usuarios. Al darla de alta (AuditDeletionDate = NULL), se reactiva automáticamente el acceso
- `SecurityCompanyId` se autogenera mediante secuencia independiente de `Id`

**Índices**:
```sql
PK: Id
UK: SecurityCompanyId
UK: Name
UK: TaxId
IX: GroupId
```

**Ejemplo de Registro**:
```sql
Id: 1
SecurityCompanyId: 12345
GroupId: 10
Name: "Transportes Rápidos S.L."
TaxId: "B12345678"
ContactEmail: "admin@transportesrapidos.com"
AuditCreationUser: "admin@infoportone.com"
AuditCreationDate: "2026-01-08 10:00:00"
```

---

#### **3.2.3. APPLICATION**

**Propósito**: Representa las aplicaciones satélite del ecosistema (CRM, ERP, BI, etc.). Define el catálogo de aplicaciones sin almacenar credenciales OAuth2.

**Tabla de Atributos**:

| Nombre Campo | Tipo | Restricciones | Descripción |
|--------------|------|---------------|-------------|
| **Id** | INT | PK, AUTO_INCREMENT, NOT NULL | Identificador único técnico de la aplicación (PK Helix6). |
| **AppName** | VARCHAR(100) | UNIQUE, NOT NULL | Nombre de la aplicación (ej: "CRM", "ERP Financiero"). Debe ser único. |
| **Description** | VARCHAR(500) | NULL | Descripción de la aplicación y su propósito. |
| **RolePrefix** | VARCHAR(10) | UNIQUE, NOT NULL | Prefijo utilizado para roles y módulos (ej: "STP" para Sintraport, "CRM" para CRM). Los módulos usarán "M" + prefijo, los roles usarán solo el prefijo. Debe ser único. |
| **AuditCreationUser** | VARCHAR(255) | NULL | Usuario que creó la aplicación. |
| **AuditCreationDate** | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Fecha de registro de la aplicación. |
| **AuditModificationUser** | VARCHAR(255) | NULL | Usuario que modificó la aplicación. |
| **AuditModificationDate** | DATETIME | NULL, ON UPDATE CURRENT_TIMESTAMP | Fecha de última modificación. |
| **AuditDeletionDate** | DATETIME | NULL | Fecha de eliminación lógica (soft delete). |

**Relaciones**:
- **1:N con Module**: Una aplicación contiene múltiples módulos. FK en Module: `ApplicationId`. ON DELETE CASCADE.
- **1:N con AppRoleDefinition**: Una aplicación define múltiples roles. FK en AppRoleDefinition: `ApplicationId`. ON DELETE CASCADE.
- **1:N con ApplicationSecurity**: Una aplicación puede tener múltiples credenciales OAuth2. FK en ApplicationSecurity: `ApplicationId`. ON DELETE CASCADE.
- **1:N con AuditLog**: Una aplicación genera registros de auditoría.

**Restricciones de Negocio**:
- `AppName` debe ser único (índice `UX_Application_AppName`)
- `RolePrefix` debe ser único (índice `UX_Application_RolePrefix`)
- **Regla de negocio**: Toda aplicación debe tener al menos un módulo (validado a nivel de aplicación)
- **Nomenclatura de roles**: Los roles deben usar el prefijo definido en `RolePrefix`
- **Nomenclatura de módulos**: Los módulos deben usar "M" + `RolePrefix`

**Índices**:
```sql
PK: Id
UK: AppName
UK: RolePrefix
```

**Ejemplo de Registro**:
```sql
Id: 5
AppName: "CRM Comercial"
RolePrefix: "CRM"
AuditCreationUser: "admin@infoportone.com"
```

**Nota importante**: Las credenciales OAuth2 están en `APPLICATIONSECURITY`, no en esta tabla.

---

#### **3.2.4. APPLICATIONSECURITY**

**Propósito**: Almacena credenciales OAuth2 para aplicaciones. Una aplicación puede tener múltiples credenciales (frontend CODE + backend ClientCredentials).

**Tabla de Atributos**:

| Nombre Campo | Tipo | Restricciones | Descripción |
|--------------|------|---------------|-------------|
| **Id** | INT | PK, AUTO_INCREMENT, NOT NULL | Identificador único de la credencial (PK Helix6). |
| **ApplicationId** | INT | FK → Application.Id, NOT NULL | Aplicación a la que pertenece esta credencial. |
| **CredentialType** | VARCHAR(20) | NOT NULL | Tipo de credencial: "CODE" (Angular SPA con PKCE) o "ClientCredentials" (Backend API). |
| **ClientId** | VARCHAR(255) | UNIQUE, NOT NULL | OAuth2 client_id generado (ej: "crm-app-frontend", "crm-api-backend"). |
| **ClientSecretHash** | VARCHAR(255) | NULL | Hash bcrypt del client_secret. NULL para CODE (no requiere secret), obligatorio para ClientCredentials. NUNCA texto plano. |
| **RedirectUris** | TEXT (JSON) | NULL | Array JSON de URIs de redirección (solo para CODE). Ej: `["https://crm.infoportone.com/*"]`. |
| **Scope** | VARCHAR(500) | NULL | Scopes OAuth2 permitidos (ej: "openid profile email"). |
| **AuditCreationUser** | VARCHAR(255) | NULL | Usuario que creó la credencial. |
| **AuditCreationDate** | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Fecha de creación de la credencial. |
| **AuditModificationUser** | VARCHAR(255) | NULL | Usuario que modificó. |
| **AuditModificationDate** | DATETIME | NULL, ON UPDATE CURRENT_TIMESTAMP | Fecha de última modificación. |
| **AuditDeletionDate** | DATETIME | NULL | Fecha de eliminación lógica (soft delete). |

**Relaciones**:
- **N:1 con Application**: Múltiples credenciales pueden pertenecer a una aplicación. FK: `ApplicationId`. ON DELETE CASCADE.

**Restricciones de Negocio**:
- `ClientId` debe ser único (índice `UX_ApplicationSecurity_ClientId`)
- `ClientSecretHash` es NULL para CredentialType="CODE"
- `ClientSecretHash` es obligatorio para CredentialType="ClientCredentials"
- `RedirectUris` solo aplica para CredentialType="CODE"
- El secret nunca se devuelve en APIs; solo se muestra en texto plano en el momento de creación

**Índices**:
```sql
PK: Id
UK: ClientId
IX: ApplicationId
```

**Ejemplos de Registros**:
```sql
-- Credencial CODE (Angular SPA)
Id: 1
ApplicationId: 5
CredentialType: "CODE"
ClientId: "crm-app-frontend"
ClientSecretHash: NULL
RedirectUris: '["https://crm.infoportone.com/*"]'

-- Credencial ClientCredentials (Backend API)
Id: 2
ApplicationId: 5
CredentialType: "ClientCredentials"
ClientId: "crm-api-backend"
ClientSecretHash: "$2a$12$K1.B1/sZQN..." (bcrypt hash)
RedirectUris: NULL
Scope: "read:data write:data"
```

**Ventajas de tabla separada**:
- Permite múltiples credenciales simultáneas (1 CODE + N ClientCredentials)
- Diferentes flujos OAuth2 para frontend y backend
- Dar de baja credenciales mediante AuditDeletionDate las revoca automáticamente en Keycloak
- Historial completo de credenciales con soft delete

---

#### **3.2.5. APPLICATIONMODULE**

**Propósito**: Representa módulos funcionales dentro de una aplicación. Permite habilitar/deshabilitar funcionalidades por organización.

**Tabla de Atributos**:

| Nombre Campo | Tipo | Restricciones | Descripción |
|--------------|------|---------------|-------------|
| **Id** | INT | PK, AUTO_INCREMENT, NOT NULL | Identificador único del módulo (PK Helix6). |
| **ApplicationId** | INT | FK → Application.Id, NOT NULL | Aplicación a la que pertenece el módulo. |
| **ModuleName** | VARCHAR(100) | NOT NULL | Nombre del módulo siguiendo nomenclatura M+RolePrefix (ej: "MSTP_Trafico", "MCRM_Facturacion"). |
| **Description** | VARCHAR(500) | NULL | Descripción de las funcionalidades que ofrece el módulo. |
| **DisplayOrder** | INT | NULL, DEFAULT 0 | Orden de visualización en interfaces (menor número = mayor prioridad). |
| **AuditCreationUser** | VARCHAR(255) | NULL | Usuario que creó el módulo. |
| **AuditCreationDate** | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Fecha de creación del módulo. |
| **AuditModificationUser** | VARCHAR(255) | NULL | Usuario que modificó el módulo. |
| **AuditModificationDate** | DATETIME | NULL, ON UPDATE CURRENT_TIMESTAMP | Fecha de última modificación. |
| **AuditDeletionDate** | DATETIME | NULL | Fecha de eliminación lógica (soft delete). |

**Relaciones**:
- **N:1 con Application**: Un módulo pertenece a una aplicación. FK: `ApplicationId`. ON DELETE CASCADE.
- **1:N con OrganizationApplicationModule**: Un módulo puede asignarse a múltiples organizaciones.

**Restricciones de Negocio**:
- Combinación (`ApplicationId`, `ModuleName`) debe ser única (índice `UX_AppMod_ApplicationId_ModuleName`)
- Toda aplicación debe tener al menos un módulo disponible (AuditDeletionDate = NULL)
- Cuando `AuditDeletionDate != NULL`, el módulo está dado de baja y no se puede asignar a nuevas organizaciones, pero las organizaciones existentes pueden seguir usándolo
- El nombre debe seguir la nomenclatura "M" + RolePrefix de la aplicación

**Índices**:
```sql
PK: Id
UK: (ApplicationId, ModuleName)
IX: ApplicationId
```

**Ejemplo de Registro**:
```sql
Id: 101
ApplicationId: 5
ModuleName: "MCRM_FacturacionElectronica"
Description: "Emisión y gestión de facturas electrónicas con firma digital"
DisplayOrder: 10
```

---

#### **3.2.6. ORGANIZATION_APPLICATIONMODULE**

**Propósito**: Tabla de relación N:M entre módulos y organizaciones. Define qué organizaciones tienen acceso a qué módulos.

**Tabla de Atributos**:

| Nombre Campo | Tipo | Restricciones | Descripción |
|--------------|------|---------------|-------------|
| **Id** | INT | PK, AUTO_INCREMENT, NOT NULL | Identificador único (PK Helix6). |
| **ModuleId** | INT | FK → Module.Id, NOT NULL | Módulo al que se concede acceso. |
| **OrganizationId** | INT | FK → Organization.Id, NOT NULL | Organización que recibe el acceso. |
| **AuditCreationUser** | VARCHAR(255) | NULL | Email del administrador que concedió el acceso. |
| **AuditCreationDate** | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Fecha de creación del registro (fecha de concesión). |
| **AuditModificationUser** | VARCHAR(255) | NULL | Usuario que modificó. |
| **AuditModificationDate** | DATETIME | NULL, ON UPDATE CURRENT_TIMESTAMP | Fecha de modificación. |
| **AuditDeletionDate** | DATETIME | NULL | Fecha de eliminación lógica (revocación de acceso). |

**Relaciones**:
- **N:1 con ApplicationModule**: FK: `ApplicationModuleId`. ON DELETE CASCADE.
- **N:1 con Organization**: FK: `OrganizationId`. ON DELETE CASCADE.

**Restricciones de Negocio**:
- Combinación (`ApplicationModuleId`, `OrganizationId`) debe ser única (índice `UX_OrgAppMod_AppModuleId_OrgId`)
- Una organización no puede tener el mismo módulo asignado dos veces
- Soft delete permite historial de accesos concedidos/revocados mediante `AuditDeletionDate`
- `AuditCreationDate` representa la fecha de concesión del acceso
- Revocación de acceso se realiza mediante soft delete (estableciendo `AuditDeletionDate`)

**Índices**:
```sql
PK: Id
UK: (ApplicationModuleId, OrganizationId)
IX: OrganizationId
```

**Ejemplo de Registro**:
```sql
Id: 5001
ModuleId: 101
OrganizationId: 1
AuditCreationUser: "admin@infoportone.com"
AuditCreationDate: "2026-01-01 10:00:00"
AuditDeletionDate: NULL
```

---

#### **3.2.7. APPLICATIONROLE**

**Propósito**: Catálogo maestro de roles disponibles en cada aplicación. Define "qué roles existen" (no quién los tiene).

**Tabla de Atributos**:

| Nombre Campo | Tipo | Restricciones | Descripción |
|--------------|------|---------------|-------------|
| **Id** | INT | PK, AUTO_INCREMENT, NOT NULL | Identificador único del rol (PK Helix6). |
| **ApplicationId** | INT | FK → Application.Id, NOT NULL | Aplicación a la que pertenece el rol. |
| **RoleName** | VARCHAR(100) | NOT NULL | Nombre del rol siguiendo nomenclatura RolePrefix (ej: "CRM_Vendedor", "STP_AsignadorTransporte"). |
| **Description** | VARCHAR(500) | NULL | Descripción de los permisos y responsabilidades del rol. |
| **AuditCreationUser** | VARCHAR(255) | NULL | Usuario que creó el rol. |
| **AuditCreationDate** | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Fecha de creación del rol. |
| **AuditModificationUser** | VARCHAR(255) | NULL | Usuario que modificó. |
| **AuditModificationDate** | DATETIME | NULL, ON UPDATE CURRENT_TIMESTAMP | Fecha de última modificación. |
| **AuditDeletionDate** | DATETIME | NULL | Fecha de eliminación lógica (soft delete). |

**Relaciones**:
- **N:1 con Application**: Un rol pertenece a una aplicación. FK: `ApplicationId`. ON DELETE CASCADE.

**Restricciones de Negocio**:
- Combinación (`ApplicationId`, `RoleName`) debe ser única (índice `UX_AppRole_ApplicationId_RoleName`)
- Cuando `AuditDeletionDate != NULL`, el rol está dado de baja y no se puede asignar a nuevos usuarios, pero los usuarios existentes pueden mantenerlo
- **Principio de responsabilidad**: InfoportOneAdmon define roles, aplicaciones satélite los asignan a usuarios
- El nombre debe seguir la nomenclatura RolePrefix de la aplicación

**Índices**:
```sql
PK: Id
UK: (ApplicationId, RoleName)
IX: ApplicationId
```

**Ejemplo de Registro**:
```sql
Id: 201
ApplicationId: 5
RoleName: "CRM_GerenteVentas"
Description: "Puede ver y gestionar oportunidades, crear presupuestos y aprobar descuentos hasta 15%"
```

---

#### **3.2.8. USERCACHE**

**Propósito**: Caché de consolidación de usuarios multi-organización y multi-aplicación. Optimiza el proceso del Background Worker.

**Tabla de Atributos**:

| Nombre Campo | Tipo | Restricciones | Descripción |
|--------------|------|---------------|-------------|
| **Id** | INT | PK, AUTO_INCREMENT, NOT NULL | Identificador único (PK Helix6). |
| **Email** | VARCHAR(255) | UNIQUE, NOT NULL | Email del usuario (clave de búsqueda global). |
| **ConsolidatedCompanyIds** | TEXT (JSON) | NOT NULL | JSON array de todos los SecurityCompanyIds del usuario. Ej: `[12345, 67890, 11111]`. |
| **ConsolidatedRoles** | TEXT (JSON) | NOT NULL | JSON array de todos los roles del usuario de todas las aplicaciones. Ej: `["CRM_Vendedor", "ERP_Contable", "STP_AsignadorTransporte"]`. |
| **LastConsolidationDate** | DATETIME | NOT NULL | Timestamp de la última consolidación exitosa. |
| **LastEventHash** | VARCHAR(64) | NULL | Hash SHA-256 del último UserEvent procesado para este usuario. |

**Relaciones**: Ninguna (tabla de caché independiente).

**Restricciones de Negocio**:
- `Email` debe ser único (índice `UX_UserConsolidationCache_Email`)
- Se actualiza cada vez que el Background Worker procesa un UserEvent
- Se utiliza para detectar si un usuario ya existe en otra organización
- Permite consolidación rápida sin consultar múltiples tablas

**Índices**:
```sql
PK: Id
UK: Email
IX: LastConsolidationDate
```

**Ejemplo de Registro**:
```sql
Id: 1
Email: "juan.perez@example.com"
ConsolidatedCompanyIds: "[12345, 67890, 11111]"
ConsolidatedRoles: "[\"CRM_Vendedor\", \"CRM_Gerente\", \"STP_AsignadorTransporte\"]"
LastConsolidationDate: "2026-01-08 15:30:45"
LastEventHash: "a3f5b8c9d2e1f4g6..."
```

**Uso en Background Worker**:
```csharp
// 1. Buscar en caché
var cached = await _cache.FirstOrDefaultAsync(u => u.Email == email);

// 2. Si existe, usar datos consolidados
if (cached != null)
{
    var allCompanies = JsonSerializer.Deserialize<int[]>(cached.ConsolidatedCompanyIds);
    var allRoles = JsonSerializer.Deserialize<string[]>(cached.ConsolidatedRoles);
    // 3. Añadir nueva organización/roles si procede
    // 4. Sincronizar con Keycloak
}
```

---

#### **3.2.9. AUDITLOG**

**Propósito**: Registro inmutable de todas las acciones administrativas realizadas en InfoportOneAdmon.

(La descripción de AUDITLOG se mantiene igual que antes, con `Id` como PK en lugar de `AuditLogId`)

---

#### **3.2.10. EVENTHASH**

**Propósito**: Tabla de control para prevención de duplicados en la publicación de eventos.

(La descripción de EVENTHASH se mantiene igual que antes)

---

#### **Resumen de Entidades**

| Entidad | Propósito | PK | FKs | Restricciones Únicas | Relaciones |
|---------|-----------|----|----|---------------------|------------|
| **OrganizationGroup** | Agrupación de organizaciones | Id | - | GroupName | 1:N con Organization |
| **Organization** | Cliente del ecosistema | Id | GroupId | SecurityCompanyId, Name, TaxId | N:1 con Group, 1:N con ModuleAccess |
| **Application** | App satélite del portfolio | Id | - | AppName, RolePrefix | 1:N con Module, 1:N con AppRole, 1:N con ApplicationSecurity |
| **ApplicationSecurity** | Credenciales OAuth2 | Id | ApplicationId | ClientId | N:1 con Application |
| **Module** | Módulo funcional de app | Id | ApplicationId | (ApplicationId, ModuleName) | N:1 con App, 1:N con ModuleAccess |
| **ModuleAccess** | Acceso módulo-organización | Id | ModuleId, OrganizationId | (ModuleId, OrganizationId) | N:1 con Module y Organization |
| **AppRoleDefinition** | Catálogo de roles | Id | ApplicationId | (ApplicationId, RoleName) | N:1 con Application |
| **UserConsolidationCache** | Caché consolidación usuarios | Id | - | Email | Ninguna (caché) |
| **AuditLog** | Registro de auditoría | Id | - | - | N:1 lógico con todas las entidades |
| **EventHashControl** | Control de duplicados | (EntityType, EntityId) | - | - | Ninguna (tabla de control) |

**Relaciones**:
- **1:N con Module**: Una aplicación contiene múltiples módulos. FK en Module: `AppId`. ON DELETE CASCADE (si se elimina la app, se eliminan sus módulos).
- **1:N con AppRoleDefinition**: Una aplicación define múltiples roles. FK en AppRoleDefinition: `AppId`. ON DELETE CASCADE.
- **1:N con AuditLog**: Una aplicación genera registros de auditoría.

**Restricciones de Negocio**:
- `AppName` debe ser único (índice `UX_Application_AppName`)
- `RolePrefix` debe ser único (índice `UX_Application_RolePrefix`) y se utiliza como prefijo para nomenclatura de roles y módulos
- `ClientId` debe ser único (índice `UX_Application_ClientId`)
- **Regla de negocio**: Toda aplicación debe tener al menos un módulo (validado a nivel de aplicación)
- `ClientSecretHash` es NULL para public clients (Angular SPAs con PKCE)
- `ClientSecretHash` es obligatorio para confidential clients (APIs backend)
- `ClientSecretHash` nunca se devuelve en APIs; solo se muestra el secreto en texto plano en el momento de creación de confidential clients
- Public clients (Angular) usan PKCE y no almacenan secretos
- **Nomenclatura de roles**: Los roles de la aplicación deben usar el prefijo definido en `RolePrefix` (ej: si RolePrefix="STP", entonces roles como "STP_AsignadorTransporte", "STP_Supervisor")
- **Nomenclatura de módulos**: Los módulos de la aplicación deben usar "M" + `RolePrefix` (ej: si RolePrefix="STP", entonces módulos como "MSTP_Trafico", "MSTP_Almacen")

**Índices**:
```sql
PK: AppId
UK: AppName
UK: RolePrefix
UK: ClientId
```

**Ejemplo de Registro (Public Client - Angular SPA)**:
```sql
AppId: 5
AppName: "CRM Comercial Frontend"
RolePrefix: "CRM"
ClientId: "crm-app-frontend"
IsPublicClient: TRUE
ClientSecretHash: NULL
RedirectUris: '["https://crm.infoportone.com/*"]'
```

**Ejemplo de Registro (Confidential Client - Backend API)**:
```sql
AppId: 6
AppName: "CRM Comercial API"
RolePrefix: "CRM"
ClientId: "crm-api-backend"
IsPublicClient: FALSE
ClientSecretHash: "$2a$12$K1.B1/sZQN..." (bcrypt hash)
RedirectUris: NULL
```

**Ejemplo de Registro (Aplicación Sintraport)**:
```sql
AppId: 7
AppName: "Sintraport"
RolePrefix: "STP"
ClientId: "sintraport-app"
IsPublicClient: TRUE
ClientSecretHash: NULL
RedirectUris: '["https://sintraport.infoportone.com/*"]'
```
> Con este RolePrefix="STP", los roles serán como "STP_AsignadorTransporte", "STP_Supervisor" y los módulos como "MSTP_Trafico", "MSTP_Almacen"

---

#### **3.2.4. APPLICATIONMODULE (duplicado)**

**Propósito**: Representa módulos funcionales dentro de una aplicación. Permite habilitar/deshabilitar funcionalidades por organización.

**Tabla de Atributos**:

| Nombre Campo | Tipo | Restricciones | Descripción |
|--------------|------|---------------|-------------|
| **ModuleId** | INT | PK, AUTO_INCREMENT, NOT NULL | Identificador único del módulo. |
| **AppId** | INT | FK → Application.AppId, NOT NULL | Aplicación a la que pertenece el módulo. |
| **ModuleName** | VARCHAR(100) | NOT NULL | Nombre del módulo (ej: "Módulo Facturación", "Módulo Reporting Avanzado"). |
| **Description** | VARCHAR(500) | NULL | Descripción de las funcionalidades que ofrece el módulo. |
| **DisplayOrder** | INT | NULL, DEFAULT 0 | Orden de visualización en interfaces (menor número = mayor prioridad). |
| **CreatedAt** | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Fecha de creación del módulo. |
| **UpdatedAt** | DATETIME | NULL, ON UPDATE CURRENT_TIMESTAMP | Fecha de última modificación. |

**Relaciones**:
- **N:1 con Application**: Un módulo pertenece a una aplicación. FK: `AppId`. ON DELETE CASCADE.
- **1:N con ModuleAccess**: Un módulo puede asignarse a múltiples organizaciones.

**Restricciones de Negocio**:
- Combinación (`AppId`, `ModuleName`) debe ser única (índice `UX_Module_AppId_ModuleName`)
- Toda aplicación debe tener al menos un módulo disponible
- Cuando un módulo está dado de baja (soft delete), no se puede asignar a nuevas organizaciones, pero las organizaciones existentes pueden seguir usándolo

**Índices**:
```sql
PK: ModuleId
UK: (AppId, ModuleName)
IX: AppId
```

**Ejemplo de Registro**:
```sql
ModuleId: 101
AppId: 5
ModuleName: "Módulo Facturación Electrónica"
Description: "Emisión y gestión de facturas electrónicas con firma digital"
DisplayOrder: 10
```

---

#### **3.2.5. ORGANIZATION_APPLICATIONMODULE (duplicado)**

**Propósito**: Tabla de relación N:M entre módulos y organizaciones. Define qué organizaciones tienen acceso a qué módulos.

**Tabla de Atributos**:

| Nombre Campo | Tipo | Restricciones | Descripción |
|--------------|------|---------------|-------------|
| **ModuleAccessId** | INT | PK, AUTO_INCREMENT, NOT NULL | Identificador único del registro de acceso. |
| **ModuleId** | INT | FK → Module.ModuleId, NOT NULL | Módulo al que se concede acceso. |
| **SecurityCompanyId** | INT | FK → Organization.SecurityCompanyId, NOT NULL | Organización que recibe el acceso. |
| **GrantedAt** | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Fecha y hora en que se concedió el acceso. |
| **GrantedBy** | VARCHAR(255) | NULL | Email del administrador que concedió el acceso. |
| **ExpiresAt** | DATETIME | NULL | Fecha de expiración del acceso (para licencias temporales). NULL = sin expiración. |

**Relaciones**:
- **N:1 con Module**: FK: `ModuleId`. ON DELETE CASCADE.
- **N:1 con Organization**: FK: `SecurityCompanyId`. ON DELETE CASCADE.

**Restricciones de Negocio**:
- Combinación (`ModuleId`, `SecurityCompanyId`) debe ser única (índice `UX_ModuleAccess_Module_Company`)
- Una organización no puede tener el mismo módulo asignado dos veces
- Si `ExpiresAt` está en el pasado, las aplicaciones deben denegar acceso al módulo

**Índices**:
```sql
PK: ModuleAccessId
UK: (ModuleId, SecurityCompanyId)
IX: SecurityCompanyId
IX: ExpiresAt
```

**Ejemplo de Registro**:
```sql
ModuleAccessId: 5001
ModuleId: 101
SecurityCompanyId: 12345
GrantedAt: "2026-01-01 10:00:00"
GrantedBy: "admin@infoportone.com"
ExpiresAt: NULL
```

**Uso en Aplicaciones**:
Las aplicaciones satélite consultan esta relación (sincronizada vía `OrganizationEvent`) para validar si una organización puede acceder a un módulo específico mediante la presencia del registro activo (no soft-deleted).

---

#### **3.2.6. APPLICATIONROLE (duplicado)**

**Propósito**: Catálogo maestro de roles disponibles en cada aplicación. Define "qué roles existen" (no quién los tiene).

**Tabla de Atributos**:

| Nombre Campo | Tipo | Restricciones | Descripción |
|--------------|------|---------------|-------------|
| **RoleId** | INT | PK, AUTO_INCREMENT, NOT NULL | Identificador único del rol. |
| **AppId** | INT | FK → Application.AppId, NOT NULL | Aplicación a la que pertenece el rol. |
| **RoleName** | VARCHAR(100) | NOT NULL | Nombre del rol (ej: "Vendedor", "Gerente", "Administrador"). |
| **Description** | VARCHAR(500) | NULL | Descripción de los permisos y responsabilidades del rol. |
| **CreatedAt** | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Fecha de creación del rol. |
| **UpdatedAt** | DATETIME | NULL, ON UPDATE CURRENT_TIMESTAMP | Fecha de última modificación. |

**Relaciones**:
- **N:1 con Application**: Un rol pertenece a una aplicación. FK: `AppId`. ON DELETE CASCADE.

**Restricciones de Negocio**:
- Combinación (`AppId`, `RoleName`) debe ser única (índice `UX_AppRole_AppId_RoleName`)
- Cuando un rol está dado de baja (soft delete), no se puede asignar a nuevos usuarios, pero los usuarios existentes pueden mantenerlo
- **Principio de responsabilidad**: InfoportOneAdmon define roles, aplicaciones satélite los asignan a usuarios

**Índices**:
```sql
PK: Id
UK: (ApplicationId, RoleName)
IX: ApplicationId
```

**Ejemplo de Registro**:
```sql
Id: 201
ApplicationId: 5
RoleName: "CRM_GerenteVentas"
Description: "Puede ver y gestionar oportunidades, crear presupuestos y aprobar descuentos hasta 15%"
```

**Sincronización**: Los roles se sincronizan como parte del `ApplicationEvent`, no tienen evento propio.

---

#### **3.2.7. AUDITLOG (duplicado)**

**Propósito**: Registro inmutable de todas las acciones administrativas realizadas en InfoportOneAdmon. Esencial para compliance y auditorías.

> **Nota importante sobre Helix6**: Como todas las entidades, AUDIT_LOG también tiene campos de auditoría Helix6 que registran quién crea/modifica los registros de log (meta-auditoría). El usuario que ejecutó la acción original sobre la entidad está en los campos `AuditCreationUser`/`AuditModificationUser` de esa entidad.

**Tabla de Atributos**:

| Nombre Campo | Tipo | Restricciones | Descripción |
|--------------|------|---------------|-------------|
| **Id** | BIGINT | PK, AUTO_INCREMENT, NOT NULL | Identificador único del registro de auditoría (PK Helix6). |
| **EntityType** | VARCHAR(50) | NOT NULL | Tipo de entidad afectada ("Organization", "Application", "Module", "AppRoleDefinition"). |
| **EntityId** | VARCHAR(100) | NOT NULL | ID de la entidad afectada (como string para flexibilidad). |
| **Action** | VARCHAR(20) | NOT NULL | Acción realizada: "INSERT", "UPDATE", "DELETE". |
| **Timestamp** | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Momento exacto en que se ejecutó la acción (UTC). |
| **OldValue** | TEXT (JSON) | NULL | Estado anterior de la entidad en formato JSON. NULL en INSERT. |
| **NewValue** | TEXT (JSON) | NULL | Estado posterior de la entidad en formato JSON. NULL en DELETE. |
| **AuditCreationUser** | VARCHAR(255) | NULL | Usuario del sistema que creó el log (meta-auditoría). |
| **AuditCreationDate** | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Fecha de creación del log. |
| **AuditModificationUser** | VARCHAR(255) | NULL | Usuario que modificó el log (normalmente NULL, tabla append-only). |
| **AuditModificationDate** | DATETIME | NULL | Fecha de modificación (normalmente NULL). |
| **AuditDeletionDate** | DATETIME | NULL | Soft delete (para archivado de logs antiguos). |

**Relaciones**:
- **N:1 con Organization** (lógica): Múltiples logs pueden referenciar la misma organización.
- **N:1 con Application** (lógica): Múltiples logs pueden referenciar la misma aplicación.

**Restricciones de Negocio**:
- **Tabla append-only**: NO se permite UPDATE ni DELETE. Solo INSERT.
- Los registros son inmutables para garantizar integridad de auditoría
- `EntityId` es string para soportar diferentes tipos de ID (int, UUID, etc.)

**Índices**:
```sql
PK: Id
IX: (EntityType, EntityId)
IX: Timestamp DESC
```

**Ejemplo de Registro**:
```sql
Id: 987654
EntityType: "Organization"
EntityId: "1"
Action: "UPDATE"
Timestamp: "2026-01-08 14:35:22"
OldValue: '{"Name": "ACME Corp"}'
NewValue: '{"Name": "ACME Corporation"}'
AuditCreationUser: "system"
AuditCreationDate: "2026-01-08 14:35:22"
AuditModificationUser: NULL
AuditModificationDate: NULL
AuditDeletionDate: NULL
```

> **Nota**: Para saber QUIÉN modificó esta organización, se consulta `ORGANIZATION.AuditModificationUser` donde `Id = 1`. Los campos de auditoría de AUDITLOG son meta-auditoría del propio log.

**Uso en Compliance**:
- Rastrear cambios en configuración de módulos y permisos (estados antes/después)
- Responder a auditorías regulatorias (GDPR Article 30, ISO 27001)
- Análisis forense de cambios críticos en el sistema
- El "quién hizo el cambio" se obtiene de los campos `AuditCreationUser`/`AuditModificationUser` de la entidad modificada
- Los campos de auditoría de AUDITLOG permiten rastrear quién/cuándo se creó el registro de log (meta-auditoría)

---

#### **3.2.8. EVENTHASH (duplicado)**

**Propósito**: Tabla de control para prevención de duplicados en la publicación de eventos. Almacena el hash SHA-256 del último evento publicado para cada entidad.

**Tabla de Atributos**:

| Nombre Campo | Tipo | Restricciones | Descripción |
|--------------|------|---------------|-------------|
| **EntityType** | VARCHAR(50) | PK (compuesta), NOT NULL | Tipo de entidad ("Organization", "Application", "User"). |
| **EntityId** | VARCHAR(100) | PK (compuesta), NOT NULL | ID de la entidad (como string para flexibilidad). |
| **LastEventHash** | VARCHAR(64) | NOT NULL | Hash SHA-256 (en Base64) del último `Payload` publicado para esta entidad. |
| **LastEventTimestamp** | DATETIME | NOT NULL | Timestamp del último evento publicado. |

**Clave Primaria Compuesta**: (`EntityType`, `EntityId`)

**Relaciones**: 
- No tiene FKs explícitas, pero lógicamente referencia a Organization, Application y usuarios de Keycloak.

**Restricciones de Negocio**:
- **Unicidad garantizada por PK compuesta**: Solo puede haber un registro por combinación (EntityType, EntityId)
- El hash se calcula sobre el `Payload` del evento (excluyendo `EventId`, `EventTimestamp`, `TraceId`)
- Si el hash coincide con `LastEventHash`, el evento NO se publica al broker

**Índices**:
```sql
PK: (EntityType, EntityId)
IX: LastEventTimestamp DESC
```

**Ejemplo de Registro**:
```sql
EntityType: "Organization"
EntityId: "12345"
LastEventHash: "a3f5b8c9d2e1f4g6h7i8j9k0l1m2n3o4p5q6r7s8t9u0v1w2x3y4z5a6b7c8d9e0f1"
LastEventTimestamp: "2026-01-08 15:20:45"
```

**Algoritmo de Prevención de Duplicados**:
```csharp
// 1. Calcular hash del Payload actual
var currentHash = ComputeSHA256Hash(payload);

// 2. Consultar EventHashControl
var control = await _db.EventHashControls
    .FirstOrDefaultAsync(e => e.EntityType == "Organization" && e.EntityId == "12345");

// 3. Comparar hashes
if (control != null && control.LastEventHash == currentHash)
{
    // NO publicar: los datos no han cambiado
    _logger.LogInformation("Event skipped (duplicate hash): {EntityType}/{EntityId}", entityType, entityId);
    return;
}

// 4. Publicar evento y actualizar control
await _eventPublisher.Publish(event);
await UpdateEventHashControl(entityType, entityId, currentHash, DateTime.UtcNow);
```

**Beneficios**:
- Reduce tráfico en ActiveMQ Artemis (solo eventos con cambios reales)
- Evita procesamiento innecesario en aplicaciones satélite
- Previene cascadas infinitas de actualizaciones circulares

---

#### **Resumen de Entidades**

| Entidad | Propósito | PK | FKs | Restricciones Únicas | Relaciones |
|---------|-----------|----|----|---------------------|------------|
| **OrganizationGroup** | Agrupación de organizaciones | Id | - | GroupName | 1:N con Organization |
| **Organization** | Cliente del ecosistema | Id | GroupId | SecurityCompanyId, Name, TaxId | N:1 con Group, 1:N con ModuleAccess |
| **Application** | App satélite del portfolio | Id | - | AppName, RolePrefix | 1:N con Module, 1:N con AppRole, 1:N con ApplicationSecurity |
| **ApplicationSecurity** | Credenciales OAuth2 | Id | ApplicationId | ClientId | N:1 con Application |
| **Module** | Módulo funcional de app | Id | ApplicationId | (ApplicationId, ModuleName) | N:1 con App, 1:N con ModuleAccess |
| **ModuleAccess** | Acceso módulo-organización | Id | ModuleId, OrganizationId | (ModuleId, OrganizationId) | N:1 con Module y Organization |
| **AppRoleDefinition** | Catálogo de roles | Id | ApplicationId | (ApplicationId, RoleName) | N:1 con Application |
| **UserConsolidationCache** | Caché consolidación usuarios | Id | - | Email | Ninguna (caché) |
| **AuditLog** | Registro de auditoría | Id | - | - | N:1 lógico con todas las entidades |
| **EventHashControl** | Control de duplicados | (EntityType, EntityId) | - | - | Ninguna (tabla de control) |

> Recuerda incluir el máximo detalle de cada entidad, como el nombre y tipo de cada atributo, descripción breve si procede, claves primarias y foráneas, relaciones y tipo de relación, restricciones (unique, not null…), etc.

---

## 4. Especificación de la API

> Si tu backend se comunica a través de API, describe los endpoints principales (máximo 3) en formato OpenAPI. Opcionalmente puedes añadir un ejemplo de petición y de respuesta para mayor claridad

---

## 5. Historias de Usuario

#### ORG-001: Crear y editar organización cliente

**Épica:** Gestión del Portfolio de Organizaciones Clientes
**Rol:** OrganizationManager
**Prioridad:** Alta | **Estimación:** 5 Story Points

**Historia:**
```
Como OrganizationManager responsable del onboarding de clientes,
quiero crear y editar una organización cliente completando un formulario simple con sus datos básicos (nombre, CIF, dirección, contacto),
para gestionar su incorporación al ecosistema y mantener sus datos actualizados sin errores que afecten al acceso a las aplicaciones.
```

**Contexto adicional:**

El onboarding rápido y sin errores reduce el tiempo de activación y la carga de soporte; es crítico validar datos al crear o editar una organización, asignar un `SecurityCompanyId` seguro y evitar la publicación de eventos hasta que se asignen permisos y módulos.

**Criterios de aceptación:**

- La organización se persiste en la base de datos y recibe un `SecurityCompanyId` generado por la secuencia PostgreSQL.
- No se publica ningún `OrganizationEvent` al crear o editar la organización salvo cuando se asignan módulos.
- Validaciones frontend y backend previenen datos inválidos y el backend devuelve HTTP 400 en caso de validación.
- No se permite crear organizaciones con `CIF` duplicado.
- La API devuelve HTTP 201/200 con la entidad organización actualizada con los identificadores nuevos asignados.
- Se incluyen tests unitarios e integración que cubran creación, edición, validaciones y ausencia de publicación de eventos cuando no correspondan.

**Requisitos no funcionales:**

- Rendimiento: la operación de creación/edición debe responder en menos de 2 segundos en condiciones normales de carga.
- Consistencia/Concurrencia: `SecurityCompanyId` se debe generar mediante secuencia PostgreSQL para evitar colisiones en entornos concurrentes.
- Seguridad: sólo usuarios con rol `OrganizationManager` (o roles con permisos adecuados) pueden crear/editar organizaciones.
- Fiabilidad: la operación debe ser atómica; ante fallo no debe quedar estado parcial en la base de datos.
- Escalabilidad: el diseño debe soportar picos de altas creaciones/ediciones (batchs) sin degradar la generación de identificadores.
- Accesibilidad: la UI del formulario debe cumplir WCAG 2.1 AA para los campos básicos.

**Definición de hecho (DoD):**
- Código implementado y revisado
- Tests unitarios e integración
- Validaciones de frontend y backend funcionando
- Organización creada/actualizada sin publicar evento cuando no procede

**Dependencias:** Ninguna

**Notas técnicas:**
- Usar EF Core, `SecurityCompanyId` por secuencia PostgreSQL
- NO publicar `OrganizationEvent` al crear o editar salvo cuando se asignen módulos



**Historia de Usuario 2**

**Historia de Usuario 3**



## 6. Tickets de Trabajo

### ORG001-T001-FE: Implementar formulario de creación y edición de organización con tres pestañas

**TICKET ID:** ORG001-T001-FE
**EPIC:** Gestión del Portfolio de Organizaciones Clientes  
**USER STORY:** ORG-001 - Crear y editar organización cliente  
**COMPONENT:** Frontend - Angular  
**PRIORITY:** Alta  
**ESTIMATION:** 6 horas  

#### TÍTULO
Implementar formulario de creación y edición de organización con Angular Material Tabs y validación por pestaña

#### DESCRIPCIÓN
Crear componente Angular para el formulario de creación/edición de organizaciones con estructura de tres pestañas según arquitectura Helix6.

**Pestaña 1 - Datos de Organización:**
- Editable por: Usuarios con permiso `Organization data modification`
- Solo lectura para: Usuarios con permiso `Organization data query` (sin modification)
- Campos: Name, TaxId (CIF), Address, City, PostalCode, Country, ContactEmail, ContactPhone, GroupId
- Validaciones: Name, TaxId, ContactEmail obligatorios
- Al guardar: **NO se publica evento OrganizationEvent**, solo se persiste en BD
- Aparece Pestaña 2 después de guardar si el usuario tiene permiso `Organization modules query` o `Organization modules modification`
 
Nota: El campo `GroupId` se mostrará como un combo desplegable. Las opciones se cargarán desde el endpoint Helix6 `OrganizationGroupClient.getAll()`.

**Pestaña 2 - Módulos y Permisos de Acceso:**
- Editable por: Usuarios con permiso `Organization modules modification`
- Solo lectura para: Usuarios con permiso `Organization modules query` (sin modification)
- Gestión de módulos/aplicaciones asignados mediante grid anidado con inline editing
- **PRIMER evento OrganizationEvent se publica aquí** al asignar el primer módulo a través de la tabla `ORGANIZATION_APPLICATIONMODULE`
- Grid master-detail: Columnas Application (ApplicationId, AppName), Módulos asignados (multiselect de ApplicationModule filtrados por ApplicationId)
- Relación N:M gestionada mediante `ORGANIZATION_APPLICATIONMODULE` (ApplicationModuleId, OrganizationId)

**Pestaña 3 - Auditoría:**
- Solo lectura para: Usuarios con permiso `Organization data query`
- Muestra histórico de cambios críticos desde tabla `AUDITLOG`
- Grid readonly con columnas: Timestamp, Action, UserId (nombre usuario), CorrelationId
- Filtrado server-side: `EntityType='Organization' AND EntityId={organizationId}`
- Acciones auditadas (Epic1): `ModuleAssigned`, `ModuleRemoved`, `OrganizationDeactivatedManual`, `OrganizationAutoDeactivated`, `OrganizationReactivatedManual`, `GroupChanged`
- Paginación server-side obligatoria (tabla puede contener miles de registros)

**Nota sobre eventos**: Los cambios en datos básicos (pestaña 1) NO publican eventos. Solo se publican eventos `OrganizationEvent` cuando:
- Se asigna/remueve un módulo (pestaña 2)
- Se activa/desactiva la organización
- Se cambia el grupo de la organización

#### ROLES Y PERMISOS

Esta funcionalidad requiere un control granular de acceso basado en permisos. A continuación se detallan los roles típicos del sistema y los permisos necesarios para cada nivel de acceso.

##### Permisos Requeridos

Añadir al enum `Access` en `src/app/theme/access/access.ts`:

| Permiso | Valor Sugerido | Descripción | Funcionalidad |
|---------|----------------|-------------|---------------|
| `Organization data modification` | 200 | Modificar datos de organización | Crear/editar nombre, TaxId, dirección y datos de contacto de organizaciones en Pestaña 1 |
| `Organization data query` | 201 | Consultar datos de organización | Ver en modo solo lectura los datos básicos de organizaciones (Pestaña 1) y acceso a Pestaña 3 (Auditoría) |
| `Organization modules modification` | 202 | Modificar módulos de organización | Asignar/desasignar módulos y aplicaciones a organizaciones en Pestaña 2 |
| `Organization modules query` | 203 | Consultar módulos de organización | Ver en modo solo lectura los módulos asignados a organizaciones en Pestaña 2 |

##### Roles y Combinaciones de Permisos

| Rol | Permisos Asociados | Nivel de Acceso | Pestañas Disponibles |
|-----|-------------------|-----------------|----------------------|
| **Organization Administrator** | • `Organization data modification` (200)<br>• `Organization data query` (201)<br>• `Organization modules modification` (202)<br>• `Organization modules query` (203) | **Acceso completo**: Puede crear/editar organizaciones, gestionar todos los módulos asignados y consultar auditoría | Pestaña 1 (Editable)<br>Pestaña 2 (Editable)<br>Pestaña 3 (Solo lectura) |
| **Organization Manager** | • `Organization data modification` (200)<br>• `Organization data query` (201) | **Gestión de datos**: Puede crear/editar datos básicos de organizaciones. Solo puede **visualizar** módulos asignados (no modificarlos) | Pestaña 1 (Editable)<br>Pestaña 2 (Solo lectura)<br>Pestaña 3 (Solo lectura) |
| **Application Manager** | • `Organization modules modification` (202)<br>• `Organization modules query` (203)<br>• `Organization data query` (201) | **Gestión de módulos**: Puede asignar/modificar módulos. Solo puede **visualizar** datos básicos de organizaciones (no modificarlos) | Pestaña 1 (Solo lectura)<br>Pestaña 2 (Editable)<br>Pestaña 3 (Solo lectura) |
| **Organization Viewer** | • `Organization data query` (201)<br>• `Organization modules query` (203) | **Solo lectura completa**: Puede ver toda la información pero no puede realizar modificaciones | Pestaña 1 (Solo lectura)<br>Pestaña 2 (Solo lectura)<br>Pestaña 3 (Solo lectura) |
| **Data Viewer** | • `Organization data query` (201) | **Lectura limitada**: Solo puede ver datos básicos y auditoría, sin acceso a módulos | Pestaña 1 (Solo lectura)<br>Pestaña 2 (Oculta)<br>Pestaña 3 (Solo lectura) |

##### Matriz de Control de UI por Permiso

| Elemento UI | Permiso Requerido | Estado sin Permiso | Estado con Permiso Query | Estado con Permiso Modification |
|-------------|-------------------|--------------------|--------------------------|---------------------------------|
| **Pestaña 1 - Formulario** | `Organization data query` | Oculto / Error | Solo lectura (campos disabled) | Editable (campos enabled) |
| **Pestaña 1 - Botón Guardar** | `Organization data modification` | Oculto | Oculto | Visible y habilitado |
| **Pestaña 1 - Combo Grupo** | `Organization data query` | Oculto | Solo lectura (disabled) | Editable (enabled) |
| **Pestaña 2 - Tab** | `Organization modules query` | Oculta | Visible | Visible |
| **Pestaña 2 - Grid Módulos** | `Organization modules query` | N/A | Solo lectura (sin inline edit) | Editable (inline edit habilitado) |
| **Pestaña 2 - Botón Asignar Módulo** | `Organization modules modification` | Oculto | Oculto | Visible y habilitado |
| **Pestaña 2 - Botón Remover Módulo** | `Organization modules modification` | Oculto | Oculto | Visible y habilitado |
| **Pestaña 3 - Tab Auditoría** | `Organization data query` | Oculta | Visible (solo lectura) | Visible (solo lectura) |
| **Pestaña 3 - Grid Auditoría** | `Organization data query` | N/A | Solo lectura (siempre) | Solo lectura (siempre) |

##### Flujo de Trabajo Recomendado

**Caso 1: Creación completa por Organization Administrator**
1. Usuario con permisos 200, 201, 202, 203 accede al formulario
2. Completa Pestaña 1 (Datos de Organización) → Guarda (sin publicar evento)
3. Automáticamente puede acceder a Pestaña 2 (Módulos)
4. Asigna módulos mediante grid inline → Guarda → **Se publica el primer OrganizationEvent**
5. Puede consultar Pestaña 3 (Auditoría) para ver acción `ModuleAssigned`

**Caso 2: Creación colaborativa (Organization Manager + Application Manager)**
1. Organization Manager (permisos 200, 201) crea organización en Pestaña 1 → Guarda
2. Organization Manager puede ver Pestaña 2 pero en **solo lectura** y Pestaña 3
3. Application Manager (permisos 201, 202, 203) accede a la organización creada
4. Application Manager puede ver Pestaña 1 en **solo lectura**
5. Application Manager edita Pestaña 2 y asigna módulos → Guarda → **Se publica el primer OrganizationEvent**
6. Ambos roles pueden consultar Pestaña 3 para ver histórico de cambios

**Caso 3: Consulta (Organization Viewer)**
- Usuario con permisos 201, 203 puede navegar por las 3 pestañas
- Todos los campos y grids están en modo **solo lectura**
- No se muestran botones de guardar/editar/asignar/remover

**Caso 4: Consulta limitada (Data Viewer)**
- Usuario con permiso 201 solo ve Pestaña 1 y Pestaña 3 en **solo lectura**
- Pestaña 2 está **oculta** (no tiene permiso 203)

##### Validación de Permisos en UI

El componente debe implementar las siguientes validaciones usando `AccessService`:

```typescript
// Pseudocódigo de validación
canViewBasicData = accessService.hasAccess(Access['Organization data query']);
canEditBasicData = accessService.hasAccess(Access['Organization data modification']);
canViewModules = accessService.hasAccess(Access['Organization modules query']);
canEditModules = accessService.hasAccess(Access['Organization modules modification']);
```

**Mensajes de estado:**
- **Sin permisos de query**: Mensaje de error "No tiene permisos para ver esta información"
- **Solo permisos de query**: Mensaje informativo "Visualización en modo solo lectura"
- **Con permisos de modification**: Sin mensaje (modo edición normal)

**Nota importante:** Los permisos deben configurarse en backend y asociarse a usuarios/roles mediante la gestión de identidad (Keycloak). El frontend solo verifica los permisos recibidos desde la API `GetPermissions`.

#### BACKEND Y CONTRATO HELIX6

El frontend utilizará los endpoints genéricos de Helix6 auto-generados para la entidad `Organization`. A continuación se detallan los endpoints específicos, sus configuraciones de carga y el comportamiento esperado.

##### Endpoints Utilizados

###### 1. GetById - Cargar Organización Existente

**Endpoint**: `GET /api/Organization/GetById`

**Parámetros**:
- `id` (int, required): ID de la organización
- `configurationName` (string, required): `"OrganizationComplete"`
- `Accept-Language` (header): Idioma del usuario (es, en, ca)

**Configuración de Carga `OrganizationComplete`**:

Esta configuración debe definirse en el `OrganizationRepository` del backend y carga:

1. **Entidad base Organization**: Todos los campos de la tabla `ORGANIZATION`
   - Id, SecurityCompanyId, Name, TaxId, Address, City, PostalCode, Country, ContactEmail, ContactPhone
   - GroupId (FK), AuditCreationUser, AuditCreationDate, AuditModificationUser, AuditModificationDate, AuditDeletionDate

2. **Navegación OrganizationGroup**: Carga el grupo asociado si `GroupId != null`
   - Incluye: Id, GroupName, Description

3. **Colección ApplicationModules**: Carga todos los módulos asignados mediante tabla `ORGANIZATION_APPLICATIONMODULE`
   - Para cada registro activo (AuditDeletionDate IS NULL):
     - ApplicationModuleId (FK)
     - **Navegación ApplicationModule**: ModuleName, Description, DisplayOrder, ApplicationId (FK)
       - **Navegación anidada Application**: AppName, Description, RolePrefix

4. **Colección AuditLogs**: Carga histórico de auditoría filtrado
   - Filtro: `EntityType='Organization' AND EntityId={id} AND AuditDeletionDate IS NULL`
   - Ordenado por: Timestamp DESC
   - Incluye: Id, Action, EntityType, EntityId, UserId, Timestamp, CorrelationId

**Response esperado** (OrganizationView):
```typescript
{
  id: number;
  securityCompanyId: number;
  name: string;
  taxId: string;
  address?: string;
  city?: string;
  postalCode?: string;
  country?: string;
  contactEmail?: string;
  contactPhone?: string;
  groupId?: number;
  organizationGroup?: {
    id: number;
    groupName: string;
    description?: string;
  };
  applicationModules?: [
    {
      id: number; // ORGANIZATION_APPLICATIONMODULE.Id
      applicationModuleId: number;
      applicationModule: {
        id: number;
        moduleName: string;
        description?: string;
        displayOrder: number;
        applicationId: number;
        application: {
          id: number;
          appName: string;
          description?: string;
          rolePrefix: string;
        };
      };
    }
  ];
  auditLogs?: [
    {
      id: number;
      action: string;
      entityType: string;
      entityId: string;
      userId?: number;
      timestamp: Date;
      correlationId?: string;
    }
  ];
  auditCreationDate: Date;
  auditModificationDate?: Date;
}
```

###### 2. GetNewEntity - Obtener Plantilla para Nueva Organización

**Endpoint**: `GET /api/Organization/GetNewEntity`

**Parámetros**:
- `Accept-Language` (header): Idioma del usuario

**Response esperado**: OrganizationView con valores por defecto (todos los campos null excepto colecciones vacías)

**Uso**: Al abrir el formulario en modo creación para inicializar el FormGroup con valores vacíos.

###### 3. Insert - Crear Nueva Organización

**Endpoint**: `POST /api/Organization/Insert`

**Parámetros**:
- `configurationName` (string, required): `"OrganizationComplete"`
- `reloadView` (bool, optional): `true` (para recibir entidad con Id generado)
- `Accept-Language` (header): Idioma del usuario

**Body**: OrganizationView completo (igual estructura que GetById response)

**Comportamiento esperado según permisos del usuario**:

1. **Si el usuario tiene permiso `Organization data modification` (200)**:
   - El backend persiste los campos de la Pestaña 1 (Name, TaxId, Address, etc.)
   - Genera automáticamente `SecurityCompanyId` (auto-increment)
   - **NO persiste** la colección `ApplicationModules` (aunque se envíe en el payload)
   - **NO publica** evento `OrganizationEvent`
   - Retorna OrganizationView con Id y SecurityCompanyId generados

2. **Si el usuario tiene permiso `Organization modules modification` (202)**:
   - Si se envía la colección `ApplicationModules` en el payload:
     - Persiste relaciones en tabla `ORGANIZATION_APPLICATIONMODULE`
     - **Publica evento `OrganizationEvent`** con payload completo incluyendo Apps y AccessibleModules
     - Registra acción `ModuleAssigned` en tabla `AUDITLOG` por cada módulo asignado

**Validaciones backend**:
- Name, TaxId, ContactEmail obligatorios (Helix6 FluentValidation)
- TaxId único (excluir soft-deleted)
- Name único (excluir soft-deleted)
- GroupId debe existir y estar activo si se proporciona
- ApplicationModuleId debe existir y estar activo

**Response**: OrganizationView completo con configuración `OrganizationComplete`

###### 4. Update - Actualizar Organización Existente

**Endpoint**: `PUT /api/Organization/Update`

**Parámetros**:
- `configurationName` (string, required): `"OrganizationComplete"`
- `reloadView` (bool, optional): `true`
- `Accept-Language` (header): Idioma del usuario

**Body**: OrganizationView completo con Id existente

**Comportamiento esperado según permisos del usuario**:

1. **Si el usuario tiene permiso `Organization data modification` (200)**:
   - Actualiza campos de Pestaña 1
   - **NO actualiza** la colección `ApplicationModules`
   - **NO publica** evento si solo cambian datos básicos
   - Si cambia `GroupId`: **Sí publica** evento `OrganizationEvent` y registra acción `GroupChanged` en `AUDITLOG`

2. **Si el usuario tiene permiso `Organization modules modification` (202)**:
   - Si la colección `ApplicationModules` cambia:
     - Detecta módulos añadidos: Crea registros en `ORGANIZATION_APPLICATIONMODULE`, publica evento, registra `ModuleAssigned`
     - Detecta módulos removidos: Marca `AuditDeletionDate` en `ORGANIZATION_APPLICATIONMODULE`, publica evento, registra `ModuleRemoved`
     - **Publica evento `OrganizationEvent`** con estado final completo

**Validaciones backend**:
- Mismas validaciones que Insert
- Id debe existir y no estar soft-deleted

**Response**: OrganizationView actualizado con configuración `OrganizationComplete`

##### Endpoints Adicionales Necesarios

###### 5. OrganizationGroupClient.getAll - Cargar Grupos para Combo

**Endpoint**: `GET /api/OrganizationGroup/GetAll`

**Parámetros**:
- `Accept-Language` (header): Idioma del usuario

**Response**: Array de OrganizationGroupView
```typescript
[
  {
    id: number;
    groupName: string;
    description?: string;
  }
]
```

**Uso**: Popular el combo desplegable de GroupId en Pestaña 1.

###### 6. ApplicationClient.getAllKendoFilter - Cargar Aplicaciones para Grid Anidado

**Endpoint**: `POST /api/Application/GetAllKendoFilter`

**Parámetros**:
- `configurationName` (string): `"ApplicationWithModules"`
- `includeDeleted` (bool): `false`
- `Accept-Language` (header): Idioma del usuario

**Body**: KendoGridFilter (vacío para obtener todas)

**Response**: PagingResponse con lista de ApplicationView incluyendo navegación a ApplicationModules

**Uso**: Popular el grid de aplicaciones disponibles en Pestaña 2 con sus módulos asociados.

###### 7. AuditLogClient.getAllKendoFilter - Cargar Auditoría

**Endpoint**: `POST /api/AuditLog/GetAllKendoFilter`

**Parámetros**:
- `configurationName` (string): `""` (sin navegaciones, tabla plana)
- `includeDeleted` (bool): `false`
- `Accept-Language` (header): Idioma del usuario

**Body**: KendoGridFilter con filtro server-side
```typescript
{
  data: {
    filter: {
      logic: 'and',
      filters: [
        { field: 'entityType', operator: 'eq', value: 'Organization' },
        { field: 'entityId', operator: 'eq', value: organizationId.toString() }
      ]
    },
    sort: [{ field: 'timestamp', dir: 'desc' }],
    skip: 0,
    take: 20
  }
}
```

**Response**: PagingResponse con lista de AuditLogView y count total

**Uso**: Popular el grid de auditoría en Pestaña 3 con paginación server-side.

##### Gestión de Permisos en Backend

El backend **debe** validar permisos usando `IUserContext` y `IUserPermissions` (provistos por Helix6):

1. **En OrganizationService.ValidateView()**: Verificar que el usuario tiene permiso para la operación solicitada
2. **En OrganizationService.PreviousActions()**: Filtrar qué partes del payload se procesarán según permisos
3. **En OrganizationService.PostActions()**: Decidir si publicar evento según cambios realizados

**Ejemplo de lógica backend** (pseudocódigo):
```csharp
// En Insert/Update
if (userHasPermission("Organization modules modification") && moduleCollectionChanged)
{
    // Persistir cambios en ORGANIZATION_APPLICATIONMODULE
    // Publicar OrganizationEvent
    // Registrar en AUDITLOG
}
else if (moduleCollectionChanged && !userHasPermission("Organization modules modification"))
{
    // Ignorar cambios en módulos (no error, solo ignorar)
}
```

##### Notas Importantes

1. **Arquitectura Event-Driven**: El backend es responsable de publicar eventos `OrganizationEvent` a ActiveMQ Artemis. El frontend **no debe** preocuparse por esto.

2. **Configuraciones de Carga**: El nombre `OrganizationComplete` debe estar documentado en el ticket backend (Ticket_ORG001_T002-BE) y definido en `OrganizationRepository.cs`.

3. **Auditoría Dual**:
   - **Helix6 Base Audit**: Todos los cambios se registran automáticamente en campos `Audit*` de la entidad
   - **AUDITLOG selectivo**: Solo 6 acciones críticas se registran explícitamente (ModuleAssigned, ModuleRemoved, OrganizationDeactivatedManual, OrganizationAutoDeactivated, OrganizationReactivatedManual, GroupChanged)

4. **Soft Delete**: Todas las entidades usan `AuditDeletionDate` para soft delete. El frontend debe filtrar registros con `AuditDeletionDate != null`.

#### GUÍA DE IMPLEMENTACIÓN CON HELIX6

Esta sección describe los pasos ordenados para implementar el formulario de organización siguiendo los patrones de arquitectura Helix6 y CommonLibrary. **No incluye código**, solo la secuencia de acciones.

##### Paso 0: Definir Permisos en Access Enum

1. Abrir archivo `src/app/theme/access/access.ts`
2. Añadir 4 nuevos permisos al enum `Access` con valores numéricos sugeridos 200-203:
   - `'Organization data modification' = 200`
   - `'Organization data query' = 201`
   - `'Organization modules modification' = 202`
   - `'Organization modules query' = 203`
3. Guardar archivo

##### Paso 1: Crear Estructura de Componentes

1. Crear carpeta `src/app/modules/organizations/components/organization-form/`
2. Crear componente standalone `organization-form.component.ts` con decorador `@Component`:
   - Selector: `app-organization-form`
   - Imports: CommonModule, ReactiveFormsModule, TranslateModule, MatTabsModule, ClInputComponent, ClComboBoxComponent, ClGridComponent, ClButtonComponent
   - Providers: OrganizationClient, OrganizationGroupClient, ApplicationClient, AuditLogClient (NSwag clients)
3. Crear archivos complementarios:
   - `organization-form.component.html`
   - `organization-form.component.scss`
   - `organization-form.component.spec.ts`

##### Paso 2: Implementar Inyección de Dependencias y Propiedades

1. Usar función `inject()` para inyectar servicios como propiedades readonly:
   - `private readonly organizationClient = inject(OrganizationClient)`
   - `private readonly organizationGroupClient = inject(OrganizationGroupClient)`
   - `private readonly applicationClient = inject(ApplicationClient)`
   - `private readonly auditLogClient = inject(AuditLogClient)`
   - `private readonly fb = inject(FormBuilder)`
   - `private readonly accessService = inject(AccessService)`
   - `private readonly translate = inject(TranslateService)`
   - `private readonly sharedMessageService = inject(SharedMessageService)`
   - `private readonly kendoFiltersService = inject(KendoFiltersService)`
2. Declarar propiedades del componente:
   - `@Input() organizationId: number = 0` (0 = creación, >0 = edición)
   - `organizationForm: FormGroup` (formulario reactivo para Pestaña 1)
   - `canViewBasicData: boolean`, `canEditBasicData: boolean`
   - `canViewModules: boolean`, `canEditModules: boolean`
   - `organizationGroups: IOrganizationGroupView[]` (datos para combo)
   - `modulesGridData: GridDataResult` (datos para grid de módulos en Pestaña 2)
   - `auditGridData: GridDataResult` (datos para grid de auditoría en Pestaña 3)
   - `selectedTabIndex: number = 0` (índice de pestaña activa)

##### Paso 3: Inicializar Permisos en ngOnInit

1. En el método `ngOnInit()`:
   - Llamar a `AccessService.hasAccess()` para cada uno de los 4 permisos
   - Asignar resultados a propiedades booleanas del componente
   - Si `!canViewBasicData`: Mostrar mensaje de error y retornar early
2. Cargar datos iniciales:
   - Si `organizationId > 0`: Llamar a `organizationClient.getById(organizationId, 'OrganizationComplete')`
   - Si `organizationId === 0`: Llamar a `organizationClient.getNewEntity()`
3. Llamar a `organizationGroupClient.getAll()` para popular combo de grupos
4. Inicializar FormGroup con `FormBuilder.group()`:
   - Definir FormControl para cada campo (name, taxId, address, city, postalCode, country, contactEmail, contactPhone, groupId)
   - Añadir Validators: `Validators.required` para name, taxId, contactEmail
   - Añadir validador custom para taxId (regex CIF español si aplica)
5. Si `!canEditBasicData`: Llamar a `organizationForm.disable()` para modo solo lectura

##### Paso 4: Implementar Template HTML con Material Tabs

1. Crear estructura de pestañas usando `<mat-tab-group>`:
   - Binding: `[(selectedIndex)]="selectedTabIndex"`
2. **Pestaña 1 - Datos de Organización**:
   - Usar directiva `*ngIf="canViewBasicData"` para mostrar/ocultar
   - Crear formulario con `[formGroup]="organizationForm"`
   - Campos usando componentes CommonLibrary:
     - `<cl-input>` para: name, taxId, address, city, postalCode, country, contactEmail, contactPhone
     - `<cl-combo-box>` para: groupId (binding a `organizationGroups`, textField="groupName", valueField="id")
   - Cada campo con:
     - `[label]` usando pipe translate: `{{ 'ORGANIZATIONS.NAME' | translate }}`
     - `[formControlName]` apuntando al control del FormGroup
     - `[disabled]` binding a `!canEditBasicData`
   - Botón "Guardar" al final:
     - `*ngIf="canEditBasicData"`
     - `[disabled]="organizationForm.invalid"`
     - `(click)="onSaveBasicData()"`
3. **Pestaña 2 - Módulos y Permisos**:
   - Usar directiva `*ngIf="canViewModules"` para mostrar/ocultar
   - Mensaje si organización no está guardada: `*ngIf="organizationId === 0"` → "Debe guardar la organización antes de asignar módulos"
   - Si `organizationId > 0`: Renderizar `<cl-grid>` con:
     - `[config]="modulesGridConfig"` (ClGridConfig con definición de columnas)
     - `[data]="modulesGridData"`
     - `[loading]="loadingModules"`
     - `(changesSaved)="onModulesSaved($event)"` (para inline editing)
   - Configurar ClGridConfig:
     - Columnas: Application (texto), Módulos asignados (multiselect editable si `canEditModules`)
     - `edition.mode = 'row'` si `canEditModules`, sino sin edición
     - Endpoints para inline save apuntando a `Organization.Update` con payload completo
4. **Pestaña 3 - Auditoría**:
   - Usar directiva `*ngIf="canViewBasicData"` (cualquiera con acceso a datos puede ver auditoría)
   - Mensaje si organización no está guardada: `*ngIf="organizationId === 0"` → "La auditoría estará disponible después de guardar"
   - Si `organizationId > 0`: Renderizar `<cl-grid>` con:
     - `[config]="auditGridConfig"` (ClGridConfig en modo solo lectura)
     - `[data]="auditGridData"`
     - `(dataStateChange)="onAuditStateChange($event)"` (paginación server-side)
   - Configurar ClGridConfig:
     - Columnas: Timestamp (fecha formateada), Action (traducida), UserId (nombre usuario), CorrelationId
     - `sortable.mode = 'single'`, sort inicial por timestamp DESC
     - `pageable` con pageSizes [10, 20, 50]
     - Sin edición (grid readonly)

##### Paso 5: Implementar Métodos de Guardado

1. **Método `onSaveBasicData()`**:
   - Validar formulario: `if (!organizationForm.valid) return;`
   - Obtener datos con `organizationForm.getRawValue()` (incluye campos disabled)
   - Si `organizationId === 0`:
     - Llamar a `organizationClient.insert(payload, 'OrganizationComplete', true)`
     - En respuesta: Asignar `organizationId = response.id`
     - Mostrar toast de éxito con `sharedMessageService.showSuccess()`
     - Si `canViewModules`: Cambiar a Pestaña 2 con `selectedTabIndex = 1`
   - Si `organizationId > 0`:
     - Llamar a `organizationClient.update(payload, 'OrganizationComplete', true)`
     - En respuesta: Actualizar FormGroup con datos frescos
     - Mostrar toast de éxito
2. **Método `onModulesSaved(event)`**:
   - Recibir evento desde grid anidado con cambios en módulos
   - Construir payload completo de OrganizationView incluyendo colección `applicationModules` modificada
   - Llamar a `organizationClient.update(payload, 'OrganizationComplete', true)`
   - En respuesta: Recargar grid de módulos con datos frescos
   - Mostrar toast indicando que se publicó evento (si aplica)
   - Recargar Pestaña 3 (auditoría) para mostrar nueva acción `ModuleAssigned` o `ModuleRemoved`

##### Paso 6: Implementar Carga de Grid de Auditoría con Paginación Server-Side

1. **Método `loadAuditLog(state?: State)`**:
   - Construir objeto KendoGridFilter con filtros:
     - `entityType = 'Organization'`
     - `entityId = organizationId.toString()`
   - Si `state` contiene paginación/ordenación: Incluir en el filter
   - Llamar a `auditLogClient.getAllKendoFilter(filter, '', false)`
   - En respuesta: Asignar a `auditGridData = { data: response.list, total: response.count }`
2. **Método `onAuditStateChange(state: State)`**:
   - Llamar a `loadAuditLog(state)` para recargar con nueva página/ordenación

##### Paso 7: Implementar Carga de Grid de Módulos

1. **Método `loadModulesGrid()`**:
   - Si la respuesta de `getById` ya incluye `applicationModules` (configuración `OrganizationComplete`):
     - Transformar datos para el grid:
       - Agrupar por Application
       - Para cada aplicación, mostrar array de módulos asignados
     - Asignar a `modulesGridData`
   - Configurar ClGridConfig para inline editing:
     - Columna Application (readonly, texto)
     - Columna Módulos (multiselect editable con lista de módulos disponibles filtrados por ApplicationId)
     - Definir endpoints de edición inline apuntando a método `onModulesSaved`

##### Paso 8: Configurar ClGridConfig para Cada Grid

1. **Para grid de módulos (Pestaña 2)**:
   - Crear instancia de `ClGridConfig` con:
     - `idGrid: 'organizationModulesGrid'`
     - `columns`: Array de ClGridColumn
       - Columna 1: field='application.appName', title traducido, editor=null (readonly)
       - Columna 2: field='modules', title traducido, editor={ type: 'custom', customTemplate: multiselect de módulos }
     - `edition`: ClGridEdition con mode='row' si `canEditModules`, allowAdding/allowDeleting según permisos
     - `filterable`, `sortable`, `pageable` según necesidad
2. **Para grid de auditoría (Pestaña 3)**:
   - Crear instancia de `ClGridConfig` con:
     - `idGrid: 'organizationAuditGrid'`
     - `columns`: Array de ClGridColumn
       - Timestamp (fecha formateada), Action (traducida), UserId, CorrelationId
     - `sortable.mode = 'single'`, sort inicial timestamp DESC
     - `pageable` con server-side paging
     - Sin edición (readonly)

##### Paso 9: Añadir Traducciones

1. Abrir archivos de traducción en `src/assets/i18n/`:
   - `es.json`
   - `en.json`
   - `ca.json`
2. Añadir claves para el módulo de organizaciones:
   - Estructura sugerida: `ORGANIZATIONS.TITLE`, `ORGANIZATIONS.NAME`, `ORGANIZATIONS.TAXID`, etc.
   - Traducciones para pestañas: `ORGANIZATIONS.TABS.BASIC_DATA`, `ORGANIZATIONS.TABS.MODULES`, `ORGANIZATIONS.TABS.AUDIT`
   - Traducciones para acciones de auditoría: `AUDIT.ACTIONS.MODULE_ASSIGNED`, `AUDIT.ACTIONS.MODULE_REMOVED`, etc.
   - Mensajes de validación y confirmación
3. Usar pipe `translate` en todos los textos del template: `{{ 'ORGANIZATIONS.NAME' | translate }}`

##### Paso 10: Configurar Routing

1. Abrir archivo de rutas del módulo organizations (ej: `organizations.routes.ts`)
2. Añadir ruta para el formulario de organización:
   - Path: `'organizations/:id/edit'` (id = 0 para creación)
   - Component: OrganizationFormComponent
   - Metadata: título traducido, permisos requeridos usando guard
3. Si existe componente de listado (organization-list), añadir navegación al formulario al hacer clic en editar/crear

##### Paso 11: Implementar Validaciones Custom

1. **Validador de TaxId** (CIF español):
   - Crear función validadora que verifique formato con regex
   - Añadir al FormControl de taxId: `Validators.pattern(/^[A-Z]\d{8}$/)`
2. **Validación de unicidad** (opcional, backend ya valida):
   - Implementar AsyncValidator que llame a endpoint de verificación
   - Añadir al FormControl de name y taxId

##### Paso 12: Implementar Tests Unitarios

1. Crear archivo `organization-form.component.spec.ts`
2. Configurar TestBed con:
   - MockProviders para todos los clients (OrganizationClient, etc.)
   - MockProviders para AccessService (retornar permisos mockeados)
   - Imports necesarios (ReactiveFormsModule, TranslateModule.forRoot(), etc.)
3. Escribir tests para:
   - **Inicialización**: Verificar que permisos se verifican correctamente
   - **Carga de datos**: Mockear respuesta de `getById` y verificar que FormGroup se populate
   - **Validaciones**: Verificar que campos requeridos muestran error
   - **Guardado**: Mockear `insert`/`update` y verificar que se llama con payload correcto
   - **Permisos**: Verificar que botones/campos se deshabilitan según permisos
   - **Navegación entre pestañas**: Verificar que pestaña 2 solo aparece después de guardar
4. Objetivo: Cobertura > 80%

##### Paso 13: Implementar Tests End-to-End

1. Crear archivo `organization-form.e2e.spec.ts` (si el proyecto usa Cypress/Playwright)
2. Escribir tests para flujos completos:
   - **Flujo de creación completa** (Organization Administrator):
     - Login como admin
     - Navegar a formulario de creación
     - Completar Pestaña 1, guardar
     - Verificar que aparece Pestaña 2
     - Asignar módulos, guardar
     - Verificar que aparece acción en Pestaña 3
   - **Flujo de edición colaborativa**:
     - Login como Organization Manager
     - Crear organización (solo Pestaña 1)
     - Logout, login como Application Manager
     - Editar organización, asignar módulos
     - Verificar evento publicado
   - **Flujo de solo lectura** (Organization Viewer):
     - Login como viewer
     - Verificar que todos los campos están disabled
     - Verificar que no aparecen botones de guardar

##### Paso 14: Añadir Estilos SCSS

1. Abrir archivo `organization-form.component.scss`
2. Añadir estilos para:
   - Layout responsive usando grid Bootstrap (row/col)
   - Espaciado entre campos de formulario
   - Estilos para pestañas Material (personalización si necesaria)
   - Estilos para grids (altura fija, scrollbar, etc.)
   - Estilos para mensajes de estado (solo lectura, sin permisos)
3. Usar variables de tema definidas en `src/styles.scss` para consistencia

##### Paso 15: Añadir Accesibilidad

1. Añadir atributos ARIA a elementos interactivos:
   - `aria-label` en botones sin texto
   - `aria-required="true"` en campos obligatorios
   - `role="tabpanel"` en contenido de pestañas
2. Verificar navegación por teclado:
   - Tab para moverse entre campos
   - Enter para guardar formulario
   - Flechas para cambiar pestañas
3. Añadir mensajes de error accesibles usando `aria-describedby`

##### Paso 16: Code Review y Ajustes

1. Ejecutar linter: `npm run lint` y corregir errores
2. Ejecutar tests: `npm test` y verificar que todos pasan
3. Verificar que no hay console.log olvidados
4. Revisar que todos los textos usan traducciones (no hardcoded)
5. Verificar que imports solo incluyen lo necesario (tree-shaking)
6. Solicitar code review al equipo

#### CONTEXTO TÉCNICO

- **Framework**: Angular 20.1.6 con Standalone Components
- **UI Components**: 
  - Angular Material Tabs para navegación entre pestañas
  - CommonLibrary (@cl/common-library) para formularios y grids:
    - `cl-input` para campos de texto
    - `cl-combo-box` para selección de grupo
    - `cl-grid` para grids de módulos y auditoría
    - `cl-modal-service` si se usa en contexto de modal
- **Validación**: Reactive Forms con validadores custom (TaxId pattern)
- **Estado**: Signals de Angular (opcional) o propiedades tradicionales para gestionar estado de pestañas
- **Permisos**: AccessService para verificar permisos del usuario (valores numéricos 200-203)
- **Routing**: Navegación con parámetros de ruta `:id` (0 para creación, >0 para edición)
- **Backend Integration**: NSwag clients auto-generados desde Swagger del backend Helix6
- **Traducciones**: ngx-translate con archivos JSON (es, en, ca)

#### CRITERIOS DE ACEPTACIÓN TÉCNICOS

- [ ] 4 permisos añadidos al enum Access con valores 200-203
- [ ] Componente OrganizationFormComponent creado como standalone con 3 pestañas Material
- [ ] Pestaña 1 implementada con todos los campos usando componentes cl-input y cl-combo-box
- [ ] Validaciones reactivas implementadas (Name, TaxId, ContactEmail obligatorios)
- [ ] TaxId validado con regex pattern español (formato CIF)
- [ ] Combo de grupos carga datos desde OrganizationGroupClient.getAll()
- [ ] Pestaña 2 implementada con grid cl-grid de módulos con inline editing
- [ ] Grid de módulos agrupa por Application y muestra multiselect de módulos asignados
- [ ] Pestaña 3 implementada con grid readonly de auditoría con paginación server-side
- [ ] Grid de auditoría filtra por EntityType='Organization' y EntityId={id}
- [ ] AccessService implementado para verificar 4 permisos por pestaña
- [ ] Campos habilitados/deshabilitados según permisos del usuario
- [ ] Pestaña 2 solo visible después de guardar organización y si usuario tiene permiso 203
- [ ] Pestaña 3 visible solo si usuario tiene permiso 201
- [ ] Integración con NSwag clients: OrganizationClient.getById/insert/update con configuración "OrganizationComplete"
- [ ] Uso de getRawValue() para obtener datos del formulario (incluyendo disabled)
- [ ] Navegación automática a Pestaña 2 después de crear (si tiene permiso 202 o 203)
- [ ] Mensajes de permisos diferenciados (solo lectura vs sin acceso)
- [ ] Todas las etiquetas y mensajes usando TranslateModule (pipe translate)
- [ ] Traducciones añadidas en es.json, en.json, ca.json
- [ ] Notificaciones toast usando SharedMessageService con mensajes traducidos
- [ ] Estilos responsive usando clases Bootstrap grid
- [ ] Providers declarados en el componente (OrganizationClient, OrganizationGroupClient, ApplicationClient, AuditLogClient)
- [ ] Inyección de dependencias usando inject() con readonly
- [ ] Tests unitarios con cobertura > 80%
- [ ] Tests verifican navegación automática a módulos
- [ ] Tests verifican permisos usando métodos de AccessService
- [ ] Tests verifican carga de grupos de organizaciones
- [ ] Tests verifican guardado sin publicar evento en Pestaña 1
- [ ] Tests verifican publicación de evento al asignar módulos en Pestaña 2
- [ ] Tests verifican que grid de auditoría se recarga después de asignar módulos
- [ ] Tests E2E del flujo completo de creación (3 pestañas)
- [ ] Code review aprobado
- [ ] Accesibilidad verificada (aria labels, navegación por teclado)

#### DEPENDENCIAS

Este ticket frontend tiene las siguientes dependencias técnicas y funcionales:

##### Tickets Backend/Base de Datos (Bloqueantes)

- **Ticket_ORG001_T002-BE**: Implementación del servicio backend OrganizationService con:
  - Endpoint `GetById` con configuración de carga `OrganizationComplete` que incluye:
    - Navegación a OrganizationGroup
    - Colección ApplicationModules con navegación a ApplicationModule y Application
    - Colección AuditLogs filtrada por EntityType y EntityId
  - Endpoints `Insert` y `Update` con lógica de permisos:
    - Persistencia selectiva según permisos del usuario
    - Publicación de evento OrganizationEvent solo cuando corresponde (asignación de módulos, cambio de grupo)
    - Registro de acciones críticas en tabla AUDITLOG
  - Validaciones de negocio (Name, TaxId únicos, GroupId válido)
  
- **Ticket_ORG001_T003-DB**: Creación de estructura de base de datos con:
  - Tabla ORGANIZATION (15 campos incluyendo SecurityCompanyId, GroupId, audit fields)
  - Tabla ORGANIZATIONGROUP (8 campos)
  - Tabla APPLICATION (9 campos incluyendo RolePrefix)
  - Tabla APPLICATIONMODULE (9 campos con FK a Application)
  - Tabla ORGANIZATION_APPLICATIONMODULE (relación N:M con 8 campos)
  - Tabla AUDITLOG (10 campos para registro de 6 acciones críticas)
  - Índices, constraints y foreign keys según diseño
  - Vista VW_ORGANIZATION (opcional para consultas optimizadas)

##### Bibliotecas y Dependencias de Frontend

- **@cl/common-library** (versión 2.8.0+): Instalada y configurada con:
  - ClGridComponent para grids de módulos y auditoría
  - ClInputComponent, ClComboBoxComponent para formularios
  - ClModalService (si se usa en contexto modal)
  - ClButtonComponent para acciones
  
- **@angular/material** (versión 20.x): Instalado con:
  - MatTabsModule para navegación entre pestañas
  - MatButtonModule, MatIconModule para UI
  
- **NSwag TypeScript Clients**: Generados desde Swagger del backend con:
  - OrganizationClient con métodos: getById, getNewEntity, insert, update
  - OrganizationGroupClient con método: getAll
  - ApplicationClient con método: getAllKendoFilter (configuración "ApplicationWithModules")
  - AuditLogClient con método: getAllKendoFilter
  - Ubicación: `src/webServicesReferences/api/apiClients.ts`

##### Servicios Core de Frontend

- **AccessService** (`src/app/theme/access/access.service.ts`): Configurado con métodos para verificar permisos:
  - `hasAccess(Access['Organization data modification'])` → boolean
  - `hasAccess(Access['Organization data query'])` → boolean
  - `hasAccess(Access['Organization modules modification'])` → boolean
  - `hasAccess(Access['Organization modules query'])` → boolean

- **TranslateModule** (ngx-translate): Configurado en app.config.ts con:
  - HttpLoaderFactory apuntando a `./assets/i18n/`
  - Idiomas soportados: es, en, ca
  - Default language configurado

- **SharedMessageService**: Disponible para mostrar notificaciones toast:
  - `showSuccess(message: string)`
  - `showError(message: string)`
  - `showWarning(message: string)`

##### Configuración de Entorno

- **Keycloak/Identity Management**: Configurado con:
  - Permisos 200-203 definidos en el sistema
  - Roles asociados a permisos (Organization Administrator, Organization Manager, etc.)
  - Endpoint GetPermissions devolviendo permisos correctos para organizaciones
  - Claims en JWT token incluyendo permisos del usuario

- **Bootstrap Grid**: Disponible en estilos globales para layout responsive (row/col classes)

##### Datos de Prueba (Opcional pero Recomendado)

- Grupos de organizaciones de ejemplo en tabla ORGANIZATIONGROUP
- Aplicaciones de ejemplo en tabla APPLICATION con módulos asociados
- Usuarios de prueba con diferentes combinaciones de permisos (roles del sistema)

##### Orden de Implementación Recomendado

1. **Primero**: Ticket_ORG001_T003-DB (estructura de datos)
2. **Segundo**: Ticket_ORG001_T002-BE (lógica de negocio y endpoints)
3. **Tercero**: Generación de NSwag clients (comando `npm run generate-clients` o similar)
4. **Cuarto**: Este ticket (Ticket_ORG001_T001-FE)

##### Verificación de Dependencias Antes de Empezar

Ejecutar checklist de dependencias:
- [ ] Tablas de BD creadas y migradas
- [ ] Backend desplegado y endpoints /api/Organization/* disponibles en Swagger
- [ ] NSwag clients regenerados con última versión de Swagger
- [ ] CommonLibrary instalada (`npm list @cl/common-library`)
- [ ] Angular Material instalada (`npm list @angular/material`)
- [ ] Archivos de traducción base creados (es.json, en.json, ca.json)
- [ ] AccessService implementado con método `hasAccess()`
- [ ] Keycloak configurado con permisos 200-203
- [ ] Usuario de prueba con rol Organization Administrator disponible para testing

#### RECURSOS

- **Angular Material Tabs**: [Documentation](https://material.angular.io/components/tabs/overview)
- **Angular Reactive Forms**: [Documentation](https://angular.io/guide/reactive-forms)
- **CommonLibrary ClGrid**: Ver Helix6_Frontend_Architecture.md - Sección 6
- **CommonLibrary ClFormFields**: Ver Helix6_Frontend_Architecture.md - Sección 8
- **NSwag Integration**: Ver Helix6_Frontend_Architecture.md - Sección 9
- **Testing Patterns**: Ver Helix6_Frontend_Architecture.md - Sección 13
- **User Story**: Epic1_UserStories/ORG001_Gestion_Organizacion/ORG001_Gestion_Organizacion.md
- **Backend Architecture**: Helix6_Backend_Architecture.md
- **Product Documentation**: readme.md (secciones 3.2.1 ORGANIZATION, 3.2.2 ORGANIZATIONGROUP, 3.2.4 AUDITLOG)
- **Event Schema**: readme.md - Sección 1.3.1 (OrganizationEvent structure)

=============================================================

## 7. Pull Requests

> Documenta 3 de las Pull Requests realizadas durante la ejecución del proyecto

**Pull Request 1**

**Pull Request 2**

**Pull Request 3**

