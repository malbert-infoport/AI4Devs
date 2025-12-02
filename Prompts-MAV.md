Prompt 1: (Definición del producto)
- Rol: Product Owner especialista en aplicaciones multiorganizacion, con una gestión centralizada de las organizaciones con acceso a cada aplicación mediante oauth2.
- Objetivo: Realizar una descripción general del proyecto en formato .md, lo más detallada posible, para la gestión de organizaciones con toda la funcionalidad que debe cubrir para permitir crear organizaciones cuyos usuarios puedan acceder a las distintas aplicaciones del ecosistema. Esta documentación deberá cubrir:
		- Una descripción breve del proyecto de organizaciones 
		- Funcionalizades principales.
		- Diagrama del sistema explicado como con diagrama mermaid adjunto.
		- Descripción de todos los casos de uso que cubran la funcionalidad completa del proyecto junto con su diagrama mermaid asociado.
		- Modelo de datos que cubra entidades, atributos (nombre y tipo) y relaciones para todos los casos de uso.
- Requisitos previos: 
		- El proyecto de organizaciones esta integrado con un identity server keycloak en su última versión y accederá a las Apis Rest de keycloak para gestionar el alta de organizaciones, usuarios, etc.
		- La interacción con el keycloak mediante apis solo se realizará desde el proyecto de organizaciones, el resto de aplicaciones del ecosistema solo utilizará el flujo de autenticación code pkce para permitir el acceso a las mismas.
		- Se define un realm único, InfoportOne, que permite que las distintas aplicaciones creadas puedan ser accedidas por los usaurios de las organizaciones con sigle sign on si tienen permisos para acceder a varias aplicaciones.
		- Desde el proyecto de organizaciones también se gestionarán las distintas aplicaciones del sistema para controlar los distintos roles que cada aplicación puede tener aunque esta entidad no se sincroniza con keycloak, se utiliza para proporcionar los roles de acceso a cada aplicación.
		- La integración con la última versión de keycloak permitirá hacer uso de su gestión propia de organizaciones para sincronizar ciertos datos relevantes desde el proyecto de organizaciones que luego viajarán en el bearer token obtenido en el proceo de autorización de un usuario en una aplicación mediante code pkce. Un dato fundamental es el SecurityCompanyId que identifica la organización en las aplicaciones y viaja como claim.
		- Las aplicaciones también tendrán un identificador entero llamado AplicationId que se usará cuando las aplicaciones reciban mediante eventos los roles asociados a las mismas.
		- El proyecto de organizaciones no solo estará integrado con keycloak sino que también debe ofrecer a las aplicaciones del sistema el poder obtener los roles asignables a los usuarios de su aplicación y permitirá a las aplicaciones poder dar de alta nuevos usuarios con ciertos roles haciendo uso del proyecto de organizaciones.
		- La integración entre las aplicaciones y el proyecto de organizaciones será mediante un broker de eventos tipo RabbitMq, ActiveMq, que independice el proyecto de organizaciones de las distintas aplicaciones.
		- La base de datos del proyecto de organizaciones es postgres y la tecnología utilizada será .net 8 y angular 20.
		- La idea es que las aplicaciones del ecosistema y el propio proyecto de organizaciones se desplieguen mediante contenedores en la nube o on premise.
		- Se deben tener en cuenta las premisas de desarrollo o de arquitectura que reduzcan los costes del proyecto en la nube tales como las transacciones realizadas a base de datos, accesos a disco, número de contenedores a incluir en la arquitectura, etc.
		
Prompt 2: (Definición del producto)
- Rol: Product Owner especialista en aplicaciones multiorganizacion, con una gestión centralizada de las organizaciones con acceso a cada aplicación mediante oauth2.
- Objetivo: Volver a generar la documentación teniendo en cuenta que el proyecto de organizaciones no gestiona los usuarios, son las aplicaciones quienes lo hacen y las que determinan cada rol que permisos de acceso efectivos tiene la propia aplicación. Desde el proyecto de organizaciones solo se gestionanrán que roles tiene cada aplicación par que la propia aplicación de de alta usuarios con sus roles asociados mediante el proyecto de organizaciones.

Prompt3: (Definición del producto)
- Rol: Product Owner especialista en aplicaciones multiorganizacion, con una gestión centralizada de las organizaciones con acceso a cada aplicación mediante oauth2.
- Objetivo: Revisa la documentación completa ya generada que te he indico a continuación para añadir una descripción a las funcionalidades principales, al menos al nivel superior de la funcionalidad indicando el sentido de la misma. Quiero que sustituyas rabbitmq por ActiveMq Artemis y todas sus apariciones en los diagramas. Y toda referencia a SGOR como nombre de proyecto pase a ser InfoportOneAdmon. En este punto de definición del proyecto no quiero que te centres en el como sino en el que, no es necesario poner ejemplos json para los claims ni el patrón de suscripción a roles. Los flujos definidos creo que quedarian más claros si los diseñas como diagramas de flujo en uml en mermaid.También debe quedar muy claro que este proyecto de administración de organizaciones esta pensado no para que las organizaciones se suscriban, habrá una organización propietaria del ecosistema de aplicaciones que se encargará de crear la nueva organización y de gestionarlo todo desde InfoportOneAdmon.

Prompt4: (Definición de Producto)
- Rol: Product Owner especialista en aplicaciones multiorganizacion, con una gestión centralizada de las organizaciones con acceso a cada aplicación mediante oauth2.
- Objetivo: En base al contexto de este hilo me gustaria que me definas en codificación .md un nuevo punto para mi informe con los Stakeholders: Identifica a todas las partes interesadas, incluyendo usuarios, compradores, fabricantes, asistencia al cliente, marketing y ventas, socios externos, instancias reguladoras, minoristas, entre otros.