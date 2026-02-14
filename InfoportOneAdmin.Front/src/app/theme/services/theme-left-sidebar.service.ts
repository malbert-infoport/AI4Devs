import { Injectable, inject } from '@angular/core';

import { TranslateService } from '@ngx-translate/core';

import { TitleNode } from '@app/theme/models/theme-left-sidebar.model';

import { IAuthUser } from '@restApi/api/apiClients';

import pck from '../../../../package.json';
import { AccessService } from '../access/access.service';

@Injectable({
  providedIn: 'root'
})

/**
 * Servicio en el que se configura los items del menú lateral
 */
export class ThemeLeftSidebarService {
  private readonly translate = inject(TranslateService);
  private readonly accessService = inject(AccessService);

  /**
   * @ignore
   */
  formatDate(date: Date, language: string) {
    const dateOptions: any = { day: '2-digit', month: '2-digit', year: 'numeric' };
    const timeOptions: any = { hour: '2-digit', minute: '2-digit' };
    return `${date.toLocaleDateString(language, dateOptions)} ${date.toLocaleTimeString(language, timeOptions)}`;
  }

  /**
   * [titleInput] : Incluye las siguientes opciones
       appName: Nombre de la aplicación
       appSlogan: Slogan de la aplicación.
       logo: Imagen del logo de la aplicación
       version: versión de la aplicación, sacada de la información de environment.
       disabled: habilita o deshabilita el modal con información de las actualizaciones (Parches)
   * @returns 
   */
  getTitle(): TitleNode[] {
    return [
      new TitleNode({
        appName: 'InfoportOneAdmin',
        appSlogan: '1.0',
        logo: 'assets/images/logo-app.png',
        disabled: false,
        version: this.translate.instant('VERSION') + ' ' + pck.version
      })
    ];
  }

  /**
   *  [menuInput]
   * [badgeOptions]
   * color: 'primary' || 'accent' || 'warn'
   * size: 'small' || 'medium || 'large'
   */
  getMenu() {
    return [
      {
        translateKey: 'FIRST_LEVEL_MENU',
        iconname: 'looks_one',
        url: '/protected/one',
        exactUrl: true,
        disabled: false,
        hasParent: false
      },


    ];
  }

  /**
   * [contactinfoInput]
   * @returns
   */
  getContactInfo() {
    return [
      {
        translateKey: 'USER_SUPPORT',
        iconname: 'headset_mic',
        disabled: false,
        hasParent: false,
        children: [
          {
            translateKey: `(+34) 96 393 95 92`,
            iconname: 'call',
            url: 'tel:+34963939592',
            hasParent: true,
            disabled: false
          },
          {
            translateKey: 'soporte@infoport.es',
            iconname: 'email',
            url: 'mailto:soporte@infoport.es',
            hasParent: true,
            disabled: false
          }
        ]
      }
    ];
  }

  /**
   * [usermenuInput]
   * @param user
   * @returns
   */
  getUserMenu(user: IAuthUser) {
    const menu = [
      {
        translateKey: user?.name ? user.name : user.login,
        translateKey_extraInfo: 'LAST_CONNECTION_DATE',
        extraInfo: user?.userConfiguration?.lastConnectionDate
          ? this.formatDate(new Date(user.userConfiguration.lastConnectionDate), user.userConfiguration.language ?? '')
          : '',
        iconname: 'account_circle',
        disabled: false,
        hasParent: false,
        children: [
          {
            translateKey: 'PREFERENCES',
            iconname: 'settings_applications',
            url: '',
            hasParent: true,
            disabled: false
          },
          {
            translateKey: 'CORE_SIGN_OUT',
            iconname: 'exit_to_app',
            url: '',
            hasParent: true,
            disabled: false
          }
        ]
      }
    ];

    return menu;
  }
}
