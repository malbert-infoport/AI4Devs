# Listado de Prompts

## Prompt 1: (Definición del producto)

-   **Rol:** Product Owner especialista en aplicaciones multiorganizacion, con una gestión centralizada de las organizaciones con acceso a cada aplicación mediante oauth2.
-   **Objetivo:** Realizar una descripción general del proyecto en formato .md, lo más detallada posible, para la gestión de organizaciones con toda la funcionalidad que debe cubrir para permitir crear organizaciones cuyos usuarios puedan acceder a las distintas aplicaciones del ecosistema. Esta documentación deberá cubrir:
    -   Una descripción breve del proyecto de organizaciones
    -   Funcionalizades principales.
    -   Diagrama del sistema explicado como con diagrama mermaid adjunto.
    -   Descripción de todos los casos de uso que cubran la funcionalidad completa del proyecto junto con su diagrama mermaid asociado.
    -   Modelo de datos que cubra entidades, atributos (nombre y tipo) y relaciones para todos los casos de uso.
-   **Requisitos previos:**
    -   El proyecto de organizaciones esta integrado con un identity server keycloak en su última versión y accederá a las Apis Rest de keycloak para gestionar el alta de organizaciones, usuarios, etc.
    -   La interacción con el keycloak mediante apis solo se realizará desde el proyecto de organizaciones, el resto de aplicaciones del ecosistema solo utilizará el flujo de autenticación code pkce para permitir el acceso a las mismas.
    -   Se define un realm único, InfoportOne, que permite que las distintas aplicaciones creadas puedan ser accedidas por los usaurios de las organizaciones con sigle sign on si tienen permisos para acceder a varias aplicaciones.
    -   Desde el proyecto de organizaciones también se gestionarán las distintas aplicaciones del sistema para controlar los distintos roles que cada aplicación puede tener aunque esta entidad no se sincroniza con keycloak, se utiliza para proporcionar los roles de acceso a cada aplicación.
    -   La integración con la última versión de keycloak permitirá hacer uso de su gestión propia de organizaciones para sincronizar ciertos datos relevantes desde el proyecto de organizaciones que luego viajarán en el bearer token obtenido en el proceo de autorización de un usuario en una aplicación mediante code pkce. Un dato fundamental es el SecurityCompanyId que identifica la organización en las aplicaciones y viaja como claim.
    -   Las aplicaciones también tendrán un identificador entero llamado AplicationId que se usará cuando las aplicaciones reciban mediante eventos los roles asociados a las mismas.
    -   El proyecto de organizaciones no solo estará integrado con keycloak sino que también debe ofrecer a las aplicaciones del sistema el poder obtener los roles asignables a los usuarios de su aplicación y permitirá a las aplicaciones poder dar de alta nuevos usuarios con ciertos roles haciendo uso del proyecto de organizaciones.
    -   La integración entre las aplicaciones y el proyecto de organizaciones será mediante un broker de eventos tipo RabbitMq, ActiveMq, que independice el proyecto de organizaciones de las distintas aplicaciones.
    -   La base de datos del proyecto de organizaciones es postgres y la tecnología utilizada será .net 8 y angular 20.
    -   La idea es que las aplicaciones del ecosistema y el propio proyecto de organizaciones se desplieguen mediante contenedores en la nube o on premise.
    -   Se deben tener en cuenta las premisas de desarrollo o de arquitectura que reduzcan los costes del proyecto en la nube tales como las transacciones realizadas a base de datos, accesos a disco, número de contenedores a incluir en la arquitectura, etc.

---

## Prompt 2: (Definición del producto)

-   **Rol:** Product Owner especialista en aplicaciones multiorganizacion, con una gestión centralizada de las organizaciones con acceso a cada aplicación mediante oauth2.
-   **Objetivo:** Volver a generar la documentación teniendo en cuenta que el proyecto de organizaciones no gestiona los usuarios, son las aplicaciones quienes lo hacen y las que determinan cada rol que permisos de acceso efectivos tiene la propia aplicación. Desde el proyecto de organizaciones solo se gestionanrán que roles tiene cada aplicación par que la propia aplicación de de alta usuarios con sus roles asociados mediante el proyecto de organizaciones.

---

## Prompt 3: (Definición del producto)

