# ThemeLeftSidebarComponent

Componente que muestra las opciones de menú en la barra lateral

<img src="/assets-doc/ThemeLeftSidebarComponent.png" alt="left-sidebar" style="width: 100%"/>

Las opciones de menú se configuran desde el servicio <span style="font-weight:bold;color:#2A43D1 "> [theme-left-sidebar.service](../../injectables/ThemeLeftSidebarService.html) </span>

## Opciones del menú lateral

- [titleInput] : Incluye las siguientes opciones
  - appName: Nombre de la aplicación
  - appSlogan: Slogan de la aplicación.
  - logo: Imagen del logo de la aplicación
  - version: versión de la aplicación, sacada de la información de environment.
  - disabled: habilita o deshabilita el modal con información de las actualizaciones (Parches)

Dichos datos se configuran en la función <span style="font-weight:bold;color:#2A43D1 ">getTile()</span> del <span style="font-weight:bold;color:#2A43D1 "> theme-left-sidebar.service</span>

<img src="../assets-doc/left-sidebar-getTitle.jpg" alt="Visualización del título" style="width: 50%"/>

- [menuInput]: Opciones del menú lateral, parte superior. Se forma con la función <span style="font-weight:bold;color:#2A43D1 "> getMenu() </span> del <span style="font-weight:bold;color:#2A43D1 "> theme-left-sidebar.service</span> Incluye las siguientes opciones:

  - trasnlateKey: Clave de traducción
  - iconname: Nombre del icono
  - url: ruta a la que redirecciona (routerLink)
  - exactUrl: para especificar si una ruta debe coincidir exactamente con la URL solicitada ( Es una de las propiedades del routerLink, [routerLinkActiveOptions]="{ exact: node.exactUrl }")
  - disabled: Activar/Desactivar el botón del menú
  - hasParent: true o false, indica si es un children y tiene parent.
  - children: Es un array para indicar los submenús.

  <img src="../assets-doc/left-sidebar-set-getMenu.jpg" alt="Configuración de opciones de menú" style="width: 50%"/>

- [usermenuInput]: Opciones del menú lateral, parte inferior,opciones de usuario. Se forma con la función <span style="font-weight:bold;color:#2A43D1 "> getUserMenu(user:IAuthUser) </span> del <span style="font-weight:bold;color:#2A43D1 "> theme-left-sidebar.service</span> Incluye las mismas opciones que el <span style="font-weight:bold;color:#2A43D1 ">menuInput</span>

  <img src="../assets-doc/left-sidebar-set-getUserMenu.jpg" alt="Configuración menú usuario" style="width: 50%"/>

  <img src="../assets-doc/user.jpg" alt="Obtención del usuario" style="width: 50%"/>

- [contactinfoInput] Opciones del menú lateral, parte inferior,opciones de contacto.Se forma con la función <span style="font-weight:bold;color:#2A43D1 "> getContactInfo() </span> del <span style="font-weight:bold;color:#2A43D1 "> theme-left-sidebar.service</span>

  <img src="../assets-doc/left-sidebar-set-getContactInfo.jpg" alt="visualización menú usuario" style="width: 50%"/>
