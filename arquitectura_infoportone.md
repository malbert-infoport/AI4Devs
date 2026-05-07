# Arquitectura de Gestión de Organizaciones, Aplicaciones y Usuarios - InfoportOne

## 1. Visión General

La solución propuesta permite gestionar organizaciones, aplicaciones y usuarios dentro del ecosistema **InfoportOne** mediante una arquitectura SaaS desacoplada basada en:

- Aplicaciones Helix7
- Keycloak para autenticación/autorización
- ActiveMQ como bus de eventos
- Arquitectura multi-organización y multi-aplicación

---

# 2. Arquitectura General de la Solución

```mermaid
flowchart LR

    subgraph Ecosistema_InfoportOne
        A[InfoportOneAdmon]
        B[Aplicaciones Principales]
        C[Aplicaciones Transversales]
    end

    D[Keycloak]
    E[ActiveMQ]

    A -->|Alta usuarios y credenciales| D
    B -->|Autorización| D
    C -->|Autorización| D

    A -->|Eventos Organización y Aplicación| E
    E -->|Consumen eventos| B
    E -->|Consumen eventos| C

    B -->|Eventos Usuario| E
    C -->|Eventos Usuario| E

    E -->|Recepción eventos usuario| A
```

---

# 3. Componentes de la Arquitectura

## 3.1 InfoportOneAdmon

Aplicación central encargada de:

- Gestión de organizaciones
- Gestión de aplicaciones
- Gestión de credenciales
- Integración con Keycloak
- Integración con ActiveMQ

## Responsabilidades

### Gestión de Organizaciones

- Datos básicos de organización
- Módulos disponibles por organización
- Agrupación de organizaciones

### Gestión de Aplicaciones

- Datos básicos
- Gestión de módulos
- Gestión de roles
- Relación entre aplicaciones principales y transversales
- Gestión de credenciales:
  - CODE PKCE
  - Client Credentials

---

## 3.2 Aplicaciones Principales

Las aplicaciones principales:

- Son multi-organización
- Gestionan usuarios
- Gestionan permisos detallados
- Gestionan acceso a aplicaciones transversales

### Responsabilidades

- Gestión de permisos por módulo
- Gestión de permisos por rol
- Gestión de usuarios
- Asociación de módulos propios y transversales

---

## 3.3 Aplicaciones Transversales

Las aplicaciones transversales:

- No gestionan usuarios
- Son multi-organización
- Son multi-aplicación

### Responsabilidades

- Gestión de módulos
- Gestión de roles
- Filtrado por organización y aplicación

---

# 4. Modelo Conceptual

```mermaid
classDiagram

    class Organizacion {
        +Id
        +Nombre
        +Grupo
    }

    class Aplicacion {
        +Id
        +Nombre
        +Tipo
    }

    class Modulo {
        +Id
        +Nombre
    }

    class Rol {
        +Id
        +Nombre
    }

    class Usuario {
        +Email
        +Claims
    }

    Organizacion --> Aplicacion
    Aplicacion --> Modulo
    Aplicacion --> Rol
    Usuario --> Organizacion
    Usuario --> Aplicacion
```

---

# 5. Flujo de Alta de Nueva Organización

## Descripción

Cuando se crea una organización:

1. Se registra en InfoportOneAdmon
2. Se generan permisos sobre aplicaciones
3. Se crea usuario administrador en Keycloak
4. Se publica evento de organización
5. Las aplicaciones consumen el evento
6. Se crean estructuras internas de seguridad

## Diagrama

```mermaid
sequenceDiagram

    participant Admin as InfoportOneAdmon
    participant KC as Keycloak
    participant MQ as ActiveMQ
    participant APP as Aplicación Principal

    Admin->>KC: Crear usuario administrador
    Admin->>MQ: Publicar evento Organización

    MQ->>APP: Evento Organización

    APP->>APP: Crear empresa seguridad
    APP->>APP: Crear usuario administrador

    Note over APP: Usuario cambia contraseña\n y gestiona usuarios
```

---

# 6. Flujo de Alta de Usuario

## Descripción

El alta de usuario se realiza desde una aplicación principal.

## Proceso

1. Se crea usuario
2. Se asignan módulos
3. Se publica evento
4. InfoportOneAdmon verifica existencia
5. Se sincroniza Keycloak
6. Se actualizan claims

## Claims utilizados

| Claim | Descripción |
|---|---|
| c_ids | Organizaciones permitidas |
| a_ids | Aplicaciones permitidas |
| modules | Módulos permitidos |
| isAdmin | Superadministrador |

