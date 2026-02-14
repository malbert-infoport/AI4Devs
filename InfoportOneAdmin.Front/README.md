# InfoportOneAdmin 1.0

This project was generated with [Angular CLI](https://github.com/angular/angular-cli) version 17.2.1.

```ts
Angular CLI:  20.1.6
Node: 22.12.0
Package Manager: npm 10.9.0

@angular-devkit/architect:  0.2001.6
@angular-devkit/core:  20.1.6
@angular-devkit/schematics:  20.1.6
@schematics/angular   20.1.6
ng-packagr: 20.2.0
rxjs: 7.8.0
typescript: 5.8.3
zone.js: 0.15.1
```

## Ajustes del proyecto

En el siguiente directorio `src\app\config\config.ts` hay una constante `appName`, que se utiliza para validar los permisos de cada aplicación

```ts
export const appName = 'InfoporOneAdmin';
```

esta debe coincidir con la que está puesta en el `back`, en el el siguiente directorio `InfoporOneAdmin.Back/InfoporOneAdmin.Back.Api/appsettings.Development.json`,dentro del objeto `HelixConfiguration` en la propiedad `ApplicationName`

```json
  "HelixConfiguration": {
    "ApplicationName": "InfoporOneAdmin",
    "RolPrefixes": "HLX_,admin",
    "PermisionsMinutesCache": 5
  },
```

## Instalar librería Common.Library

[Instalar Common.Library](https://storybook.infoport.es/?path=/story/instalaci%C3%B3n--instalaci%C3%B3n)

#### Ejemplos componentes librería

[Common Library](https://storybook.infoport.es/)

#### Instalar la última versión de la librería

```ts
npm i @cl/common-library@latest
```

## ¿Que dependencias vienen instaladas al usar la librería @cl/common-library?

(Estas dependencias vendran instaladas con la librería y no se deben incluir en nuestro proyecto)

```json
{
  "name": "@cl/common-library",
  "version": "2.1.0",
  "sideEffects": false,
  "dependencies": {
    "@angular/localize": "~20.1.2",
    "@ngx-translate/core": "^15.0.0",
    "@phosphor-icons/web": "~2.1.1",
    "@progress/kendo-angular-buttons": "~19.2.0",
    "@progress/kendo-angular-charts": "~19.2.0",
    "@progress/kendo-angular-common": "~19.2.0",
    "@progress/kendo-angular-dateinputs": "~19.2.0",
    "@progress/kendo-angular-dialog": "~19.2.0",
    "@progress/kendo-angular-dropdowns": "~19.2.0",
    "@progress/kendo-angular-excel-export": "~19.2.0",
    "@progress/kendo-angular-filter": "~19.2.0",
    "@progress/kendo-angular-gauges": "~19.2.0",
    "@progress/kendo-angular-grid": "~19.2.0",
    "@progress/kendo-angular-icons": "~19.2.0",
    "@progress/kendo-angular-indicators": "~19.2.0",
    "@progress/kendo-angular-inputs": "~19.2.0",
    "@progress/kendo-angular-intl": "~19.2.0",
    "@progress/kendo-angular-l10n": "~19.2.0",
    "@progress/kendo-angular-label": "~19.2.0",
    "@progress/kendo-angular-layout": "~19.2.0",
    "@progress/kendo-angular-menu": "~19.2.0",
    "@progress/kendo-angular-navigation": "~19.2.0",
    "@progress/kendo-angular-notification": "~19.2.0",
    "@progress/kendo-angular-pdf-export": "~19.2.0",
    "@progress/kendo-angular-popup": "~19.2.0",
    "@progress/kendo-angular-progressbar": "~19.2.0",
    "@progress/kendo-angular-scheduler": "~19.2.0",
    "@progress/kendo-angular-sortable": "~19.2.0",
    "@progress/kendo-angular-tooltip": "~19.2.0",
    "@progress/kendo-angular-treeview": "~19.2.0",
    "@progress/kendo-angular-utils": "~19.2.0",
    "@progress/kendo-data-query": "~1.7.1",
    "@progress/kendo-drawing": "~1.21.2",
    "@progress/kendo-font-icons": "~4.5.0",
    "@progress/kendo-licensing": "~1.6.0",
    "@progress/kendo-theme-default": "~11.2.0",
    "hammerjs": "~2.0.0",
    "jspreadsheet-ce": "~4.14.0",
    "luxon": "~3.4.4"
  },
  "peerDependencies": {
    "@angular/animations": "~20.1.2",
    "@angular/common": "~20.1.2",
    "@angular/compiler": "~20.1.2",
    "@angular/core": "~20.1.2",
    "@angular/forms": "~20.1.2",
    "@angular/localize": "~20.1.2",
    "@angular/platform-browser": "~20.1.2",
    "@angular/platform-browser-dynamic": "~20.1.2",
    "@angular/router": "~20.1.2"
  }
}
```

## package.json (^ | ~)

`^ (caret)`: Este símbolo se utiliza para permitir cambios que no modifican el primer número de versión no cero. Por ejemplo, ^1.2.3 permitirá instalar cualquier versión hasta 2.0.0, pero no 2.0.0 o superior.

`~ (tilde)`: Este símbolo se utiliza para permitir cambios que no modifican el último número de versión especificado. Por ejemplo, ~1.2.3 permitirá instalar cualquier versión hasta 1.3.0, pero no 1.3.0 o superior.

## GRID: CommonLibrary

Una grid de una sola página, debe mostrar 20 registros por defecto. (take 20)
Una grid en un modal, con más elementos en la pantalla (máx. take 10)
Si la paginación no pasa de 10 líneas, quitamos la paginación y mostramos las líneas que hay (inf. a 10), pero sin paginación.

## Responsive: CommonLibrary

La common de momento no está planteada para visualizarse en dispositivos móviles.
Los diseños se realizan en 1440px de ancho,
La resolución mínima es de 1024px (A partir de esta resolución aparece el scroll), máxima de 1920px(A partir de esta resolucion aparecen divs laterales de fondo blanco)

## licencia kendo telerik

1. Descargar la licencia de kendo telerik: `https://www.telerik.com/account/your-licenses/license-keys`
2. Si estás en windows, alojar el archivo telerik-license.txt en el siguiente directorio: %AppData%\Roaming\Telerik\telerik-license.txt (La carpeta Telerik habrá que crearla)
3. Ejecutar el comando: npx kendo-ui-license activate
4. En Mac o Linux, revisar documentación `https://www.telerik.com/kendo-angular-ui/components/licensing#downloading-the-license-key `

## Angular 20

Para trabajar con angular 20, debemos tener instalada la versión 22.12.0 de node e instalar la versión 20.1.6 de Angular (npm i -g @angular/cli@20.1.6)

## Filename too long on windows

`git config --global core.longpaths true`

## TOUR

La librería que se gasta para el TOUR, es: `"driver.js": "^1.4.0"`
La documentación de la librería se encuentra en:
`https://driverjs.com/docs/installation`
