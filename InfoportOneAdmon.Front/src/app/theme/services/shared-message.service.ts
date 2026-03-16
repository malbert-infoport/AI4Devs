import { Injectable, inject } from '@angular/core';

import { ClNotificationConfig, ClNotificationService } from '@cl/common-library/cl-notifications';
import { TranslateService } from '@ngx-translate/core';
@Injectable({
  providedIn: 'root'
})
export class SharedMessageService {
  private clNotificationService = inject(ClNotificationService);
  private translate = inject(TranslateService);

  showError(err: any) {
    const errList = [];
    //TODO: Revisar mensajes de error, cuando vienen desde detail o title no se traducen

    /** Caso 1: Existe array de errores
     * status?: number | undefined;
     * title?: string | undefined;
     * type?: string | undefined;
     * errors?: { [key: string]: string[]; } | undefined;
     */
    if (err.errors) {
      const errors = err.errors;
      for (const key in errors) {
        if (errors.hasOwnProperty(key)) {
          errList.push(...errors[key]);
        }
      }
    } else if (err.detail) {
      /** Caso 2: Existe detail
       * detail?: string | undefined;
       */
      errList.push(err.detail);
    } else if (err.title) {
      /** Caso 3: Existe title
       * title?: string | undefined;
       */
      errList.push(err.title);
    }

    // Recorremos el listado de errores y mostramos tantos errores como existan

    if (errList.length > 0) {
      errList.forEach((err) => {
        this.showMessage(err, 'error');
      });
    } else {
      // En este punto no deberíamos entrar, lo dejamos por si el objeto
      //que manda el back, en el agún momento fuera diferente
      this.showMessage(this.translate.instant('UNKNOWN_ERROR'), 'error');
    }
  }

  showMessage(message: string, type?: 'standard' | 'warning' | 'error') {
    this.clNotificationService.showNotification(
      new ClNotificationConfig({
        content: message,
        type: type ?? 'standard',
        icon: true,
        position: {
          horizontal: 'right',
          vertical: 'bottom'
        }
      })
    );
  }
}
