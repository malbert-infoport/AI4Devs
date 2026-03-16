# ThemeTopbarComponent

Componente para mostrar el menú superior.

- [userNameTopInput]: Muestra el nombre del usuario en el menú superior. Se utiliza la función <span style="font-weight:bold;color:#2A43D1 ">getUser()</span> del servicio <span style="font-weight:bold;color:#2A43D1 ">theme-topbar</span>.service.ts.
- [topMenuInput]: Configuración de las opciones del menú superior. Se utiliza la función <span style="font-weight:bold;color:#2A43D1 ">getTopMenu()</span> del servicio <span style="font-weight:bold;color:#2A43D1 ">theme-topbar</span>.service.ts.
- [environment]: Indica en que entorno te encuentras.(Desarrollo,Producción,etc..). Lee de el servicio <span style="font-weight:bold;color:#2A43D1 ">EnvConfigurationService</span> de la propiedad <span style="font-weight:bold;color:#2A43D1 ">environment</span>.
- [colorEnvironment]: Color, para identificar facilmente en que entorno de encuentras. Lee de el servicio <span style="font-weight:bold;color:#2A43D1 ">EnvConfigurationService</span> de la propiedad <span style="font-weight:bold;color:#2A43D1 ">colorEnvironment</span>.

<img src="/assets-doc/ThemeTopBarComponent.png" alt="Theme topbar" style="width: 100%"/>

## Configuración del menú

<img src="../assets-doc/theme-topbar-getTopMenu.jpg" alt="Configuración del menu" style="width: 50%"/>

## Datos del usuario

<img src="../assets-doc/theme-topbar-getUser.jpg" alt="Datos del usuario" style="width: 25%"/>

## Inputs de theme-topbar

<img src="../assets-doc/topbar.jpg" alt="Componente topbar inputs" style="width: 50%"/>