-   **Rol:** Product Owner especialista en aplicaciones multiorganizacion, con una gestión centralizada de las organizaciones con acceso a cada aplicación mediante oauth2.
-   **Objetivo:** Revisa la documentación completa ya generada que te he indico a continuación para añadir una descripción a las funcionalidades principales, al menos al nivel superior de la funcionalidad indicando el sentido de la misma. Quiero que sustituyas rabbitmq por ActiveMq Artemis y todas sus apariciones en los diagramas. Y toda referencia a SGOR como nombre de proyecto pase a ser InfoportOneAdmon. En este punto de definición del proyecto no quiero que te centres en el como sino en el que, no es necesario poner ejemplos json para los claims ni el patrón de suscripción a roles. Los flujos definidos creo que quedarian más claros si los diseñas como diagramas de flujo en uml en mermaid.También debe quedar muy claro que este proyecto de administración de organizaciones esta pensado no para que las organizaciones se suscriban, habrá una organización propietaria del ecosistema de aplicaciones que se encargará de crear la nueva organización y de gestionarlo todo desde InfoportOneAdmon.

---

## Prompt 4: (Definición de Producto)

-   **Rol:** Product Owner especialista en aplicaciones multiorganizacion, con una gestión centralizada de las organizaciones con acceso a cada aplicación mediante oauth2.
-   **Objetivo:** En base al contexto de este hilo me gustaria que me definas en codificación .md un nuevo punto para mi informe con los Stakeholders: Identifica a todas las partes interesadas, incluyendo usuarios, compradores, fabricantes, asistencia al cliente, marketing y ventas, socios externos, instancias reguladoras, minoristas, entre otros.

---

## Prompt 5: (Definición de Producto)

-   **Rol:** Product Owner especialista en aplicaciones multiorganizacion, con una gestión centralizada de las organizaciones con acceso a cada aplicación mediante oauth2.
-   **Objetivo:** Añádeme en base al contexto del proyecto los siguientes puntos:
    -   Componentes Principales y Sitemaps: Detalla la estructura y organización del producto, incluyendo sus componentes principales y cómo se relacionan entre sí
    -   Diseño y Experiencia del Usuario: Incluye especificaciones sobre el diseño del producto y la experiencia del usuario, asegurando que el producto sea usable y estéticamente agradable.
    -   Requisitos Técnicos: Detalla los aspectos técnicos necesarios para el desarrollo del producto, incluyendo hardware, software, interactividad, personalización y normativas.
    -   Planificación del Proyecto: Proporciona información sobre plazos, hitos y dependencias, crucial para la planificación y gestión efectiva del proyecto. Esta debe estar acotada a un plazo de 30 horas que son más o menos las horas dedicadas a realziar este proyecto mediante IA. Esto debe ser tenido en cuenta para determinar el PMV de este proyecto.
    -   Criterios de aceptación: Define los estándares y condiciones bajo los cuales el producto será aceptado tras su finalización.

---

## Prompt 6: (Definición de Producto)

-   **Rol:** Product Owner especialista en aplicaciones multiorganizacion, con una gestión centralizada de las organizaciones con acceso a cada aplicación mediante oauth2.
-   **Objetivo:** quiero que analices primero la documentanción del producto que estoy definendo y a continuación apliques sobre el mismo los siguientes cambios en la documentación y diagramas correspondiente a los siguientes criterios:
    -   Las organizaciones deben poder agruparse en grupos de organizaciones para que desde las aplicaciones se puedan realizar funcionalidades entre las organizaciones de un mismo grupo. Esto debe ser mantenible y generar eventos que lo comuniquen a los servicios.
    -   En el documento se explica que las aplicaciones cuando arranquen se conectarán vía api a InfoportOne para sincronizar datos. Esto NO debe ser así. Cuando se despliegue una aplicación y se quiera sincronizar datos con la misma desde InfoportOne debe haber una funcionalidad que permita enviar por ejemplo para las aplicaciones el listado completo de aplicaciones mediante eventos a la cola a la que esté suscrita la aplicación destinataria. Este será un método de sincronización de datos o de inicialización de datos para una aplicación nueva.

---

## Prompt 7: (Definición de Producto)

-   **Rol:** Product Owner especialista en aplicaciones multiorganizacion, con una gestión centralizada de las organizaciones con acceso a cada aplicación mediante oauth2.
-	**Objetivo:** He visto que en la definición de eventos aparecen los sufijos added, created, updated, deleted y creo que la aplicación satélite receptora no tiene porque estar en el mismo estado sus tablas que las de InfoportOne. Por ejemplo podria haber una actualización de una organización en InfoportOne pero si la aplicación satélite no tiene todavia organizaciones se trataría de crear una nueva organización en la aplciación satélite. Por tanto me gustaría que se definan eventos generales para cada entidad del tipo OrganizacionEvent Este evento tendrá una propiedad tipo OrganizationEvent, una fecha de creación, un flag IsDeleted para indicar si ha sido borrado en origen y las propiedades de la Organización. El resto de eventos seguirian una estructura similar. Puedes incluir en la documentación la definicación de los eventos.