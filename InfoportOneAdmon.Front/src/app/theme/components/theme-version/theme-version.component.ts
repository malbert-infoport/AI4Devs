import { Component, OnInit, inject } from '@angular/core';
import { take } from 'rxjs/operators';

import { ThemeVersionDetailComponent } from '@app/theme/components/theme-version/theme-version-detail/theme-version-detail.component';

import { SecurityVersionClient } from '@restApi/api/apiClients';

import pck from '../../../../../package.json';

@Component({
  selector: 'theme-version',
  template: `<theme-version-detail [data]="versiones"></theme-version-detail> `,
  providers: [SecurityVersionClient],
  imports: [ThemeVersionDetailComponent],
  styles: [
    `
      :host {
        display: block !important;
        height: 100% !important;
        overflow-y: auto !important;
      }
    `
  ]
})

/**
 * Componente que recoge el dato de b.d. de la tabla SecurityVersion y lo muestra en el front
 */
export class ThemeVersionComponent implements OnInit {
  private securityVersionClient = inject(SecurityVersionClient);

  /**
   * Versión de la aplicación (según su entorno)
   */
  version = pck.version;

  /**
   * Listado de Versiones con sus mejoras y nuevas funciones
   */
  versiones;

  /**
   * @ignore
   */
  ngOnInit() {
    this.securityVersionClient
      .getAll()
      .pipe(take(1))
      .subscribe((versiones) => {
        // Eliminar el for, cuando venga Deserializado desde el back
        for (const v of versiones) {
          v.observations = JSON.parse(v.observations);
        }
        this.versiones = versiones;
      });
  }
}
