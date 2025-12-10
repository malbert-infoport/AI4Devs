# 🧭 1. InfoportOneAdmon - Sistema de Gestión Centralizada de Organizaciones y Roles

## 📚 Tabla de Contenidos

1. [📝 1. Descripción General del Producto](#-1-descripción-general-del-producto)
2. [⚙️ 2. Funcionalidades Principales](#%EF%B8%8F-2-funcionalidades-principales)
3. [🏗️ 3. Arquitectura Lógica del Sistema](#%EF%B8%8F-3-arquitectura-lógica-del-sistema)
4. [🔀 4. Flujos de Proceso de Negocio](#-4-flujos-de-proceso-de-negocio)
5. [🗃️ 5. Modelo de Datos Conceptual](#%EF%B8%8F-5-modelo-de-datos-conceptual)
6. [🚀 6. Estrategia de Optimización y Rendimiento](#-6-estrategia-de-optimización-y-rendimiento)
7. [👥 7. Identificación y Clasificación de Stakeholders](#-7-identificación-y-clasificación-de-stakeholders)
8. [🧱 8. Componentes Principales y Sitemaps](#-8-componentes-principales-y-sitemaps)
9. [🎨 9. Diseño y Experiencia del Usuario (UX/UI)](#-9-diseño-y-experiencia-del-usuario-uxui)
10. [🛠️ 10. Requisitos Técnicos](#%EF%B8%8F-10-requisitos-técnicos)
11. [🗓️ 11. Planificación del Proyecto (MVP de 30 Horas)](#%EF%B8%8F-11-planificación-del-proyecto-mvp-de-30-horas)

---

## 📝 1. Descripción General del Producto

### 🌟 Visión del Producto

**InfoportOneAdmon** es la plataforma administrativa centralizada ("Back-Office") diseñada exclusivamente para que la **Organización Propietaria** del ecosistema gestione el ciclo de vida de los clientes (Organizaciones), sus agrupaciones, y la seguridad transversal de las aplicaciones satélites.

A diferencia de modelos SaaS de auto-servicio, en este ecosistema **las organizaciones no se registran por sí mismas**. Es la Organización Propietaria quien, a través de InfoportOneAdmon, da de alta, configura y provisiona los entornos para sus clientes, garantizando un control total sobre quién accede al ecosistema y cómo se relacionan entre sí.

**Misión**: Centralizar la complejidad administrativa (altas de clientes, grupos de clientes, seguridad OAuth2, catálogo de roles) para que las aplicaciones de negocio (CRM, ERP, etc.) puedan centrarse exclusivamente en su lógica funcional y en la gestión de sus propios usuarios.

### 🎯 Alcance y Responsabilidades

InfoportOneAdmon actúa como la **Fuente de la Verdad** para:

1.  **Gestión de Inquilinos (Tenants)**: Control del ciclo de vida de las organizaciones clientes.
2.  **Gestión de Grupos de Organizaciones**: Creación y mantenimiento de agrupaciones lógicas de organizaciones.
3.  **Catálogo Maestro de Roles**: Definición única de qué roles existen en cada aplicación.
4.  **Gobierno de Identidad**: Orquestación de Keycloak para la seguridad de las aplicaciones.

**🔑 PRINCIPIO CLAVE DE RESPONSABILIDAD**:
* **InfoportOneAdmon**: Define *quién* es el cliente (Organización), *cómo se agrupan* y *qué* roles existen (Definiciones).
* **Aplicaciones Satélite**: Gestionan *quiénes* son los usuarios finales y *qué* roles tienen asignados.

### 🧩 Principios de Diseño

| Principio | Descripción | Justificación de Negocio |
|-----------|-------------|--------------------------|
| **Administración Centralizada** | Gestión exclusiva por la Organización Propietaria | Control total sobre el onboarding y la estructura de clientes. |
| **Single Realm** | Un único realm (InfoportOne) en Keycloak | Simplifica la gestión de identidades y permite SSO real. |
| **Usuarios Descentralizados** | Las Apps crean sus propios usuarios | Permite a cada aplicación escalar y gestionar sus usuarios sin cuellos de botella centrales. |
| **Roles como Catálogo** | InfoportOneAdmon define, Apps asignan | Asegura coherencia en los nombres y flexibilidad en la asignación. |
| **State-Transfer-Oriented Events** | Los eventos no comunican la acción (creado, actualizado), sino el **estado final** de la entidad. | **Desacopla al consumidor del productor**. El consumidor no necesita conocer la historia; aplica la lógica "upsert" (si existe, actualiza; si no, crea) o borra si `IsDeleted` es true, haciendo el sistema más resiliente. |
| **Sincronización por Eventos**| La inicialización de datos en nuevas aplicaciones se realiza mediante la emisión de eventos desde InfoportOneAdmon | Asegura un bajo acoplamiento y permite a las aplicaciones inicializarse o resincronizarse bajo demanda y de forma asíncrona |
---

## ⚙️ 2. Funcionalidades Principales

### 2.1️⃣ Gestión de Organizaciones (Clientes)

**📝 Descripción**:
Este módulo permite a los administradores de la Organización Propietaria gestionar el ciclo de vida completo de las empresas clientes. Su objetivo es centralizar el alta administrativa y técnica en un solo paso.

**🧠 Capacidades**:
* ✅ **Onboarding de Clientes**: Alta de nueva organización, generando su `SecurityCompanyId`.
* 🛠️ **Gestión de Configuración**: Modificación de datos corporativos.
* 🔌 **Kill-Switch (Desactivación)**: Bloqueo de acceso de una organización.
* 🧾 **Auditoría de Tenant**: Trazabilidad completa de cambios.

### 2.2️⃣ Gestión de Grupos de Organizaciones

**📝 Descripción**:
Permite crear y gestionar agrupaciones lógicas de organizaciones. Estas agrupaciones son cruciales para las aplicaciones que necesitan implementar funcionalidades transversales entre varias organizaciones que pertenecen a un mismo "consorcio" o "holding".

**🧠 Capacidades**:
* 🆕 **Creación de Grupos**: Definir un nuevo grupo de organizaciones (ej: "Grupo Logístico Peninsular").
* 🔄 **Asociación de Miembros**: Añadir o eliminar organizaciones de un grupo existente.
* 🗑️ **Gestión del Ciclo de Vida**: Modificar o eliminar grupos.
* 📢 **Propagación de Cambios**: Cada cambio (creación, modificación, borrado de grupo, o cambio en sus miembros) genera un evento de estado que se publica en el bus para notificar a las aplicaciones.

### 2.3️⃣ Gestión de Definiciones de Roles (Catálogo)

**📝 Descripción**:
Funciona como un repositorio maestro de roles. Permite definir qué "perfiles" existen dentro de cada aplicación (ej: "Vendedor", "Gerente").

**🧠 Capacidades**:
* 📘 **Creación de Catálogo**: Definir nuevos roles para una aplicación.
* 🧪 **Deprecación**: Marcar roles como obsoletos.
* 🔎 **Consulta de Roles**: Endpoint para que las aplicaciones descarguen su lista de roles.

### 2.4️⃣ Gestión de Aplicaciones (Ecosistema)

**📝 Descripción**:
Permite registrar nuevas aplicaciones satélite en el ecosistema, gestionando su configuración de seguridad OAuth2.

**🧠 Capacidades**:
* 🆕 **Registro de Aplicación**: Alta de nueva app, generando `client_id` y `client_secret`.
* 🔐 **Gestión de Secretos**: Rotación y administración segura de credenciales.
* 🚦 **Control de Acceso**: Definir si una aplicación está activa o en mantenimiento.
* ✨ **Sincronización de Datos**: Funcionalidad para enviar catálogos completos (ej: de aplicaciones, de organizaciones) a una aplicación específica mediante eventos, útil para inicializar una nueva instancia.

### 2.5️⃣ Integración Transparente con Keycloak

**📝 Descripción**:
Abstrae la complejidad de Keycloak. Los administradores no necesitan acceder a su consola.

**🧠 Capacidades**:
* 🔄 **Sincronización de Estructuras**: Creación automática de grupos y atributos en Keycloak.
* 🧩 **Configuración de Claims**: Garantiza que los tokens incluyan el `SecurityCompanyId`.

### 2.6️⃣ Arquitectura Orientada a Eventos (ActiveMQ Artemis)

**📝 Descripción**:
Mecanismo de comunicación asíncrona basado en el patrón **"State Transfer Event"** para mantener la coherencia entre InfoportOneAdmon y las aplicaciones satélite. En lugar de notificar acciones (ej. "se creó X"), se notifica el **nuevo estado de la entidad**. Esto hace que los sistemas consumidores sean más robustos y fáciles de sincronizar.

**📣 Tópicos de Eventos Principales**:
Se define un tópico por cada entidad de negocio principal.

*   `infoportone.events.organization`
*   `infoportone.events.organization-group`
*   `infoportone.events.application`
*   `infoportone.events.role`
*   `infoportone.events.synchronization` (Para eventos de sincronización masiva)

### 2.7️⃣ Definición de la Estructura de Eventos

Todos los eventos comparten una estructura común que permite a los consumidores aplicar una lógica de "upsert" (actualizar o insertar) o eliminar, independientemente de si tenían el dato previamente.

#### Estructura Genérica del Evento

```json
{
  "EventId": "Guid", // Identificador único del evento
  "EventType": "string", // Describe la entidad, ej: "OrganizationEvent"
  "EventTimestamp": "DateTime", // Fecha y hora de generación del evento
  "IsDeleted": false, // `false` para creación/actualización, `true` para eliminación
  "Payload": {
    // Objeto completo de la entidad en su estado final
  }
}
```

#### Ejemplo: `OrganizationEvent`

Enviado al tópico `infoportone.events.organization`.

*   **`EventType`**: `"OrganizationEvent"`
*   **`Payload`**: Objeto completo de la entidad `ORGANIZATION`.

```json
{
  "EventId": "a1b2c3d4-e5f6-7890-1234-567890abcdef",
  "EventType": "OrganizationEvent",
  "EventTimestamp": "2025-12-10T10:00:00Z",
  "IsDeleted": false,
  "Payload": {
    "SecurityCompanyId": 12345,
    "Nombre": "Cliente Final S.L.",
    "Estado": "Activo",
    "GroupId": 101
  }
}
```
*Si `IsDeleted` fuera `true`, el `Payload` aún contendría el `SecurityCompanyId` para que el consumidor sepa qué entidad eliminar.*

#### Ejemplo: `OrganizationGroupEvent`

Enviado al tópico `infoportone.events.organization-group`.

*   **`EventType`**: `"OrganizationGroupEvent"`
*   **`Payload`**: Objeto completo de la entidad `ORGANIZATION_GROUP`.

```json
{
  "EventId": "b2c3d4e5-f6a7-8901-2345-67890abcdef0",
  "EventType": "OrganizationGroupEvent",
  "EventTimestamp": "2025-12-10T11:30:00Z",
  "IsDeleted": false,
  "Payload": {
    "GroupId": 101,
    "Name": "Grupo Logístico Principal"
  }
}
```

**Lógica del Consumidor:**
1. Recibe un mensaje del tópico `infoportone.events.organization`.
2. Deserializa el `Payload` en un objeto `Organization`.
3. Si `IsDeleted` es `true`:
   - `DELETE FROM Organizations WHERE SecurityCompanyId = payload.SecurityCompanyId;`
4. Si `IsDeleted` es `false`:
   - `SELECT * FROM Organizations WHERE SecurityCompanyId = payload.SecurityCompanyId;`
   - Si existe: `UPDATE Organizations SET ... WHERE SecurityCompanyId = ...;`
   - Si no existe: `INSERT INTO Organizations (...) VALUES (...);`

Este enfoque simplifica enormemente la lógica del consumidor y lo hace inmune a eventos perdidos o desordenados (siempre que procese el último estado).

## 🏗️ 3. Arquitectura Lógica del Sistema
*(Sin cambios)*

## 🔀 4. Flujos de Proceso de Negocio
*(Los diagramas siguen siendo válidos, ya que la acción de "Publicar Evento" ahora implica publicar un evento de estado en el tópico correspondiente).*

### 4.1️⃣ Alta de Nueva Organización (Onboarding)
Publica un `OrganizationEvent` con `IsDeleted: false` y el payload de la nueva organización.

### 4.2️⃣ Gestión de un Grupo de Organizaciones
*   **Crear Grupo**: Publica un `OrganizationGroupEvent` con el nuevo grupo.
*   **Añadir/Quitar Miembro**: Publica un `OrganizationEvent` para la organización afectada, con su `GroupId` actualizado.

### 4.3️⃣ Sincronización de Datos para una Nueva Aplicación
Publica un evento especial en el tópico de sincronización, cuyo payload es una lista de los objetos a sincronizar (ej: un array de `Organization`).

## 🗃️ 5. Modelo de Datos Conceptual
*(Sin cambios)*

## 🚀 6. Estrategia de Optimización y Rendimiento
*(Sin cambios)*

## 👥 7. Identificación y Clasificación de Stakeholders
*(Sin cambios)*

## 🧱 8. Componentes Principales y Sitemaps
*(Sin cambios)*

## 🎨 9. Diseño y Experiencia del Usuario (UX/UI)
*(Sin cambios)*

## 🛠️ 10. Requisitos Técnicos
*(Sin cambios)*

## 🗓️ 11. Planificación del Proyecto (MVP de 30 Horas)
*(Sin cambios)*