# InfoportOneAdmon - Sistema de Gestión Centralizada de Organizaciones y Roles

## Tabla de Contenidos

1. [Descripción General del Producto](#descripción-general-del-producto)
2. [Funcionalidades Principales](#funcionalidades-principales)
3. [Arquitectura Lógica del Sistema](#arquitectura-lógica-del-sistema)
4. [Flujos de Proceso de Negocio](#flujos-de-proceso-de-negocio)
5. [Modelo de Datos Conceptual](#modelo-de-datos-conceptual)
6. [Estrategia de Optimización y Rendimiento](#estrategia-de-optimización-y-rendimiento)

---

## Descripción General del Producto

### Visión del Producto

**InfoportOneAdmon** es la plataforma administrativa centralizada ("Back-Office") diseñada exclusivamente para que la **Organización Propietaria** del ecosistema gestione el ciclo de vida de los clientes (Organizaciones) y la seguridad transversal de las aplicaciones satélites.

A diferencia de modelos SaaS de auto-servicio, en este ecosistema **las organizaciones no se registran por sí mismas**. Es la Organización Propietaria quien, a través de InfoportOneAdmon, da de alta, configura y provisiona los entornos para sus clientes, garantizando un control total sobre quién accede al ecosistema.

**Misión**: Centralizar la complejidad administrativa (altas de clientes, seguridad OAuth2, catálogo de roles) para que las aplicaciones de negocio (CRM, ERP, etc.) puedan centrarse exclusivamente en su lógica funcional y en la gestión de sus propios usuarios.

### Alcance y Responsabilidades

InfoportOneAdmon actúa como la **Fuente de la Verdad** para:

1.  **Gestión de Inquilinos (Tenants)**: Control del ciclo de vida de las organizaciones clientes.
2.  **Catálogo Maestro de Roles**: Definición única de qué roles existen en cada aplicación.
3.  **Gobierno de Identidad**: Orquestación de Keycloak para la seguridad de las aplicaciones.

**PRINCIPIO CLAVE DE RESPONSABILIDAD**:
* **InfoportOneAdmon**: Define *quién* es el cliente (Organización) y *qué* roles existen (Definiciones).
* **Aplicaciones Satélite**: Gestionan *quiénes* son los usuarios finales y *qué* roles tienen asignados.

### Principios de Diseño

| Principio | Descripción | Justificación de Negocio |
|-----------|-------------|--------------------------|
| **Administración Centralizada** | Gestión exclusiva por la Organización Propietaria | Control total sobre el onboarding de clientes y licencias. |
| **Single Realm** | Un único realm (InfoportOne) en Keycloak | Simplifica la gestión de identidades y permite SSO real. |
| **Usuarios Descentralizados** | Las Apps crean sus propios usuarios | Permite a cada aplicación escalar y gestionar sus usuarios sin cuellos de botella centrales. |
| **Roles como Catálogo** | InfoportOneAdmon define, Apps asignan | Asegura coherencia en los nombres y permisos de los roles, pero flexibilidad en la asignación. |
| **Event-Driven** | Uso de ActiveMQ Artemis | Garantiza que los cambios administrativos se propaguen a las apps sin acoplamiento fuerte. |

---

## Funcionalidades Principales

### 1. Gestión de Organizaciones (Clientes)

**Descripción**:
Este módulo permite a los administradores de la Organización Propietaria gestionar el ciclo de vida completo de las empresas clientes que utilizarán el ecosistema de aplicaciones. Su objetivo es centralizar el alta administrativa y técnica en un solo paso, evitando configuraciones manuales en sistemas de terceros (como Keycloak).

**Capacidades**:
* **Onboarding de Clientes**: Alta de nueva organización, generando automáticamente su estructura de seguridad (Grupos en Keycloak) y su identificador único de seguridad (`SecurityCompanyId`).
* **Gestión de Configuración**: Modificación de datos corporativos y configuraciones globales del tenant.
* **Kill-Switch (Desactivación)**: Capacidad de bloquear el acceso de una organización completa al ecosistema de forma inmediata en caso de impago o baja del servicio.
* **Auditoría de Tenant**: Trazabilidad completa de cuándo se creó o modificó una organización.

### 2. Gestión de Definiciones de Roles (Catálogo)

**Descripción**:
Funciona como un repositorio maestro de roles. Permite definir qué "perfiles" existen dentro de cada aplicación (ej: "Vendedor", "Gerente", "Auditor") y qué permisos técnicos conllevan. Esto evita que los roles se definan "hardcoded" dentro del código de las aplicaciones, permitiendo cambios dinámicos.

**Capacidades**:
* **Creación de Catálogo**: Definir nuevos roles para una aplicación específica con su lista de permisos granulares.
* **Evolución de Roles**: Modificar los permisos asociados a un rol existente (ej: agregar el permiso "borrar_facturas" al rol "Gerente"). Los cambios se notifican a las apps.
* **Deprecación**: Marcar roles como obsoletos para evitar nuevas asignaciones, guiando la migración hacia nuevos roles.
* **Consulta de Roles**: Endpoint público para que las aplicaciones descarguen su lista actualizada de roles disponibles.

### 3. Gestión de Aplicaciones (Ecosistema)

**Descripción**:
Permite registrar nuevas aplicaciones satélite en el ecosistema. Al registrar una app, InfoportOneAdmon se encarga de toda la "fontanería" de seguridad OAuth2, entregando a la aplicación las credenciales necesarias para operar.

**Capacidades**:
* **Registro de Aplicación**: Alta de nueva app (ej: "Módulo de Finanzas"), generando automáticamente el `client_id` y `client_secret` en Keycloak.
* **Gestión de Secretos**: Rotación y administración segura de credenciales OAuth2.
* **Control de Acceso**: Definir si una aplicación está activa o en mantenimiento para todo el ecosistema.

### 4. Integración Transparente con Keycloak

**Descripción**:
InfoportOneAdmon abstrae la complejidad de Keycloak. Los administradores no necesitan entrar a la consola de Keycloak; InfoportOneAdmon traduce las acciones de negocio (ej: "Crear Cliente") en comandos técnicos hacia el servidor de identidad.

**Capacidades**:
* **Sincronización de Estructuras**: Creación automática de grupos raíz (`/orgs/{nombre}`) y atributos de seguridad.
* **Configuración de Claims**: Garantiza que los tokens emitidos incluyan siempre el `SecurityCompanyId`, vital para que las aplicaciones sepan a qué datos puede acceder un usuario.

### 5. Arquitectura Orientada a Eventos (ActiveMQ Artemis)

**Descripción**:
Mecanismo de comunicación asíncrona que mantiene la coherencia entre InfoportOneAdmon y las aplicaciones satélite. Cuando ocurre un cambio administrativo, se emite un evento para que las aplicaciones interesadas reaccionen.

**Eventos Principales**:
* `OrganizationCreated` / `Updated` / `Deactivated`
* `ApplicationRegistered`
* `RoleCreated` / `Updated` / `Deprecated`

---

## Arquitectura Lógica del Sistema

El siguiente diagrama ilustra cómo InfoportOneAdmon orquesta la seguridad y los datos maestros, sirviendo a las aplicaciones del ecosistema.

graph TB
    subgraph Cliente_Admin[Admin Propietario]
        A1[Frontend Administración]
        A2[OAuth2 Client]
    end
    
    subgraph Gestor_Identidad[Gestor de Identidad]
        K1["Keycloak<br/>(Realm Único)"]
        K2["Admin API"]
    end
    
    subgraph InfoportOneAdmon[InfoportOneAdmon]
        S1["Backend Administración<br/>(Orgs, Roles, Apps)"]
        S2["Bus de Eventos<br/>Publisher"]
    end
    
    subgraph Infra_Mensajeria[Infraestructura de Mensajería]
        E1["ActiveMQ Artemis<br/>(Topics & Queues)"]
    end
    
    subgraph PersistenciaCore[Persistencia Core]
        D1["Base de Datos<br/>InfoportOneAdmon"]
    end
    
    subgraph EcosistemaApps[Ecosistema de Aplicaciones]
        AP1["App Satélite 1<br/>(Gestión de sus Usuarios)"]
        AP2["App Satélite 2<br/>(Gestión de sus Usuarios)"]
    end
    
    %% Relaciones
    A1 --> A2
    A2 -- "Autenticación Admin" --> K1
    A2 -- "Gestión" --> S1
    
    S1 -- "Provisionamiento" --> K2
    K2 -- "Configura" --> K1
    
    S1 -- "Persiste Datos" --> D1
    S1 -- "Publica Cambios" --> S2
    S2 -- "Envía Mensajes" --> E1
    
    E1 -- "Notifica Eventos" --> AP1
    E1 -- "Notifica Eventos" --> AP2
    
    AP1 -- "Consulta Catálogo Roles" --> S1
    AP2 -- "Consulta Catálogo Roles" --> S1
    
    %% Estilos
    style K1 fill:#4A90E2,color:#fff
    style S1 fill:#7ED321,color:#fff
    style E1 fill:#F5A623,color:#fff
    style D1 fill:#BD10E0,color:#fff

## Flujos de Proceso de Negocio

### 1. Alta de Nueva Organización (Onboarding)

Este proceso es ejecutado exclusivamente por el personal de la Organización Propietaria cuando se cierra un contrato con un nuevo cliente.

graph TD
    Start([Inicio: Admin Propietario solicita Alta]) --> Validar[Validar Datos y Unicidad de Nombre]
    
    Validar -->|Nombre Duplicado| Error[Retornar Error]
    Validar -->|Datos Válidos| GenID[Generar SecurityCompanyId]
    
    GenID --> KC_Step[Provisionar en Keycloak]
    KC_Step --> KC_Group[Crear Grupo Raíz '/orgs/cliente']
    KC_Step --> KC_Attr[Asignar Atributos de Seguridad]
    
    KC_Attr --> DB_Save[Guardar Organización en BD InfoportOneAdmon]
    
    DB_Save --> Event[Publicar Evento 'OrganizationCreated' en ActiveMQ]
    
    Event --> Audit[Registrar en Auditoría]
    Audit --> End([Fin: Organización Activa])
    
    subgraph "Procesamiento Asíncrono (Apps Satélite)"
    Event -->|Consumo| App1[App crea estructura local si es necesario]
    end

### 2. Definición de Nuevo Rol en una Aplicación

El administrador define un nuevo perfil funcional que estará disponible para una aplicación específica.

graph TD
    Start([Inicio: Admin define Nuevo Rol]) --> SelectApp[Seleccionar Aplicación Destino]
    
    SelectApp --> Define[Definir Nombre y Permisos]
    Define --> DB_Check[Verificar si el rol ya existe en catálogo]
    
    DB_Check -->|Ya Existe| Error[Error: Rol Duplicado]
    DB_Check -->|Nuevo| Save[Guardar Definición en InfoportOneAdmon]
    
    Save --> Publish[Publicar Evento 'RoleCreated' en ActiveMQ]
    
    Publish --> End([Fin: Rol Disponible en Catálogo])
    
    subgraph "Reacción de la Aplicación"
    Publish -->|Consumo| AppListener[App recibe definición]
    AppListener --> AppCache[App actualiza su caché de roles locales]
    end

### 3. Registro de Nueva Aplicación en el Ecosistema

Proceso técnico para dar de alta una nueva aplicación satélite y permitirle interactuar con Keycloak.

graph TD
    Start([Inicio: Registrar Nueva App]) --> Validate[Validar ID de Aplicación]
    
    Validate --> KC_Client[Solicitar Credenciales a Keycloak]
    KC_Client --> KC_Gen[Keycloak genera ClientId y ClientSecret]
    
    KC_Gen --> Encrypt[Encriptar Secret en BD InfoportOneAdmon]
    Encrypt --> Store[Guardar Registro de Aplicación]
    
    Store --> Roles_Init[Cargar Roles por Defecto en Catálogo]
    
    Roles_Init --> Notify[Notificar 'ApplicationRegistered']
    Notify --> End([Fin: App Lista para Conectar])

### 4. Autenticación y Autorización (Vista de Usuario Final)

Cómo un usuario de una Organización Cliente accede a una App Satélite. InfoportOneAdmon no participa activamente en el login (solo configuró el entorno previamente), pero su configuración es vital.

graph TD
    User([Usuario Final]) --> Login[Intento de Login en App Satélite]
    Login --> Redirect[Redirección a Keycloak]
    
    Redirect --> Auth[Usuario introduce credenciales]
    Auth --> ValidKC[Keycloak Valida Identidad]
    
    ValidKC --> TokenGen[Generación de Token]
    TokenGen --> Inject[Inyección de Claims: SecurityCompanyId]
    
    Inject --> Return[Retorno a App con Token]
    
    Return --> AppCheck[App Satélite Valida Token]
    AppCheck --> LocalAuth[App consulta Roles Locales del Usuario]
    
    LocalAuth --> Access{¿Tiene Permisos?}
    Access -->|Sí| Grant[Acceso Permitido]
    Access -->|No| Deny[Acceso Denegado 403]

## Modelo de Datos Conceptual

A continuación, se presentan las entidades principales que maneja InfoportOneAdmon. Este modelo no busca detallar tipos de datos SQL, sino las relaciones de negocio.

erDiagram
    ORGANIZATION ||--o{ APP_ACCESS : "tiene acceso a"
    ORGANIZATION {
        uuid SecurityCompanyId "Identificador Inmutable Global"
        string Nombre "Nombre Comercial"
        string Estado "Activo / Inactivo"
    }
    
    APPLICATION ||--o{ APP_ACCESS : "es accedida por"
    APPLICATION ||--o{ APP_ROLE_DEFINITION : "define catálogo de"
    APPLICATION {
        int AppId "Identificador Interno"
        string ClientId "Identificador OAuth2"
        string Nombre "Nombre App"
    }
    
    APP_ROLE_DEFINITION {
        string RoleName "Nombre del Rol (ej: Editor)"
        list Permissions "Lista de Permisos Funcionales"
        bool Deprecated "Estado de vigencia"
    }
    
    APP_ACCESS {
        date GrantedAt "Fecha de concesión"
        bool Active "Estado del acceso"
    }
    
    AUDIT_LOG }o--|| ORGANIZATION : "registra cambios sobre"
    AUDIT_LOG }o--|| APPLICATION : "registra cambios sobre"

### Entidades Clave

1.  **Organization (Organización): Representa al cliente legal. Su atributo más crítico es el SecurityCompanyId, que es el pegamento de seguridad entre Keycloak, InfoportOneAdmon y las Apps Satélite.

2.  **Application (Aplicación): Representa un software del ecosistema (ej: "ERP", "Portal Clientes"). Contiene las credenciales para hablar con Keycloak.

3.  **AppRoleDefinition (Definición de Rol): Es la plantilla del rol. InfoportOneAdmon guarda la definición (qué puede hacer el rol "Admin"), pero no guarda quién tiene ese rol (eso está en la base de datos de cada App).

4.  **AuditLog: Registro inmutable de todas las operaciones realizadas por los administradores propietarios.

## Estrategia de Optimización y Rendimiento

Aunque InfoportOneAdmon es un sistema de administración (tráfico bajo comparado con las apps satélite), su disponibilidad es crítica. Se aplican las siguientes estrategias no funcionales:

1. **Desacoplamiento mediante ActiveMQ Artemis
El uso de un bus de mensajes empresarial garantiza que si una aplicación satélite está caída durante una actualización administrativa (ej: cambio de nombre de una organización), no se pierda el dato. La aplicación procesará el mensaje al reconectarse.

2. **Estrategia de Caché en Aplicaciones
Para evitar latencia en la validación de permisos:

InfoportOneAdmon es la fuente de la verdad de las definiciones de roles.

Las aplicaciones *deben cachear* estas definiciones localmente.

Las aplicaciones solo consultan a InfoportOneAdmon en el arranque o cuando reciben un evento de RoleUpdated.

Esto elimina el tráfico de red en cada request HTTP del usuario final.

3. **Seguridad Stateless (Tokens)
La validación de seguridad en tiempo de ejecución se basa en el estándar *JWT (JSON Web Tokens)*.

*** El token es autosuficiente: contiene el SecurityCompanyId.

*** InfoportOneAdmon no es consultado para validar tokens; esta validación es matemática (criptografía) y local en cada app, garantizando máxima velocidad.

4. **Auditoría Asíncrona
El registro de auditoría no bloquea la operación principal. Se procesa en segundo plano para asegurar una experiencia de usuario fluida para el administrador.