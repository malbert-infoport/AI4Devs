import { Injectable, inject } from '@angular/core';
import { AccessService } from '@app/theme/access/access.service';

import pck from '../../../../package.json';

/**
 * Servicio que ofrece el nombre del usuario conectado a la aplicación y en el que se configuran los items del menú superior
 */
@Injectable({
  providedIn: 'root'
})
export class ThemeTopBarService {
  private readonly accessService = inject(AccessService);
  // private readonly integrationsService = inject(IntegrationsService); //por definir

  /**
   * Versión de la aplicación (según su entorno)
   */
  version: string = pck.version;

  /**
   * [userNameTopInput] Usuario
   * @param name
   * @returns
   */

  getUser(name: string): string {
    return name;
  }

  /**
   * [topMenuInput] Menú superior
   * @returns objeto menú
   */
  getTopMenu() {
    return [
      {
        identifier: '#test11',
        toolTip: 'ATTACHMENTS.ATTACHMENTS_MANAGEMENT',
        url: '/protected/attachments/attachments-management',
        class: 'me-2',
        iconName: 'attach_file',
        xPosition: 'before',
        overlapTrigger: false,
        hasChildren: false,
        hidden: false,
        disabled: false
      },
      {
        identifier: '#test3',
        toolTip: 'SYSTEM_OPTIONS.TITLE',
        url: '',
        class: 'menu-item-icon me-2',
        iconName: 'settings',
        overlapTrigger: false,
        hasChildren: true,
        disabled: false,
        hidden: false,
        children: [
          {
            title: 'SYSTEM_OPTIONS.SECURITY.TITLE',
            url: '/protected/system-options/security',
            class: 'menu-item-icon me-2',
            iconName: 'security',
            extraInfo: '',
            disabled: false,
            hidden: false
          },
        ]
      },
      {
        identifier: '#test4',
        toolTip: 'VERSION',
        url: '',
        class: 'menu-item-icon me-2',
        iconName: 'info',
        overlapTrigger: false,
        hasChildren: true,
        disabled: false,
        hidden: false,
        children: [
          {
            title: 'VERSION',
            url: '/protected/version',
            class: 'menu-item-icon me-2',
            iconName: 'info',
            extraInfo: this.version,
            disabled: false,
            hidden: false
          }
        ]
      }
    ];
  }
}