## Diagrama

```mermaid
sequenceDiagram

    participant APP as Aplicación Principal
    participant MQ as ActiveMQ
    participant ADMIN as InfoportOneAdmon
    participant KC as Keycloak

    APP->>MQ: Evento Usuario

    MQ->>ADMIN: Recepción evento

    ADMIN->>ADMIN: Buscar usuario por email

    ADMIN->>KC: Sincronizar usuario y claims

    KC-->>ADMIN: Usuario actualizado
```

---

# 7. Acceso a Aplicación Principal

## Reglas de acceso

- Se valida que la aplicación exista en `a_ids`
- Se carga organización inicial desde `c_ids`
- Todo acceso al backend se filtra por organización
- El backend valida siempre los claims

## Diagrama

```mermaid
flowchart TD

    A[Usuario accede aplicación] --> B{Aplicación en a_ids?}

    B -- No --> C[Acceso denegado]

    B -- Sí --> D[Cargar organización inicial]

    D --> E[Usuario interactúa]

    E --> F[Backend valida organización]

    F --> G[Procesar petición]
```

---

# 8. Acceso a Aplicación Transversal

## Escenario desde aplicación principal

La aplicación principal abre la transversal enviando:

- Aplicación origen
- Organización origen

## Escenario directo

Si se accede directamente:

- Se selecciona primera aplicación disponible
- Se selecciona primera organización disponible

## Diagrama

```mermaid
flowchart LR

    A[Aplicación Principal]
    B[Aplicación Transversal]

    A -->|SSO + app + organización| B

    B --> C[Filtrado por aplicación]
    C --> D[Filtrado por organización]

    D --> E[Validación claims]
```

---

# 9. Alta de Nueva Aplicación

## Proceso

1. Se desarrolla aplicación Helix7
2. Se configura identificador único
3. Se registra en InfoportOneAdmon
4. Se publican eventos
5. Las aplicaciones sincronizan configuración

## Diagrama

```mermaid
sequenceDiagram

    participant DEV as Desarrollo
    participant ADMIN as InfoportOneAdmon
    participant MQ as ActiveMQ
    participant APP as Aplicación Principal

    DEV->>ADMIN: Alta aplicación

    ADMIN->>MQ: Evento Aplicación

    MQ->>APP: Evento Aplicación

    APP->>APP: Sincronizar módulos y apps transversales
```

---

# 10. Configuración de Permisos por Superadministrador

## Claim especial

`isAdmin = true`

## Capacidades

- Configurar permisos por módulo
- Configurar permisos por rol
- Administración avanzada

## Diagrama

```mermaid
flowchart TD

    A[Usuario autenticado]

    A --> B{isAdmin?}

    B -- No --> C[Gestión estándar]

    B -- Sí --> D[Gestión avanzada permisos]

    D --> E[Configurar módulos]
    D --> F[Configurar roles]
```

---

# 11. Arquitectura SaaS Completa

```mermaid
flowchart TB

    subgraph Seguridad
        KC[Keycloak]
    end

    subgraph Integracion
        MQ[ActiveMQ]
    end

    subgraph Administracion
        ADMIN[InfoportOneAdmon]
    end

    subgraph Clientes
        ORG1[Organización A]
        ORG2[Organización B]
        ORG3[Organización C]
    end

    subgraph Apps_Principales
        APP1[Aplicación Principal 1]
        APP2[Aplicación Principal 2]
    end

    subgraph Apps_Transversales
        T1[Aplicación Transversal 1]
        T2[Aplicación Transversal 2]
    end

    ADMIN --> KC
    ADMIN --> MQ

    APP1 --> KC
    APP2 --> KC

    T1 --> KC
    T2 --> KC

    APP1 --> MQ
    APP2 --> MQ

    T1 --> MQ
    T2 --> MQ

    ORG1 --> APP1
    ORG1 --> APP2

    ORG2 --> APP1

    ORG3 --> APP2

    APP1 --> T1
    APP1 --> T2

    APP2 --> T1
```

---

# 12. Beneficios de la Arquitectura

## Escalabilidad

- Arquitectura desacoplada mediante eventos
- Nuevas aplicaciones integrables fácilmente

## Seguridad

- Centralización de autenticación en Keycloak
- Claims desacoplados y auditables

## Multi-tenant

- Multi-organización
- Multi-aplicación
- Filtrado contextual

## Mantenibilidad

- Separación clara de responsabilidades
- Integración estándar mediante eventos

## Extensibilidad

- Soporte sencillo para nuevas aplicaciones
- Integración de módulos transversales
