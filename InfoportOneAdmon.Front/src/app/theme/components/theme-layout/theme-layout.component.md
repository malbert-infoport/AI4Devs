# ThemeLayoutComponent

Este componente es el marco de nuestra aplicación, se cargará siempre dentro de la
ruta **/protected** configurada dentro del **app.routes.ts**,incluye un menú lateral
<span style="font-weight:bold;color:#2A43D1">theme-left-sidebar</span> y un menú superior <span style="font-weight:bold;color:#2A43D1 ">
theme-topbar</span>.

Las opciones del menú lateral se configuran desde el servicio <span style="font-weight:bold;color:#2A43D1 ">theme-left-sidebar.service </span> y las del menú superior desde <span style="font-weight:bold;color:#2A43D1 ">theme-topbar.service </span>

La ruta **/protected** está protediga por la guarda **OidcGuardService**

![ThemeLayoutComponent](/assets-doc/ThemeLayoutComponent.png)

- [theme-left-sidebar](/components/ThemeLeftSidebarComponent.html)
- [theme-left-sidebar.service](/injectables/ThemeLeftSidebarService.html)
- [theme-topbar](/components/ThemeTopbarComponent.html)
- [theme-topbar.service](/injectables/ThemeTopBarService.html)
